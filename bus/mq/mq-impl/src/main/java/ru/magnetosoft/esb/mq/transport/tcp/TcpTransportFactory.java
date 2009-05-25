package ru.magnetosoft.esb.mq.transport.tcp;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Socket;

import ru.magnetosoft.esb.mq.transport.Transport;
import ru.magnetosoft.esb.mq.transport.TransportFactory;
import ru.magnetosoft.esb.mq.transport.TransportServer;

public class TcpTransportFactory implements TransportFactory
{

	public Transport createTransport(InetSocketAddress address)	throws IOException {
		
		Socket socket = new Socket();
		socket.connect(address);
		
		return new TcpTransport(socket);
	}

	public TransportServer createTransportServer(InetSocketAddress address)	throws IOException {
		return new TcpTransportServer(address);
	}

}
