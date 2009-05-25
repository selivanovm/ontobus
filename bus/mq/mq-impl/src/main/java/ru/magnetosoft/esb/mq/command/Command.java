package ru.magnetosoft.esb.mq.command;

import java.util.LinkedList;
import java.util.List;
import java.util.UUID;

import ru.magnetosoft.esb.mq.destination.Destination;
import ru.magnetosoft.esb.mq.destination.DestinationType;
import ru.magnetosoft.esb.mq.utils.IRI;
import ru.magnetosoft.esb.mq.utils.MarshallSupport;
import ru.magnetosoft.esb.mq.utils.Parameters;

public class Command implements MarshallSupport
{
	public interface Codes
	{
		int CHANNEL_INFO = 		1;
		int MESSAGE =		2;
		
		int OPEN_SESSION = 		3;
		int CLOSE_SESSION = 	4;
		
		int CREATE_QUEUE = 5;
		int CREATE_TOPIC = 6;
		int CREATE_PROXY = 7;
		int REMOVE_CUSTOMER = 8;
		int QUEUE_INFO = 9;
		int TOPIC_INFO = 10;
		int PROXY_INFO = 11;
		int QUEUE_PEEK = 12;
		int TOPIC_SUBSCRIBE = 13;
		int TOPIC_UNSUBSCRIBE = 14;
		
		int BROKER_INFO = 15;
		
		int RESPONSE = 16;
		int EXCEPTION = 17;
		
		int NULL_TYPE = 100;
		int INTEGER_TYPE = 		101;
		int SHORT_TYPE = 			102;
		int LONG_TYPE = 				103;
		int FLOAT_TYPE = 			104;
		int DOUBLE_TYPE = 			105;
		int BOOLEAN_TYPE = 		106;
		int BYTE_TYPE = 				107;
		int CHAR_TYPE = 				108;
		int STRING_TYPE = 			109;
		int DATETIME_TYPE =		110;
		int IRI_TYPE = 				111;
		
		int LIST_TYPE = 							201;
		int MAP_TYPE =								202;
		int STREAM_TYPE =							203;
		int COMMAND_TYPE = 						204;
		
	}
	
	public String id = UUID.randomUUID().toString();
	public int code;// String commandName;
	public Parameters parameters = new Parameters();
	
//	public Deque<PreparedParameter> prepared = new LinkedList<PreparedParameter>();
	public List<Object> prepared = new LinkedList<Object>();
//	public List<Object> preparedHeader = new ArrayList<Object>();
	
	@Override
	public boolean equals(Object obj) {
		Command other = (Command)obj;
		return (id == null) ? false : id.equals(other.id);
	}
	
	@Override
	public int hashCode() {
		return id.hashCode();
	}
	
//	@Override
//	public String toString() {
//		return commandName;
//	}
//	
	
	public static Command newCommand(int code){
		Command cmd = new Command();
		cmd.code = code;
		return cmd;
	}
	
	public static Command newResponse(Command cmd){
		Command response = new Command();
		response.id = cmd.id;
		response.code = Codes.RESPONSE;
		return response;
	}
	
	
	public boolean has(String key){
		return this.parameters.contains(key);
	}
	
	public Command set(String key, Object value){
		parameters.set(key, value);
		return this;
	}

	public Command set(String key){
		parameters.set(key, null);
		return this;
	}
	
	@SuppressWarnings("unchecked")
	public <T> T get(String key){
		return (T)parameters.get(key);
	}
	
//	public Command code(String name){
//		this.commandName = name;
//		return this;
//	}
	
	public int code(){
		return this.code;
	}
	
	
//	public boolean is(String name){
//		return name.equals(this.commandName);
//	}
	
	public Command id(String id){
		this.id = id;
		return this;
	}

	
	
	
	public void afterUnmarshall() {
	}

	public void beforeMarshall() {
	}

	
	
	
	protected void prepare_destination(Destination destination){
//		prepared.add( PreparedParameter.prepareInt( (destination == null) ? null : destination.type().ordinal()) );
//		prepared.add( PreparedParameter.prepareList( (destination == null) ? null : destination.iriList() ) );
		prepared.add( (destination == null) ? null : destination.type().ordinal() );
		prepared.add( (destination == null) ? null : destination.iriList() );
	}
	
	protected Destination restore_destination(){
		Integer type = (Integer)prepared.get(0);//pop();//.restore();
		List<IRI> list = (List<IRI>)prepared.get(0);//.pop();//.restore();
		return (type != null) ? new Destination(DestinationType.values()[type], list) : null;
	}
	
}
