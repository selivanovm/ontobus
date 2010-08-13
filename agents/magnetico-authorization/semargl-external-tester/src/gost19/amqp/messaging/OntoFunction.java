/**
 * Copyright (c) 2006-2009, Magnetosoft, LLC
 * All rights reserved.
 *
 * Licensed under the Magnetosoft License. You may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.magnetosoft.ru/LICENSE
 * 
 * file: OntoFunction.java
 */

package gost19.amqp.messaging;

import java.util.List;

public class OntoFunction {

    private Triple command = null;
    private List<Triple> arguments = null;
    private String replyTo = null;

    public OntoFunction(Triple command, List<Triple> arguments) {
	super();
	this.setCommand(command);
	this.setArguments(arguments);
    }
    
    @Override
    public boolean equals(Object other) {
	if (other instanceof OntoFunction) {
	    OntoFunction of = (OntoFunction) other;
	    if (!this.getCommand().equals(of.getCommand()))
		return false;
	    else if (this.getArguments().size() != of.getArguments().size())
		return false;
	    else if (!TripleUtils
		     .listEqualityCheck(this.getArguments(), of.getArguments()))
		return false;
	} else {
	    return false;
	}
	return true;
    }
    
    @Override
    public String toString() {
	String args = "";
	for (Triple tr : getArguments()) {
	    args += String.format("%s\n", tr.toString());
	}
	return (String.format("OntoFunction: command = %s, replyTo = %s, arguments = [ \n%s ]", command, replyTo, args));
    }
    
    @Override
    public int hashCode() {                                                                                                                          
	int result = 17;                                                                                                                                  
	result = 31 * result + getCommand().hashCode();                                                                                                                 
	for (Triple tr : getArguments()) {
	    result = 31 * result + tr.hashCode();
	}
	return result;                                                                                                                                           
    }
    
    public void setCommand(Triple command) {
	this.command = command;
    }
    
    public Triple getCommand() {
	return command;
    }
    
    public void setArguments(List<Triple> arguments) {
	this.arguments = arguments;
    }
    
    public List<Triple> getArguments() {
	return arguments;
    }

    public void setReplyTo(String replyTo) {
	this.replyTo = replyTo;
    }

    public String getReplyTo() {
	return this.replyTo;
    }

}
