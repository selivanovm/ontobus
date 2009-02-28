// import TripleStorageInvoker;
private import tango.io.Stdout;
//import Integer = tango.text.convert.Integer;
import tango.io.File;
import Text = tango.text.Util;
import tango.time.StopWatch;

import HashMap;
import TripleStorage;
import ListTriple;

int main(char[][] args)
{
	//	uint max_count_elements = 300000;
	auto elapsed = new StopWatch();
	elapsed.start;

	uint count_add_triple = 0;

	TripleStorage ts = new TripleStorage();

	//
	auto file = new File("organization_triple");
	auto content = cast(char[]) file.read;
	foreach(line; Text.lines(content))
	{
		char[] s, p, o;
		int idx = 0;
		foreach(element; Text.delimit(line, ">"))
		{
			element = Text.chopl(element, "<");
			idx++;
			if(idx == 1)
			{
				s = element;
			}
			if(idx == 2)
			{
				p = element;
			}
			if(idx == 3)
			{
				o = element;
			}

		}
		Stdout.format("{}: s={}, p={}, o={}", count_add_triple, s, p, o).newline;
		ts.addTriple(s, p, o);
		count_add_triple++;
	}

	//	
	double time = elapsed.stop;
	Stdout.format("create TripleStorage time ={}, count triples = {}", time,
			count_add_triple).newline;

	for(uint i = 0; i < 50; i++)
	{
		uint count_read = 0;
		ListTriple result0 = ts.getTriples("Contact", null, null);
		elapsed.start;

		for(uint h = 0; h < 1000; h++)
		{
			ListElement next_element0 = result0.first_element;

			//				Stdout.format("#2").newline;
			for(uint aa = 0; aa < result0.size; aa++)
			{
				//				Stdout.format("#3").newline;
				Triple triple0 = next_element0.content;
				next_element0 = next_element0.next_element;

				ListTriple result, result1;
				//		uint i = 0;

				// тест считывания обьекта персона + данные подразделения в который он входит
				//		for(i = 0; i < 1_000_000; i++)
				{
					// 1. считываем все поля контакта
					result = ts.getTriples(triple0.p, null, null);
					// 2. ищем в них поле
					if(result !is null)
					{
						ListElement next_element = result.first_element;
						for(uint j = 0; j < result.size; j++)
						{
							Triple triple = next_element.content;
							if(triple.p == "Department")
							{
								result1 = ts.getTriples(triple.o, null, null);
								//					print_list_triples (result1);
								if(result1 !is null)
								{
									ListElement
											next_element1 = result1.first_element;
									for(uint jj = 0; jj < result1.size; jj++)
									{
										Triple triple1 = next_element1.content;

										next_element1 = next_element1.next_element;
									}
								}
							}
							//				
							//				Stdout.format("triple:s={}, p={}, o={}",
							//					triple.s, triple.p, triple.o).newline;

							next_element = next_element.next_element;
						}
						count_read++;
					}

				}
			}
		}
		time = elapsed.stop;

		Stdout.format("read TripleStorage, read={}, time ={}, cps={}",
				count_read, time, count_read / time).newline;

	}

	return 0;
}

private void print_list_triples(ListTriple result)
{

	ListElement next_element = result.first_element;
	//	Stdout.format("#2").newline;
	for(uint j = 0; j < result.size; j++)
	{
		//	Stdout.format("#3").newline;
		Triple triple = next_element.content;

		Stdout.format("triple:s={}, p={}, o={}", triple.s, triple.p, triple.o).newline;

		next_element = next_element.next_element;
	}
}
