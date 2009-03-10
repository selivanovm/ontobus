package ru.magnetosoft.esb.mq.statistic;

public class AgentName
{
	public String contextName;
	public String objectName;

	public AgentName() {}
	public AgentName(String context, String name) {
		this.contextName = context;
		this.objectName = name;
	}
	
	public static AgentName newName(String context, String name){
		return new AgentName(context, name);
	}
}
