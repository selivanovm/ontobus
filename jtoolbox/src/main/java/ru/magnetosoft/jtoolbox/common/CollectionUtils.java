package ru.magnetosoft.jtoolbox.common;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.magnetosoft.jtoolbox.functions.Aggregate;
import ru.magnetosoft.jtoolbox.functions.ForEach;
import ru.magnetosoft.jtoolbox.functions.Function;

/**
 * Вспомогательный класс для работы с коллекциями объектов
 * 
 * @author Kodanev Yuriy
 */
public class CollectionUtils
{
	private CollectionUtils(){}
	
	/**
	 * Создает экземпляр списка строк
	 * @return ArrayList<String>
	 */
	public static List<String> newStringList(){
		return new ArrayList<String>();
	}
	
	/**
	 * Создает экземпляр хэш-таблицы строковых пар ключ-значение
	 * @return HashMap<String, String>
	 */
	public static Map<String, String> newStringMap(){
		return new HashMap<String, String>();
	}
	
	
	
	
	
	
	
	public static <T> ForEach<T> forEach(Function<T, Void> func){
		final Function<T, Void> f = func;
		return new ForEach<T>(){
			public Void apply(Collection<T> in) {
				for(T item : in)
					f.apply(item);
				return null;
			}
		};
	}
	
	public static <T, Acc> Aggregate<T, Acc> aggregate(Acc first, Function<Pair<Acc, T>, Acc> func){
		final Acc initVal = first;
		final Function<Pair<Acc, T>, Acc> f = func;
		return new Aggregate<T, Acc>(){
			public Acc apply(Collection<T> in) {
				Acc acc = initVal;
				for(T item : in)
					acc = f.apply( new Pair<Acc, T>(acc, item) );
				return acc;
			}
		};
	}
	
	public static <T> Aggregate<T, T> fold(Function<Pair<T, T>, T> func){
		final Function<Pair<T, T>, T> f = func;
		return new Aggregate<T, T>(){
			public T apply(Collection<T> in) {
				if(in.isEmpty()) return null;
				T acc = null;
				for(T item : in){
					if(acc == null) 
						acc = item;
					else
						acc = f.apply( new Pair<T, T>(acc, item) );
				}
				return acc;
			}
		};		
	}
	
	
	
}
