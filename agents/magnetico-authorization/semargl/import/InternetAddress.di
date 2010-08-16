// D import file generated from '/usr/include/d/dmd/tango/net/InternetAddress.d'
module tango.net.InternetAddress;
private 
{
    import tango.net.device.Berkeley;
}
class InternetAddress : IPv4Address
{
    this()
{
}
    this(char[] addr, int port = PORT_ANY);
    this(uint addr, ushort port)
{
super(addr,port);
}
    this(ushort port)
{
super(port);
}
    private 
{
    static 
{
    int parse(char[] s);
}
}
}
