module trioplax.memory.IndexException;

enum errorCode
{
	short_order_is_full = -1,
	hash2short_is_out_of_range = -2,
	block_triple_area_is_full = -3
};

class IndexException: Exception
{
	public char[] idxName;
	public int errCode;
	public uint curLimitParam;
	public char[] message;

	this(char[] msg, char[] _idxName, int _errCode, uint _curLimitParam)
	{
		super(msg);
		message = msg;
		idxName = _idxName;
		errCode = _errCode;
		curLimitParam = _curLimitParam;
	}
}