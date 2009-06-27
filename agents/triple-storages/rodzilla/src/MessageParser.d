import std.stdio;
import std.string;
import Text = tango.text.Util;
import OntoFunction;
import ListOntoFunctions;
private import Triple;

class MessageParser 
{
  
  ListOntoFunctions functionsFromString(string s) 
  {
    
    ListOntoFunctions result = new ListOntoFunctions();

    OntoFunction[char[]] functions;
    ListTriples[char[]] args;
    
    int[] indexes = split(s);
    int triple_start = 0;

    foreach(i; indexes)
      {

	Triple triple = tripleFromLine(strip(s[triple_start..i + 1]));
	triple_start = i + 1;

	if (triple.s == "subject")
	  {
	    if (triple.m == TripleType.SET)
	      {
		// генерим идентификатор для агрументов функции
		uint hash = 17;
		foreach(c; triple.o) { hash = 31 * hash + c; }
		char[] new_triple_uid = std.string.format("uid-%d", hash);

		if (!(new_triple_uid in functions)) 
		  { 
		    triple.m = TripleType.LITERAL;
		    functions[new_triple_uid] = new OntoFunction(triple, new ListTriples());
		  }

		int triple_start_idx = 0;
		foreach(idx; split(triple.o))
		  {
		    functions[new_triple_uid].arguments.add(new Triple(new_triple_uid, "argument", triple.o[triple_start_idx..idx + 1], TripleType.SET));
		    triple_start_idx = idx + 1;
		  }

		triple.o = new_triple_uid; 		

	      } else if (!(triple.o in functions)) { functions[triple.o] = new OntoFunction(triple, new ListTriples()); }

	  } else if (triple.p == "argument" && triple.s in functions)
	  functions[triple.s].arguments.add(triple);
      }

    foreach(key; functions.keys)
      result.add(functions[key]);

    return result;
  }

  // метод возвращает индексы символов массива символов соответствующие 
  //концам триплетов в строке содержащей список триплетов
  int[] split(string triplets) {

    int[] indexes = new int[triplets.length / 7];

    int idx_count = 0;

    bool is_beetween_tokens = false;

    int delim_num = 1;

    char prev_char = ' ';

    // функция для определения параметров проверки разделителей
    void get_scan_param(char c, int dn) {
      prev_char = c;
      
      switch (dn) {
      case 0:
	is_beetween_tokens = false;
	delim_num = 1;
	break;
      case 1:
	is_beetween_tokens = true;
	delim_num = 2;
	break;
      case 2:
	is_beetween_tokens = false;
	delim_num = 3;
	break;
      case 3:
	is_beetween_tokens = true;
	delim_num = 4;
	break;
      case 4:
	is_beetween_tokens = false;
	delim_num = 5;
	break;
      case 5:
	is_beetween_tokens = true;
	delim_num = 6;
	break;
      case 6:
	is_beetween_tokens = true;
	delim_num = 0;
	break;
      }
    }

    for(int i = 0; i < triplets.length; i++) {
      char c = triplets[i];
      bool is_process_needed = false;

      if (c != ' ') {

	switch (delim_num) {
	case 0:
	  is_process_needed = c == '<';
	  break;
	case 1:
	  is_process_needed = c == '>';
	  break;
	case 2:
	  is_process_needed = c == '<';
	  break;
	case 3:
	  is_process_needed = c == '>';
	  break;
	case 4:
	  is_process_needed = (c == '"' || c == '{' || c == '<');
	  break;
	case 5:
	  switch (prev_char) {
	  case '"': 
	    is_process_needed = c == '"';
	    break;
	  case '<':
	    is_process_needed = c == '>';
	    break;
	  case '{':
	    is_process_needed = c == '}';
	    break;
	  default:
	    is_process_needed = false;
	  }
	  break;
	case 6:
	  is_process_needed = c == '.';
	  break;
	default:
	  is_process_needed = false;
	  break;
	}

	//	writefln("c = %s | del_num = %d | is_process_needed = %s | idx_num = %d", c, delim_num, is_process_needed, idx_count);

	if (is_process_needed) 
	  {
	    if (c == '.') { indexes[idx_count++] = i; }
	    get_scan_param(c, delim_num);
	  } else if (is_beetween_tokens) 
	  {
	    if (delim_num == 0 && idx_count > 0) 
	      {
		get_scan_param(prev_char, --idx_count);
	      } else 
	      {
		get_scan_param(c, delim_num);
	      }
	  }
      }
    }
    indexes.length = idx_count;
    return indexes;
  }

  Triple tripleFromLine(char[] line)
  {

    char[] s, p, o;
    int m;

    line = std.string.strip(line);

    //    val line = triplet.trim
    int i1 = std.string.find(line, '>');
    if (i1 > -1) 
      {
	s = line[1..i1];
	int i2 = std.string.find(line[(i1 + 1)..line.length], '>') + i1 + 1;
	if (i2 > -1) 
	  { 
	    int i3 = std.string.find(line[i1..line.length], "<") + i1;
	    p = line[i3 + 1..i2];
	    char[] obj_token = std.string.strip(line[i2 + 1..line.length]);
	    o = std.string.strip(obj_token[0..(obj_token.length - 1)]);
	    switch (obj_token[0]) 
	      {
	      case '<':
		m = TripleType.URI;
		break;
	      case '{':
		m = TripleType.SET;
		break;
	      default:
		m = TripleType.LITERAL;
	      }
	  }
      }

    return new Triple(s, p, o[1..o.length - 1], m);
  }

}

unittest
{

  MessageParser testable = new MessageParser();

  // split
  char[] tripletsLine = "<s1><p1><o1>. <s2> <p2> \"o2\". <s3> <p3> \"o3\" .";
  int[] expected = [ 12, 28, 45 ];

  int[] result = testable.split(tripletsLine);
  assert(expected == result);

  tripletsLine = "<subject><store> \"uid1\" . <uid1><argument> <do_it_yourself#1> .<uid1><argument> <do_it_yourself#2> .<subject><store> \"uid2\" . <uid2><argument> \"<do> <it> <yourself#3> .\" .<uid2><argument> \"<do> <it> <yourself#4> .\" .<subject><store> \"uid3\" . <uid3><argument> {<do> <it> <yourself#5> .<do> <it> <yourself#6>.} .";
  expected = [ 24, 62, 99, 124, 170, 215, 240, 309 ];
  result = testable.split(tripletsLine);
  assert(expected == result);


  // functionsFromString
  Triple cmd1 = new Triple("subject", "store", "uid1", TripleType.LITERAL);
  ListTriples args1 = new ListTriples([ new Triple("uid1", "argument", "do_it_yourself#1", TripleType.URI), 
					new Triple("uid1", "argument", "do_it_yourself#2", TripleType.URI) ]);

  Triple cmd2 = new Triple("subject", "store", "uid2", TripleType.LITERAL);
  ListTriples args2 = new ListTriples([ new Triple("uid2", "argument", "<do> <it> <yourself#3> .", TripleType.LITERAL), 
					new Triple("uid2", "argument", "<do> <it> <yourself#4> .", TripleType.LITERAL) ]);

  Triple cmd3 = new Triple("subject", "store", "uid3", TripleType.LITERAL);
  ListTriples args3 = new ListTriples([ new Triple("uid3", "argument", "<do> <it> <yourself#5> .<do> <it> <yourself#6>.", TripleType.SET) ]);

  char[] args_string = "<do> <it> <yourself#7> .<do> <it> <yourself#8>.";

  uint hash = 17;
  foreach(c; args_string) { hash = 31 * hash + c; }  
  char[] hash_s = std.string.format("uid-%d",hash);

  Triple cmd4 = new Triple("subject", "store", hash_s, TripleType.LITERAL);
  ListTriples args4 = new ListTriples([ new Triple(hash_s, "argument", "<do> <it> <yourself#7> .", TripleType.SET),
					new Triple(hash_s, "argument", "<do> <it> <yourself#8>.", TripleType.SET) ]);

  ListOntoFunctions fn_expected = new ListOntoFunctions([ new OntoFunction(cmd1, args1),
							  new OntoFunction(cmd2, args2),
							  new OntoFunction(cmd3, args3),
							  new OntoFunction(cmd4, args4) ]);

  char[] message = "<subject><store> \"uid1\" . <uid1><argument> <do_it_yourself#1> .<uid1><argument> <do_it_yourself#2> .<subject><store> \"uid2\" . <uid2><argument> \"<do> <it> <yourself#3> .\" .<uid2><argument> \"<do> <it> <yourself#4> .\" .<subject><store> \"uid3\" . <uid3><argument> {<do> <it> <yourself#5> .<do> <it> <yourself#6>.} .<subject><store>{<do> <it> <yourself#7> .<do> <it> <yourself#8>.}.";

  auto functions = testable.functionsFromString(message);

  writefln(fn_expected);
  writefln(functions);

  assert(functions.containsAll(fn_expected));
  assert(fn_expected.containsAll(functions));
  
}
