
public char[] str_2_chararray(char* str)
{
	uint str_length = 0;
	char* tmp_ptr = str;
	while(*tmp_ptr != 0)
	{
		//			Stdout.format("@={}", *tmp_ptr).newline;
		tmp_ptr++;
	}

	str_length = tmp_ptr - str;

	char[] res = new char[str_length];

	uint i;
	for(i = 0; i < str_length; i++)
	{
		res[i] = *(str + i);
	}
	res[i] = 0;

	return res;
}
