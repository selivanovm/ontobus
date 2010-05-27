module trioplax.memory.Hash;

//private import tango.io.Stdout;

public uint getHash(char[] val1, char[] val2, char[] val3)
{
	uint hash = 0;

	if(val1 !is null)
	{
		for(int i = 0; i < val1.length; i++)
		{
			hash = val1[i] + (hash << 6) + (hash << 16) - hash;
			//		    Stdout.format("val1={:X2}, {:X4}", val1[i], hash).newline;
		}
	}

	if(val2 !is null)
	{
		for(int i = 0; i < val2.length; i++)
		{
			hash = val2[i] + (hash << 6) + (hash << 16) - hash;
			//		    Stdout.format("val2={:X2}, {:X4}", val2[i], hash).newline;
		}
	}

	if(val3 !is null)
	{
		for(int i = 0; i < val3.length; i++)
		{
			hash = val3[i] + (hash << 6) + (hash << 16) - hash;
			//		    Stdout.format("val3={:X2}, {:X4}", val3[i], hash).newline;
		}
	}

	return hash;
}

public uint getHash(char* val1, char* val2, char* val3)
{
	uint hash = 0;

	if(val1 !is null)
	{
		while(*val1 != 0)
		{
			hash = *cast(ubyte*) val1 + (hash << 6) + (hash << 16) - hash;
			//		    Stdout.format("! val1={:X2}, {:X4}", *val1, hash).newline;
			val1++;
		}
	}

	if(val2 !is null)
	{
		while(*val2 != 0)
		{
			hash = *cast(ubyte*) val2 + (hash << 6) + (hash << 16) - hash;
			//		    Stdout.format("! val1={:X2}, {:X4}", *val2, hash).newline;
			val2++;
		}
	}

	if(val3 !is null)
	{
		while(*val3 != 0)
		{
			hash = *cast(ubyte*) val3 + (hash << 6) + (hash << 16) - hash;
			//		    Stdout.format("! val1={:X2}, {:X4}", *val3, hash).newline;
			val3++;
		}
	}

	return hash;
}
