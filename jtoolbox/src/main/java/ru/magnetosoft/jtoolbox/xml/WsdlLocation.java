package ru.magnetosoft.jtoolbox.xml;

import java.net.MalformedURLException;
import java.net.URL;

import javax.xml.namespace.QName;

public class WsdlLocation
{
	protected QName serviceName;
	protected URL wsdlUrl;
	
	
	
	public QName serviceName(){
		return this.serviceName;
	}
	
	public URL wsdlURL(){
		return this.wsdlUrl;
	}
	
	
	public static WsdlLocation create(String url, String ns, String svcname) throws MalformedURLException{
		WsdlLocation wsloc = new WsdlLocation();
		wsloc.serviceName = new QName(ns, svcname);
		wsloc.wsdlUrl = new URL(url);
		return wsloc;
	}
}
