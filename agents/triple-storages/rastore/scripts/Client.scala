import scala.io.Source
import scala.collection.mutable.Set

import com.rabbitmq.client._

object Client {

  def main(args: Array[String]) {
    
    if (args.size == 12) {

      val message = args(0)
      val hostName = args(1)
      val portNumber = args(2)
      val virtualHost = args(3)
      val exchange = args(4)
      val queue = args(5)
      val userName = args(6)
      val password = args(7)
      val heartBeat = args(8)
      val routingKey = args(9)
      val exchangeType = args(10)
      val listenAfterSending = args(11)

      println(String.format("host = %s, port = %s, virtualHost = %s, exchange = %s, queue = %s, userName = %s, password = %s, heartBeat = %s, " +
                            "routingKey = %s, exchangeType = %s, listenAfterSending = %s, message = %s", hostName, portNumber, virtualHost,
                          exchange, queue, userName, password, heartBeat, routingKey, exchangeType, listenAfterSending, message))

      var params = new ConnectionParameters()
      params.setUsername(userName)
      params.setPassword(password)
      params.setVirtualHost(virtualHost)
      params.setRequestedHeartbeat(heartBeat.toInt)

      val factory = new ConnectionFactory(params)
      val conn = factory.newConnection(hostName, portNumber.toInt)
      
      val channel = conn.createChannel()
      
//      channel.exchangeDeclare(exchange, exchangeType)
      if (routingKey.length == 0) {
        channel.queueDeclare(exchange)
      }
      channel.queueDeclare(queue)
//      channel.queueBind(queue, exchange, routingKey)

      channel.basicPublish(routingKey, exchange,
                           MessageProperties.PERSISTENT_TEXT_PLAIN,
                           message.getBytes)

      if (listenAfterSending == "true") {
        val consumer = new QueueingConsumer(channel)
        channel.basicConsume(queue, true, consumer)

        while(true) {
          val delivery = consumer.nextDelivery
          val body = new String(delivery.getBody)
          println("Got answer : " + body)
        }

      }

    } else
      println ("Usage : <message> <host> <port> <vhost> <exchange> <targetQueue> <user> <password> <heartbeat> <routingKey> <exchangeType> <listen_flag>")
    println ("Done.")
    System.exit(0)
  }

  def escapeString(line: String): String = {
    
    var sb = new StringBuilder()

    for (i <- 0 until line.length) {
      val c = line.charAt(i)
      sb.append(
        c match {
          case '\t' => "\\t"
          case '\n' => "\\n"
          case '\r' => "\\r"
          case '\\' => "\\\\"
          case '\"' => "\\\""
          case _ => c
        }
      )
    }

    return sb.toString
  }

}
