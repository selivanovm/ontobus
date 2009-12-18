/**
 * Copyright (c) 2006-2009, Magnetosoft, LLC
 * All rights reserved.
 *
 * Licensed under the Magnetosoft License. You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.magnetosoft.ru/LICENSE
 * 
 */

package ru.magnetosoft.magnet.messaging;

import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;

public class TripleUtils {

	private MessageParser messageParser = null;

	public String getDataTripleObjectFromReply(List<String> reply) {
		if (reply.size() == 1) {
			List<String> resultTriples = getMessageParser().split(reply.get(0));
			if (resultTriples.size() > 0) {
				Triple triple = TripleUtils.getTripleFromLine(resultTriples.get(0));
				return triple.getObj();
			}
		}
		return "";
	}
	
	public List<String> getDataFromReply(String reply) {
		List<String> result = new ArrayList<String>();
		List<String> triplesLines = getMessageParser().split(reply);
		for (String tripleLine : triplesLines) {
			Triple triple = TripleUtils.getTripleFromLine(tripleLine);
			if (triple.getPred().equals(Predicates.RESULT_DATA)) {
				result.add(triple.getObj());
			}
		}
		return result;
	}

	public String getStatusFromReply(String reply) {
		List<String> triplesLines = getMessageParser().split(reply);
		for (String tripleLine : triplesLines) {
			Triple triple = TripleUtils.getTripleFromLine(tripleLine);
			if (triple.getPred().equals(Predicates.RESULT_STATE)) {
				return triple.getObj();
			}
		}
		return null;
	}
	
	public static Triple getTripleFromLine(String triple) {
		if (triple != null) {
			String line = triple.trim();
			int i1 = line.indexOf(">");
			if (i1 > -1) {
				String subj = line.substring(1, i1);
				int i2 = line.indexOf(">", i1 + 1);
				if (i2 > -1) {
					int i3 = line.indexOf("<", i1);
					String pred = line.substring(i3 + 1, i2);
					String obj_token = line.substring(i2 + 1, line.length()).trim();
					String obj = obj_token.substring(0, obj_token.length() - 1)
						.trim();
					int mod = -1;
					if (obj_token.startsWith("<")) {
						mod = TripleModifier.Subject.ordinal();
					} else if (obj_token.startsWith("{")) {
						mod = TripleModifier.TripleSet.ordinal();
					} else {
						mod = TripleModifier.Literal.ordinal();
					}
					return new Triple(0, subj, pred, obj.substring(1, obj.length() - 1), mod);
				}
			}
		}
		return null;
	}
	
	public static <T> boolean listEqualityCheck(List<T> s1, List<T> s2) {
		if (s1.size() != s2.size())
			return false;
		else {
			
			Object[] ss1 = s1.toArray();
			Arrays.sort(ss1);
			
			Object[] ss2 = s2.toArray();
			Arrays.sort(ss2);
			
			for (int i = 0; i < ss1.length; i++) {
				if (!ss1[i].equals(ss2[i])) {
					return false;
				}
			}
		}
		return true;
	}

	public MessageParser getMessageParser() {
		if (messageParser == null) {
			messageParser = new MessageParser();
		}
		return messageParser;
	}

}
