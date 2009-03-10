package ru.magnetosoft.esb.mq.customer;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.Executor;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;

import ru.magnetosoft.esb.mq.MessageHandler;
import ru.magnetosoft.esb.mq.command.MQMessage;

public class MQProxy extends AbstractMessageCustomer
{
//	public static final String THREAD_POOL_SIZE = "thread-pool-size";
	class BlockingExecutor implements Executor
	{
		private List<Thread> threadList = new ArrayList<Thread>();
		private BlockingQueue<Runnable> tasks;

		public BlockingExecutor(int numThreads, BlockingQueue<Runnable> taskQueue, ThreadFactory factory){
			
			this.tasks = taskQueue;
			
			for(int i = 0; i < numThreads; i++){
				Thread t = factory.newThread(new Runnable(){
					public void run() {
						for(;;){
							try{
								Runnable r = tasks.take();
								r.run();
							}
							catch(InterruptedException e){
								e.printStackTrace();
							}
						}
					}
				} );
				threadList.add(t);
				t.start();
			}
		}
		
		public void execute(Runnable r) {
			try {
				tasks.put(r);
			}
			catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		
	}
	
	
	protected MessageHandler handler;	
	protected Executor threadPool;
//	protected int maxNotificationThreads = 0;
//	protected BlockingQueue<Object> queue;
	
	public MQProxy(String name, int threadPoolSize, int maxQueueSize) {
		super(name);
		
//		PropertiesHelper ph = PropertiesHelper.newInstance(props);
//		maxNotificationThreads = ph.getInt(THREAD_POOL_SIZE, 0);
//		this.queue = new LinkedBlockingQueue<Object>(maxQueueSize);
		
		final String theName = name;
		threadPool = new BlockingExecutor(
				threadPoolSize,
				new LinkedBlockingQueue<Runnable>(maxQueueSize),
				new ThreadFactory(){
					public Thread newThread(Runnable task) {
						Thread thread = new Thread(task, String.format("MQListenerTask [%s]", theName));
						thread.setDaemon(true);
						return thread;
					}
				});	
	}
	
	
	
	public void put(MQMessage message) {
		
		if(handler != null){
			final MQMessage msg = message;
			threadPool.execute(new Runnable(){
				public void run() {
					handler.onMessage(msg);
				}
			});
		}			
	}
	
	public void setMessageHandler(MessageHandler handler){
		this.handler = handler;
	}
	
}
