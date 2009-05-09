
class ListElementString
{
	public ListElementString next_element = null;

	char[] content;

	public ListElementString getNext()
	{
		return next_element;
	}

	public void setNext(ListElementString element)
	{
		next_element = element;
	}

}

class ListStrings
{
	public uint size = 0;

	public ListElementString first_element = null;
	public ListElementString end_element = null;

	private ListElementString first_element1 = null;
	private ListElementString end_element1 = null;

	private ListElementString first_element2 = null;
	private ListElementString end_element2 = null;

	private ListElementString first_element3 = null;
	private ListElementString end_element3 = null;

	this()
	{
	}

	public void add(char[] element)
	{
		ListElementString new_element = new ListElementString();

		new_element.content = element;
		
		if(first_element is null)
			first_element = new_element;

		if(end_element !is null)
			end_element.setNext(new_element);

		end_element = new_element;

		size++;
	}

}