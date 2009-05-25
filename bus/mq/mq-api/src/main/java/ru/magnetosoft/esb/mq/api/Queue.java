package ru.magnetosoft.esb.mq.api;



/**
 * Очередь сообщений как источник и отправитель сообщений
 * 
 * @author Kodanev Yuriy
 */
public interface Queue extends Destination
{
	String getName();
		
	Message receive();
}
