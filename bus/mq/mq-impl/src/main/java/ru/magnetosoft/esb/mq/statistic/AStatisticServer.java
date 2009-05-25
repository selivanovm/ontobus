package ru.magnetosoft.esb.mq.statistic;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.Map.Entry;

import ru.magnetosoft.esb.mq.ServiceSupport;
import ru.magnetosoft.esb.mq.context.Context;

public class AStatisticServer implements ServiceSupport
{
	class StatisticDaemon extends TimerTask
	{
		@Override
		public void run() {
			for(StatisticAgent agent : agents){
				Map<String, StatisticParam> params = agent.parameters();
				for(Entry<String, StatisticParam> param : params.entrySet())
					System.out.println(param.getKey() + ": " + param.getValue().toString());
				agent.reset();
			}
		}
	}
	
	
	
	protected Set<StatisticAgent> agents = new HashSet<StatisticAgent>();

	public void doStart() {
		Timer timer = new Timer("StatisticDaemon", true);
		timer.schedule(new StatisticDaemon(), 300, 2000);
	}

	public void doStop() {
	}
	
	public void register(StatisticAgent agent){
		agents.add(agent);
	}
	
	public void deregister(StatisticAgent agent){
		agents.remove(agent);
	}

	public void doInit(Context ctx) {
		
	}
	
}
