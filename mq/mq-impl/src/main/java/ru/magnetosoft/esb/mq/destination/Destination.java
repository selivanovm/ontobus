package ru.magnetosoft.esb.mq.destination;

import java.util.ArrayList;
import java.util.List;

import ru.magnetosoft.esb.mq.utils.IRI;

public class Destination
{
	protected List<IRI> iriList = new ArrayList<IRI>();
	protected DestinationType destinationType = DestinationType.COMPOSITE;
	
	
	public Destination(){}
	public Destination(DestinationType type){
		this.destinationType = type;
	}
	public Destination(DestinationType type, List<IRI> irilist){
		this.destinationType = type;
		this.iriList = irilist;
	}
	
	
	
	public DestinationType type(){
		return this.destinationType;
	}
	
	public List<IRI> iriList(){
		return this.iriList;
	}
	
	
	public Destination addIRI(IRI dest){
		iriList.add(dest);
		return this;
	}
	
	
	public static Destination createSingle(IRI iri){//String broker, String addressee){
		return new Destination(DestinationType.SINGLE).addIRI(iri/*iri(broker, addressee)*/);
	}
	
	public static Destination createComposite(){
		return new Destination(DestinationType.COMPOSITE);
	}
	
//	public static IRI iri(String broker, String addressee){
//		return IRI.fromString( String.format("mmqp://%s/%s", broker, addressee) );
//	}
//	protected static DestinationPoint destination_point(String queueName, String addressee){
//		return new DestinationPoint(queueName, addressee);
//	}
}
