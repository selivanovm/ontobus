package ru.magnetosoft.esb.mq.message;

import ru.magnetosoft.esb.mq.api.Destination;
import ru.magnetosoft.esb.mq.api.Message;
import ru.magnetosoft.esb.mq.command.MQMessage;

public abstract class AbstractMessage implements Message
{
	protected Destination destination;
	protected Destination replyTo;
	protected String correlationID;
	protected String messageID;
	
	
	public AbstractMessage(){}
	public AbstractMessage(MQMessage src){
//		this.destination = src.destination;
//		this.replyTo = src.replyTo;
		this.correlationID = src.correlationID;
		this.messageID = src.messageID;
	}
	
	

	public String getCorrelationID() {
		return this.correlationID;
	}

	public Destination getDestination() {
		return this.destination;
	}

	public String getMessageID() {
		return this.messageID;
	}

	public Destination getReplyTo() {
		return this.replyTo;
	}

	public void setCorrelationID(String id) {
		this.correlationID = id;
	}

	public void setDestination(Destination destination) {
		this.destination = destination;
	}

	public void setMessageID(String id) {
		this.messageID = id;
	}

	public void setReplyTo(Destination replyTo) {
		this.replyTo = replyTo;
	}

}
