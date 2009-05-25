package ru.magnetosoft.esb.mq;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

import ru.magnetosoft.esb.mq.command.Command;
import ru.magnetosoft.esb.mq.command.MQMessage;
import ru.magnetosoft.esb.mq.command.Command.Codes;
import ru.magnetosoft.esb.mq.context.Context;
import ru.magnetosoft.esb.mq.context.MQContext;
import ru.magnetosoft.esb.mq.context.MQContext.TransportContext;
import ru.magnetosoft.esb.mq.customer.MQProxy;
import ru.magnetosoft.esb.mq.customer.MQQueue;
import ru.magnetosoft.esb.mq.customer.MQTopic;
import ru.magnetosoft.esb.mq.customer.MessageCustomer;
import ru.magnetosoft.esb.mq.destination.DestinationType;
import ru.magnetosoft.esb.mq.format.binary.BMQFormat;
import ru.magnetosoft.esb.mq.lock.ChannelMutexBuffer;
import ru.magnetosoft.esb.mq.transport.Transport;
import ru.magnetosoft.esb.mq.transport.TransportAcceptListener;
import ru.magnetosoft.esb.mq.transport.TransportFactory;
import ru.magnetosoft.esb.mq.transport.TransportListener;
import ru.magnetosoft.esb.mq.transport.TransportServer;
import ru.magnetosoft.esb.mq.transport.tcp.TcpTransportFactory;
import ru.magnetosoft.esb.mq.utils.IRI;
import ru.magnetosoft.esb.mq.utils.NetworkUtils;

public class MQBroker implements ServiceSupport
{
	public class MQSession
	{
		protected String sessionID = UUID.randomUUID().toString();
		protected Map<String, MessageCustomer> customers = new HashMap<String, MessageCustomer>();
		protected MessageHandler handler = new MessageHandler(){
			public void onException(Exception ex) {
				ex.printStackTrace();
			}

			public void onMessage(MQMessage message) {
				for(IRI iri : message.destination.iriList()){
					MessageCustomer customer = customers.get(iri.getPath().substring(1));
					if(customer != null)
						customer.put(message);
				}
			}
		};
		
		public MQSession() {
			handlerList.add(this.handler);
		}

		
		public String getID(){
			return this.sessionID;
		}
		
		public void close() {
			handlerList.remove(this.handler);
		}
		
		
		
		public MQQueue createQueueCustomer(String name, int queueSize){
			MQQueue queue = new MQQueue(name, queueSize);
			customers.put(name, queue);
			return queue;
		}

		public MQTopic createTopicCustomer(String name){
			throw new UnsupportedOperationException("Not supported yet");
		}
		
		public MQProxy createProxyCustomer(String name, MessageHandler handler, int threadPoolSize, int maxQueueSize){
			MQProxy proxy = new MQProxy(name, threadPoolSize, maxQueueSize);
			proxy.setMessageHandler(handler);
			customers.put(name, proxy);
			return proxy;
		}		
		
		public void removeCustomer(String name){
			customers.remove(name);
		}
	}
	
	
	
	protected class MQTransportListener implements TransportListener
	{
		protected MQChannel channel;
		
		public MQTransportListener(MQChannel ch){
			this.channel = ch;
		}
		
		public void onCommand(Object obj) {
			Command cmd = (Command)obj;
			
			// сообщения попадают в очередь
			int code = cmd.code();
//			int hints = cmd.has("broker-hints") ? (Integer)cmd.get("broker-hints") : 0;
			
			if(code == Codes.MESSAGE){
				try {
					messageQueue.put((MQMessage)cmd);
				}
				catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
			else if(code == Codes.CHANNEL_INFO){
//				MQChannel ch = cmd.has("keep-channel") ? channel : findChannel(channel.getTransport().getRemoteAddress());
				
//				ChannelInfoCommand response = new ChannelInfoCommand();
//				response.setBrokerName(brokerName);
				
				try{
					if(cmd.has("address")){
						InetSocketAddress backAddr = NetworkUtils.parseSocketAddress( (String)cmd.get("address") );
						MQChannel chReverse = findChannel(backAddr);
						if(chReverse == null){
							TransportContext tctx = new TransportContext();
							tctx.factory = new TcpTransportFactory();
							tctx.format = new BMQFormat();
							tctx.remoteAddress = backAddr;
							tctx.sendQueueSize = 50;
							chReverse = createChannel(tctx);
						}							
					}
				}
				catch(IOException e){
					e.printStackTrace();
				}
				
				
				
				
				channel.send( Command.newResponse(cmd)
					.set("broker-name", brokerName)
					);
			}
			else if(code == Codes.OPEN_SESSION){
				MQSession session = createSession();
								
//				MQChannel ch = check(hints, Hints.ASYNC) ? findChannel(channel.getTransport().getRemoteAddress()) : channel;
				channel.send( Command.newResponse(cmd)
					.set("session-id", session.getID())
					);
			}
			else if(code == Codes.CLOSE_SESSION){
				String sid = cmd.get("session-id");
				MQSession session = getSession(sid);
				
				if(session != null)
					session.close();
			}
			else if(code == Codes.CREATE_QUEUE){
				String sid = cmd.get("session-id");
				MQSession session = getSession(sid);
				
				String name = cmd.get("name");
//				int queueSize = (Integer)cmd.get("queue-size");
				session.createQueueCustomer(name, 100);
				
				// посылаем пустой ответ как сигнал того, что все закончилось хорошо
				channel.send( Command.newResponse(cmd) );				
			}
			else if(code == Codes.CREATE_PROXY){
				String sid = cmd.get("session-id");
				String name = cmd.get("name");
				final InetSocketAddress forwardAddress = NetworkUtils.parseSocketAddress( (String)cmd.get("address-to-send") );
				MQSession session = getSession(sid);

				try{
					MQChannel forwardCh = findChannel(forwardAddress);
					if(forwardCh == null){
						TransportContext tctx = new TransportContext();
						tctx.factory = new TcpTransportFactory();
						tctx.format = new BMQFormat();
						tctx.remoteAddress = forwardAddress;
						tctx.sendQueueSize = 50;
						forwardCh = createChannel(tctx);
					}
				}
				catch(IOException e){
					e.printStackTrace();
				}
				
				session.createProxyCustomer(name, new MessageHandler(){
					public void onException(Exception ex) {
						ex.printStackTrace();
					}
					public void onMessage(MQMessage message) {
						MQChannel ch = findChannel(forwardAddress);
						ch.send(message);
					}
				}, 1, 30);
				
				// посылаем пустой ответ как сигнал того, что все закончилось хорошо
				channel.send( Command.newResponse(cmd) );
			}
			

			else{
				System.out.println("Unknown command [" + cmd + "]");
			}
		}

		public void onException(Exception ex) {
			ex.printStackTrace();
		}
				
	}
	
	
	
	
	protected class MQDispatchThread extends Thread
	{
		
		public MQDispatchThread() {
			super("MQDispatchThread");
		}
		
		@Override
		public void run() {
			
			System.out.println("Диспетчер очереди запущен");
			
			for(;;){
				
				try {
					MQMessage message = messageQueue.take();
					
					boolean transit = true;
					for(IRI iri : message.destination.iriList()){
						if(brokerName.equals(iri.getHost())){
							notify_observers(message);
							if(message.destination.type() == DestinationType.SINGLE)
								transit = false;
						}
					}
					

					// если сообщение, транзитное, то выполняем рассылку по всем выходным каналам
					if(transit){
						// отмечаем, что данная очередь была посещена сообщением
						message.path.add(brokerName);
						
						for(MQChannel ch : channels){
							
							// если канал для отправления, готов и связан с другим брокером
							if(ch.isOutput() && ch.isReady() && ch.getRemoteEndpoint().isBroker()){
								// отправяем сообщения только туда, где оно еще не было
								if(!message.path.contains(ch.getRemoteEndpoint().getBrokerName())){
									// проверяем, существует ли транспорт к данной очереди
//									Transport t = ch.transport;//outTransports.get(ch.queueName);
	//								if(!t.isConnected()) ch.connect();
									
									ch.send(message);
								}
							}
						}
						
					}
				}
				catch (InterruptedException e) {
					interrupted();
					break;
				}
				catch(Exception e){
					e.printStackTrace();
				}
			}
			
			System.out.println("Диспетчер очереди остановлен");
		}
		
		protected void notify_observers(MQMessage message){
			for(MessageHandler mqo : handlerList)
				mqo.onMessage( message );
		}
		
	}
	
	
	
	
	public interface Hints
	{
		int ASYNC = 1 << 0;
	}
	
	
	public static final String TRANSPORT_FACTORY = "transport-factory";
	
	
	protected String brokerName;
	protected InetSocketAddress serverAddress;
	protected Set<MQChannel> channels = new HashSet<MQChannel>();
	protected TransportFactory transportFactory;
	protected MQContext context;
	
	
	protected TransportServer transportServer;
		
	protected BlockingQueue<MQMessage> messageQueue = new LinkedBlockingQueue<MQMessage>(500);
	protected List<MessageHandler> handlerList = new ArrayList<MessageHandler>();
	
	protected MQDispatchThread dispatcher = new MQDispatchThread();
	
	protected ChannelMutexBuffer channelMutexBuffer = new ChannelMutexBuffer();
	
	protected Map<String, MQSession> sessions = new ConcurrentHashMap<String, MQSession>();
	
	
	public MQBroker(){
	}
	
	

	public void doStart() {
		dispatcher.start();
	}


	public void doStop() {
		for(MQChannel ch : channels)	ch.getTransport().doStop();
//		for(Transport t : inTransports)	t.doStop();
		if(transportServer != null)	transportServer.doStop();
		
		dispatcher.interrupt();
	}
	
	
	
	public String getBrokerName(){
		return this.brokerName;
	}
	
	
//	public void setBrokerName(String name){
//		this.brokerName = name;
//	}
//	
//	public void setServerAddress(InetSocketAddress address){
//		this.serverAddress = address;
//	}
	
	public MQChannel createChannel(TransportContext ctx) throws IOException{		
		Transport t = ctx.factory.createTransport(ctx.remoteAddress);
		t.doInit(ctx);
		MQChannel ch = new MQChannel(t, this.transportServer, this.channelMutexBuffer);// MQChannel.newOutputChannel(t);
		//TODO исправить это нахрен
		t.setTransportListener(new MQTransportListener(ch));
		this.channels.add(ch);
		ch.open();
		
		return ch;
	}
	
	public MQSession createSession(){
		MQSession session = new MQSession();
		sessions.put(session.getID(), session);
		return session;
	}
	
	public MQSession getSession(String id){
		return sessions.get(id);
	}
	
	
	public boolean trySend(MQMessage msg){
		return this.messageQueue.offer(msg);
	}

	public boolean trySend(MQMessage msg, long timeout, TimeUnit timeUnit){
		try {
			return this.messageQueue.offer(msg, timeout, timeUnit);
		}
		catch (InterruptedException e) {
		}
		return false;
	}
	
	
	public List<MessageHandler> getMessageHandlers(){
		return this.handlerList;
	}



	public void doInit(Context ctx) {
		this.context = (MQContext)ctx;
		
		try{
//			this.transportFactory = context.getTransportFactory();// (TransportFactory)context.lookup(TRANSPORT_FACTORY);
			this.brokerName = context.getBrokerName();
			this.messageQueue = new LinkedBlockingQueue<MQMessage>( context.getBrokerQueueSize() );
			
			List<TransportContext> tdlist = context.getInTranportContextList();
			for(TransportContext td : tdlist){
				if(this.transportServer == null){

					this.serverAddress = td.localAddress;
					this.transportFactory = td.factory;
					
					// создаем транспортный сервер
					transportServer = transportFactory.createTransportServer(serverAddress);
					
					final TransportContext tctx = td;
					transportServer.setAcceptListener(new TransportAcceptListener(){

						public void onAccept(Transport transport) {
							transport.doInit(tctx);
							MQChannel ch = new MQChannel(transport, channelMutexBuffer);// MQChannel.newInputChannel(transport);//new MQChannel(transport);
							//TODO исправить это нахрен
							transport.setTransportListener(new MQTransportListener(ch));
							channels.add(ch);
							ch.open();							
						}

						public void onException(Exception ex) {
							ex.printStackTrace();
						}
					});
					// инициализируем сервер
					transportServer.doInit(td);
					// запускаем сервер
					transportServer.doStart();										
				}
			}
			
			
			tdlist = context.getOutTranportContextList();
			for(TransportContext td : tdlist){
				createChannel(td);				
			}
			
			
//			TransportServerInfo tsInfo = context.getTransportServerInfoList().get(0);
//			this.serverAddress = tsInfo.address;
//			this.transportFactory = tsInfo.factory;
			
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}

	
	
	public MQChannel findChannel(InetSocketAddress address){
		for(MQChannel ch : this.channels){
			if(ch.isOutput() && ch.getTransport().getRemoteAddress().equals(address))
				return ch;
		}
		return null;
	}

	protected boolean check(int hints, int flag){
		return (hints & flag) != 0;
	}
	
}
