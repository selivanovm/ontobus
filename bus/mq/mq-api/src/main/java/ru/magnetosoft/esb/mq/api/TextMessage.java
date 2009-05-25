package ru.magnetosoft.esb.mq.api;


public interface TextMessage  extends Message
{
	void setText(String text);
	String getText();
}
