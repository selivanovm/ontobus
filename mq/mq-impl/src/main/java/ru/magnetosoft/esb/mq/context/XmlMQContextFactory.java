package ru.magnetosoft.esb.mq.context;

import java.util.List;

import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;

import ru.magnetosoft.esb.mq.context.MQContext.TransportContext;
import ru.magnetosoft.esb.mq.utils.NetworkUtils;
import ru.magnetosoft.jtoolbox.resources.Resource;
import ru.magnetosoft.jtoolbox.xml.XPathNode;

public class XmlMQContextFactory implements ContextFactory
{
	
	protected XmlMQContextFactory() {}

	public Context newContext(Resource rc) {
		MQContext ctx = new MQContext();
		
		try {
			Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse( rc.openStream() );
			XPathNode root = XPathNode.wrap(doc);
			
			XPathNode node = root.element("statisticServer");
			if(node != null)
				ctx.statisticServer = instance_from_classname(node.text());
	
			node = root.element("broker");
			ctx.brokerName = node.attr("name");
			ctx.brokerQueueSize = Integer.parseInt( node.attr("queueSize") );
			
			List<XPathNode> nodelist = root.elementList("transports/inTransport");
			for(XPathNode item : nodelist){
				TransportContext td = new TransportContext();
				td.factory = instance_from_classname( item.attr("factory") );
				td.format = instance_from_classname( item.attr("format") );
				td.localAddress = NetworkUtils.parseSocketAddress( item.attr("localAddress") );
				td.remoteAddress = NetworkUtils.parseSocketAddress( item.attr("remoteAddress") );
				td.sendQueueSize = Integer.parseInt( item.attr("sendQueueSize") );
				
				ctx.inTransportContextList.add(td);
			}

			nodelist = root.elementList("transports/outTransport");
			for(XPathNode item : nodelist){
				TransportContext td = new TransportContext();
				td.factory = instance_from_classname( item.attr("factory") );
				td.format = instance_from_classname( item.attr("format") );
				td.localAddress = NetworkUtils.parseSocketAddress( item.attr("localAddress") );
				td.remoteAddress = NetworkUtils.parseSocketAddress( item.attr("remoteAddress") );
				td.sendQueueSize = Integer.parseInt( item.attr("sendQueueSize") );
				
				ctx.outTransportContextList.add(td);
			}
			
			
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		
		return ctx;
	}
	
	
	protected <T> T instance_from_classname(String className) throws Exception{
		return (T)Class.forName(className).newInstance();
	}
	
	
	public static XmlMQContextFactory newInstance(){
		return new XmlMQContextFactory();
	}
}
