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
import com.rabbitmq.client._
import ru.magnetosoft.rastore.core.LogManager

object Server {

  val PERFORMANCE_MEASURE_DELAY = 1000000000.0
  val NANOSECONDS_IN_SECOND = 1000000000.0

  def main(args: Array[String]) {

    val server_start = System.nanoTime

    val messageInterpreter = actor {
      LogManager.info("Message interpreter started.")
      var count = 0
      var start = System.nanoTime
      
      loop {
        react {
          case msg: Set[OntoFunction] => {
            LogManager.debug("Got message [ " + msg + " ]")

            for(fn <- msg) {
              
            }

            count = count + msg.size
            val now = System.nanoTime
            if (now - start > PERFORMANCE_MEASURE_DELAY) {
              LogManager.info ("Speed " + (count / ((now - start) / NANOSECONDS_IN_SECOND)) + "/sec.")
              start = System.nanoTime
              count = 0
            }
          }
        }
      }
    }

    val messageParser = if (StoreConfiguration.getProperties.getProperty("thread_for_message_parser") == "true")
      actor {
        LogManager.info("Message parser started.")
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
        LogManager.info("Message parser started.")
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
      LogManager.info("Message receiver started.")
      while(true) {
        try {

          val delivery = AMQPConnectionManager.getNextMessage
          val body = new String(delivery.getBody())

          messageParser ! body

        } catch {
          case ex: Exception => { ex.printStackTrace() }
        }
      }
      AMQPConnectionManager.close    
    }  
    
    val loading_time = (System.nanoTime - server_start) / NANOSECONDS_IN_SECOND
    LogManager.info(String.format("Server started in %s seconds.", Array(String.valueOf(loading_time).substring(0, 5))))

  }

}
