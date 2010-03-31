package ru.magnetosoft.em2onto;

import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.xml.namespace.QName;

import ru.magnetosoft.bigarch.wsclient.bl.searchservice.HashMapEntryType;
import ru.magnetosoft.bigarch.wsclient.bl.searchservice.HashMapType;
import ru.magnetosoft.bigarch.wsclient.bl.searchservice.MapDataType;
import ru.magnetosoft.bigarch.wsclient.bl.searchservice.SearchEndpoint;
import ru.magnetosoft.bigarch.wsclient.bl.searchservice.SearchRequestType;
import ru.magnetosoft.bigarch.wsclient.bl.searchservice.SearchResponseType;
import ru.magnetosoft.bigarch.wsclient.bl.searchservice.SearchResultResponseType;
import ru.magnetosoft.bigarch.wsclient.bl.searchservice.SearchResultsRequestType;
import ru.magnetosoft.bigarch.wsclient.bl.searchservice.SearchResultsResponseType;
import ru.magnetosoft.bigarch.wsclient.bl.searchservice.SearchService;

public class SearchUtil {

	private static SearchEndpoint searchPort;
	private static SearchService searchService;
	private static SearchUtil instance;

	private SearchUtil() {
	}

	public static SearchUtil getInstance() {
		if (instance == null) {
			instance = new SearchUtil();
		}
		return instance;
	}

	public ArrayList<String> getAllDocumentsOfType(QName qname, String url,
			String ticket, Map<String, String> params)
			throws Exception {
		searchService = new SearchService(new URL(url), qname);
		return searchDocsAttributive(params, ticket);
	}

	private ArrayList<String> searchDocsAttributive(
			Map<String, String> requestData, String ticketId) throws Exception {
		Map<String, String> map = new HashMap<String, String>();
		map.put("search-type", "attributive");
		map.put("search-objects", "documents");
		map.putAll(requestData);
		return searchInternal(map, ticketId);
	}

	private SearchEndpoint getSearchEndpoint() {
		if (null == searchPort) {
			searchPort = searchService.getSearchServiceEndpointPort();
		}
		return searchPort;
	}

	private ArrayList<String> searchInternal(Map<String, String> requestData,
			String ticketId) throws Exception {
		SearchEndpoint endpoint = getSearchEndpoint();
		SearchRequestType requestBase = new SearchRequestType();
		requestBase.setRequestData(createHSearchRequest(requestData));
		SearchResponseType searchResponse = endpoint.searchSync(ticketId,
				requestBase);
		if (searchResponse.isErrorOccurred())
			throw new IllegalStateException(
					"Exception occured while requesting: " + requestData);

		int offset = 0;
		int quant = 1000;

		ArrayList<String> result = new ArrayList<String>();
		SearchResultsResponseType srt;
		do {

			SearchResultsRequestType request = new SearchResultsRequestType();
			request.setFromPosition(offset);
			request.setExpectedQuantity(quant);
			request.setContextName(searchResponse.getContextName());

			srt = endpoint.getSearchResults(ticketId, request);

			if (offset == 0) {
				System.out.println("Total : " + srt.getTotalCount() + "...");
			}
			System.out.print("got " + offset + " docs of " + srt.getTotalCount() + "...");
			
			for (SearchResultResponseType sr : srt.getResults()) {
				result.add(sr.getId());
			}
			offset += quant;
		} while (srt.isInProcess() || offset < srt.getTotalCount());
		return result;
	}

	private MapDataType createHSearchRequest(Map<String, String> map) {
		MapDataType mapDataType = new MapDataType();
		HashMapType result = new HashMapType();
		mapDataType.setMap(result);
		for (Map.Entry<String, String> entry : map.entrySet()) {
			HashMapEntryType mapEntry = new HashMapEntryType();
			mapEntry.setKey(entry.getKey());
			mapEntry.setValue(entry.getValue());
			result.getContent().add(mapEntry);
		}
		return mapDataType;
	}
}
