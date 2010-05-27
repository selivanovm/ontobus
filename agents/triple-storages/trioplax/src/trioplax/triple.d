module trioplax.triple;
struct Triple
{
    short s_length = 0;
    short p_length = 0;
    short o_length = 0;
    char* s;
    char* p;
    char* o;
}
struct triple_list_element
{
    Triple* triple;
    triple_list_element* next_triple_list_element;
}
