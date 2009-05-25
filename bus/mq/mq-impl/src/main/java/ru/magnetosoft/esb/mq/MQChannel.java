package ru.magnetosoft.esb.mq;

import ru.magnetosoft.esb.mq.command.Command;
import ru.magnetosoft.esb.mq.command.Command.Codes;
import ru.magnetosoft.esb.mq.lock.ChannelMutex;
import ru.magnetosoft.esb.mq.lock.ChannelMutexBuffer;
import ru.magnetosoft.esb.mq.transport.Transport;
import ru.magnetosoft.esb.mq.transport.TransportListener;
import ru.magnetosoft.esb.mq.transport.TransportServer;
import ru.magnetosoft.esb.mq.utils.NetworkUtils;

public class MQChannel// implements Sender
{
	public class Endpoint
	{
		protected String brokerName;
		
		public String getBrokerName(){
			return this.brokerName;
		}
		
		public boolean isBroker(){
			return brokerName != null;
		}
	}
	
	
//	public static final int IN = 			1;
//	public static final int OUT = 		2;
//	public static final int IN_OUT = 	3;
	
//	private int mode;
	private Endpoint remoteEndpoint;
	private Transport transport;
	private TransportServer transportServer;
	private ChannelMutexBuffer mutexPool;
	
	protected MQChannel(Transport t, ChannelMutexBuffer mbuf){
		this.transport = t;
		this.transportServer = null;
		this.mutexPool = mbuf;
	}
	
	protected MQChannel(Transport t, TransportServer srv, ChannelMutexBuffer mbuf){
		this.transportServer = srv;
		this.transport = t;
		this.mutexPool = mbuf;
//		this.mode = mode;
		
	}
	
	
	public void open(){
		final TransportListener brokerListener = transport.getTransportListener();
		transport.setTransportListener( new TransportListener(){
			public void onCommand(Object command) {
				// Обрабатываем полученное сообщение
				if(command != null){
					Command cmd = (Command)command;
					ChannelMutex mutex = mutexPool.findMutex(cmd.id);
					// если найден монитор, то сообщение обрабатывается синхронно
					if(mutex != null){
						synchronized(mutex){
							mutex.object = command;
							mutex.notifyAll();
						}
						return;
					}
				}
				brokerListener.onCommand(command);
			}
			public void onException(Exception ex) {
				brokerListener.onException(ex);
			}
		} );
		
		
		// запускаем транспорт
		transport.doStart();
		// получаем информацию о соединении
		if( isOutput() ){
			//TODO здесь может отвалиться запрос
			Command response = (Command)requestSync( 
					Command.newCommand(Codes.CHANNEL_INFO)
						.set("address", NetworkUtils.socketAddressToString(transportServer.getAddress()))
						);
			
			remoteEndpoint = new Endpoint();
			remoteEndpoint.brokerName = (response.has("broker-name")) ? (String)response.get("broker-name") : null;
		}
	}
	
	public void close(){
		transport.doStop();
	}
	
	public boolean isClosed(){
		return !transport.isConnected();
	}
	
	public boolean isReady(){
		return remoteEndpoint != null;
	}
	
	public boolean isOutput(){
		return transportServer != null;
	}
	
	public Endpoint getRemoteEndpoint(){
		return this.remoteEndpoint;
	}
	
	public Transport getTransport(){
		return this.transport;
	}

	
	
	
	
	public void send(Command cmd) {
		this.transport.send(cmd);
	}
	
	
	public Object requestSync(Command cmd){
		ChannelMutex mutex = mutexPool.createMutex(cmd.id);
		synchronized(mutex){
			send(cmd);
			try {
				mutex.wait();
			}
			catch (Exception e) {
				e.printStackTrace();
			}
			finally{
				mutexPool.removeMutex(cmd.id);
			}
		}
		
		return mutex.object;
	}
	
//	public int getMode(){
//		return this.mode;
//	}
	
//	public static MQChannel newInputChannel(TransportServer srv, Transport t){
//		return new MQChannel(srv, t, IN);
//	}
//	
//	public static MQChannel newOutputChannel(TransportServer srv, Transport t){
//		return new MQChannel(srv, t, OUT);
//	}
	
}
