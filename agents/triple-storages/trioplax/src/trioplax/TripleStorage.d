module trioplax.TripleStorage;

private import trioplax.triple;
private import tango.io.device.File;

interface TripleStorage
{
	// main functions
	
	public int addTriple(char[] s, char[] p, char[] o);
	public triple_list_element* getTriples(char* s, char* p, char* o);
	public triple_list_element* getTriplesUseIndexS1PPOO(char* s, char* p, char* o);
	public bool removeTriple(char[] s, char[] p, char[] o);
	
	// configure functions	
	public void set_new_index(ubyte index, uint max_count_element, uint max_length_order, uint inital_triple_area_length);
	
	public void define_predicate_as_multiple(char[] predicate);	
	public void setPredicatesToS1PPOO(char[] P1, char[] P2, char[] _store_predicate_in_list_on_idx_s1ppoo);

	public void set_stat_info_logging(bool flag);		
	public void set_log_query_mode (bool on_off);
//	public void set_apoptosis_mode (bool on_off);
	
	/////////////////////////////////////////	
	
	public void release_all_lists();
	public void list_no_longer_required(triple_list_element* first_element_of_list);

	////////////////////////////////////////
		
	public void print_stat();
	public void print_list_triple_to_file(File log_file, triple_list_element* list_iterator);
	public void print_list_triple(triple_list_element* list_iterator);

	public int get_count_form_list_triple(triple_list_element* list_iterator);
	
	////////////////////////////////////////	
	private void logging_query(char[] op, char* s, char* p, char* o, triple_list_element* list);	
}
