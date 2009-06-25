import std.stdio;
import Triple;
import OntoFunction;

class ListElementOntoFunction
{
  public ListElementOntoFunction next_element = null;

  OntoFunction onto_function;

  public ListElementOntoFunction getNext()
  {
    return next_element;
  }

  public void setNext(ListElementOntoFunction element)
  {
    next_element = element;
  }

}

class ListOntoFunctions
{
  public uint size = 0;

  public ListElementOntoFunction first_element = null;
  public ListElementOntoFunction end_element = null;

  this()
  {
  }

  this(OntoFunction[] fn_array)
  {
    foreach(fn; fn_array)
      this.add(fn);
  }

  public void add(OntoFunction element)
  {
    ListElementOntoFunction new_element = new ListElementOntoFunction();

    new_element.onto_function = element;
		
    if(first_element is null)
      first_element = new_element;

    if(end_element !is null)
      end_element.setNext(new_element);

    end_element = new_element;

    size++;
  }
  
  public OntoFunction[] getAsArray()
  {
    OntoFunction[] result = new OntoFunction[this.size];
    auto element = this.first_element;
    int idx = 0;
    while(element !is null)
      {
	result[idx++] = element.onto_function;
      }

    return result;
  }

  bool containsAll(ListOntoFunctions other)
  {
    auto element = this.first_element;
    while(element !is null)
      {
	bool contains = false;
	auto other_element = other.first_element;

	while(other_element !is null)
	  {
	    if (element.onto_function == other_element.onto_function)
	      {
		contains = true;
		break;
	      }
	    other_element = other_element.next_element;
	  }
	if (!contains)
	  return false;
	element = element.next_element;
      }
    return true;
  }

  override char[] toString()
  {
    char[] fn_string = "";
    auto element = this.first_element;
    while(element !is null)
      {
	fn_string = std.string.format("%s \n %s", fn_string, element.onto_function);
	element = element.next_element;
      }
    return std.string.format("ListOntoFunctions : [ %s\n]", fn_string);
  }

}