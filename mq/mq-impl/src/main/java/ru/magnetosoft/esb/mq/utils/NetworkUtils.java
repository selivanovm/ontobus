package ru.magnetosoft.esb.mq.utils;

import java.net.InetSocketAddress;

public class NetworkUtils 
{
	
	public static InetSocketAddress parseSocketAddress(String s){

		String host = "";
		int port = 0;
		
		int i = s.indexOf(':');
		if(i != -1){
			host = s.substring(0, i).trim();
			port = Integer.parseInt(s.substring(i+1).trim());
		}
		else{
			host = s;
			port = 0;
		}
		
		return new InetSocketAddress(host, port);
	}
	
	public static String socketAddressToString(InetSocketAddress address){
		return String.format("%s:%d", address.getHostName(), address.getPort());
	}
	
}
