package ru.magnetosoft.esb.mq.statistic.jmx;

import java.lang.management.ManagementFactory;

import javax.management.MBeanServer;
import javax.management.ObjectName;

import ru.magnetosoft.esb.mq.statistic.AgentName;
import ru.magnetosoft.esb.mq.statistic.StatisticServer;

public class JMXStatisticServer implements StatisticServer
{
	protected MBeanServer mbs = null;
	
	public JMXStatisticServer() {
		mbs = ManagementFactory.getPlatformMBeanServer();
	}

	public void register(AgentName name, Object agent) throws Exception{
		ObjectName objName = new ObjectName( String.format("%s:name=%s", name.contextName, name.objectName) );
		mbs.registerMBean(agent, objName);
	}

}
