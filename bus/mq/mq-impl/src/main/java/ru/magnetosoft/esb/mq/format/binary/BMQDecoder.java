package ru.magnetosoft.esb.mq.format.binary;

import java.io.DataInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.magnetosoft.esb.mq.command.Command;
import ru.magnetosoft.esb.mq.command.CommandFactory;
import ru.magnetosoft.esb.mq.command.Command.Codes;
import ru.magnetosoft.esb.mq.payload.Payload;
import ru.magnetosoft.esb.mq.utils.IRI;
import ru.magnetosoft.esb.mq.utils.Parameters;
import ru.magnetosoft.jtoolbox.common.StringUtils;
import ru.magnetosoft.jtoolbox.resources.MemResource;

public class BMQDecoder 
{
	protected DataInputStream in;
	
	public BMQDecoder(DataInputStream dis){
		this.in = dis;
	}
	
	
	protected Command readCommand() throws IOException{
		
		int code = in.read();//.readInt();
		Command cmd = CommandFactory.newInstance().newCommand(code);

		cmd.id = readString();
		cmd.parameters = Parameters.fromMap( readMap() );
		
		
//		int sz = in.readInt();
//		for(int i = 0; i < sz; i++)
//			cmd.prepared.add( readObject() );
		
		return cmd;
	}
	
	protected String readString() throws IOException{
		int len = in.readInt();
		byte[] buf = new byte[len];
		in.readFully(buf);
		return StringUtils.fromBytesUTF(buf);		
	}
	
	protected List readList() throws IOException{
		List<Object> list = new ArrayList<Object>();
		int sz = in.readInt();
		for(int i = 0; i < sz; i++){
			list.add(readObject());
		}
		return list;
	}
	
	protected Map readMap() throws IOException{
		Map<String, Object> map = new HashMap<String, Object>();
		int sz = in.readInt();
		for(int i = 0 ; i < sz; i++){
			String key = readString();
			Object value = readObject();
			map.put(key, value);
		}
		return map;
	}
	
	protected byte[] readByteArray() throws IOException{
		int len = in.readInt();
		byte[] buf = new byte[len];
		in.readFully(buf);
		return buf;
	}
	
	protected Payload readByteStream() throws IOException{
		int sz = in.readInt();
		//TODO вот здесь в зависимости от размера данных, следует решить, какого типа ресурс создавать
		byte[] buf = new byte[sz];
		in.readFully(buf);
		return new Payload(new MemResource(buf), sz);
	}
	
	
	public Object readObject() throws IOException{
		int type = in.read();
		
//		PreparedParameter obj = new PreparedParameter(code, null);
		Object obj = null;
		
		switch(type){
			case Codes.NULL_TYPE: break;
			case Codes.COMMAND_TYPE: obj = readCommand(); break;
			case Codes.BOOLEAN_TYPE: obj = in.readBoolean(); break;
			case Codes.BYTE_TYPE: obj = in.readByte(); break;
			case Codes.CHAR_TYPE: obj = in.readChar(); break;
			case Codes.DATETIME_TYPE: obj = new Date(in.readLong()); break;
			case Codes.DOUBLE_TYPE: obj = in.readDouble(); break;
			case Codes.FLOAT_TYPE: obj = in.readFloat(); break;
			case Codes.INTEGER_TYPE: obj = in.readInt(); break;
			case Codes.IRI_TYPE: obj = IRI.create( readString() ); break;
			case Codes.LIST_TYPE: obj = readList(); break;
			case Codes.LONG_TYPE: obj = in.readLong(); break;
			case Codes.MAP_TYPE: obj = readMap(); break;
			case Codes.SHORT_TYPE: obj = in.readShort(); break;
			case Codes.STRING_TYPE: obj = readString(); break;
			case Codes.STREAM_TYPE: obj = readByteStream(); break;
			default:
				throw new IOException("Unknown type code [" + type + "]");
		}
		
		return obj;
	}
	
	
	
	
/*	
	@SuppressWarnings("unchecked")
	public <T> T read() throws IOException{
		int type = in.readInt();
		
		Object obj = null;
		
		if(BMQConstants.NULL == type){
			obj = null;			
		}
		else if(BMQConstants.INTEGER == type){			
			obj = in.readInt();
		}
		else if(BMQConstants.STRING == type){
			int len = in.readInt();
			byte[] buf = new byte[len];
			in.readFully(buf);
			obj = StringUtils.fromBytesUTF(buf);
//			obj = in.readUTF();
		}
		else if(BMQConstants.BYTE_SEQUENCE == type){
			int len = in.readInt();
			byte[] bytes = new byte[len];
			in.readFully(bytes);
			obj = new ByteSequence(bytes);
		}
		else if(BMQConstants.LIST == type){			
			List<Object> list = new ArrayList<Object>();
			int sz = in.readInt();
			for(int i = 0; i < sz; i++)
				list.add(read());
			obj = list;
		}
		else if(BMQConstants.DESTINATION == type){			
			DestinationType dtype = DestinationType.values()[in.readInt()];
			Destination dest = new Destination(dtype);
			
			int sz = in.readInt();
			for(int i = 0; i < sz; i++){
				String qname = read();
				String addr = read();
				dest.addURI( new DestinationPoint(qname, addr) );				
			}
			
			obj = dest;
		}
		else if(BMQConstants.PAYLOAD == type){			
			Payload payload = new Payload();
			payload.type = PayloadType.values()[in.readInt()];
			payload.bytes = read();
			obj = payload;
		}
		else if(BMQConstants.MESSAGE == type){
			MQMessage msg = new MQMessage();
			msg.id = read();
			msg.parameters = read();
			msg.messageType = MessageType.values()[in.readInt()];
			msg.messageID = read();
			msg.correlationID = read();
			msg.destination = read();
			msg.replyTo = read();
			msg.path = read();
			msg.payload = read();		
			obj = msg;
		}
		else if(BMQConstants.PROPERTIES == type){			
			Map<Object, Object> map = read();
			obj = Parameters.fromMap(map);
		}
		else if(BMQConstants.MAP == type){
			Map<Object, Object> map = new HashMap<Object, Object>();
			int sz = in.readInt();
			for(int i = 0 ; i < sz; i++){
				Object key = read();
				Object value = read();
				map.put(key, value);
			}
			obj = map;
		}
		else if(BMQConstants.COMMAND == type){
			Command cmd = new Command();
			cmd.id = read();
			cmd.code = (Integer)read();
			cmd.parameters = read();
			obj = cmd;
		}
		else if(BMQConstants.IRI == type){
			obj = IRI.fromString((String)read());
		}
		else{
			throw new IOException("Unknown object type_id [" + type + "]");
		}
		
		return (T)obj;
	}
*/	
}
