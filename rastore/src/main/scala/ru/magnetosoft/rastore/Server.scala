package ru.magnetosoft.rastore

import scala.collection.mutable.Set

import ru.magnetosoft.rastore.core.Store
import ru.magnetosoft.rastore.core.StoreConfiguration
import ru.magnetosoft.rastore.core.Triplet

import com.rabbitmq.client._

object Server {

  def main(args: Array[String]) {
    
    val hostName = StoreConfiguration.getProperties.getProperty("amqp_host")
    val portNumber = StoreConfiguration.getProperties.getProperty("amqp_port")
    val userName = StoreConfiguration.getProperties.getProperty("amqp_username")
    val password = StoreConfiguration.getProperties.getProperty("amqp_password")
    val virtualHost = StoreConfiguration.getProperties.getProperty("amqp_vhost")
    val heartBeat = StoreConfiguration.getProperties.getProperty("amqp_heartbeat")
    val queue = StoreConfiguration.getProperties.getProperty("amqp_queue")
    val exchange = StoreConfiguration.getProperties.getProperty("amqp_exchange")
    val routingKey = StoreConfiguration.getProperties.getProperty("amqp_routing_key")
    val exchangeType = StoreConfiguration.getProperties.getProperty("amqp_exchange_type")

    var params = new ConnectionParameters()
    params.setUsername(userName)
    params.setPassword(password)
    params.setVirtualHost(virtualHost)
    params.setRequestedHeartbeat(heartBeat.toInt)

    val factory = new ConnectionFactory(params)
    val conn = factory.newConnection(hostName, portNumber.toInt)
    
    val channel = conn.createChannel()
    
    channel.exchangeDeclare(exchange, exchangeType)
    channel.queueDeclare(queue)
    channel.queueBind(queue, exchange, routingKey)

    val consumer = new QueueingConsumer(channel)
    channel.basicConsume(queue, true, consumer)

    println ("Listening queue '" + userName + ":" + password + "@" + hostName + ":" + portNumber + "'")

    while(true) {
      
      try {

        val delivery = consumer.nextDelivery()
        val body = new String(delivery.getBody())
        val tokens = body.split("-:-")
        val cmd = tokens(0)

        println ("Got message " + body)

        if (cmd == "store") {
          
          var triplets = Set[Triplet]()
          for(i <- 1 until (tokens.size / 3)) {
            triplets += new Triplet(0, tokens(i * 3), tokens(i * 3 + 1), tokens(i * 3 + 2))
          }

          Store.getManager.putTriplets(triplets)

        }

      } catch {
        case ex: Exception => { ex.printStackTrace() }
      }

    }

    channel.close();
    conn.close()

    
  }  

}
