module script_util;

private import Predicates;

private import RightTypeDef;
private import TripleStorage;
private import tango.io.Stdout;
private import fact_tools;
private import Log;
private import tango.text.convert.Integer;
private import tango.stdc.string;
private import tango.stdc.stringz;
private import tango.stdc.time;

public char* isInDocFlow(char* elementId, TripleStorage ts)
{
	//log.trace("isInDocFlow, elementId={}", getString(elementId));
	// найдем субьекта ACL записи по <magnet-ontology#elementId>=elementId
	uint* iterator0 = ts.getTriples(null, ELEMENT_ID.ptr, elementId);
	char* ACL_subject;

	if(iterator0 !is null) // таких записей может быть несколько, но с DOCFLOW одна
	{
	  
	  uint next_element = 0xFF;
	  while(next_element > 0)
	  {
		byte* triple0 = cast(byte*) *iterator0;

		if(triple0 !is null)
		{
		  ACL_subject = cast(char*) triple0 + 6;
		  //log.trace("isInDocFlow #1 ACL Subject {}", getString(ACL_subject));

		  // найдем автора 
		  iterator0 = ts.getTriples(ACL_subject, AUTHOR_SYSTEM.ptr, "DOCFLOW");

		  if(iterator0 !is null)
		  {
		    return ACL_subject;
		  }
		}
		next_element = *(iterator0 + 1);
		iterator0 = cast(uint*) next_element;
	  }

	}
	return null;
}

/*
 * возвращает массив субьектов (s) вышестоящих подразделений по отношению к user   
 */
public char*[] getDepartmentTreePathOfUser(char* user, TripleStorage ts)
{
	// получаем путь до корня в дереве подразделений начиная от заданного подразделения
	char*[] result = new char*[16];
	ubyte count_result = 0;

	uint* iterator0;
	byte* triple0;

	//log.trace("getDepartmentTreePath #1 for user={}", getString(user));

	iterator0 = ts.getTriples(user, MEMBER_OF.ptr, null);

	//	print_list_triple(iterator0);

	if(iterator0 !is null)
	{
		triple0 = cast(byte*) *iterator0;
		char* next_branch = cast(char*) (triple0 + 6 + (*(triple0 + 0) << 8) + *(triple0 + 1) + 1 + (*(triple0 + 2) << 8) + *(triple0 + 3) + 1);;

		if(next_branch !is null)
		{
			//			log.trace("getDepartmentTreePath #1 next_branch={}", getString(next_branch));
			result[count_result] = next_branch;
			count_result++;
		}

		while(next_branch !is null)
		{
			uint* iterator1 = ts.getTriples(null, HAS_PART.ptr, next_branch);
			next_branch = null;
			if(iterator1 !is null)
			{
				byte* triple = cast(byte*) *iterator1;
				char* s = cast(char*) triple + 6;
				//log.trace("next_element1={}", getString (s));
				result[count_result] = s;
				count_result++;
				next_branch = s;
			}

		}
	}

	//		Stdout.format("getDepartmentTreePath #5 ok").newline;

	result.length = count_result;
	return result;
}

/*
 * возвращает массив субьектов (s) вышестоящих подразделений по отношению к delegate_id   
 */
public char*[] getDelegateAssignersTreeArray(char* delegate_id, TripleStorage ts)
{

	char*[] result = new char*[20];
	uint result_cnt = 0;

	void put_in_result(char* founded_delegate)
	{
		result[result_cnt++] = founded_delegate;
	}

	getDelegateAssignersForDelegate(delegate_id, ts, &put_in_result);

	result.length = result_cnt;

	return result;

}

public void getDelegateAssignersForDelegate(char* delegate_id, TripleStorage ts, void delegate(char* founed_delegate) process_delegate)
{

	uint* delegates_facts = ts.getTriples(null, DELEGATION_DELEGATE.ptr, delegate_id);

	if(delegates_facts !is null)
	{
		//log.trace("#2 gda");
		uint next_delegate = 0xFF;
		while(next_delegate > 0)
		{
			//log.trace("#3 gda");
			byte* de_legate = cast(byte*) *delegates_facts;
			if(de_legate !is null)
			{
				char* subject = cast(char*) de_legate + 6;
				uint* owners_facts = ts.getTriples(subject, DELEGATION_OWNER.ptr, null);

				if(owners_facts !is null)
				{
					uint next_owner = 0xFF;
					while(next_owner > 0)
					{
						byte* owner = cast(byte*) *owners_facts;
						if(owner !is null)
						{
							//log.trace("#4 gda");

							char* object = cast(char*) (owner + 6 + (*(owner + 0) << 8) + *(owner + 1) + 1 + (*(owner + 2) << 8) + *(owner + 3) + 1);

							//log.trace("delegate = {}, owner = {}", getString(subject), getString(object));

							/*			  strcpy(result_ptr++, ",");
							 strcpy(result_ptr, object);
							 result_ptr += strlen(object);*/
							process_delegate(object);

							uint* with_tree_facts = ts.getTriples(subject, DELEGATION_WITH_TREE.ptr, null);
							if(with_tree_facts !is null)
							{
								uint next_with_tree = 0xFF;
								while(next_with_tree > 0)
								{
									byte* with_tree = cast(byte*) *with_tree_facts;
									if(with_tree !is null)
									{
										if(strcmp(cast(char*) with_tree, "1") == 0)
											getDelegateAssignersForDelegate(object, ts, process_delegate);
										next_with_tree = 0;
									}
									else
									{
										next_with_tree = *(with_tree_facts + 1);
										with_tree_facts = cast(uint*) next_with_tree;
									}
								}
							}
							next_owner = 0;
						}
						else
						{
							next_owner = *(owners_facts + 1);
							owners_facts = cast(uint*) next_owner;
						}
					}
				}
			}
			next_delegate = *(delegates_facts + 1);
			delegates_facts = cast(uint*) next_delegate;
		}
	}
}

public bool is_right_actual(char* subject, TripleStorage ts)
{
	char* from;
	char* to;

	uint* from_iter = ts.getTriples(subject, DATE_FROM.ptr, null);

	// log.trace("#1");

	if(from_iter !is null)
	{
		uint next_el = 0xFF;
		while(next_el > 0)
		{
			byte* el = cast(byte*) *from_iter;
			if(el !is null)
			{
				from = cast(char*) (el + 6 + (*(el + 0) << 8) + *(el + 1) + 1 + (*(el + 2) << 8) + *(el + 3) + 1);
				if(el !is null)
					break;
				else
					from = null;
			}
			next_el = *(from_iter + 1);
			from_iter = cast(uint*) next_el;
		}
	}

	//	log.trace("#10");

	uint* to_iter = ts.getTriples(subject, DATE_TO.ptr, null);
	if(to_iter !is null)
	{
		uint next_el = 0xFF;
		while(next_el > 0)
		{
			byte* el = cast(byte*) *to_iter;
			if(el !is null)
			{
				to = cast(char*) (el + 6 + (*(el + 0) << 8) + *(el + 1) + 1 + (*(el + 2) << 8) + *(el + 3) + 1);
				if(el !is null)
					break;
				else
					to = null;
			}
			next_el = *(to_iter + 1);
			to_iter = cast(uint*) next_el;
		}
	}

	//	log.trace("#20");	

	return is_today_in_interval(from, to);
}

public tm* get_local_time()
{
	time_t rawtime;
	tm * timeinfo;

	time ( &rawtime );
	timeinfo = localtime ( &rawtime );

	return timeinfo;
}

public char[] get_year(tm* timeinfo)
{
	char[] lt = new char[4];
	itoa(lt, cast(uint)timeinfo.tm_year + 1900);
	return lt;
}

public char[] get_month(tm* timeinfo)
{
	char[] lt = new char[2];
	itoa(lt, cast(uint)timeinfo.tm_mon + 1);
	if(timeinfo.tm_mon < 9)
		lt[0] = '0';
	return lt;
}

public char[] get_day(tm* timeinfo)
{
	char[] lt = new char[2];
	itoa(lt, cast(uint)timeinfo.tm_mday);
	if(timeinfo.tm_mday < 10)
		lt[0] = '0';
	return lt;
}

public int cmp_date_with_tm(char* date, tm* timeinfo)
{
	
	assert(strlen(date) == 10);

	char[] today_y = get_year(timeinfo);
	char[] today_m = get_month(timeinfo);
	char[] today_d = get_day(timeinfo);

	for(int i = 0; i < 4; i++)
	{
		if(*(date + i + 6) > today_y[i])
			return 1;
		else if(*(date + i + 6) < today_y[i])
			return -1;
	}

	for(int i = 0; i < 2; i++)
	{
		if(*(date + i + 3) > today_m[i])
			return 1;
		else if(*(date + i + 3) < today_m[i])
			return -1;
	}

	for(int i = 0; i < 2; i++)
		if(*(date + i) > today_d[i])
			return 1;
		else if(*(date + i) < today_d[i])
			return -1;

	return 0;
}

public bool is_today_in_interval(char* from, char* to)
{
	//log.trace("#itii 11");

	tm* timeinfo = get_local_time();

	if(from !is null && strlen(from) == 10 && cmp_date_with_tm(from, timeinfo) > 0)
		return false;

	//log.trace("#itii 22");

	if(to !is null && strlen(to) == 10 && cmp_date_with_tm(to, timeinfo) < 0)
		return false;

	//log.trace("#itii 33");
	return true;
}

unittest 
{
	
	Stdout.format("\n ::: TESTS START ::: ").newline;

	tm* timeinfo = get_local_time();
	Stdout.format("\nLocal time : {}.{}.{}", get_day(timeinfo), get_month(timeinfo), get_year(timeinfo)).newline;

	timeinfo.tm_year = 45;
	timeinfo.tm_mon = 8;
	timeinfo.tm_mday = 5;

	char[] date = "05.09.1945";

	Stdout.format("\n{} == {}.{}.{}?\n", date, get_day(timeinfo), get_month(timeinfo), get_year(timeinfo)).newline;

	assert(cmp_date_with_tm(date.ptr, timeinfo) == 0);
	assert(!is_today_in_interval("10.10.1990".ptr, "10.10.2000".ptr));
	assert(is_today_in_interval("10.10.1990".ptr, "10.10.2200".ptr));

	Stdout.format(" ::: TESTS FINISH ::: \n").newline;
}
