package ru.magnetosoft.jtoolbox.common;

import java.util.Properties;

public class PropertiesHelper 
{
	protected Properties props = new Properties();
	
	protected PropertiesHelper(Properties props){
		this.props = props;
	}
	
	
	
	public int getInt(String key){
		return getInt(key, 0);
	}
	
	public int getInt(String key, int defaultValue){
		String value = props.getProperty(key);
		if(value == null) return defaultValue;
		return Integer.parseInt(value);
	}
	
	public void setInt(String key, int value){
		props.setProperty(key, Integer.toString(value));
	}
	
	public String getString(String key, String defaultValue){
		String value = props.getProperty(key);
		if(value == null) return defaultValue;
		return value;
	}
	
	public void setString(String key, String value){
		props.setProperty(key, value);
	}
	
	
	
	public Properties properties(){
		return this.props;
	}
	
	public static PropertiesHelper newInstance(Properties props){
		return new PropertiesHelper(props);
	}
}
