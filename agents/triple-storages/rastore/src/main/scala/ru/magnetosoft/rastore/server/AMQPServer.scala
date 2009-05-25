package ru.magnetosoft.rastore.server

import scala.actors.Actor
import scala.actors.Actor._

import com.rabbitmq.client.Connection
import com.rabbitmq.client.ConnectionParameters
import com.rabbitmq.client.ConnectionFactory
import com.rabbitmq.client.Channel
import com.rabbitmq.client.Consumer
import com.rabbitmq.client.QueueingConsumer
import com.rabbitmq.client.AMQP

object AMQPServer {

    def main(args: Array[String]) {

        if (args.length > 6) {

            val username = args(0)
            val password = args(1)
            val vhost = args(2)
            val host = args(3)
            val port = args(4).toInt
            val exchange = args(5)
            val queue = args(6)
            val routingKey = args(7)

            val params = new ConnectionParameters()
            params.setUsername(username)
            params.setPassword(password)
            params.setVirtualHost(vhost)


            val factory = new ConnectionFactory(params)
            val conn = factory.newConnection(host , port)

            val channel = conn.createChannel()
            channel.exchangeDeclare(exchange, "direct")
            channel.queueDeclare(queue);
            channel.queueBind(queue, exchange, routingKey)

            var consumer = new QueueingConsumer(channel)
            channel.basicConsume(queue, false, consumer)

            while (true) {
                var delivery: QueueingConsumer.Delivery = null
                try {
                    delivery = consumer.nextDelivery();
                } catch {
                  case (ex: InterruptedException) => continue;
                }
                // (process the message components ...)
                channel.basicAck(delivery.getEnvelope().getDeliveryTag(), false);
            }

            
            channel.close()
            conn.close()

            
            return

        } else {
            System.out.println("Usage: AMQPServer <username> <password> <virtualHost> <host> <port> <exhange> <queue> <routeingKey>")
        }

    }

/*    class MessageReciever extends Actor {



    }*/

}
