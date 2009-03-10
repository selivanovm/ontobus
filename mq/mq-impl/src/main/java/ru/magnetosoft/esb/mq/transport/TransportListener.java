package ru.magnetosoft.esb.mq.transport;


public interface TransportListener
{
	void onCommand(Object command);
	void onException(Exception ex);
}
