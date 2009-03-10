package ru.magnetosoft.esb.mq.api;

public interface MessageListener
{
	void onMessage(Message message);
}
