package ru.magnetosoft.rastore.client

import com.rabbitmq.client._

object Client {

  var conn: Connection = null
  var channel: Channel = null
  var consumer: QueueingConsumer = null
  
/*  def sendCommandsMessages(commands: Set[OntoFunction]) {
    
  }*/

}
