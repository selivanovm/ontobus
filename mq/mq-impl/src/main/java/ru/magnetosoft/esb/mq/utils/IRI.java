package ru.magnetosoft.esb.mq.utils;

import java.net.URI;

public class IRI
{
	protected URI uri; // ыыыы. я лентяй
	
	protected IRI(URI uri){
		this.uri = uri;
	}

	public String getHost(){
		return uri.getHost();
	}
	
	public String getPath(){
		return uri.getPath();
	}
	
	@Override
	public String toString() {
		return uri.toString();
	}
	
	public static IRI create(String s){
		return new IRI(URI.create(s));
	}
	
	@Override
	public boolean equals(Object obj) {
		IRI other = (IRI)obj;
		return uri.equals(other.uri);
	}
	
	@Override
	public int hashCode() {
		return uri.hashCode();
	}
}
