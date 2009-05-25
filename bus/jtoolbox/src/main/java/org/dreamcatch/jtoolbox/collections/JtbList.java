package org.dreamcatch.jtoolbox.collections;

import java.util.List;

import org.dreamcatch.jtoolbox.functions.Function;


/**
 * Обертка для классов, реализующих интерфейс List
 * 
 * @author Kodanev Yuriy
 *
 * @param <T>
 */
public class JtbList <T>
{
	protected List<T> _list;
	
	protected JtbList(List<T> list){
		this._list = list;
	}
	
	public T first(){
		return (_list.isEmpty()) ? null : _list.get(0);
	}
	
	public T last(){
		int sz = _list.size();
		return (sz == 0) ? null : _list.get(sz - 1);		
	}
	
	public void each(Function<T, Void> func){
		for(T item : _list)
			func.apply(item);
	}
	
		
	
	public List<T> innerList(){
		return _list;
	}
	
	
	public static <T> JtbList<T> wrap(List<T> list){
		return new JtbList<T>(list);
	}
}
