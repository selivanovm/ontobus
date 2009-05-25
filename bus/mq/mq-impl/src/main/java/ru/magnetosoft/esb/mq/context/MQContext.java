package ru.magnetosoft.esb.mq.context;

import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.List;

import ru.magnetosoft.esb.mq.format.Format;
import ru.magnetosoft.esb.mq.statistic.StatisticServer;
import ru.magnetosoft.esb.mq.transport.TransportFactory;


public class MQContext implements Context
{
	public static class TransportContext implements Context
	{
		public TransportFactory factory;
		public InetSocketAddress localAddress;
		public InetSocketAddress remoteAddress;
		public int sendQueueSize;
		public Format format;
	}
	
//	protected Map<String, Object> env = new HashMap<String, Object>();
	
	protected StatisticServer statisticServer = null;
//	protected TransportFactory transportFactory = new TcpTransportFactory();
	protected List<TransportContext> inTransportContextList = new ArrayList<TransportContext>();
	protected List<TransportContext> outTransportContextList = new ArrayList<TransportContext>();
	protected String brokerName = null;
	protected int brokerQueueSize = 100;
	
	
	public MQContext(){}
//	public MQContext(Map<String, Object> env) {
//		this.env = env;
//	}
	
	
	
//	public void bind(String name, Object obj){
//		this.env.put(name, obj);
//	}
//	
//	public Object lookup(String name){
//		return env.get(name);
//	}
//	
//	
//	public void setStatisticServer(StatisticServer srv){
//		this.statServer = srv;
//	}
//	
	public StatisticServer getStatisticServer(){
		return this.statisticServer;
	}

//	public TransportFactory getTransportFactory() {
//		return transportFactory;
//	}

	public String getBrokerName() {
		return brokerName;
	}

	public List<TransportContext> getInTranportContextList() {
		return inTransportContextList;
	}

	public List<TransportContext> getOutTranportContextList() {
		return outTransportContextList;
	}
	
	public int getBrokerQueueSize() {
		return brokerQueueSize;
	}
		
}
