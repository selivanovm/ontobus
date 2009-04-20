package org.dreamcatch.jtoolbox.resources;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

public class ClassPathResource implements Resource
{
	public URL url;

	public ClassPathResource(String classpath){
		this.url = ClassPathResource.class.getClassLoader().getResource(classpath);		
	}

	public ClassPathResource(URL url){
		this.url = url;		
	}
	
	public boolean exists() {
		return url != null;
	}

	public InputStream openStream() throws IOException {
		return url.openStream();
	}

}
