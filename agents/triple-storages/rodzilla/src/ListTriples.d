import Triple;
import std.c.stdlib;

class ListElementTriple
{
  public ListElementTriple next_element = null;

  Triple triple;

  public ListElementTriple getNext()
  {
    return next_element;
  }

  public void setNext(ListElementTriple element)
  {
    next_element = element;
  }

}

class ListTriples
{

  public uint size = 0;
  
  public ListElementTriple first_element = null;
  public ListElementTriple end_element = null;

  this()
  {
  }

  this(Triple[] triples)
  {
    foreach(triple; triples) { this.add(triple); }
  }

  public void add(Triple element)
  {

    ListElementTriple new_element = new ListElementTriple();

    new_element.triple = element;
		
    if(first_element is null)
      first_element = new_element;

    if(end_element !is null)
      end_element.setNext(new_element);

    end_element = new_element;

    size++;
  }
  
  bool containsAll(ListTriples other)
  {
    auto element = this.first_element;
    while(element !is null)
      {
	bool contains = false;
	auto other_element = other.first_element;
	while(other_element !is null)
	  {
	    if (element.triple == other_element.triple)
	      {
		contains = true;
		break;
	      }
	    other_element = other_element.next_element;
	  }
	if (!contains)
	  {
	    return false;
	  }
	element = element.next_element;
      }
    return true;
  }

}