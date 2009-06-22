// D import file generated from 'src/HashMap.d'
private
{
    import tango.stdc.stdlib;
}
private
{
    import std.c.string;
}
private
{
    import tango.io.Stdout;
}
import Integer = tango.text.convert.Integer;
import Hash;
import dee0xd.Log;
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
    this(uint _max_count_elements, uint _triple_area_length, uint _max_size_short_order);
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
    char[] str_2_char_array(char* str);
}
