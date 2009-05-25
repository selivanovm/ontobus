package org.dreamcatch.jtoolbox.resources;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class FileResource implements Resource
{
	protected File file;

	public FileResource(String filePath){
		this.file = new File(filePath);
	}
	
	public boolean exists() {
		return this.file.exists();
	}

	public InputStream openStream() throws IOException {
		return new FileInputStream(this.file);
	}

}
