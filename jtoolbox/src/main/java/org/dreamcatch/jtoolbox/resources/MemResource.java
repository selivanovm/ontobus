package org.dreamcatch.jtoolbox.resources;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;

public class MemResource implements Resource
{
	protected byte[] data = null;

	public MemResource(byte[] data) {
		this.data = data;
	}
	
	public boolean exists() {
		return data != null;
	}

	public InputStream openStream() throws IOException {
		return new ByteArrayInputStream(data);
	}

	public byte[] byteArray(){
		return this.data;
	}
}
