module fact_tools;

private import tango.io.Stdout;
private import tango.stdc.string;

public void print_list_triple (uint* list_iterator)
{
	byte *triple;
	Stdout.format("list_iterator {:X4}", list_iterator).newline;
	if(list_iterator !is null)
	{
		uint next_element0 = 0xFF;
		while(next_element0 > 0)
		{
			triple = cast(byte*) *list_iterator;
			Stdout.format("triple {:X4}", triple).newline;
			print_triple(triple);

			next_element0 = *(list_iterator + 1);
			list_iterator = cast(uint*) next_element0;
		}
	}
	
}

public void print_triple(byte* triple)
{
	if (triple is null) return;
	
	char* s = cast(char*) triple + 6;
	
	char* p = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1);
	
	char* o = cast(char*) (triple + 6 + (*(triple + 0) << 8) + *(triple + 1) + 1 + (*(triple + 2) << 8) + *(triple + 3) + 1);

	Stdout.format("triple: <{}><{}><{}>", toStringz(s), toStringz(p), toStringz(o)).newline;
}

private char[] toStringz(char* s)
{
	return s ? s[0 .. strlen(s)] : cast(char[]) null;
}
