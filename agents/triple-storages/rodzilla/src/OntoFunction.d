import std.string;

import Triple;
import ListTriples;

class OntoFunction 
{

  public Triple command;
  public ListTriples arguments;

  this(Triple _command, ListTriples _arguments)
  {
    command = _command;
    arguments = _arguments;
  }

  override uint toHash()
  {
    uint hash = 17;
    hash = hash * 31 + command.toHash();
    hash = hash * 31 + arguments.toHash();
    return hash;
  }

  override char[] toString()
  {
    char[] args = "";
    auto element = arguments.first_element;
    while (element !is null)
      {
	args = std.string.format("%s \n %s", args, element.triple.toString());
	element = element.next_element;
      }
    return std.string.format("OntoFunction: command = %s, arguments = [ %s\n]", command, args);
  }

  override int opEquals(Object o)
  {
    OntoFunction other = cast(OntoFunction) o;
    return other && command == other.command && arguments.size == other.arguments.size && arguments.containsAll(other.arguments) && other.arguments.containsAll(arguments);
  }
}
