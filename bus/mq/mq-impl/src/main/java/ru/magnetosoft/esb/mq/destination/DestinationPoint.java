/**
 * 
 */
package ru.magnetosoft.esb.mq.destination;


public class DestinationPoint
{
	public DestinationPoint(String domain, String addressee){
		this.domain = domain;
		this.addressee = addressee;
	}
	
	public String domain;
	public String addressee;
	
	
//	public URI asURI(){
//		URI uri = URI.create( String.format("mmqp://", domain, addressee) );
////		uri.get
//	}
}