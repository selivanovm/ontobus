package ru.magnetosoft.em2onto;

import java.net.URL;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;

import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.namespace.QName;

import ru.magnetosoft.bigarch.wsclient.bl.dictionaryservice.DictionaryEndpoint;
import ru.magnetosoft.bigarch.wsclient.bl.dictionaryservice.DictionaryRecordAttributeType;
import ru.magnetosoft.bigarch.wsclient.bl.dictionaryservice.DictionaryService;
import ru.magnetosoft.bigarch.wsclient.bl.dictionaryservice.DictionaryType;
import ru.magnetosoft.objects.ObjectsHelper;

public class DictionaryUtil {

	private static final QName DICTIONARY_QNAME = new QName(
			"http://dictionaries.bigarchive.magnetosoft.ru/",
			"DictionaryService");

	private static DictionaryEndpoint dictionaryInvoker = null;

	private static DictionaryUtil instance = null;

	private DictionaryUtil() {
	}

	public static DictionaryUtil getInstance() {
		if (instance == null) {
			instance = new DictionaryUtil();
		}
		return instance;
	}

	public List<DictionaryType> listDictionaries(String ticket, String url)
			throws Exception {

		if (dictionaryInvoker == null) {
			dictionaryInvoker = new DictionaryService(new URL(url),
					DICTIONARY_QNAME).getDictionaryServiceEndpointPort();
		}

		return dictionaryInvoker.listDictionaries(ticket,
				date2xmlgregoriancalendar(null), true);
	}

	public List<DictionaryRecordAttributeType> listDictionaryAttributes(String ticket,
			String url, String dictionaryId) throws Exception {

		if (dictionaryInvoker == null) {
			dictionaryInvoker = new DictionaryService(new URL(url),
					DICTIONARY_QNAME).getDictionaryServiceEndpointPort();
		}

		return dictionaryInvoker
				.listDictionaryAttributes(ticket, ObjectsHelper
						.date2xmlgregoriancalendar(null), dictionaryId, true);

	}

	public static XMLGregorianCalendar date2xmlgregoriancalendar(Date date) {
		if (date == null) {
			return null;
		}
		GregorianCalendar gcal = new GregorianCalendar();

		try {
			DatatypeFactory df = DatatypeFactory.newInstance();
			gcal.setTime(date);
			XMLGregorianCalendar xmlCal = df.newXMLGregorianCalendar(gcal);
			return xmlCal;
		} // end try
		catch (Exception ex) {
			return null;
		} // end catch
	} // end string2xmlgregoriancalendar()

}
