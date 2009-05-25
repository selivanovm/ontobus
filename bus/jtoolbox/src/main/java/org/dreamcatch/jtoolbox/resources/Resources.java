package org.dreamcatch.jtoolbox.resources;

public class Resources
{
	private Resources(){}
	
	
	public static Resource fromFile(String path){
		return new FileResource(path);
	}
	
	public static Resource fromClasspath(String cp){
		return new ClassPathResource(cp);
	}
	
	public static Resource fromByteArray(byte[] bytes){
		return new MemResource(bytes);
	}
}
