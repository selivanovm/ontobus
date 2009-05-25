package ru.magnetosoft.esb.mq.customer;

import ru.magnetosoft.esb.mq.command.MQMessage;

public class MQTopic extends AbstractMessageCustomer
{
	public MQTopic(String name) {
		super(name);
	}
	
	public void put(MQMessage message) {
	}
}
