package ru.magnetosoft.esb.mq.format.binary;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static ru.magnetosoft.esb.mq.utils.Parameters.KeyValue.keyvalue;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import org.junit.Test;

import ru.magnetosoft.esb.mq.command.Command;
import ru.magnetosoft.esb.mq.command.CommandFactory;
import ru.magnetosoft.esb.mq.command.Command.Codes;
import ru.magnetosoft.esb.mq.utils.IRI;
import ru.magnetosoft.esb.mq.utils.Parameters;

public class CoderDecoderTest
{
	
	@Test
	public void testEncoding() throws Exception{
		
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy:MM:dd");
		
		Command cmd = CommandFactory.newInstance().newCommand(Codes.BROKER_INFO);
		cmd.set("testNull");
		cmd.set("testString", "alice.broker");
		cmd.set("testBoolean", true);
		cmd.set("testShort", 1);
		cmd.set("testInt", 2);
		cmd.set("testLong", 3);
		cmd.set("testFloat", 1.0f);
		cmd.set("testDouble", 1.0);
		cmd.set("testChar", 'q');
		cmd.set("testDatetime", sdf.parse("2009:03:07"));
		cmd.set("testIRI", IRI.create("mmqp://broker.esb/agent"));
		cmd.set("testList", Arrays.asList(new Integer[] {1, 2, 3, 4, 5}));
		cmd.set("testMap", Parameters.fromKeyValues(keyvalue("key1", "alice"), keyvalue("key2", 12)).getMap());
//		cmd.set("testByteArray", new byte[] {5, 4, 3, 2, 1});
		
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		BMQEncoder encoder = new BMQEncoder( new DataOutputStream(baos) );
		encoder.writeCommand(cmd);
		

		
		BMQDecoder decoder = new BMQDecoder(new DataInputStream(new ByteArrayInputStream(baos.toByteArray())));
		Command cmdOut = decoder.readCommand();
		
		assertEquals(Codes.BROKER_INFO, cmdOut.code);
		assertEquals(cmd.id, cmdOut.id);
		assertTrue(cmdOut.has("testNull"));
		assertNull(cmdOut.get("testNull"));
		assertEquals("alice.broker", cmdOut.get("testString"));
		assertEquals(true, cmdOut.get("testBoolean"));
		assertEquals(1, cmdOut.get("testShort"));
		assertEquals(2, cmdOut.get("testInt"));
		assertEquals(3, cmdOut.get("testLong"));
		assertEquals(1.0f, cmdOut.get("testFloat"));
		assertEquals(1.0, cmdOut.get("testDouble"));
		assertEquals('q', cmdOut.get("testChar"));
		assertEquals(sdf.parse("2009:03:07"), cmdOut.get("testDatetime"));
		assertEquals(IRI.create("mmqp://broker.esb/agent"), cmdOut.get("testIRI"));
		List<Integer> list = cmdOut.get("testList");
		assertEquals(5, list.size());
		assertEquals(3, (int)list.get(2));
		Parameters params = Parameters.fromMap( (Map<String, Object>)cmdOut.get("testMap") );
		assertEquals(2, params.count());
		assertEquals("alice", params.get("key1"));
		assertEquals(12, params.get("key2"));
		
	}
	
	
}
