package ru.magnetosoft.esb.mq;

import ru.magnetosoft.esb.mq.command.MQMessage;



public interface MessageHandler
{
	void onMessage(MQMessage message);
	void onException(Exception ex);
}
