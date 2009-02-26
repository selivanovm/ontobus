private import tango.io.Stdout;
import Integer = tango.text.convert.Integer;
import tango.time.StopWatch;

import ListTriple;

class C
{
uint qq;
}

struct A
{
 C cc;
 uint q13;
 uint q14;
 uint q15;
} 

class B
{
	public uint max_count_elements = 5_000_000;
        public A *[] test_array_of_A;
        
        this ()
        {
         test_array_of_A = new A *[max_count_elements];         
	}
	
	public A *get (uint idx)
	{
	 return test_array_of_A[idx];
	}
}

void main()
{

   B b = new B ();
   
	Stdout.format("generate test data...").newline;
	for (uint i = 0; i < b.max_count_elements; i++)
	{
    	    b.test_array_of_A[i] = new A ();
	}
	Stdout.format("generate test data...ok").newline;
	
	auto elapsed = new StopWatch();

for (int k = 0; k < 50; k++)
{
	elapsed.start;

	Stdout.format("access to test data ({})...", b.max_count_elements).newline;
	for(uint i = 0; i < b.max_count_elements; i++)
	{
//		A *a = b.get (i);
		A *a = b.test_array_of_A[i];
	}

	double time = elapsed.stop;
	Stdout.format("access to test data time ={}, cps={}", time,
			b.max_count_elements / time).newline;
}
}