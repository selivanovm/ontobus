package ru.magnetosoft.jtoolbox.xml;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.util.List;

import javax.xml.parsers.DocumentBuilderFactory;

import org.junit.Test;
import org.w3c.dom.Document;

import ru.magnetosoft.jtoolbox.resources.ClassPathResource;

public class XPathNodeTest
{
	
	@Test
	public void testParseXml() throws Exception{
		
		Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse( new ClassPathResource("/sample.xml").openStream() );
		
		XPathNode root = XPathNode.wrap(doc);
		assertTrue(root != null);
		
		List<XPathNode> nodelist = root.elementList("customers/customer");
		assertEquals(2, nodelist.size());
		
		XPathNode node = nodelist.get(0);
		assertEquals("1", node.text("cust-id"));
		assertEquals("false", node.element("cust-id").attr("encripted"));
		assertEquals("Robert", node.element("first-name").text());
		
		assertEquals("Asimov", root.text("customers/customer[2]/last-name"));
	}
	
	
	
}
