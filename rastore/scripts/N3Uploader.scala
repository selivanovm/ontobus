import scala.io.Source
import scala.collection.mutable.Set

import com.rabbitmq.client._

object N3Uploader {

  def main(args: Array[String]) {
    
    if (args.size == 11) {

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

      var msg = "store"
      var i = 0

      Source.fromFile(args(0)).getLines.foreach { line =>
        if (i < 10) {

          val tokens = line.split("[>]")
          val subj = escapeString(tokens(0).trim.substring(1))
          val pred = escapeString(tokens(1).trim.substring(1))
          val obj = escapeString(tokens(2).substring(0, tokens(2).length - 2).substring(2, tokens(2).length - 4))

          msg += "-:-" + subj + "-:-" + pred + "-:-" + obj
          
          i = i + 1
        } else {
          channel.basicPublish(exchange, routingKey,
                               MessageProperties.PERSISTENT_TEXT_PLAIN,
                               msg.getBytes)
          i = 0
          msg = "store"
        }
      }
    } else
      println ("Usage : <inputFile> <host> <port> <vhost> <exchange> <targetQueue> <user> <password> <heartbeat> <routingKey> <exchangeType>")

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
