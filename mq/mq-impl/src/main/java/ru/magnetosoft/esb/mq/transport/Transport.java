package ru.magnetosoft.esb.mq.transport;

import java.net.InetSocketAddress;

import ru.magnetosoft.esb.mq.ServiceSupport;

public interface Transport extends ServiceSupport
{
	void send(Object command);
//	Object request(Object command);
	
	void setTransportListener(TransportListener listener);
	TransportListener getTransportListener();
	
	InetSocketAddress getRemoteAddress();
	InetSocketAddress getLocalAddress();
	
	boolean isConnected();
}
