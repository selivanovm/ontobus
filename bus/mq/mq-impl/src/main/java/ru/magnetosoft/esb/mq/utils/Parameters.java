package ru.magnetosoft.esb.mq.utils;

import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

public class Parameters 
{
	public static class KeyValue
	{
		public String key;
		public Object value;
		
		protected KeyValue(String key, Object value){
			this.key = key;
			this.value = value;
		}
		
		public static KeyValue keyvalue(String key, Object value){
			return new KeyValue(key, value);
		}
	}
	
	
	protected Map<String, Object> map = new HashMap<String, Object>();
	
	
//	public void setObject(String key, Object value){
//		params.put(key, new Parameter(key, value));
//	}
//	
//	
//	public Object getObject(String key){
//		Parameter entry = params.get(key);
//		return (entry == null) ? null : entry.value;
//	}
	
	
	
	public Parameters set(String key, Object value){
		map.put(key, value);//new Entry(key, value));
		return this;
	}
	
//	@SuppressWarnings("unchecked")
	public Object get(String key){
//		Entry entry = params.get(key);
//		return (entry == null) ? null : (T)entry.value;
		return map.get(key);
	}
	
	public boolean contains(String key){
		return map.containsKey(key);
	}
	
	public Map<String, Object> getMap(){
		return this.map;
	}
	
//	public Collection<Entry> entries(){
//		return params.values();
//	}
	
	public int count(){
		return this.map.size();
	}
	
	
	
	public static Parameters fromMap(Map<String, Object> map){
		Parameters out = new Parameters();
		for(Entry<String, Object> entry : map.entrySet()){
			out.map.put(entry.getKey(), entry.getValue());
		}
		return out;
	}
	
	public static Parameters fromKeyValues(KeyValue... kv){
		Parameters out = new Parameters();		
		for(int i = 0; i < kv.length; i++)
			out.map.put(kv[i].key, kv[i].value);
		return out;
	}
}
