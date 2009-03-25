package ru.magnetosoft.esb.mq.test;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

import ru.magnetosoft.esb.mq.MQBroker;
import ru.magnetosoft.esb.mq.MQSession;
import ru.magnetosoft.esb.mq.MessageHandler;
import ru.magnetosoft.esb.mq.command.MQMessage;
import ru.magnetosoft.esb.mq.context.Context;
import ru.magnetosoft.esb.mq.context.XmlMQContextFactory;
import ru.magnetosoft.esb.mq.context.MQContext.TransportContext;
import ru.magnetosoft.esb.mq.customer.MQProxy;
import ru.magnetosoft.esb.mq.destination.Destination;
import ru.magnetosoft.esb.mq.format.binary.BMQFormat;
import ru.magnetosoft.esb.mq.message.MessageType;
import ru.magnetosoft.esb.mq.payload.Payload;
import ru.magnetosoft.esb.mq.transport.tcp.TcpTransportFactory;
import ru.magnetosoft.esb.mq.utils.IRI;
import ru.magnetosoft.esb.mq.utils.NetworkUtils;
import ru.magnetosoft.esb.mq.utils.Parameters;
import ru.magnetosoft.jtoolbox.common.FileUtils;
import ru.magnetosoft.jtoolbox.common.StringUtils;
import ru.magnetosoft.jtoolbox.resources.FileResource;
import ru.magnetosoft.jtoolbox.resources.MemResource;

public class Main 
{
	static class Command
	{
		public String type = null;
		public List<String> parameterList = new ArrayList<String>();
		
		public static Command parse(String s){
			
			Command cmd = new Command();
			
			StringTokenizer tokenizer = new StringTokenizer(s, " ");
			while(tokenizer.hasMoreTokens()){
				String token = tokenizer.nextToken();
				if(cmd.type == null)
					cmd.type = token.toLowerCase();
				else
					cmd.parameterList.add(token);
			}
			
			return cmd;
		}
		
		public String param(int index){
			return this.parameterList.get(index);
		}
		
		public int paramInt(int index){
			return Integer.parseInt( this.parameterList.get(index) );
		}
		
		
		@Override
		public String toString() {
			return (type == null) ? "unknown" : type;
		}
		
		@Override
		public boolean equals(Object obj) {
			return toString().equals(obj.toString());
		}
	}
	 
	
	
	protected static MessageHandler messageHandler = new MessageHandler()
	{

		public void onException(Exception ex) {
			ex.printStackTrace();
		}

		public void onMessage(MQMessage message) {
			if( !message.parameters.contains("spam") ){
				try{
					byte[] buf = new byte[message.payload.getSize()];
					DataInputStream in = new DataInputStream(message.payload.getResource().openStream());
					in.readFully(buf);
					
					System.out.println("Received message [" + StringUtils.fromBytesUTF(buf) + "]");
				}
				catch(IOException e){
					onException(e);
				}
			}
		}
		
	};
	
	
	
	public static void main(String[] args){
		
//		String queueName = args[0];
//		String srvAddress = args[1];
		
//		MQContext ctx = new MQContext();
		Context ctx = XmlMQContextFactory.newInstance().newContext( new FileResource(FileUtils.curdir() + FileUtils.f_sep + "configuration.xml") );
				
		
		MQBroker mq = new MQBroker();
		mq.doInit(ctx);
		mq.doStart();
		
		MQSession session = mq.createSession();
//		PropertiesHelper ph = PropertiesHelper.newInstance(new Properties());
//		ph.setInt(MQProxy.THREAD_POOL_SIZE, 1);
		MQProxy mql = session.createProxyCustomer(
				"aaa", 
				messageHandler, 
				Parameters.newInstance().set(MQProxy.PNames.THREAD_POOL_SIZE, 1).set(MQProxy.PNames.MAX_QUEUE_SIZE, 50)
				);
		
		BufferedReader con = new BufferedReader(new InputStreamReader(System.in));
		
		try {
			for(;;){
				Command cmd = Command.parse( con.readLine() );
				
				long t0 = System.currentTimeMillis();				
				
				if(cmd.equals("exit")){
					break;
				}
				else if(cmd.equals("send")){
					MQMessage msg = new MQMessage();
					msg.messageID = UUID.randomUUID().toString();
					msg.messageType = MessageType.TEXT;
					msg.destination = Destination.createSingle( IRI.create(cmd.param(0)));
					
					byte[] data = StringUtils.asBytesUTF(cmd.param(1));
					msg.payload = new Payload( new MemResource(data), data.length );
//					msg.payload.type = PayloadType.BYTE_SEQUENCE;
//					msg.payload.bytes = ByteSequence.fromBytes( StringUtils.asBytesUTF(cmd.param(1)) );  
//					ByteSequence.fromString(cmd.param(2));
					
					mq.trySend(msg);
				}
				else if(cmd.equals("connect")){
					TransportContext tc = new TransportContext();
					tc.factory = new TcpTransportFactory();
					tc.format = new BMQFormat();
					tc.localAddress = null;
					tc.remoteAddress = NetworkUtils.parseSocketAddress(cmd.param(0));
					tc.sendQueueSize = 30;
					
					mq.createChannel(tc);
				}
				else if(cmd.equals("spam")){
					String target = cmd.param(0);
					int n = cmd.paramInt(1);
					int dataLen = cmd.paramInt(2);
					
					int numRejected = 0;
					
					for(int i = 0; i < n; i++){
						MQMessage msg = new MQMessage();
						msg.messageID = UUID.randomUUID().toString();
						msg.messageType = MessageType.TEXT;
						msg.destination = Destination.createSingle( IRI.create(target) );
						
						msg.parameters.set("spam", null);
						
						msg.payload = new Payload( new MemResource(new byte[dataLen]), dataLen );
//						msg.payload.type = PayloadType.BYTE_SEQUENCE;
//						msg.payload.bytes = ByteSequence.wrap( new byte[dataLen] );
						
						if(!mq.trySend(msg, 500, TimeUnit.MILLISECONDS)) 
							numRejected++;
					}
					
					
					System.out.println( String.format("%d message(s) has been rejected", numRejected) );
				}
				else{
					System.out.println("Unknown command [" + cmd.type + "]");
				}
				
				long t1 = System.currentTimeMillis();
				System.out.println( String.format("Done in %d ms", t1 - t0) );				
			}
		}
		catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		finally{
			session.close();
			mq.doStop();
		}
		
	}
	
		
	
}
