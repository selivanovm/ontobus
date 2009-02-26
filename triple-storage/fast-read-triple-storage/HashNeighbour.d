import KeysValueEntry;

class HashNeighbour
{
	public KeysValueEntry[7] hashNeighbours;
	public byte size = 0;

	public void add(KeysValueEntry entry)
	{
		hashNeighbours[size] = entry;
		size++;
	}
}