package org.dreamcatch.jtoolbox.xml;

import java.util.ArrayList;
import java.util.List;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
 * XPathNode для reference-реализации XPath
 * 
 * @author Kodanev Yuriy
 */
public class XPathNode
{
	protected static XPath xpath = XPathFactory.newInstance().newXPath();
	protected Node node;
	
	protected XPathNode(Node node){
		this.node = node;
	}
	
//	protected XPathNode(Document doc){
//		this.node = doc.getDocumentElement();
//	}
	
	
	public XPathNode element(String expression) throws XPathExpressionException{
		Node node = (Node)xpath.evaluate(expression, this.node, XPathConstants.NODE);
		if(node == null) return null;
		return (node.getNodeType() == Node.ELEMENT_NODE) ? new XPathNode(node) : null;
	}
	
	public List<XPathNode> elementList(String expression) throws XPathExpressionException{
		List<XPathNode> result = new ArrayList<XPathNode>();
		NodeList nodelist = (NodeList)xpath.evaluate(expression, this.node, XPathConstants.NODESET);
		for(int i = 0; i < nodelist.getLength(); i++){
			Node nd = nodelist.item(i);
			if(nd.getNodeType() == Node.ELEMENT_NODE)
				result.add( new XPathNode(nd) );
		}
		return result;		
	}
	
	public String text(String expression) throws XPathExpressionException{
		return (String)xpath.evaluate(expression, this.node, XPathConstants.STRING);
	}
	
	public String text(){
		return this.node.getTextContent();
	}

	public String name(){
		return this.node.getNodeName();
	}
	
	/**
	 * Получение атрибута узла. Полагается, что тип узла ELEMENT_NODE
	 * @param name имя атрибута
	 * @return значение атрибута. null, если атрибута с таким именем не найдено
	 */
	public String attr(String name){
		return ((Element)this.node).getAttribute(name);
	}
	
	
	
	
	public static XPathNode wrap(Node node){
		return new XPathNode(node);
	}

	public static XPathNode wrap(Document doc){
		return new XPathNode(doc.getDocumentElement());
	}
	
}
