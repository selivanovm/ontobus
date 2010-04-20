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
private
{
    import Integer = tango.text.convert.Integer;
}
private
{
    import tango.io.FileConduit;
}
private
{
    import tango.time.WallClock;
}
private
{
    import tango.time.Clock;
}
private
{
    import tango.text.locale.Locale;
}
private
{
    Locale layout;
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
    bool log_query = false;
}
    private
{
    bool log_stat_info = true;
}
    public
{
    bool INFO_remove_triple_from_list = false;
}
    private
{
    bool f_init_debug = false;
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
    private
{
    bool[char[]] predicate_as_multiple;
}
    this(uint max_count_element, uint max_length_order, uint inital_triple_area_length)
{
layout = new Locale;
cat_buff1 = new char[](64 * 1024);
cat_buff2 = new char[](64 * 1024);
buff = new char[](32);
if (f_init_debug)
log.trace("create idx_spo...");
idx_spo = new HashMap("SPO",max_count_element,inital_triple_area_length,max_length_order);
if (f_init_debug)
log.trace("ok");
}
    public
{
    void define_predicate_as_multiple(char[] predicate)
{
predicate_as_multiple[predicate] = true;
log.trace("define predicate [{}] as multiple",predicate);
}
}
    public
{
    void list_no_longer_required(triple_list_element* first_element_of_list)
{
}
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
    triple_list_element* getTriplesUseIndex(char* s, char* p, char* o, ubyte useindex);
}
    public
{
    triple_list_element* getTriples(char* s, char* p, char* o);
}
    private
{
    void logging_query(char[] op, char* s, char* p, char* o, triple_list_element* list)
{
char[] a_s = "";
char[] a_p = "";
char[] a_o = "";
if (s !is null)
a_s = "S";
if (p !is null)
a_p = "P";
if (o !is null)
a_o = "O";
int count = get_count_form_list_triple(list);
auto style = File.ReadWriteOpen;
style.share = File.Share.Read;
style.open = File.Open.Append;
File log_file = new File("triple-storage-io",style);
auto tm = WallClock.now;
auto dt = Clock.toDate(tm);
log_file.output.write(layout("{:yyyy-MM-dd HH:mm:ss},{} ",tm,dt.time.millis));
log_file.output.write("\x0a" ~ op ~ " FROM INDEX " ~ a_s ~ a_p ~ a_o ~ " s=[" ~ fromStringz(s) ~ "] p=[" ~ fromStringz(p) ~ "] o=[" ~ fromStringz(o) ~ "] " ~ Integer.format(buff,count) ~ "\x0a");
print_list_triple_to_file(log_file,list);
log_file.close();
}
}
    public
{
    bool removeTriple(char[] s, char[] p, char[] o);
}
    bool f_trace_addTriple = false;
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
    void print_triple(Triple* triple);
}
    public
{
    char[] triple_to_string(Triple* triple);
}
}
