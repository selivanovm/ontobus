// D import file generated from 'src/TripleStorage.d'
module TripleStorage;
private
{
    import HashMap;
}
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
    import Log;
}
private
{
    import tango.stdc.stringz;
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
    bool log_stat_info = false;
}
    uint max_count_element = 100000;
    uint max_length_order = 4;
    private
{
    char[] cat_buff1;
}
    private
{
    char[] cat_buff2;
}
    this(ubyte useindex, uint _max_count_element, uint _max_length_order, uint inital_triple_area_length);
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
    void do_things(char* ooo);
}
}
