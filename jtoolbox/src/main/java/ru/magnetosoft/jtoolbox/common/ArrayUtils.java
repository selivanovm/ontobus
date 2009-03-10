package ru.magnetosoft.jtoolbox.common;

public class ArrayUtils
{
	
	public static <T> boolean contains(T[] array, T elem){
		for(int i = 0; i < array.length; i++)
			if(array[i].equals(elem)) return true;
		return false;
	}
	
	
}
