package ru.magnetosoft.esb.mq.transport.tcp;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;

import ru.magnetosoft.esb.mq.context.Context;
import ru.magnetosoft.esb.mq.transport.TransportAcceptListener;
import ru.magnetosoft.esb.mq.transport.TransportServer;

public class TcpTransportServer implements TransportServer, Runnable
{
	protected InetSocketAddress serverAddress;
	protected Thread thread = new Thread(this, "SocketTransportServer");
	protected volatile boolean stopped = true;
	protected ServerSocket server = null;
	
	protected TransportAcceptListener acceptListener;
	
	
	
	protected TcpTransportServer(InetSocketAddress address){
		this.serverAddress = address;
	}

	
	public void setAcceptListener(TransportAcceptListener listener) {
		this.acceptListener = listener;
	}

	public void doStart() {
		stopped = false;
		thread.start();
	}

	public void doStop() {
		stopped = true;
		try {
			if(server != null)
				server.close();
		}
		catch (IOException e) {
			doException(e);
		}
	}

	public void run() {
		System.out.println("SocketTransportServer " + serverAddress + " started.");

		try{			
			server = new ServerSocket();
			server.bind(serverAddress);		

			for(;;){
				Socket socket = server.accept();
				acceptListener.onAccept( new TcpTransport(socket) );
			}			
			
		}
		catch(IOException e){
			if(!stopped) doException(e);
		}
		
		System.out.println("SocketTransportServer " + serverAddress + " stopped.");
	}

	protected void doException(Exception e){
		if(acceptListener != null)
			acceptListener.onException(e);
		else
			e.printStackTrace();
	}


	public void doInit(Context context) {
		
	}


	public InetSocketAddress getAddress() {
		return this.serverAddress;
	}
}
