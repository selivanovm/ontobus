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

package gost19.amqp.messaging;

public class Triple implements Comparable<Triple> {

	private int id = 0;
	private String subj = null;
	private String obj = null;
	private String pred = null;
	private int mod = 0;
	
	public Triple(int id, String subj, String pred, String obj, int mod) {
		super();
		this.setId(id);
		this.setSubj(subj);
		this.setObj(obj);
		this.setPred(pred);
		this.setMod(mod);
	}

	@Override
	public boolean equals(Object other) {
		if (other instanceof Triple) {
			Triple rdft = (Triple) other;
			if (!this.getSubj().equals(rdft.getSubj()))
				return false;
			else if (!this.getObj().equals(rdft.getObj()))
				return false;
			else if (!this.getPred().equals(rdft.getPred()))
				return false;
			else if (this.getMod() != rdft.getMod())
				return false;
		} else {
			return false;
		}
		return true;
	}

	public void populate(int id, String subj, String pred, String obj, int mod) {
		this.setId(id);
		this.setSubj(subj);
		this.setObj(obj);
		this.setPred(pred);
		this.setMod(mod);
	}

	@Override
	public String toString() {
		return String.format(
				"Triple: id = %d, subj = %s, pred = %s, obj = %s, mod = %s",
				getId(), getSubj(), getPred(), getObj(), getMod());
	}

	@Override
	public int hashCode() {
		int result = 17;
		result = 31 * result + getSubj().hashCode();
		result = 31 * result + getPred().hashCode();
		result = 31 * result + getObj().hashCode();
		result = 31 * result + getMod();
		return result;
	}

	public void setSubj(String subj) {
		this.subj = subj;
	}

	public String getSubj() {
		return subj;
	}

	public void setObj(String obj) {
		this.obj = obj;
	}

	public String getObj() {
		return obj;
	}

	public void setPred(String pred) {
		this.pred = pred;
	}

	public String getPred() {
		return pred;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}

	public void setMod(int mod) {
		this.mod = mod;
	}

	public int getMod() {
		return mod;
	}

	public int compareTo(Triple other) {
		if (this.equals(other)) {
			return 0;
		} else if (this.hashCode() > other.hashCode()){
			return 1;
		} else {
			return -1;
		}
	}

}
