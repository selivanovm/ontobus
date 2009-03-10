package ru.magnetosoft.esb.mq.customer;

import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

import ru.magnetosoft.esb.mq.command.MQMessage;

public class MQQueue extends AbstractMessageCustomer
{
	protected Queue<MQMessage> queue = new ConcurrentLinkedQueue<MQMessage>();
	protected int maxQueueSize;
	
	public MQQueue(String name, int maxQueueSize) {
		super(name);
		
		this.maxQueueSize = maxQueueSize;
	}
	
	
	public void put(MQMessage message) {
		queue.add(message);
	}
	
	
}
