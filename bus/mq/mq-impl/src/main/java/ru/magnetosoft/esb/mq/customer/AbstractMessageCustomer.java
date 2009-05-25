package ru.magnetosoft.esb.mq.customer;


public abstract class AbstractMessageCustomer implements MessageCustomer
{
	protected String name;

//	protected Queue<MQMessage> queue = new ConcurrentLinkedQueue<MQMessage>();
	
	public AbstractMessageCustomer(String name) {
		this.name = name;
	//	this.maxQueueLength = maxQueueLength;
				
	}
	
	
	public String getName(){
		return this.name;
	}
	
//	public Queue<MQMessage> getQueue(){
//		return this.queue;
//	}

}
