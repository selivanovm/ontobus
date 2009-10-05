// D import file generated from 'src/TripleStorage.d'
module TripleStorage;
import HashMap;
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
import tango.util.container.HashMap;
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
    uint count_look_predicate_on_idx_s1ppoo = 0;
}
    private
{
    char* idx;
}
    private
{
    ulong stat__idx_s__reads = 0;
}
    private
{
    ulong stat__idx_p__reads = 0;
}
    private
{
    ulong stat__idx_o__reads = 0;
}
    private
{
    ulong stat__idx_sp__reads = 0;
}
    private
{
    ulong stat__idx_po__reads = 0;
}
    private
{
    ulong stat__idx_so__reads = 0;
}
    private
{
    ulong stat__idx_spo__reads = 0;
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
    void setPredicatesToS1PPOO(char[] P1, char[] P2)
{
look_predicate_p1_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = P1;
look_predicate_p2_on_idx_s1ppoo[count_look_predicate_on_idx_s1ppoo] = P2;
count_look_predicate_on_idx_s1ppoo++;
}
}
    public
{
    uint* getTriples(char* p1, char* p2, char* o1, char* o2);
}
    public
{
    uint* getTriples(char* s, char* p, char* o, bool debug_info);
}
    public
{
    bool removeTriple(char* s, char* p, char* o);
}
    public
{
    bool removeTriple(char[] s, char[] p, char[] o);
}
    public
{
    bool addTriple(char[] s, char[] p, char[] o);
}
    public
{
    void print_stat()
{
log.trace("*** statistic read *** \x0aindex s={} reads \x0aindex p={} reads \x0aindex o={} reads \x0aindex sp={} reads \x0aindex po={} reads \x0aindex so={} reads \x0aindex spo={} reads \x0a",stat__idx_s__reads,stat__idx_p__reads,stat__idx_o__reads,stat__idx_sp__reads,stat__idx_po__reads,stat__idx_so__reads,stat__idx_spo__reads);
}
}
}
private
{
    static 
{
    char[] _toString(char* s)
{
return s ? s[0..strlen(s)] : cast(char[])null;
}
}
}
