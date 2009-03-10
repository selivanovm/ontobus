package ru.magnetosoft.esb.mq.utils;


public class ByteSequence
{
	protected byte[] bytes = new byte[0];
	
	public ByteSequence() {
	}	
	public ByteSequence(byte[] bytes){
		this.bytes = bytes;
	}
	public ByteSequence(byte[] bytes, boolean deepCopy){
		this.bytes = (deepCopy) ? bytes.clone() : bytes;
	}
	
	public byte[] asByteArray(){
		return this.bytes;
	}
	
	
//	public static ByteSequence fromString(String s){
//		return new ByteSequence( StringUtils.asBytesUTF(s) );
//	}
//	
	public static ByteSequence fromBytes(byte[] data){
		return (data == null) ? new ByteSequence() : new ByteSequence(data, true);
	}
	
	public static ByteSequence wrap(byte[] data){
		return (data == null) ? new ByteSequence() : new ByteSequence(data);		
	}
	
//	@Override
//	public String toString() {
//		return StringUtils.fromBytesUTF(this.bytes);
//	}
}
