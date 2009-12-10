// D import file generated from 'C:\tango-0.99.8-bin-win32-dmd.1.041\import\tango\net\InternetAddress.d'
module tango.net.InternetAddress;
private
{
    import tango.net.Socket;
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
