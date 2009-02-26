public uint getHash(char[] val)
{
	uint hash = 0;

	for(int i = 0; i < val.length; i++)
	{
		hash = val[i] + (hash << 6) + (hash << 16) - hash;
	}

	//    Stdout.format("hash={}", hash).newline;

	return hash;
}

public uint getHash(char[] val1, char[] val2)
{
	uint hash = 0;

	for(int i = 0; i < val1.length; i++)
	{
		hash = val1[i] + (hash << 6) + (hash << 16) - hash;
	}

	for(int i = 0; i < val2.length; i++)
	{
		hash = val2[i] + (hash << 6) + (hash << 16) - hash;
	}

	//    Stdout.format("hash={}", hash).newline;

	return hash;
}

public uint getHash(char[] val1, char[] val2, char[] val3)
{
	uint hash = 0;

	for(int i = 0; i < val1.length; i++)
	{
		hash = val1[i] + (hash << 6) + (hash << 16) - hash;
	}

	for(int i = 0; i < val2.length; i++)
	{
		hash = val2[i] + (hash << 6) + (hash << 16) - hash;
	}

	for(int i = 0; i < val3.length; i++)
	{
		hash = val3[i] + (hash << 6) + (hash << 16) - hash;
	}
	//    Stdout.format("hash={}", hash).newline;

	return hash;
}