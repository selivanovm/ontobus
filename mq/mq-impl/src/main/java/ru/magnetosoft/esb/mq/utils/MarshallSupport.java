package ru.magnetosoft.esb.mq.utils;


public interface MarshallSupport
{
	void beforeMarshall();
//	void afterMarshall();
	
//	void beforeUnmarshall();
	void afterUnmarshall();	
}
