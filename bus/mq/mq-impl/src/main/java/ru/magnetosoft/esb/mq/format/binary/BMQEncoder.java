package ru.magnetosoft.esb.mq.format.binary;

import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import ru.magnetosoft.esb.mq.command.Command;
import ru.magnetosoft.esb.mq.command.Command.Codes;
import ru.magnetosoft.esb.mq.payload.Payload;
import ru.magnetosoft.esb.mq.utils.IRI;
import ru.magnetosoft.jtoolbox.common.StringUtils;

public class BMQEncoder
{	
	protected static final int MAX_BUFFER_SIZE = 4096;
	
	protected DataOutputStream out;
	
	
	public BMQEncoder(DataOutputStream os) {
		this.out = os;
	}
	
	
	
	
	protected final void writeType(int type) throws IOException{
		out.write(type);		
	}
	
	protected void writeCommand(Command command) throws IOException{
//		writeType(Codes.COMMAND_TYPE);
		
		writeByte((byte)command.code);
//		writeInt(command.code);
		writeString(command.id);
		writeMap(command.parameters.getMap());
		
//		out.writeInt(command.prepared.size());
//		while( !command.prepared.isEmpty() ){
////			PreparedParameter param = command.prepared.pop();
//			writeObject(command.prepared.pop());//  param.type, param.value);
//		}
//		writeMap(command.parameters.getMap());
	}
	
	
//	protected void writeNull() throws IOException{
//		writeType(Codes.NULL_TYPE);		
//	}

	protected void writeString(String s) throws IOException{
//		writeType(Codes.STRING_TYPE);
		byte[] buf = StringUtils.asBytesUTF(s);
		out.writeInt(buf.length);
		out.write(buf);
	}
	
	protected void writeInt(Integer i) throws IOException{
//		writeType(Codes.INTEGER_TYPE);
		out.writeInt(i);
	}

	protected void writeLong(Long i) throws IOException{
//		writeType(Codes.LONG_TYPE);
		out.writeLong(i);
	}

	protected void writeBoolean(Boolean i) throws IOException{
//		writeType(Codes.BOOLEAN_TYPE);
		out.writeBoolean(i);
	}

	protected void writeByte(Byte i) throws IOException{
//		writeType(Codes.BYTE_TYPE);
		out.writeByte(i);		
	}
	
	protected void writeShort(Short i) throws IOException{
//		writeType(Codes.SHORT_TYPE);
		out.writeShort(i);
	}

	protected void writeChar(Character i) throws IOException{
//		writeType(Codes.CHAR_TYPE);
		out.writeChar(i);
	}
	
	protected void writeDatetime(Date datetime) throws IOException{
//		writeType(Codes.DATETIME_TYPE);
		out.writeLong(datetime.getTime());		
	}

	protected void writeDouble(Double v) throws IOException{
//		writeType(Codes.DOUBLE_TYPE);
		out.writeDouble(v);
	}
	
	protected void writeFloat(Float v) throws IOException{
//		writeType(Codes.FLOAT_TYPE);
		out.writeFloat(v);
	}
	
	
	protected void writeMap(Map<String, Object> map) throws IOException{
//		writeType(Codes.MAP_TYPE);
		
		Collection<Entry<String, Object>> entries = map.entrySet();
		out.writeInt(entries.size());
		for(Entry<String, Object> entry : entries){
			writeString(entry.getKey());
			writeObject(entry.getValue());
		}		
	}
	
	protected void writeList(List list) throws IOException{
//		writeType(Codes.LIST_TYPE);
		out.writeInt(list.size());
		for(Object elem : list)	writeObject(elem);		
	}
	
	protected void writeByteArray(byte[] data) throws IOException{
//		writeType(Codes.BYTE_ARRAY_TYPE);
		out.writeInt(data.length);
		out.write(data);
	}
	
	protected void writeByteStream(Payload payload) throws IOException{
		
		out.writeInt(payload.getSize());

		InputStream in = payload.getResource().openStream();
		byte[] buf = new byte[MAX_BUFFER_SIZE];		
		int actual = 0;
		int n = 0;
		while( (actual = in.read(buf)) != -1 ){
			n += actual;
			out.write(buf, 0, actual);
		}
		
	}
	
	
	
	public void writeObject(Object obj) throws IOException{
//		if(obj == null){
//			writeNull();
//			return;			
//		}
		
//		Class<?> clazz = obj.getClass();
		
//		int code = 0;
//		if(obj == null) write();
		
		int type = 0;
		if(obj == null) type = Codes.NULL_TYPE;
		else if(obj instanceof Command) type = Codes.COMMAND_TYPE;//writeCommand((Command)obj);
		else if(obj instanceof Integer) type = Codes.INTEGER_TYPE;// writeInt((Integer)obj);
		else if(obj instanceof Long) type = Codes.LONG_TYPE;//writeLong((Long)obj);//code = Codes.LONG_TYPE;
		else if(obj instanceof Short) type = Codes.SHORT_TYPE;//writeShort((Short)obj);//code = Codes.SHORT_TYPE;
		else if(obj instanceof Boolean) type = Codes.BOOLEAN_TYPE;//writeBoolean((Boolean)obj);//code = Codes.BOOLEAN_TYPE;
		else if(obj instanceof Byte) type = Codes.BYTE_TYPE;//writeByte((Byte)obj);//code = Codes.BYTE_TYPE;
		else if(obj instanceof Character) type = Codes.CHAR_TYPE;//writeChar((Character)obj);//code = Codes.CHAR_TYPE;
		else if(obj instanceof Date) type = Codes.DATETIME_TYPE;//writeLong( ((Date)obj).getTime() );//code = Codes.DATETIME_TYPE;
		else if(obj instanceof Double) type = Codes.DOUBLE_TYPE;//writeDouble((Double)obj);//code = Codes.DOUBLE_TYPE;
		else if(obj instanceof Float) type = Codes.FLOAT_TYPE;//writeFloat((Float)obj);//code = Codes.FLOAT_TYPE;
		else if(obj instanceof IRI) type = Codes.IRI_TYPE;//writeString(((IRI)obj).toString());//code = Codes.IRI_TYPE;
		else if(obj instanceof List) type = Codes.LIST_TYPE;//writeList((List)obj);//code = Codes.LIST_TYPE;
		else if(obj instanceof Map) type = Codes.MAP_TYPE;//writeMap((Map<String, Object>)obj);//code = Codes.MAP_TYPE;
		else if(obj instanceof String) type = Codes.STRING_TYPE;//writeString((String)obj);//code = Codes.STRING_TYPE;
		else if(obj instanceof Payload) type = Codes.STREAM_TYPE;//writeByteArray((byte[])obj);//code = Codes.BYTE_ARRAY_TYPE;
		else
			throw new IOException("Cannot map class [" + obj.getClass().getName() + "] to predefined type");
		
		
		writeType(type);
		
		switch(type){
			case Codes.COMMAND_TYPE: writeCommand((Command)obj); return;
			case Codes.BOOLEAN_TYPE: writeBoolean((Boolean)obj); return;
			case Codes.BYTE_TYPE: writeByte((Byte)obj); return;
			case Codes.CHAR_TYPE: writeChar((Character)obj); return;
			case Codes.DATETIME_TYPE: writeLong( ((Date)obj).getTime() ); return; 
			case Codes.DOUBLE_TYPE: writeDouble((Double)obj); return;
			case Codes.FLOAT_TYPE: writeFloat((Float)obj); return;
			case Codes.INTEGER_TYPE: writeInt((Integer)obj); return;
			case Codes.IRI_TYPE: writeString(((IRI)obj).toString()); return;
			case Codes.LIST_TYPE: writeList((List)obj); return;
			case Codes.LONG_TYPE: writeLong((Long)obj); return;
			case Codes.MAP_TYPE: writeMap((Map<String, Object>)obj); return;
			case Codes.SHORT_TYPE: writeShort((Short)obj); return;
			case Codes.STRING_TYPE: writeString((String)obj); return;
			case Codes.STREAM_TYPE: writeByteStream((Payload)obj); return;
//			default:
//				throw new IOException("Unknown type code [" + type + "]");
		} 
		
	}
	
/*	
	protected void write(int code, Object value) throws IOException{
		if(value == null){
			out.writeInt(Codes.NULL_TYPE);
//			writeNull();
			return;			
		}
		
		out.writeInt(code);
		
		switch(code){
//			case Codes.COMMAND_TYPE: writeCommand((Command)value); return;
			case Codes.BOOLEAN_TYPE: out.writeBoolean((Boolean)value); return;
			case Codes.BYTE_TYPE: out.writeByte((Byte)value); return;
			case Codes.CHAR_TYPE: out.writeChar((Character)value); return;
			case Codes.DATETIME_TYPE: out.writeLong( ((Date)value).getTime() ); return; 
			case Codes.DOUBLE_TYPE: out.writeDouble((Double)value); return;
			case Codes.FLOAT_TYPE: out.writeFloat((Float)value); return;
			case Codes.INTEGER_TYPE: out.writeInt((Integer)value); return;
			case Codes.IRI_TYPE: writeString(((IRI)value).toString()); return;
			case Codes.LIST_TYPE: writeList((List)value); return;
			case Codes.LONG_TYPE: out.writeLong((Long)value); return;
			case Codes.MAP_TYPE: writeMap((Map<String, Object>)value); return;
			case Codes.SHORT_TYPE: out.writeShort((Short)value); return;
			case Codes.STRING_TYPE: writeString((String)value); return;
			case Codes.BYTE_ARRAY_TYPE: writeByteArray((byte[])value); return;
			default:
//				writeCommand((Command)value);
				throw new IOException("Unknown type code [" + code + "]");
		} 
	}
*/	
	
/*	
	public void write(Object obj) throws IOException{
		
		if(obj == null){
			out.writeInt(BMQConstants.NULL);
			return;
		}
		
		Class<?> clazz = obj.getClass();
		
		if(clazz == Integer.class){
			out.writeInt(BMQConstants.INTEGER);
			out.writeInt((Integer)obj);
		}
		else if(clazz == Long.class){
			out.writeInt(BMQConstants.LONG);
			out.writeLong((Long)obj);
		}
		else if(clazz == String.class){
			out.writeInt(BMQConstants.STRING);
			byte[] buf = StringUtils.asBytesUTF((String)obj);
			out.writeInt(buf.length);
			out.write(buf);
//			out.writeUTF((String)obj);
		}
		else if(clazz == ByteSequence.class){
			out.writeInt(BMQConstants.BYTE_SEQUENCE);
			byte[] bytes = ((ByteSequence)obj).asByteArray();
			out.writeInt(bytes.length);
			out.write(bytes);
		}
		else if(clazz == ArrayList.class || 
						clazz == LinkedList.class){
			List<?> list = (List<?>)obj;
			out.writeInt(BMQConstants.LIST);
			out.writeInt(list.size());
			for(Object elem : list)	write(elem);
		}
		else if(clazz == Destination.class){
			Destination destination = (Destination)obj;
			out.writeInt(BMQConstants.DESTINATION);
			out.writeInt(destination.type().ordinal());
			out.writeInt(destination.iriList().size());
			for(DestinationPoint dp : destination.iriList()){
				write(dp.domain);
				write(dp.addressee);
			}
		}
		else if(clazz == Payload.class){
			Payload payload = (Payload)obj;
			out.writeInt(BMQConstants.PAYLOAD);
			out.writeInt(payload.type.ordinal());
			write(payload.bytes);
		}
		else if(clazz == MQMessage.class){
			MQMessage msg = (MQMessage)obj;
			out.writeInt(BMQConstants.MESSAGE);
			write(msg.id);
			write(msg.parameters);
			out.writeInt(msg.messageType.ordinal());
			write(msg.messageID);
			write(msg.correlationID);
			write(msg.destination);
			write(msg.replyTo);
			write(msg.path);
			write(msg.payload);
		}
		else if(clazz == Command.class){
			out.writeInt(BMQConstants.COMMAND);
			
			Command cmd = (Command)obj;
			write(cmd.id);
			write(cmd.code);
			write(cmd.parameters);
		}
		else if(clazz == Parameters.class){
			out.writeInt(BMQConstants.PROPERTIES);
			
			Parameters params = (Parameters)obj;
			write(params.getMap());
		}
		else if(clazz == HashMap.class){
			out.writeInt(BMQConstants.MAP);
			
			@SuppressWarnings("unchecked")
			Map<Object, Object> map = (Map<Object, Object>)obj;
			Collection<Entry<Object, Object>> entries = map.entrySet();
			out.writeInt(entries.size());
			for(Entry<Object, Object> entry : entries){
				write(entry.getKey());
				write(entry.getValue());
			}
		}
		else if(clazz == IRI.class){
			out.writeInt(BMQConstants.IRI);
			
			IRI iri = (IRI)obj;
			write(iri.toString());
		}
		else{
			throw new InvalidClassException(clazz.getName(), "Class not supported by protocol");
		}
		
	}
*/	
	public void flush() throws IOException{
		out.flush();
	}

}
