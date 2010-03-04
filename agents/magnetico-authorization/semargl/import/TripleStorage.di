// D import file generated from 'src/TripleStorage.d'
module TripleStorage;
private
{
    import tango.io.Stdout;
}
private
{
    import tango.stdc.string;
}
private
{
    import tango.stdc.stringz;
}
private
{
    import HashMap;
}
private
{
    import IndexException;
}
private
{
    import Log;
}
import Integer = tango.text.convert.Integer;
private
{
    import tango.io.FileConduit;
}
enum idx_name 
{
S = 1 << 0,
P = 1 << 1,
O = 1 << 2,
SP = 1 << 3,
PO = 1 << 4,
SO = 1 << 5,
SPO = 1 << 6,
S1PPOO = 1 << 7,
}
class TripleStorage
{
    private
{
    char[] buff = null;
}
    public
{
    bool INFO_stat_get_triples = false;
}
    public
{
    bool INFO_remove_triple_from_list = false;
}
    private
{
    HashMap idx_s = null;
}
    private
{
    HashMap idx_p = null;
}
    private
{
    HashMap idx_o = null;
}
    private
{
    HashMap idx_sp = null;
}
    private
{
    HashMap idx_po = null;
}
    private
{
    HashMap idx_so = null;
}
    private
{
    HashMap idx_spo = null;
}
    private
{
    HashMap idx_s1ppoo = null;
}
    private
{
    char[][16] look_predicate_p1_on_idx_s1ppoo;
}
    private
{
    char[][16] look_predicate_p2_on_idx_s1ppoo;
}
    private
{
    char[][16] look_predicate_pp_on_idx_s1ppoo;
}
    private
{
    char[][16] store_predicate_in_list_on_idx_s1ppoo;
}
    private
{
    uint count_look_predicate_on_idx_s1ppoo = 0;
}
    private
{
    char* idx;
}
    private
{
    bool log_stat_info = true;
}
    private
{
    char[] cat_buff1;
}
    private
{
    char[] cat_buff2;
}
    private
{
    int dummy;
}
    this(uint max_count_element, uint max_length_order, uint inital_triple_area_length)
{
cat_buff1 = new char[](64 * 1024);
cat_buff2 = new char[](64 * 1024);
buff = new char[](32);
idx_spo = new HashMap("SPO",max_count_element,inital_triple_area_length,max_length_order);
}
    public
{
    void set_new_index(ubyte index, uint max_count_element, uint max_length_order, uint inital_triple_area_length);
}
    public
{
    void set_stat_info_logging(bool flag)
{
log_stat_info = flag;
}
}
    public
{
    void setPredicatesToS1PPOO(char[] P1, char[] P2, char[] _store_predicate_in_list_on_idx_s1ppoo)
{
look_predicate_p1_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = P1;
look_predicate_p2_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = P2;
look_predicate_pp_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = P1 ~ P2;
store_predicate_in_list_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = _store_predicate_in_list_on_idx_s1ppoo;
count_look_predicate_on_idx_s1ppoo++;
}
}
    public
{
    uint* getTriplesUseIndex(char* s, char* p, char* o, ubyte useindex);
}
    public
{
    uint* getTriples(char* s, char* p, char* o);
}
    public
{
    bool removeTriple(char[] s, char[] p, char[] o);
}
    public
{
    int addTriple(char[] s, char[] p, char[] o);
}
    public
{
    void print_stat()
{
if (idx_s !is null)
log.trace("index {}, counts={} ",idx_s.getName(),idx_s.get_count_elements());
if (idx_p !is null)
log.trace("index {}, counts={} ",idx_p.getName(),idx_p.get_count_elements());
if (idx_o !is null)
log.trace("index {}, counts={} ",idx_o.getName(),idx_o.get_count_elements());
if (idx_sp !is null)
log.trace("index {}, counts={} ",idx_sp.getName(),idx_sp.get_count_elements());
if (idx_po !is null)
log.trace("index {}, counts={} ",idx_po.getName(),idx_po.get_count_elements());
if (idx_so !is null)
log.trace("index {}, counts={} ",idx_so.getName(),idx_so.get_count_elements());
if (idx_spo !is null)
log.trace("index {}, counts={} ",idx_spo.getName(),idx_spo.get_count_elements());
if (idx_s1ppoo !is null)
log.trace("index {}, counts={} ",idx_s1ppoo.getName(),idx_s1ppoo.get_count_elements());
}
}
    public
{
    void print_list_triple_to_file(File log_file, triple_list_element* list_iterator);
}
    public
{
    void print_list_triple(triple_list_element* list_iterator);
}
    public
{
    int get_count_form_list_triple(triple_list_element* list_iterator);
}
    public
{
    void print_triple(byte* triple);
}
    public
{
    char[] triple_to_string(byte* triple);
}
}
