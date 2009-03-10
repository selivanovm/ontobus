package ru.magnetosoft.esb.mq.lock;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class ChannelMutexBuffer
{
	protected Map<Object, ChannelMutex> mutexes = Collections.synchronizedMap( new HashMap<Object, ChannelMutex>() );

	
	public ChannelMutex createMutex(Object obj){
		ChannelMutex mutex = new ChannelMutex(this);
		mutexes.put(obj, mutex);
		return mutex;
	}
	
	public ChannelMutex findMutex(Object obj){
		return mutexes.get(obj);
	}
	
	public void removeMutex(Object obj){
		mutexes.remove(obj);
	}
	
}
