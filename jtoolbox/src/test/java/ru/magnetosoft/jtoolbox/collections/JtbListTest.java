package ru.magnetosoft.jtoolbox.collections;

import static org.junit.Assert.assertEquals;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

import ru.magnetosoft.jtoolbox.common.Pair;
import ru.magnetosoft.jtoolbox.functions.Function;

public class JtbListTest
{
	
	protected Function<Pair<Integer, Integer>, Integer> sumOfInt = new Function<Pair<Integer,Integer>, Integer>(){
		public Integer apply(Pair<Integer, Integer> in) {
			return in.first + in.second;
		}
	};
	

	@Test
	public void testJtbList() throws Exception{
		
		List<String> src = new ArrayList<String>();
		src.add("Alice");
		src.add("Red Queen");
		src.add("Cheshire Cat");
		
		JtbList<String> list = JtbList.wrap( src );
		
		assertEquals("Alice", list.first());
		assertEquals("Cheshire Cat", list.last());
		
	}

	
	
	
	
}
