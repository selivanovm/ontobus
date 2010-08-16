// D import file generated from '/usr/include/d/dmd/tango/net/device/Socket.d'
module tango.net.device.Socket;
private 
{
    import tango.sys.Common;
}
private 
{
    import tango.io.device.Conduit;
}
package 
{
    import tango.net.device.Berkeley;
}
version (Windows)
{
    private 
{
    import tango.sys.win32.WsaSock;
}
}
class Socket : Conduit,ISelectable
{
    public 
{
    alias native socket;
}
    private 
{
    SocketSet pending;
}
    private 
{
    Berkeley berkeley;
}
    deprecated 
{
    void setTimeout(double t)
{
timeout = cast(uint)(t * 1000);
}
}
    deprecated 
{
    bool hadTimeout()
{
return false;
}
}
    this()
{
this(AddressFamily.INET,SocketType.STREAM,ProtocolType.TCP);
}
    this(Address addr)
{
this(addr.addressFamily,SocketType.STREAM,ProtocolType.TCP);
}
    this(AddressFamily family, SocketType type, ProtocolType protocol);
    override 
{
    char[] toString()
{
return "<socket>";
}
}
    Handle fileHandle()
{
return cast(Handle)berkeley.sock;
}
    Berkeley* native()
{
return &berkeley;
}
    override 
{
    size_t bufferSize()
{
return 1024 * 8;
}
}
    Socket connect(char[] address, uint port)
{
scope addr = new IPv4Address(address,port);
return connect(addr);
}
    Socket connect(Address addr)
{
if (scheduler)
asyncConnect(addr);
else
native.connect(addr);
return this;
}
    Socket bind(Address address)
{
berkeley.bind(address);
return this;
}
    Socket shutdown()
{
berkeley.shutdown(SocketShutdown.BOTH);
return this;
}
    override 
{
    void detach()
{
berkeley.detach;
}
}
    override 
{
    size_t read(void[] dst);
}
    override 
{
    size_t write(void[] src);
}
    override 
{
    OutputStream copy(InputStream src, size_t max = -1)
{
auto x = cast(ISelectable)src;
if (scheduler && x)
asyncCopy(x.fileHandle);
else
super.copy(src,max);
return this;
}
}
    package 
{
    final 
{
    bool wait(bool reading);
}
}
    final 
{
    void error()
{
super.error(this.toString ~ " :: " ~ SysError.lastMsg);
}
}
    version (Win32)
{
    private 
{
    OVERLAPPED overlapped;
}
    private 
{
    void asyncConnect(Address addr)
{
IPv4Address.sockaddr_in local;
auto handle = berkeley.sock;
.bind(handle,cast(Address.sockaddr*)&local,local.sizeof);
ConnectEx(handle,addr.name,addr.nameLen,null,0,null,&overlapped);
wait(scheduler.Type.Connect);
patch(handle,SO_UPDATE_CONNECT_CONTEXT);
}
}
    private 
{
    void asyncCopy(Handle handle)
{
TransmitFile(berkeley.sock,cast(HANDLE)handle,0,0,&overlapped,null,0);
if (wait(scheduler.Type.Transfer) is Eof)
berkeley.exception("Socket.copy :: ");
}
}
    private 
{
    size_t asyncRead(void[] dst);
}
    private 
{
    size_t asyncWrite(void[] src);
}
    private 
{
    size_t wait(scheduler.Type type, uint bytes = 0);
}
    private 
{
    static 
{
    void patch(socket_t dst, uint how, socket_t* src = null)
{
auto len = src ? src.sizeof : 0;
if (setsockopt(dst,SocketOptionLevel.SOCKET,how,src,len))
berkeley.exception("patch :: ");
}
}
}
}
    version (Posix)
{
    private 
{
    void asyncConnect(Address addr)
{
assert(false);
}
}
    Socket asyncCopy(Handle file)
{
assert(false);
}
    private 
{
    size_t asyncRead(void[] dst)
{
assert(false);
}
}
    private 
{
    size_t asyncWrite(void[] src)
{
assert(false);
}
}
}
}
class ServerSocket : Socket
{
    this(uint port, int backlog = 32, bool reuse = false)
{
scope addr = new IPv4Address(cast(ushort)port);
this(addr,backlog,reuse);
}
    this(Address addr, int backlog = 32, bool reuse = false)
{
super(addr);
berkeley.addressReuse(reuse).bind(addr).listen(backlog);
}
    override 
{
    char[] toString()
{
return "<accept>";
}
}
    Socket accept(Socket recipient = null)
{
if (recipient is null)
recipient = new Socket;
if (scheduler)
asyncAccept(recipient);
else
berkeley.accept(recipient.berkeley);
recipient.timeout = timeout;
return recipient;
}
    version (Windows)
{
    private 
{
    void asyncAccept(Socket recipient)
{
byte[128] tmp;
DWORD bytes;
DWORD flags;
auto target = recipient.berkeley.sock;
AcceptEx(berkeley.sock,target,tmp.ptr,0,64,64,&bytes,&overlapped);
wait(scheduler.Type.Accept);
patch(target,SO_UPDATE_ACCEPT_CONTEXT,&berkeley.sock);
}
}
}
    version (Posix)
{
    private 
{
    void asyncAccept(Socket recipient)
{
assert(false);
}
}
}
}
