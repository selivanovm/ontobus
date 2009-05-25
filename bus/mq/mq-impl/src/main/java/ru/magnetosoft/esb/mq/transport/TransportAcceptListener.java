package ru.magnetosoft.esb.mq.transport;

public interface TransportAcceptListener
{
	void onAccept(Transport transport);
	void onException(Exception ex);
}
