import scala.io.Source
import scala.collection.mutable.Set

import com.rabbitmq.client._

object Client {

  def main(args: Array[String]) {
    
    if (args.size == 15) {

      val msg = args(0)
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
      val msgCount = if (args(12) == null) 1 else args(12).toInt
      val msgMultiplier = if (args(13) == null) 1 else args(13).toInt
      val listen = if (args(14) == null || args(14) != "true") false else true

      println(String.format("host = %s, port = %s, virtualHost = %s, exchange = %s, queue = %s, userName = %s, password = %s, heartBeat = %s, " +
                            "routingKey = %s, exchangeType = %s, listenAfterSending = %s, message = %s, count = %s, multiplier = %s listen = %s", 
                            hostName, portNumber, virtualHost, exchange, queue, userName, password, heartBeat, routingKey, exchangeType, listenAfterSending, 
                            msg, int2Integer(msgCount), int2Integer(msgMultiplier), boolean2Boolean(listen)))

      var params = new ConnectionParameters()
      params.setUsername(userName)
      params.setPassword(password)
      params.setVirtualHost(virtualHost)
      params.setRequestedHeartbeat(heartBeat.toInt)

      val factory = new ConnectionFactory(params)
      val conn = factory.newConnection(hostName, portNumber.toInt)
      
      val channel = conn.createChannel()

      //      channel.exchangeDeclare(exchange, exchangeType)
      //      channel.queueBind(queue, exchange, routingKey)

      if (!listen) {

        if (routingKey.length == 0) {
          try {
            channel.queueDelete(exchange)
          } catch {
            case ex: Exception =>
          }
          channel.queueDeclare(exchange, false)
        }
        try {
          channel.queueDelete(queue)
        } catch {
          case ex: Exception =>
        }
        channel.queueDeclare(queue, false)

        var messageBuilder = new StringBuilder(1000)
        for(i <- 0 until msgMultiplier) {
          messageBuilder.append(msg)
        }
        val message = messageBuilder.toString

        val startTime = System.nanoTime;
        for(i <- 0 until msgCount) {
          channel.basicPublish(routingKey, exchange,
                               MessageProperties.TEXT_PLAIN,
                               message.getBytes)

          Thread.sleep(50)

          if (listenAfterSending == "true") {
            val consumer = new QueueingConsumer(channel)
            channel.basicConsume(queue, true, consumer)

            while(true) {
              val delivery = consumer.nextDelivery
              val body = new String(delivery.getBody)
              println("Got answer : " + body)
            }
          }
        }

        val execTime = (System.nanoTime - startTime) / 1000000000.0
        val sentBytesCount = message.length * msgCount
        println(String.format("Message size %s", int2Integer(message.length)))
        println(String.format("Total messages sent: %s", int2Integer(msgCount)))
        println(String.format("Total bytes sent: %s", int2Integer(sentBytesCount)))
        println(String.format("In %s sec.", double2Double(execTime)))
        println(String.format("Speed %.2f bytes/sec", double2Double(sentBytesCount / execTime)))
        println(String.format("Speed %.2f msgs/sec", double2Double(msgCount / execTime)))

      } else {

        if (routingKey.length == 0) {
          channel.queueDeclare(exchange, false)
        }
        channel.queueDeclare(queue, false)

        val consumer = new QueueingConsumer(channel)
        channel.basicConsume(queue, true, consumer)

        var receivedBytesCount : Long = 0
        var receptionTime : Long= 0
        var receivedMsgCount : Long = 0
        var i = msgCount - 1
        while(i > 0) {
          val start = System.nanoTime

          val delivery = consumer.nextDelivery

          val end = System.nanoTime
          val body = new String(delivery.getBody)

          receivedBytesCount += body.length
          receptionTime += end - start;
          receivedBytesCount += 1
          i -= 1
        }

        println(String.format("Receiving Speed %.2f bytes/sec", double2Double(receivedBytesCount / (receptionTime / 1000000000.0))))
        println(String.format("Receiving Speed %.2f msgs/sec", double2Double(msgCount / (receptionTime / 1000000000.0))))

      }

    } else
      println ("Usage : <message> <host> <port> <vhost> <exchange> <targetQueue> <user> <password> <heartbeat> <routingKey> <exchangeType> <listenFlag>")
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
