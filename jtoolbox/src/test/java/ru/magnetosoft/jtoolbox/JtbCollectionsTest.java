package ru.magnetosoft.jtoolbox;

import static org.junit.Assert.assertEquals;

import java.util.Arrays;
import java.util.List;

import org.junit.Test;

import ru.magnetosoft.jtoolbox.common.CollectionUtils;
import ru.magnetosoft.jtoolbox.common.Pair;
import ru.magnetosoft.jtoolbox.functions.Aggregate;
import ru.magnetosoft.jtoolbox.functions.Function;

public class JtbCollectionsTest
{

	
	@Test
	public void testForEach() throws Exception{
		
		List<String> src = Arrays.asList("a", "b", "c", "d", "e");
		
		final StringBuffer sb = new StringBuffer();
		
		CollectionUtils.forEach(new Function<String, Void>(){
			public Void apply(String in) {
				sb.append(in);
				return null;
			}
		}).apply(src);
		
		assertEquals("abcde", sb.toString());
	}
	
	
	@Test
	public void testAggregate() throws Exception{
		
		List<String> src = Arrays.asList("1", "2", "3", "4", "5");
		
		Aggregate<String, Integer> sum = CollectionUtils.aggregate(0, new Function<Pair<Integer, String>, Integer>(){
			public Integer apply(Pair<Integer, String> in) {
				return in.first + Integer.parseInt(in.second);
			}
		});
		
		assertEquals(new Integer(15), sum.apply(src));
	}
	
	
	@Test
	public void testFold() throws Exception{
		
		
		
		
	}
	
	
	
	
}
