package ru.magnetosoft.jtoolbox.resources;

import java.io.IOException;
import java.io.InputStream;

public interface Resource
{
	boolean exists();
	InputStream openStream() throws IOException;
}
