import HashMap;
import Triple;
import ListTriple;

class TripleStorage
{
	private HashMap idx_s;
	private HashMap idx_p;
	private HashMap idx_o;
	private HashMap idx_sp;
	private HashMap idx_po;
	private HashMap idx_so;
	private HashMap idx_spo;
	char[] idx;
	ListTriple list;

	this()
	{
		//		str_buff = new char[65536]; 
		idx_s = new HashMap();
		idx_p = new HashMap();
		idx_o = new HashMap();
		idx_sp = new HashMap();
		idx_po = new HashMap();
		idx_so = new HashMap();
		idx_spo = new HashMap();

	//		str_buff = new char[1024];
	}

	public ListTriple getTriples(char[] s, char[] p, char[] o)
	{
		if(s != null)
		{
			//				Stdout.format("#s != null").newline;
			if(p != null)
			{
				if(o != null)
				{
					// spo
					//					idx = s ~ p ~ o;

					// пипец какая тормозная операция, особенно когда память захламлена (если задействован своп), 
					// но после перезагрузки линуха, скорость стала приемлема

					HashMap idx_xxx = idx_spo;
					list = idx_xxx.get(s, p, o);
				} else
				{
					// sp
					//idx = s ~ p;
					HashMap idx_xxx = idx_sp;
					list = idx_xxx.get(s, p);
				}
			} else
			{
				if(o != null)
				{
					// so
					//idx = s ~ o;
					HashMap idx_xxx = idx_so;
					list = idx_xxx.get(s, o);
				} else
				{
					// s
					idx = s;
					HashMap idx_xxx = idx_s;
					list = idx_xxx.get(idx);
				}

			}
		} else
		{
			//				Stdout.format("#s == null").newline;
			if(p != null)
			{
				//				Stdout.format("#p != null").newline;
				if(o != null)
				{
					// po
					//idx = p ~ o;
					HashMap idx_xxx = idx_po;
					list = idx_xxx.get(p, o);
				} else
				{
					//				Stdout.format("#o == null").newline;
					// p
					idx = p;
					HashMap idx_xxx = idx_p;
					list = idx_xxx.get(idx);
				}
			} else
			{
				if(o != null)
				{
					// o
					idx = o;
					HashMap idx_xxx = idx_o;
					list = idx_xxx.get(idx);
				} else
				{
					// ?
				}

			}
		}
		return list;
	}

	public void addTriple(char[] s, char[] p, char[] o)
	{
		//				Stdout.format("*** add triple {},{},{}", s,p,0).newline;

		//бля затупил
		//при добавлении триплета нужно сделать все добавления для всех вариантов индексов

		Triple triple = new Triple(s, p, o);

		//        vv.add (triple);

		if(s != null && p != null && o != null)
		{
			//		Stdout.format("*** add in index spo").newline;
			//idx = s ~ p ~ o;
			HashMap idx_xxx = idx_spo;
			list= idx_xxx.get(s, p, o);
			if(list is null)
			{
				list = new ListTriple	();
				idx_xxx.put(s, p, o, list);
			}
			list.add(triple);
		}

		if(s != null && p != null)
		{
			//		Stdout.format("*** add in index sp").newline;
			// sp
			//idx = s ~ p;
			HashMap idx_xxx = idx_sp;
			//		Stdout.format("*** add in index sp #1").newline;
			list = idx_xxx.get(s, p);
			//		Stdout.format("*** add in index sp #1.1").newline;

			if(list is null)
			{
				//							Stdout.format("*** add in index sp #2").newline;

				list = new ListTriple();
				//								Stdout.format("*** add in index #3").newline;

				idx_xxx.put(s, p, list);
			}
			list.add(triple);
		}

		if(s != null && o != null)
		{
			//		Stdout.format("*** add in index so").newline;
			// so
			//idx = s ~ o;
			HashMap idx_xxx = idx_so;
			list = idx_xxx.get(s, o);
			if(list is null)
			{
				list = new ListTriple();
				idx_xxx.put(s, o, list);
			}
			list.add(triple);
		}

		if(s != null)
		{
			//						Stdout.format("*** add in index s").newline;

			// s
			idx = s;
			HashMap idx_xxx = idx_s;
			list = idx_xxx.get(idx);
			if(list is null)
			{
				list = new ListTriple();
				idx_xxx.put(idx, list);
			}
			list.add(triple);
		}

		/////////////

		if(p != null && o != null)
		{
			//						Stdout.format("*** add in index po").newline;

			// po
			//idx = p ~ o;
			HashMap idx_xxx = idx_po;
			list = idx_xxx.get(p, o);
			if(list is null)
			{
				list = new ListTriple();
				idx_xxx.put(p, o, list);
			}
			list.add(triple);
		}

		if(p != null)
		{
			//						Stdout.format("*** add in index p").newline;

			//		Stdout.format("#add in indexp, {}", p).newline;

			// p
			idx = p;
			HashMap idx_xxx = idx_p;
			list = idx_xxx.get(idx);
			if(list is null)
			{
				list = new ListTriple();
				idx_xxx.put(idx, list);
			}
			list.add(triple);
		}

		if(o != null)
		{
			//						Stdout.format("*** add in index o").newline;

			// o
			idx = o;
			HashMap idx_xxx = idx_o;
			list = idx_xxx.get(idx);
			if(list is null)
			{
				list = new ListTriple();
				idx_xxx.put(idx, list);
			}
			list.add(triple);
		}

	}

}