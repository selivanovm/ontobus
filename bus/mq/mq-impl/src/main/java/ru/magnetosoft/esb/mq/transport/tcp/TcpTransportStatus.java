/**
 * 
 */
package ru.magnetosoft.esb.mq.transport.tcp;

import ru.magnetosoft.esb.mq.statistic.AvgParam;

public class TcpTransportStatus implements TcpTransportStatusMBean
{
	public AvgParam sendTime = new AvgParam();
	public AvgParam receiveTime = new AvgParam();
	
	public String getSendTime() {
		return sendTime.toString();
	}
	public String getReceiveTime() {
		return receiveTime.toString();
	}
	
}