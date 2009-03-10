package ru.magnetosoft.esb.mq.payload;

import ru.magnetosoft.jtoolbox.resources.Resource;

public class Payload 
{
//	public PayloadType type;
//	public ByteSequence bytes;
	
	protected Resource rc;
	protected int size;
	
//	public Payload(PayloadType type){
//		this.type = type;
//	}
//	
//	public PayloadType type(){
//		return type;
//	}
//	
//	public ByteSequence asByteSequence(){
//		return bytes;
//	}
	public Payload(Resource rc, int sz){
		this.rc = rc;
		this.size = sz;
	}
	
	public Resource getResource(){
		return this.rc;
	}
	
	public int getSize(){
		return size;
	}
	
//	@Override
//	public String toString() {
//		return (bytes == null) ? null : bytes.toString();
//	}
}
