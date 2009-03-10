package ru.magnetosoft.esb.mq.customer;

import ru.magnetosoft.esb.mq.command.MQMessage;



public interface MessageCustomer
{
	void put(MQMessage message);
}
