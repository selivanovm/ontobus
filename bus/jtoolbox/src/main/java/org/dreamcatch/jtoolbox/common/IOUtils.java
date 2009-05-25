package org.dreamcatch.jtoolbox.common;

import java.io.IOException;
import java.io.InputStream;

public class IOUtils
{
	
	public static int read_bytes(InputStream in, byte[] bytes) throws IOException{
		int n = 0;
		int total = 0;
		while((n = in.read(bytes, total, bytes.length - total)) != -1) total += n;
		return total;
	}
	
	
}
