package ru.magnetosoft.jtoolbox.common;

public class Pair<T, K>
{
	public T first;
	public K second;
	
	public Pair() {}
	public Pair(T item1, K item2) {
		this.first = item1;
		this.second = item2;
	}
	
//	public T key(){
//		return first;
//	}
//	
//	public K value(){
//		return second;
//	}
	
}
