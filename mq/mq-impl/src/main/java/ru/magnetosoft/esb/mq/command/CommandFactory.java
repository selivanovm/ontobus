package ru.magnetosoft.esb.mq.command;

import ru.magnetosoft.esb.mq.command.Command.Codes;

public class CommandFactory
{
	
	
	public Command newCommand(int code){
		switch(code){
			case Codes.MESSAGE: return new MQMessage();
			default:
				return Command.newCommand(code);
		}
	}
	
	
	public static CommandFactory newInstance(){
		return new CommandFactory();
	}
}
