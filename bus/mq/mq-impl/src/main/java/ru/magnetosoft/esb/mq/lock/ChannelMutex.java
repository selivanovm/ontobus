package ru.magnetosoft.esb.mq.lock;

public class ChannelMutex
{
	protected ChannelMutexBuffer buffer = new ChannelMutexBuffer();
	
//	private Object key;
	public Object object;
	
	public ChannelMutex(ChannelMutexBuffer buffer){//, Object key) {
		this.buffer = buffer;
//		this.key = key;
	}
	
	
//	public void detach(){
//		buffer.mutexes.remove(key);
//	}
}
