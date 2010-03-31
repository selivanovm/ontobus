package ru.magnetosoft.em2onto;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import java.util.ArrayList;
import javax.xml.namespace.QName;

import ru.magnetosoft.bigarch.wsclient.bl.documentservice.AccessDeniedException_Exception;
import ru.magnetosoft.bigarch.wsclient.bl.documentservice.BigArchiveServerException_Exception;
import ru.magnetosoft.bigarch.wsclient.bl.documentservice.DocumentEndpoint;
import ru.magnetosoft.bigarch.wsclient.bl.documentservice.DocumentService;
import ru.magnetosoft.bigarch.wsclient.bl.documentservice.DocumentType;
import ru.magnetosoft.bigarch.wsclient.bl.documentservice.DocumentTemplateType;
import ru.magnetosoft.bigarch.wsclient.bl.documentservice.JaxbObjectType;

public class DocumentUtil {

	public static final QName DOCUMENT_QNAME = new QName(
			"http://documents.bigarchive.magnetosoft.ru/", "DocumentService");

	private static DocumentEndpoint documentService;

	private static DocumentService service = null;

	private static DocumentUtil instance;

	private DocumentUtil() {
	}

	public static DocumentUtil getInstance() {
		if (instance == null) {
			instance = new DocumentUtil();
		}
		return instance;
	}

	public DocumentType getDocumentById(String url, String id, String ticket) throws MalformedURLException, AccessDeniedException_Exception, BigArchiveServerException_Exception {
		service = new DocumentService(new URL(url), DOCUMENT_QNAME);
		documentService = service.getDocumentServiceEndpointPort();

		DocumentType document = documentService.getDocument(ticket, id);
		
		return document;
	}

	public List<String> listDocuments(String url, String ticket) throws MalformedURLException, AccessDeniedException_Exception, BigArchiveServerException_Exception {
		List<String> result = new ArrayList<String>(80000);
		result.addAll(listDocs(url, ticket, JaxbObjectType.DOCUMENT));
		result.addAll(listDocs(url, ticket, JaxbObjectType.DICTIONARY));
		result.addAll(listDocs(url, ticket, JaxbObjectType.ORGANIZATION));
		return result;
	}
	
	private List<String> listDocs(String url, String ticket, JaxbObjectType jot) throws MalformedURLException, AccessDeniedException_Exception, BigArchiveServerException_Exception {

		service = new DocumentService(new URL(url), DOCUMENT_QNAME);
		documentService = service.getDocumentServiceEndpointPort();

		List<String> result = new ArrayList<String>(10000);

		int docsCount = documentService.countDocuments(jot);
		
		int from = 0;
		int quantity = 5000;

		StringBuilder sb = new StringBuilder(10000);

		int i1 = 0;
		int i2 = 0;
		
			
		int i3 = 0;
		int i4 = 0;
			
		int i5 = 0;
		int i6 = 0;


		List<String> documents = new ArrayList<String>(1000);

		while (from < docsCount) {
			documents.clear();
			documents.addAll(documentService.pageDocuments(jot, from, quantity));
			//System.out.println("!");
		    for (String document : documents) {


			    //    System.out.println(String.format("%s \n\n", document));

			i1 = document.lastIndexOf("<id>");
			i2 = document.lastIndexOf("</id>");
			
			
			i3 = document.lastIndexOf("<authorId>");
			i4 = document.lastIndexOf("</authorId>");

			i5 = document.lastIndexOf("<typeId>");
			i6 = document.lastIndexOf("</typeId>");

			//			String ss = String.format("%s:%s:%s", document.substring(i1 + 4, i2), document.substring(i3 + 10, i4), document.substring(i5 + 8, i6));
			copyToStringBuilder(sb, document, i1 + 4, i2);
			sb.append(":");
			copyToStringBuilder(sb, document, i3 + 10, i4);
			sb.append(":");
			copyToStringBuilder(sb, document, i5 + 8, i6);
			//			System.out.println(ss);

			//				    DocumentType dt = documentService.getDocument(ticket, document);
			result.add(sb.toString());
			sb.delete(0, sb.length());
			
		    }
		    from += quantity;
		    System.out.println(String.format("get %s from %s", from, docsCount));
		    //		    if(from == 15000)
		    //    break;
		}		
		return result;
	}
	
	
	public List<DocumentTemplateType> listDocumentTypes(String url, String ticket) throws MalformedURLException, AccessDeniedException_Exception, BigArchiveServerException_Exception {
		List<DocumentTemplateType> result = new ArrayList();
		result.addAll(listTemplates(url, ticket, JaxbObjectType.DOCUMENT));
		result.addAll(listTemplates(url, ticket, JaxbObjectType.DICTIONARY));
		result.addAll(listTemplates(url, ticket, JaxbObjectType.ORGANIZATION));
		return result;
	}

	private List<DocumentTemplateType> listTemplates(String url, String ticket, JaxbObjectType jot) throws MalformedURLException, AccessDeniedException_Exception, BigArchiveServerException_Exception {
		service = new DocumentService(new URL(url), DOCUMENT_QNAME);
		documentService = service.getDocumentServiceEndpointPort();
		return documentService.getDocumentTemplates(ticket, jot, false, false);
	}

	private void copyToStringBuilder(StringBuilder sb, String src, int from, int to) {
		for(int i = from; i < to; i++) {
			sb.append(src.charAt(i));
		}
	}
	
}
