package ru.magnetosoft.rastore

import scala.collection.mutable.Set

import ru.magnetosoft.rastore.core.Store
import ru.magnetosoft.rastore.core.StoreConfiguration
import ru.magnetosoft.rastore.core.Triplet
import ru.magnetosoft.rastore.core.FileStore
import ru.magnetosoft.rastore.core.AMQPConnectionManager

import com.rabbitmq.client._

object Server {

  def main(args: Array[String]) {

    val saveTriplets = if (StoreConfiguration.getProperties.getProperty("server_mode") == "file")
      (triplets: Array[String]) => {
        var set = Set[String]()
        for(i <- 0 until ((triplets.size - 1) / 3)) {
          set += (triplets(i * 3 + 1) + " " + triplets(i * 3 + 2) + " " + triplets(i * 3 + 3))
        }
        FileStore.putTriplets(set)
      }
    else
      (triplets: Array[String]) => {
        var set = Set[Triplet]()
        for(i <- 0 until ((triplets.size - 1) / 3)) {
          set += new Triplet(0, triplets(i * 3 + 1), triplets(i * 3 + 2), triplets(i * 3 + 3))
        }
        Store.getManager.putTriplets(set)        
      }   

    while(true) {
      
      try {

        val delivery = AMQPConnectionManager.getNextMessage
        val body = new String(delivery.getBody())

        val tokens = body.split("-:-")
        val cmd = tokens(0)

        println ("Got message !")

        if (cmd == "store") {
          saveTriplets(tokens)
        }

      } catch {
        case ex: Exception => { ex.printStackTrace() }
      }

    }

    AMQPConnectionManager.close
    
  }  

}
