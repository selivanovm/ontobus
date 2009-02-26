import HashNeighbour;
import KeysValueEntry;
import Triple;
import Hash;
import ListTriple;

class HashMap
{
	private uint max_count_elements = 100000;

	private HashNeighbour[] entries;

	this()
	{
		entries = new HashNeighbour[max_count_elements];
	}

	public void put(char[] key1, char[] key2, ListTriple value)
	{
		//	                    Stdout.format("*** put in hash map key[{}]", key).newline;
		//		        uint hash0 = (getHash (key1 ~ key2) & 0x7FFFFFFF) % max_count_elements;
		uint hash = (getHash(key1, key2) & 0x7FFFFFFF) % max_count_elements;

		//			if (hash0 != hash)
		//			    Stdout.format("###############  hash0[{}] != hash1{}]", hash0, hash).newline;

		HashNeighbour nbh = entries[hash];

		if(nbh is null)
		{
			nbh = new HashNeighbour();
			entries[hash] = nbh;
		}

		KeysValueEntry entry = new KeysValueEntry();
		//			entry.set_key (key1, key2);
		entry.key1 = key1;
		entry.key2 = key2;
		entry.value = value;

		//	if (nbh.size > 0)
		//	    Stdout.format("*** COLLIZION on key[{}]", key).newline;

		nbh.add(entry);

	}

	public void put(char[] key1, char[] key2, char[] key3, ListTriple value)
	{
		//	                    Stdout.format("*** put in hash map key[{}]", key).newline;
		//		        uint hash0 = (getHash (key1 ~ key2) & 0x7FFFFFFF) % max_count_elements;
		uint
				hash = (getHash(key1, key2, key3) & 0x7FFFFFFF) % max_count_elements;

		//			if (hash0 != hash)
		//			    Stdout.format("###############  hash0[{}] != hash1{}]", hash0, hash).newline;

		HashNeighbour nbh = entries[hash];

		if(nbh is null)
		{
			nbh = new HashNeighbour();
			entries[hash] = nbh;
		}

		KeysValueEntry entry = new KeysValueEntry();
		//			entry.set_key (key1, key2, key3);
		entry.key1 = key1;
		entry.key2 = key2;
		entry.key3 = key3;
		entry.value = value;

		//	if (nbh.size > 0)
		//	    Stdout.format("*** COLLIZION on key[{}]", key).newline;

		nbh.add(entry);

	}

	public void put(char[] key, ListTriple value)
	{
		//	                    Stdout.format("*** put in hash map key[{}]", key).newline;
		uint hash = (getHash(key) & 0x7FFFFFFF) % max_count_elements;

		HashNeighbour nbh = entries[hash];

		if(nbh is null)
		{
			nbh = new HashNeighbour();
			entries[hash] = nbh;
		}

		KeysValueEntry entry = new KeysValueEntry();
		//			entry.set_key (key);
		entry.key1 = key;
		entry.value = value;

		//	if (nbh.size > 0)
		//	    Stdout.format("*** COLLIZION on key[{}]", key).newline;

		nbh.add(entry);

	}

	public ListTriple get(char[] key)
	{
		uint hash = (getHash(key) & 0x7FFFFFFF) % max_count_elements;
		HashNeighbour nbh = entries[hash];

		if(nbh is null || nbh.size == 0)
			return null;

		for(byte i = 0; i < nbh.size; i++)
		{
			if(nbh.hashNeighbours[i].key1 == key)
				return nbh.hashNeighbours[i].value;
		}

		return null;
	}

	public ListTriple get(char[] key1, char[] key2)
	{
		uint hash = (getHash(key1, key2) & 0x7FFFFFFF) % max_count_elements;
		HashNeighbour nbh = entries[hash];

		if(nbh is null || nbh.size == 0)
			return null;

		for(byte i = 0; i < nbh.size; i++)
		{
			if(nbh.hashNeighbours[i].key1 == key1 && nbh.hashNeighbours[i].key2 == key2)
				return nbh.hashNeighbours[i].value;
		}

		return null;
	}

	public ListTriple get(char[] key1, char[] key2, char[] key3)
	{
		uint
				hash = (getHash(key1, key2, key3) & 0x7FFFFFFF) % max_count_elements;
		HashNeighbour nbh = entries[hash];

		if(nbh is null || nbh.size == 0)
			return null;

		for(byte i = 0; i < nbh.size; i++)
		{
			if(nbh.hashNeighbours[i].key1 == key1 && nbh.hashNeighbours[i].key2 == key2 && nbh.hashNeighbours[i].key3 == key3)
				return nbh.hashNeighbours[i].value;
		}

		return null;
	}
}
