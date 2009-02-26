import Triple;

class ListElement
{
	public ListElement next_element = null;

	Triple content;

	public ListElement getNext()
	{
		return next_element;
	}

	public void setNext(ListElement element)
	{
		next_element = element;
	}

}

class ListTriple
{
	public uint size = 0;

	public ListElement first_element = null;
	public ListElement end_element = null;

	private ListElement first_element1 = null;
	private ListElement end_element1 = null;

	private ListElement first_element2 = null;
	private ListElement end_element2 = null;

	private ListElement first_element3 = null;
	private ListElement end_element3 = null;

	this()
	{
	}

	public void add(Triple element)
	{
		ListElement new_element = new ListElement();

		new_element.content = element;
		
		if(first_element is null)
			first_element = new_element;

		if(end_element !is null)
			end_element.setNext(new_element);

		end_element = new_element;

		size++;
	}

}