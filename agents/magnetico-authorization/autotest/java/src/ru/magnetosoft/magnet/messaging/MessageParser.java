/**
 * Copyright (c) 2006-2009, Magnetosoft, LLC
 * All rights reserved.
 *
 * Licensed under the Magnetosoft License. You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.magnetosoft.ru/LICENSE
 * 
 * file: MessageParser.java
 */

package ru.magnetosoft.magnet.messaging;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class MessageParser {
    
    private boolean sp1;
    private int sp2;
    private char prev_delimiter = ' ';
    
    public MessageParser() {
    }
    
    public List<OntoFunction> functionsFromMessage(String message) {
	
	//	System.out.println("Получил сообщение для парсинга [ " + message + " ]");
	
	HashMap<String, OntoFunction> functions = new HashMap<String, OntoFunction>();
	HashMap<String, List<Triple>> argumentsMap = new HashMap<String, List<Triple>>();
	
	List<String> lines = split(message);
	
	for (String line : lines) {
	    
	    Triple triple = TripleUtils.getTripleFromLine(line);
	    
	    if (triple.getPred().equals(Predicates.SUBJECT)) { 
		if (triple.getMod() == TripleModifier.TripleSet.ordinal()) {
		    
		    for (String s : split(triple.getObj())) {
			if (argumentsMap.get(triple.getSubj()) == null) {
			    argumentsMap.put(triple.getSubj(), new ArrayList<Triple>());
			}
			argumentsMap.get(triple.getSubj()).add(new Triple(0, triple.getSubj(), Predicates.FUNCTION_ARGUMENT, s,
									  TripleModifier.TripleSet.ordinal()));
		    }
		    
		    if (functions.get(triple.getSubj()) == null) {
			functions.put(triple.getSubj(), new OntoFunction(triple, new ArrayList<Triple>()));
		    }
		    
		} else if (functions.get(triple.getSubj()) == null)
		    functions.put(triple.getSubj(), new OntoFunction(triple, new ArrayList<Triple>()));
	    } else if (triple.getPred().equals(Predicates.FUNCTION_ARGUMENT)) {
		if (argumentsMap.get(triple.getSubj()) == null) {
		    argumentsMap.put(triple.getSubj(), new ArrayList<Triple>());
		}
		argumentsMap.get(triple.getSubj()).add(triple);
	    } else if (triple.getPred().equals(Predicates.REPLY_TO)) {
		if (functions.get(triple.getSubj()) == null) {
		    functions.put(triple.getSubj(), new OntoFunction(triple, new ArrayList<Triple>()));
		}
		functions.get(triple.getSubj()).setReplyTo(triple.getObj());
	    }
	}
	
	ArrayList<OntoFunction> result = new ArrayList<OntoFunction>();
	
	for (String key : argumentsMap.keySet()) {
	    functions.get(key).getArguments().addAll(argumentsMap.get(key));
	    result.add(functions.get(key));
	}
	
	//	System.out.println("Созданы объекты OntoFunction [ " + result.toString() + " ]");
	return result;
    }

    public Triple getArgumentByPredicate(List<Triple> args, String argName) {
	Triple result = null;
	for (Triple triple : args) {
	    if (triple.getPred().equals(argName)) {
		return triple;
	    }
	}
	return result;
    }
    
    public List<String> split(String tripletsLine) {
	List<String> result = new ArrayList<String>();
	
	if (tripletsLine != null && tripletsLine.trim().length() > 0) {
	    ArrayList<Integer> indexes = new ArrayList<Integer>();
	    
	    boolean isBeetweenTokens = false;
	    int delim_number = 1;
	    boolean isProcessNeeded;
	    
	    for (int i = 0; i < tripletsLine.length(); i++) {
		char c = tripletsLine.charAt(i);
		if (c != ' ') { // если пробел, пох
		    switch (delim_number) {
		    case 0:
			isProcessNeeded = c == '<';
			break;
		    case 1:
			isProcessNeeded = c == '>';
			break;
		    case 2:
			isProcessNeeded = c == '<';
			break;
		    case 3:
			isProcessNeeded = c == '>';
			break;
		    case 4:
			isProcessNeeded = (c == '"' || c == '<' || c == '{');
			break;
		    case 5:
			switch (prev_delimiter) {
			case '"':
			    isProcessNeeded = (c == '"');
			    break;
			case '<':
			    isProcessNeeded = (c == '>');
			    break;
			case '{':
			    isProcessNeeded = (c == '}');
			    break;
			default:
			    isProcessNeeded = false;
			}
			break;
		    case 6:
			isProcessNeeded = c == '.';
			break;
		    default:
			isProcessNeeded = false;
		    }
		    if (isProcessNeeded) { // если один из разделителей, то не пох
			if (c == '.') // ага, конец триплета
			    indexes.add(i); // закидываем индекс конца триплета в
			// список
			searchParams(c, delim_number); // берем следующий tuple
			// (разделитель,
			// мы_между_тоекнами,
			// номер_разделителя) для
			// поиска
			// nextChar = search_params._1
			isBeetweenTokens = sp1;
			delim_number = sp2;
		    } else if (isBeetweenTokens) {
			if (delim_number == 0 && indexes.size() > 0) {
			    indexes.remove(indexes.size() - 1);
			    searchParams(prev_delimiter, 5);
			} else
			    searchParams(c, delim_number);
			// nextChar = search_params._1
			isBeetweenTokens = sp1;
			delim_number = sp2;
		    }
		}
	    }
	    
	    int prev = 0;
	    for (Integer i : indexes) {
		result.add(tripletsLine.substring(prev, i + 1).trim());
		prev = i + 1;
	    }
	}
	//	System.out.println(String.format("Получены токены триплетов из строки [ %s ]", result));
	return result;
    }
    
    public void searchParams(char ch, int delim_number) {
	prev_delimiter = ch;
	switch (delim_number) {
	case 0:
	    sp1 = false;
	    sp2 = 1;
	    break;
	case 1:
	    sp1 = true;
	    sp2 = 2;
	    break;
	case 2:
	    sp1 = false;
	    sp2 = 3;
	    break;
	case 3:
	    sp1 = true;
	    sp2 = 4;
	    break;
	case 4:
	    sp1 = false;
	    sp2 = 5;
	    break;
	case 5:
	    sp1 = true;
	    sp2 = 6;
	    break;
	case 6:
	    sp1 = true;
	    sp2 = 0;
	    break;
	}
    }
    
}