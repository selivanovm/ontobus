package org.dreamcatch.jtoolbox.resources;

import java.io.InputStream;

import org.dreamcatch.jtoolbox.resources.ClassPathResource;
import org.dreamcatch.jtoolbox.resources.Resource;
import org.junit.Test;
import static org.junit.Assert.*;



public class ClassPathResourceTest
{
	
	@Test
	public void testResourceExistance() throws Exception{
		
		Resource rc = new ClassPathResource("somefile.txt");
		assertTrue(rc.exists());
		
		rc = new ClassPathResource("notexistingfile.txt");
		assertFalse(rc.exists());
	}
	
	@Test
	public void testInputStream() throws Exception{
		
		Resource rc = new ClassPathResource("somefile.txt");
		InputStream is = rc.openStream();
		
		byte[] bytes = new byte[is.available()];
		is.read(bytes);
		assertEquals("hello", new String(bytes, "utf-8"));
		
	}
	
}
