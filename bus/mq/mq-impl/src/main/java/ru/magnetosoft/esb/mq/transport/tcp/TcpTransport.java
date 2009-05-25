package ru.magnetosoft.esb.mq.transport.tcp;

import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.nio.ByteBuffer;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

import ru.magnetosoft.esb.mq.context.Context;
import ru.magnetosoft.esb.mq.context.MQContext;
import ru.magnetosoft.esb.mq.context.MQContext.TransportContext;
import ru.magnetosoft.esb.mq.format.Format;
import ru.magnetosoft.esb.mq.format.binary.BMQFormat;
import ru.magnetosoft.esb.mq.transport.Transport;
import ru.magnetosoft.esb.mq.transport.TransportListener;

public class TcpTransport implements Transport, Runnable
{
//	class ResponseMonitor
//	{
//		Object response;
//	}
	
	
	protected class TransportExecutor implements Runnable
	{
		public void run() {
			try {
				for(;;){
					try {
						
//						byte[] data = (byte[])sendQueue.take();
//						
//						long t = System.nanoTime();
//						byte[] sz = new byte[4];
//						ByteBuffer.wrap(sz).putInt(data.length);
//						out.write(sz);
//						out.write(data);
//						transportStatus.sendTime.add(System.nanoTime() - t);
						
						Object command = sendQueue.take();
						
						long t = System.nanoTime();
						format.marshal(command, out);
						transportStatus.sendTime.add(System.nanoTime() - t);
					}
					catch (IOException e) {
						doException(e);
					}
				}
			}
			catch (InterruptedException e) {
				Thread.interrupted();
			}
		}
		
	}
	
	
	protected Socket socket;
	protected InputStream in;
	protected OutputStream out;

	protected volatile boolean stopped = true;
	protected Thread thread;
	protected Thread sendThread; 
	protected BlockingQueue<Object> sendQueue;
	
	protected TransportListener listener;
	protected Format format;
	
	protected TcpTransportStatus transportStatus = new TcpTransportStatus();
	
//	protected Map<Object, ResponseMonitor> monitors = Collections.synchronizedMap( new HashMap<Object, ResponseMonitor>() );
	
	
	
	
	protected TcpTransport(Socket socket){
		this.socket = socket;
		try{
			this.in = socket.getInputStream();
			this.out = socket.getOutputStream();			
		}
		catch(IOException e){
			e.printStackTrace();
		}
	}
	

	public boolean isConnected() {
		return (socket != null && socket.isConnected());
	}

	public void send(Object command) {
		try {
			
//			ByteArrayOutputStream baos = new ByteArrayOutputStream();
//			format.marshal(command, baos);
//			
//			sendQueue.put(baos.toByteArray());
			
			sendQueue.put(command);
		}
		catch (Exception e) {
			doException(e);
		}
	}

	public void setTransportListener(TransportListener listener) {
		this.listener = listener;
	}

	public void doStart() {
		stopped = false;
		sendThread.start();
		thread.start();
	}

	public void doStop() {
		stopped = true;
		if(sendThread != null)
			sendThread.interrupt();
		
		try{
			if(socket != null)
				socket.close();
		}
		catch(IOException e){
		}
	}


	public void run() {
		System.out.println(thread.getName() + " started");
		
		try {
			for(;;){
				
//				long t = System.nanoTime();
//				byte[] sz = new byte[4];
//				in.read(sz);
//				int len = ByteBuffer.wrap(sz).getInt();
//				
//				byte[] data = new byte[len];
////				in.read(data);
//				int offset = 0;
//				int n = 0;
//				while( (n = in.read(data, offset, len - offset)) != -1 && offset < len)
//					offset += n;
//				transportStatus.receiveTime.add(System.nanoTime() - t);
//				
//				
//				Object command = format.unmarshal(new ByteArrayInputStream(data));
				Object command = format.unmarshal(in);
				
//				// Обрабатываем полученное сообщение
//				if(command != null){
//					ResponseMonitor mon = monitors.get(command.hashCode());
//					// если найден монитор, то сообщение обрабатывается синхронно
//					if(mon != null){
//						synchronized(mon){
//							mon.response = command;
//							mon.notifyAll();
//						}
//					}
//					else{
//						listener.onCommand(command);
//					}
//				}
				
				listener.onCommand(command);				
			}
		}
		catch (EOFException e) {
			doException(new IOException("Connection closed by other side"));
		}
		catch (IOException e) {
			if(!stopped) doException(e);
		}
		finally{
			
			try {
				if(socket != null)
					socket.close();
			}
			catch (IOException e) {
				doException(e);
			}			
		}

		System.out.println(thread.getName() + " stopped");
	}

	
	protected void doException(Exception e){
		if(this.listener != null) 
			listener.onException(e);
		else
			e.printStackTrace();
	}


	public void doInit(Context context) {
		TransportContext ctx = (TransportContext)context;
		
//		try{
//			StatisticServer ss = (StatisticServer)ctx.lookup("statistic.server");
//			if(ss != null)
//				ss.register(AgentName.newName("TcpTransport", "statistic"), this.transportStatus);
//		}
//		catch(Exception e){
//			e.printStackTrace();
//		}
		
//		List<TransportDescription> tdlist = 
		this.out = new BufferedOutputStream(this.out, 4096);
		
		this.format = ctx.format;
		this.sendQueue = new LinkedBlockingQueue<Object>( ctx.sendQueueSize );
		
		this.thread = new Thread(this, String.format("SocketTransport [%s]", socket.getRemoteSocketAddress()));
		
		this.sendThread = new Thread(new TransportExecutor(), "TransportExecutor");
		this.sendThread.setDaemon(true);
	}


//	public Object request(Object command) {
//		
//		ResponseMonitor mon = new ResponseMonitor();
//		monitors.put(command.hashCode(), mon);
//		synchronized(mon){
//			send(command);
//			try {
//				mon.wait();
//			}
//			catch (InterruptedException e) {
//				e.printStackTrace();
//			}
//		}
//		
//		return mon.response;
//	}


	public InetSocketAddress getRemoteAddress() {
		return (InetSocketAddress)socket.getRemoteSocketAddress();
	}

	public InetSocketAddress getLocalAddress() {
		return (InetSocketAddress)socket.getLocalSocketAddress();
	}


	public TransportListener getTransportListener() {
		return this.listener;
	}


}
