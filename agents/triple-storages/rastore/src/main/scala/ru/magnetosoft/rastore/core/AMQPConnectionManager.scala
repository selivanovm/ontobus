package ru.magnetosoft.rastore.core

import com.rabbitmq.client._

object AMQPConnectionManager {

  val logger = new Logger(AMQPConnectionManager)
  var conn: Connection = null
  var channel: Channel = null
  var consumer: QueueingConsumer = null

  def checkConnection() {

    if (conn == null || !conn.isOpen()) {

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
      conn = factory.newConnection(hostName, portNumber.toInt)
      channel = conn.createChannel()
      
      channel.exchangeDeclare(exchange, exchangeType)
      channel.queueDeclare(queue)
      channel.queueBind(queue, exchange, routingKey)

      consumer = new QueueingConsumer(channel)
      channel.basicConsume(queue, true, consumer)

      logger.info ("Listening queue '" + userName + ":" + password + "@" + hostName + ":" + portNumber + "'")

    }

  }

  def sendMessage(queue: String, message: String) = {
    checkConnection
    val exchange = StoreConfiguration.getProperties.getProperty("amqp_exchange")
    val routingKey = StoreConfiguration.getProperties.getProperty("amqp_routing_key")
    channel.basicPublish(exchange, routingKey, MessageProperties.PERSISTENT_TEXT_PLAIN, message.getBytes)
    logger.debug("Message sent to [ " + queue + " ] : " + message)
  }

  def getNextMessage(): QueueingConsumer.Delivery = {
    checkConnection()
    return consumer.nextDelivery()
  }

  def getNextMessage(ms: Int): QueueingConsumer.Delivery = {
    checkConnection()
    return consumer.nextDelivery(ms)
  }

  def close() {
    try {
      channel.close();
      conn.close()
    } catch {
      case e: Exception => 
        logger.error("Unable to close amqp connection, may be it was already closed.")
    }
  }

}
