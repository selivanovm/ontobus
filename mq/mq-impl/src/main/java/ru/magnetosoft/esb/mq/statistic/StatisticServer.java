package ru.magnetosoft.esb.mq.statistic;


public interface StatisticServer
{
	
	void register(AgentName name, Object agent) throws Exception;
	
}
