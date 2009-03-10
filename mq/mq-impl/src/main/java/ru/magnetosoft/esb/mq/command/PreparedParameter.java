/**
 * 
 */
package ru.magnetosoft.esb.mq.command;

import java.util.List;

import ru.magnetosoft.esb.mq.command.Command.Codes;

public class PreparedParameter
{
	public int type;
	public Object value;
	
	public PreparedParameter(int type, Object value){
		this.type = type;
		this.value = value;
	}
	
	
	public static PreparedParameter prepareInt(int value){
		return new PreparedParameter(Codes.INTEGER_TYPE, value);
	}
	
	public static PreparedParameter prepareString(String value){
		return new PreparedParameter(Codes.STRING_TYPE, value);
	}

	public static PreparedParameter prepareList(List value){
		return new PreparedParameter(Codes.LIST_TYPE, value);
	}
	
	
	
	
	
	
	
	public <T> T restore(){
		return (T)value;
	}
	
}