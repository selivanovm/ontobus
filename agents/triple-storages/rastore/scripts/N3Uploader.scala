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
      
//      channel.exchangeDeclare(exchange, exchangeType)
      channel.queueDeclare(exchange)
  //    channel.queueBind(queue, exchange, routingKey)

      var msg = "<uid1><magnet-ontology#subject><magnet-ontology/logging#put>.<uid1><magnet-ontology/transport#reply_to>\"" + queue + 
                "\".<uid1><magnet-ontology/transport#argument>{"
      var i = 0
      var total = 0

      Source.fromFile(args(0)).getLines.foreach { line =>
        if (i < 100) {
          msg += line.substring(0, line.length - 1)
          i = i + 1
        } else {
          channel.basicPublish(routingKey, exchange,
                               MessageProperties.PERSISTENT_TEXT_PLAIN,
                               (msg + "}.").getBytes)
          total += i
          println("Uploaded " + total + " triplets")
          i = 0
          msg = "<uid1><magnet-ontology#subject><magnet-ontology/logging#put>.<uid1><magnet-ontology/transport#reply_to>\"" + queue + 
                "\".<uid1><magnet-ontology/transport#argument>{"
        }
      }
      if (i > 0) {
          channel.basicPublish(routingKey, exchange,
                               MessageProperties.PERSISTENT_TEXT_PLAIN,
                               (msg + "}.").getBytes)
      }
    } else
      println ("Usage : <inputFile> <host> <port> <vhost> <exchange> <targetQueue> <user> <password> <heartbeat> <routingKey> <exchangeType>")
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
