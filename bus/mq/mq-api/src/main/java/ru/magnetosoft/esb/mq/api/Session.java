package ru.magnetosoft.esb.mq.api;

public interface Session
{
	Queue createQueue(String name);
	
//	MessageQueue getQueue(String name);
//	String[] getQueueNames();
	
//	QueueReceiver createReceiver(Queue queue);
//	QueueSender createSender(Queue queue);
	
	MessageListener getMessageListener(String name);
	void setMessageListener(String name, MessageListener listener);
	
	void send(Message message);	
	
	TextMessage createTextMessage();
	
	void close();
}
