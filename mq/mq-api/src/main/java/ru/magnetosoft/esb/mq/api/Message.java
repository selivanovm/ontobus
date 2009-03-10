package ru.magnetosoft.esb.mq.api;

/**
 * Сообщение, как квант передачи информации
 * 
 * @author Kodanev Yuriy
 */
public interface Message
{
	String getMessageID();
	String getCorrelationID();
	Destination getReplyTo();
	Destination getDestination();
	
	void setMessageID(String id);	
	void setCorrelationID(String id);
	void setReplyTo(Destination replyTo);
	void setDestination(Destination destination);
	
}
