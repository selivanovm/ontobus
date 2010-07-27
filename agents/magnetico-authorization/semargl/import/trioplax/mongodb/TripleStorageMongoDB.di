// D import file generated from 'src/trioplax/mongodb/TripleStorageMongoDB.d'
module trioplax.mongodb.TripleStorageMongoDB;
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
    import trioplax.triple;
}
private
{
    import trioplax.TripleStorage;
}
private
{
    import trioplax.Log;
}
private
{
    import bson;
}
private
{
    import md5;
}
private
{
    import mongo;
}
private
{
    import tango.stdc.stdlib;
}
class TripleStorageMongoDB : TripleStorage
{
    private
{
    int max_length_pull = 1024 * 10;
}
    private
{
    int average_list_size = 3;
}
    private
{
    char* strings = null;
}
    private
{
    Triple* triples = null;
}
    private
{
    triple_list_element* elements_in_list = null;
}
    private
{
    triple_list_element*[] used_list = null;
}
    private
{
    int last_used_element_in_pull = 0;
}
    private
{
    int last_used_element_in_strings = 0;
}
    private
{
    char[] buff = null;
}
    private
{
    const 
{
    char* col = "az1";
}
}
    private
{
    const 
{
    char* ns = "az1.simple";
}
}
    private
{
    int count_all_allocated_lists = 0;
}
    private
{
    int max_length_list = 0;
}
    private
{
    int max_use_pull = 0;
}
    private
{
    bool[char[]] predicate_as_multiple;
}
    private
{
    bool log_query = false;
}
    private
{
    mongo_connection conn;
}
    this(char[] host, int port);
    public
{
    void set_log_query_mode(bool on_off)
{
log_query = on_off;
}
}
    public
{
    void release_all_lists()
{
last_used_element_in_pull = 0;
last_used_element_in_strings = 0;
}
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
    bool f_trace_list_pull = true;
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
    private
{
    char[] p_rt = "mo/at/acl#rt\x00";
}
    public
{
    triple_list_element* getTriplesUseIndexS1PPOO(char* s, char* p, char* o);
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
log.trace("TripleStorage:stat: max used pull={}, max length list={}",max_use_pull,max_length_list);
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
