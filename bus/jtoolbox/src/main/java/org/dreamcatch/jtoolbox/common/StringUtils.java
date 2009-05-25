package org.dreamcatch.jtoolbox.common;

import java.io.UnsupportedEncodingException;

public class StringUtils
{
	public static byte[] asBytesUTF(String s){
		try {
			return (s == null) ? null : s.getBytes("utf-8");
		}
		catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return new byte[0];
	}
	
	public static String fromBytesUTF(byte[] data){
		try {
			return (data == null) ? null : new String(data, "utf-8");
		}
		catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return "";
	}
}
