package ru.magnetosoft.esb.mq.transport;

import java.net.InetSocketAddress;

import ru.magnetosoft.esb.mq.ServiceSupport;

public interface TransportServer extends ServiceSupport
{
	void setAcceptListener(TransportAcceptListener listener);
	
	InetSocketAddress getAddress();
}
