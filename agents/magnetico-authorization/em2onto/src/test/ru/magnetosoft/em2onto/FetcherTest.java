package ru.magnetosoft.em2onto;


import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import static org.junit.Assert.*;

public class FetcherTest {

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testEscape() throws Exception {
		
		String actual = Fetcher.escape("\" \\ \n \r \t");
		String expected = "\\\" \\\\ \\n \\r \\t";
		
		assertEquals(expected, actual);
		
	}	
	
}
