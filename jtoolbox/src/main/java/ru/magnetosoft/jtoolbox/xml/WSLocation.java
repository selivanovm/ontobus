package ru.magnetosoft.jtoolbox.xml;

import java.net.MalformedURLException;
import java.net.URL;

import javax.xml.namespace.QName;

public class WSLocation
{
	protected QName serviceName;
	protected URL wsdlUrl;
	
	
	
	public QName serviceName(){
		return this.serviceName;
	}
	
	public URL wsdlURL(){
		return this.wsdlUrl;
	}
	
	
	public static WSLocation create(String url, String ns, String svcname) throws MalformedURLException{
		WSLocation wsloc = new WSLocation();
		wsloc.serviceName = new QName(ns, svcname);
		wsloc.wsdlUrl = new URL(url);
		return wsloc;
	}
}
