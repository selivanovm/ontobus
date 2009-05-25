package ru.magnetosoft.esb.mq.format.binary;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import ru.magnetosoft.esb.mq.command.Command;
import ru.magnetosoft.esb.mq.format.Format;

public class BMQFormat implements Format
{

	public void marshal(Object obj, OutputStream out) throws IOException {
		BMQEncoder writer = new BMQEncoder( new DataOutputStream(out) );
		
		Command cmd = (Command)obj;
		cmd.beforeMarshall();
		writer.writeObject(cmd);
//		cmd.afterMarshall();
		
		writer.flush();
	}

	public Object unmarshal(InputStream in) throws IOException {
		BMQDecoder reader = new BMQDecoder( new DataInputStream(in) );
		
		Command cmd = (Command)reader.readObject();
		cmd.afterUnmarshall();
		
		return cmd;
	}

}
