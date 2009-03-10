package ru.magnetosoft.esb.mq.transport;

import java.io.IOException;
import java.net.InetSocketAddress;

public interface TransportFactory
{
	Transport createTransport(InetSocketAddress address) throws IOException;
	
	TransportServer createTransportServer(InetSocketAddress address) throws IOException;
}
