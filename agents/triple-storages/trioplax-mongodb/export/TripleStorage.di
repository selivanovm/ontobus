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
    import tango.stdc.stdlib;
}
private
{
    import HashMap;
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
private
{
    import libmongoc_headers;
}
private
{
    import tango.stdc.stdlib;
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
    const 
{
    char* col = "az1";
}
    const 
{
    char* ns = "az1.simple";
}
    private
{
    bool[char[]] predicate_as_multiple;
}
    public
{
    bool log_query = false;
}
    mongo_connection conn;
    this(uint max_count_element, uint max_length_order, uint inital_triple_area_length);
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
    void set_new_index(ubyte index, uint max_count_element, uint max_length_order, uint inital_triple_area_length)
{
}
}
    public
{
    void set_stat_info_logging(bool flag)
{
}
}
    public
{
    void setPredicatesToS1PPOO(char[] P1, char[] P2, char[] _store_predicate_in_list_on_idx_s1ppoo)
{
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
