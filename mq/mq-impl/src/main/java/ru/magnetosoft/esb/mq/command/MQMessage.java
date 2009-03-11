package ru.magnetosoft.esb.mq.command;

import java.util.ArrayList;
import java.util.List;

import ru.magnetosoft.esb.mq.destination.Destination;
import ru.magnetosoft.esb.mq.destination.DestinationType;
import ru.magnetosoft.esb.mq.message.MessageType;
import ru.magnetosoft.esb.mq.payload.Payload;
import ru.magnetosoft.esb.mq.utils.IRI;

public class MQMessage extends Command
{
	{
		this.code = Codes.MESSAGE;
	}
	
	public Destination destination;
	public MessageType messageType;
	public Destination replyTo;
	public String messageID;
	public String correlationID;
	public List<String> path = new ArrayList<String>();
	
	public Payload payload;
	
	
	
	
	@Override
	public void beforeMarshall() {
		super.beforeMarshall();
		
		
		set("message-type", messageType.name());
		set("message-id", messageID);
		set("correlation-id", correlationID);
		set("destination-type", (destination != null) ? destination.type().ordinal() : null);
		set("destination-iri-list", (destination != null) ? destination.iriList() : null);
		set("reply-to-type", (replyTo != null) ? replyTo.type().ordinal() : null);
		set("reply-to-iri-list", (replyTo != null) ? replyTo.iriList() : null);
		set("path", path);
		set("payload", payload);
		
	}
	
	@Override
	public void afterUnmarshall() {
		super.afterUnmarshall();
		
		messageType = MessageType.valueOf( (String)parameters.get("message-type") );
		messageID = get("message-id");
		correlationID = get("correlation-id");
		if(get("destination-type") != null){
			DestinationType dtype = DestinationType.values()[ (Integer)parameters.get("destination-type") ];
			List<IRI> irilist = get("destination-iri-list");
			destination = new Destination(dtype, irilist);
		}
		if(get("reply-to-type") != null){
			DestinationType dtype = DestinationType.values()[ (Integer)parameters.get("reply-to-type") ];
			List<IRI> irilist = get("reply-to-iri-list");
			replyTo = new Destination(dtype, irilist);
		}
		path = get("path");
		payload = get("payload");
		
		
	}
}
