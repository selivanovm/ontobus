// D import file generated from 'src/HashMap.d'
module HashMap;
private
{
    import tango.stdc.string;
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
class HashMap
{
    private
{
    uint max_count_elements = 1000;
}
    uint max_size_short_order = 8;
    uint reducer_area_length;
    uint[] reducer_area_ptr;
    uint reducer_area_right;
    uint key_2_list_triples_area__length;
    ubyte[] key_2_list_triples_area;
    uint key_2_list_triples_area__last;
    uint key_2_list_triples_area__right;
    char[] hashName;
    this(char[] _hashName, uint _max_count_elements, uint _triple_area_length, uint _max_size_short_order);
    public
{
    void put(char[] key1, char[] key2, char[] key3, void* triple);
}
    public
{
    uint* get(char* key1, char* key2, char* key3, bool debug_info);
}
    private
{
    void dump_mem(ubyte[] mem, uint ptr);
}
}
private
{
    bool _strcmp(char[] mem, uint ptr, char[] key);
}
private
{
    bool _strcmp(char[] mem, uint ptr, char* key);
}
private
{
    char[] mem_to_char(ubyte[] mem, uint ptr, int length);
}
private
{
    uint ptr_from_mem(ubyte[] mem, uint ptr);
}
private
{
    void ptr_to_mem(ubyte[] mem, uint max_size_mem, uint ptr, uint addr);
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
