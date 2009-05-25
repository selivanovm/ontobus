package ru.magnetosoft.esb.mq.message;

import ru.magnetosoft.esb.mq.api.TextMessage;
import ru.magnetosoft.esb.mq.command.MQMessage;

public class TextMessageImpl extends AbstractMessage implements TextMessage
{
	protected String text;

	
	public TextMessageImpl(){}
	public TextMessageImpl(MQMessage src){
		super(src);
		
		this.text = src.payload.toString();// new String(src.payload.toString(), "utf-8");
	}
	
	
	public String getText() {
		return this.text;
	}

	public void setText(String text) {
		this.text = text;
	}

}
