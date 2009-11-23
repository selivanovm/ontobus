// D import file generated from 'src/HashMap.d'
module HashMap;
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
    import tango.io.Stdout;
}
private
{
    import Integer = tango.text.convert.Integer;
}
private
{
    import Hash;
}
private
{
    import Log;
}
private
{
    import tango.core.Thread;
}
struct triple
{
    char[]* s;
    char[]* p;
    char[]* o;
}
public
{
    struct triple_list_element
{
    triple* triple_ptr;
    triple_list_element* next_triple_list_element;
}
}
struct triple_list_header
{
    triple_list_element* last_element;
    triple* keys;
    triple_list_element* first_element;
}
class HashMap
{
    private
{
    uint max_count_elements = 1000;
}
    private
{
    uint max_size_short_order = 8;
}
    private
{
    triple_list_header*[][] reducer;
}
    private
{
    char[] hashName;
}
    private
{
    byte[] triples_list_elements;
}
    private
{
    uint triples_list_elements_tail = 0;
}
    private
{
    byte[] triples_area;
}
    private
{
    uint triples_area_tail = 0;
}
    private
{
    byte[] list_headers_area;
}
    private
{
    uint list_headers_area_tail = 0;
}
    this(char[] _hashName, uint _max_count_elements, uint _triple_area_length, uint _max_size_short_order)
{
hashName = _hashName;
max_size_short_order = _max_size_short_order;
max_count_elements = _max_count_elements;
log.trace("*** create HashMap[name={}, max_count_elements={}, max_size_short_order={}, triple_area_length={} ... start",hashName,_max_count_elements,max_size_short_order,_triple_area_length);
triples_list_elements = new byte[](_triple_area_length);
reducer = new triple_list_header*[][](max_count_elements);
triples_area = new byte[](_max_count_elements * 100);
list_headers_area = new byte[](_max_count_elements * triple_list_header.sizeof);
log.trace("*** create object HashMap... ok");
}
    public
{
    triple* put(char[] key1, char[] key2, char[] key3, triple* triple_ptr, bool is_delete);
}
    public
{
    triple_list_element* get(char[] key1, char[] key2, char[] key3, bool debug_info);
}
    public
{
    void remove_triple_from_list(triple_list_element* removed_triple, char[] s, char[] p, char[] o);
}
}
