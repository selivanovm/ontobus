package org.dreamcatch.jtoolbox;

import static org.junit.Assert.assertEquals;

import java.util.Arrays;
import java.util.List;

import org.dreamcatch.jtoolbox.common.CollectionUtils;
import org.dreamcatch.jtoolbox.common.Pair;
import org.dreamcatch.jtoolbox.functions.Aggregate;
import org.dreamcatch.jtoolbox.functions.Function;
import org.junit.Test;


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
