package ru.magnetosoft.esb.mq.format.binary;

public interface BMQConstants
{
	int NULL = 				0;
	int INTEGER = 		1;
	int SHORT = 			2;
	int LONG = 				3;
	int FLOAT = 			4;
	int DOUBLE = 			5;
	int BOOLEAN = 		6;
	int BYTE = 				7;
	int CHAR = 				8;
	int STRING = 			9;
	int DATETIME =		10;
	int IRI = 				11;

	int BYTE_SEQUENCE = 	100;
	int DESTINATION = 					101;
	int COMMAND =								102;
	int MESSAGE = 							103;
	int PAYLOAD = 							104;
	int PROPERTIES =						105;
	
	int LIST = 								201;
	int MAP =								202;

}
