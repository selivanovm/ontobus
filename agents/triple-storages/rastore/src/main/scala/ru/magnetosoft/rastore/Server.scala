package ru.magnetosoft.rastore

import scala.collection.mutable.Set
import scala.actors.Actor._

import ru.magnetosoft.rastore.core.Store
import ru.magnetosoft.rastore.core.StoreConfiguration
import ru.magnetosoft.rastore.core.Triplet
import ru.magnetosoft.rastore.core.FileStore
import ru.magnetosoft.rastore.core.AMQPConnectionManager
import ru.magnetosoft.rastore.server.MessageParser
import ru.magnetosoft.rastore.server.OntoFunction
import ru.magnetosoft.rastore.core.TripletModifier
import ru.magnetosoft.rastore.core.Logger
import com.rabbitmq.client._

object Server {

  val PERFORMANCE_MEASURE_DELAY = 1000000000.0
  val NANOSECONDS_IN_SECOND = 1000000000.0
  val logger = new Logger(Server)

  def main(args: Array[String]) {

    val server_start = System.nanoTime

    val messageInterpreter = actor {
      logger.info("Message interpreter started.")
      var count = 0
      var start = System.nanoTime
      
      loop {
        react {
          case msg: Set[OntoFunction] => {
            logger.debug("Got message with function requests [ " + msg + " ]")

            for(fn <- msg) {
              val fn_start = System.nanoTime
              fn.command.pred match {
                case "store" => {
                  val stringsToStore = Set[String]()
                  for(arg <- fn.arguments) {
                    val strings = if (TripletModifier.TripletSet.id == arg.mod) MessageParser.split(arg.obj) else Set[String](arg.obj)
                    stringsToStore ++ strings
                  }
                  FileStore.putTriplets(stringsToStore)
                }
                case "get" => {
                  
                  val lines = FileStore.lineIterator
                  val array = Set[String]()
                  for(line <- lines) {
                    if (array.size == 1000 || !lines.hasNext) {
                      AMQPConnectionManager.sendMessage(fn.command.obj, array.mkString(""))
                      array.clear
                    } else array += line
                  }

                }
/*                case "get_triplets_count" => 
                  AMQPConnectionManager.sendMessage(fn.command.obj, FileStore.tripletsCount.toString) */
                case _ => logger.debug("Unknown command : " + fn.command.pred)
              }
              val fn_finish = System.nanoTime
              logger.debug("Function [ " + fn.command.pred + " ] finished in " + ((fn_finish - fn_start) / NANOSECONDS_IN_SECOND) + "/sec.")
            }

            count = count + msg.size
            val now = System.nanoTime
            if (now - start > PERFORMANCE_MEASURE_DELAY) {
              logger.info ("Speed " + (count / ((now - start) / NANOSECONDS_IN_SECOND)) + "/sec.")
              start = System.nanoTime
              count = 0
            }
          }
        }
      }
    }

    val messageParser = if (StoreConfiguration.getProperties.getProperty("thread_for_message_parser") == "true")
      actor {
        logger.info("Message parser started.")
        while(true) {
          receive {
            case msg: String =>
              messageInterpreter ! MessageParser.functionsFromMessage(msg)
            case msg: Int =>
              return
          }
        }
      }
      else
      actor {
        logger.info("Message parser started.")
        loop {
          react {
            case msg: String =>
              messageInterpreter ! MessageParser.functionsFromMessage(msg)
            case msg: Int =>
              return
          }
        }
      }

    val messageReceiver = actor {
      logger.info("Message receiver started.")
      while(true) {
        try {

          val delivery = AMQPConnectionManager.getNextMessage
          if (delivery != null) {
            val body = new String(delivery.getBody())
            messageParser ! body
          }
//          Thread.sleep(1)
        } catch {
          case ex: Exception => { ex.printStackTrace() }
        }
      }
      AMQPConnectionManager.close    
    }  
    
    val loading_time = (System.nanoTime - server_start) / NANOSECONDS_IN_SECOND
    logger.info(String.format("Server started in %s seconds.", Array(String.valueOf(loading_time).substring(0, 5))))

  }

}
