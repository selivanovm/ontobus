package ru.magnetosoft.jtoolbox.common;

public class KeyValuePair<K, V>
{
	public K key;
	public V value;

//	protected KeyValuePair(){}
	public KeyValuePair(K key, V value){
		this.key = key;
		this.value = value;
	}
	
	
//	public static <K, V> KeyValuePair<K, V> keyvalue(K key, V value){
//		KeyValuePair<K, V> kvp = new KeyValuePair<K, V>();
//		kvp.key = key;
//		kvp.value = value;
//		return kvp;
//	}
}
