package ru.magnetosoft.esb.mq.format;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public interface Format 
{
	void marshal(Object obj, OutputStream out) throws IOException;
	Object unmarshal(InputStream in) throws IOException;
}
