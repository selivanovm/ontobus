package ru.magnetosoft.jtoolbox.common;

import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;


public class Parameters
{
	public static class KeyValue extends KeyValuePair<String, Object>
	{
		public KeyValue(String key, Object value) {
			super(key, value);
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
	
	@SuppressWarnings("unchecked")
	public <T> T get(String key){
		return (T)map.get(key);
	}

	@SuppressWarnings("unchecked")
	public <T> T get(String key, T defaultValue){
		Object val = map.get(key);
		if(val == null) return defaultValue;
		return (T)val;
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
	
	public static Parameters newParameters(){
		return new Parameters();
	}

}
