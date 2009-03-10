package ru.magnetosoft.esb.mq;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class SyncSupport
{
	public class Monitor
	{
		public Object object;
	}
	
	protected Map<Object, Monitor> monitors = Collections.synchronizedMap( new HashMap<Object, Monitor>() );
	
	
	
	
	
}
