import std.string;

class Triple
{

  public char[] s;
  public char[] p;
  public char[] o;
  public int    m;

  this(char[] _s, char[] _p, char[] _o, int _m)
  {
    s = _s;
    p = _p;
    o = _o;
    m = _m;
  }

  override char[] toString() { return std.string.format("Triplet: subj = %s , pred = %s , obj = %s, mod = %d", s, p, o, m); }

  override uint toHash()
  {
    uint result = 17;
    foreach(c; s) { result = 31 * result + c; }
    foreach(c; p) { result = 31 * result + c; }
    foreach(c; o) { result = 31 * result + c; }
    result = 31 * result + m;
    return result;
  }

  override int opEquals(Object obj)
  {   
    Triple other = cast(Triple) obj;
    if (other && s == other.s && p == other.p && o == other.o && m == other.m)
      return 1;
    else return 0;

  }

}

private enum TripleType { URI, LITERAL, SET }
