// D import file generated from '/usr/include/d/tango-dmd/tango/net/Socket.d'
module tango.net.Socket;
private
{
    import tango.time.Time;
}
private
{
    import tango.sys.Common;
}
private
{
    import tango.core.Exception;
}
version = Tango;
version (Tango)
{
    private
{
    char[] toString(char[] tmp, int i);
}
}
version (linux)
{
    version = BsdSockets;
}
version (darwin)
{
    version = BsdSockets;
}
version (Posix)
{
    version = BsdSockets;
}
version (Win32)
{
    pragma(lib, "ws2_32.lib");
    private
{
    typedef int socket_t = ~0;
}
    private
{
    const 
{
    int IOCPARM_MASK = 127;
}
}
    private
{
    const 
{
    int IOC_IN = cast(int)-2147483648u;
}
}
    private
{
    const 
{
    int FIONBIO = cast(int)(IOC_IN | ((int).sizeof & IOCPARM_MASK) << 16 | 102 << 8 | 126);
}
}
    private
{
    const 
{
    int WSADESCRIPTION_LEN = 256;
}
}
    private
{
    const 
{
    int WSASYS_STATUS_LEN = 128;
}
}
    private
{
    const 
{
    int WSAEWOULDBLOCK = 10035;
}
}
    private
{
    const 
{
    int WSAEINTR = 10004;
}
}
    struct WSADATA
{
    WORD wVersion;
    WORD wHighVersion;
    char[WSADESCRIPTION_LEN + 1] szDescription;
    char[WSASYS_STATUS_LEN + 1] szSystemStatus;
    ushort iMaxSockets;
    ushort iMaxUdpDg;
    char* lpVendorInfo;
}
    alias WSADATA* LPWSADATA;
    extern (Windows) 
{
    alias closesocket close;
    int WSAStartup(WORD wVersionRequested, LPWSADATA lpWSAData);
    int WSACleanup();
    socket_t socket(int af, int type, int protocol);
    int ioctlsocket(socket_t s, int cmd, uint* argp);
    uint inet_addr(char* cp);
    int bind(socket_t s, sockaddr* name, int namelen);
    int connect(socket_t s, sockaddr* name, int namelen);
    int listen(socket_t s, int backlog);
    socket_t accept(socket_t s, sockaddr* addr, int* addrlen);
    int closesocket(socket_t s);
    int shutdown(socket_t s, int how);
    int getpeername(socket_t s, sockaddr* name, int* namelen);
    int getsockname(socket_t s, sockaddr* name, int* namelen);
    int send(socket_t s, void* buf, int len, int flags);
    int sendto(socket_t s, void* buf, int len, int flags, sockaddr* to, int tolen);
    int recv(socket_t s, void* buf, int len, int flags);
    int recvfrom(socket_t s, void* buf, int len, int flags, sockaddr* from, int* fromlen);
    int select(int nfds, fd_set* readfds, fd_set* writefds, fd_set* errorfds, timeval* timeout);
    int getsockopt(socket_t s, int level, int optname, void* optval, int* optlen);
    int setsockopt(socket_t s, int level, int optname, void* optval, int optlen);
    int gethostname(void* namebuffer, int buflen);
    char* inet_ntoa(uint ina);
    hostent* gethostbyname(char* name);
    hostent* gethostbyaddr(void* addr, int len, int type);
    int WSAGetLastError();
}
    static this();
    }
version (BsdSockets)
{
    private
{
    import tango.stdc.errno;
}
    private
{
    typedef int socket_t = -1;
}
    private
{
    const 
{
    int F_GETFL = 3;
}
}
    private
{
    const 
{
    int F_SETFL = 4;
}
}
    version (darwin)
{
    private
{
    const 
{
    int O_NONBLOCK = 4;
}
}
}
else
{
    version (solaris)
{
    private
{
    const 
{
    int O_NONBLOCK = 128;
}
}
}
else
{
    private
{
    const 
{
    int O_NONBLOCK = 2048;
}
}
}
}
    extern (C) 
{
    socket_t socket(int af, int type, int protocol);
    int fcntl(socket_t s, int f,...);
    uint inet_addr(char* cp);
    int bind(socket_t s, sockaddr* name, int namelen);
    int connect(socket_t s, sockaddr* name, int namelen);
    int listen(socket_t s, int backlog);
    socket_t accept(socket_t s, sockaddr* addr, int* addrlen);
    int close(socket_t s);
    int shutdown(socket_t s, int how);
    int getpeername(socket_t s, sockaddr* name, int* namelen);
    int getsockname(socket_t s, sockaddr* name, int* namelen);
    int send(socket_t s, void* buf, int len, int flags);
    int sendto(socket_t s, void* buf, int len, int flags, sockaddr* to, int tolen);
    int recv(socket_t s, void* buf, int len, int flags);
    int recvfrom(socket_t s, void* buf, int len, int flags, sockaddr* from, int* fromlen);
    int select(int nfds, fd_set* readfds, fd_set* writefds, fd_set* errorfds, timeval* timeout);
    int getsockopt(socket_t s, int level, int optname, void* optval, int* optlen);
    int setsockopt(socket_t s, int level, int optname, void* optval, int optlen);
    int gethostname(void* namebuffer, int buflen);
    char* inet_ntoa(uint ina);
    hostent* gethostbyname(char* name);
    hostent* gethostbyaddr(void* addr, int len, int type);
}
}
private
{
    const 
{
    socket_t INVALID_SOCKET = socket_t.init;
}
}
private
{
    const 
{
    int SOCKET_ERROR = -1;
}
}
struct timeval
{
    int tv_sec;
    int tv_usec;
}
struct fd_set
{
}
struct sockaddr
{
    ushort sa_family;
    char[14] sa_data = 0;
}
struct hostent
{
    char* h_name;
    char** h_aliases;
    version (Win32)
{
    short h_addrtype;
    short h_length;
}
else
{
    version (BsdSockets)
{
    int h_addrtype;
    int h_length;
}
}
    char** h_addr_list;
    char* h_addr()
{
return h_addr_list[0];
}
}
version (BigEndian)
{
    ushort htons(ushort x)
{
return x;
}
    uint htonl(uint x)
{
return x;
}
}
else
{
    version (LittleEndian)
{
    import tango.core.BitManip;
    ushort htons(ushort x)
{
return cast(ushort)(x >> 8 | x << 8);
}
    uint htonl(uint x)
{
return bswap(x);
}
}
else
{
    static assert(0);
}
}
ushort ntohs(ushort x)
{
return htons(x);
}
uint ntohl(uint x)
{
return htonl(x);
}
private
{
    extern (C) 
{
    int strlen(char*);
}
}
private
{
    static 
{
    char[] toString(char* s)
{
return s ? s[0..strlen(s)] : cast(char[])null;
}
}
}
private
{
    static 
{
    char* convert2C(char[] input, char[] output)
{
output[0..input.length] = input;
output[input.length] = 0;
return output.ptr;
}
}
}
public
{
    static 
{
    int lastError();
}
    version (Win32)
{
    enum SocketOption : int
{
SO_DEBUG = 1,
SO_BROADCAST = 32,
SO_REUSEADDR = 4,
SO_LINGER = 128,
SO_DONTLINGER = ~SO_LINGER,
SO_OOBINLINE = 256,
SO_SNDBUF = 4097,
SO_RCVBUF = 4098,
SO_ERROR = 4103,
SO_ACCEPTCONN = 2,
SO_KEEPALIVE = 8,
SO_DONTROUTE = 16,
SO_TYPE = 4104,
IP_MULTICAST_TTL = 10,
IP_MULTICAST_LOOP = 11,
IP_ADD_MEMBERSHIP = 12,
IP_DROP_MEMBERSHIP = 13,
TCP_NODELAY = 1,
}
    union linger
{
    struct
{
ushort l_onoff;
ushort l_linger;
}
    ushort[2] array;
}
    enum SocketOptionLevel 
{
SOCKET = 65535,
IP = 0,
TCP = 6,
UDP = 17,
}
}
else
{
    version (darwin)
{
    enum SocketOption : int
{
SO_DEBUG = 1,
SO_BROADCAST = 32,
SO_REUSEADDR = 4,
SO_LINGER = 128,
SO_DONTLINGER = ~SO_LINGER,
SO_OOBINLINE = 256,
SO_ACCEPTCONN = 2,
SO_KEEPALIVE = 8,
SO_DONTROUTE = 16,
SO_TYPE = 4104,
SO_SNDBUF = 4097,
SO_RCVBUF = 4098,
SO_ERROR = 4103,
IP_MULTICAST_TTL = 10,
IP_MULTICAST_LOOP = 11,
IP_ADD_MEMBERSHIP = 12,
IP_DROP_MEMBERSHIP = 13,
TCP_NODELAY = 1,
}
    union linger
{
    struct
{
int l_onoff;
int l_linger;
}
    int[2] array;
}
    enum SocketOptionLevel 
{
SOCKET = 65535,
IP = 0,
TCP = 6,
UDP = 17,
}
}
else
{
    version (freebsd)
{
    enum SocketOption : int
{
SO_DEBUG = 1,
SO_BROADCAST = 32,
SO_REUSEADDR = 4,
SO_LINGER = 128,
SO_DONTLINGER = ~SO_LINGER,
SO_OOBINLINE = 256,
SO_ACCEPTCONN = 2,
SO_KEEPALIVE = 8,
SO_DONTROUTE = 16,
SO_TYPE = 4104,
SO_SNDBUF = 4097,
SO_RCVBUF = 4098,
SO_ERROR = 4103,
IP_MULTICAST_TTL = 10,
IP_MULTICAST_LOOP = 11,
IP_ADD_MEMBERSHIP = 12,
IP_DROP_MEMBERSHIP = 13,
TCP_NODELAY = 1,
}
    union linger
{
    struct
{
int l_onoff;
int l_linger;
}
    int[2] array;
}
    enum SocketOptionLevel 
{
SOCKET = 65535,
IP = 0,
TCP = 6,
UDP = 17,
}
}
else
{
    version (solaris)
{
    enum SocketOption : int
{
SO_DEBUG = 1,
SO_BROADCAST = 32,
SO_REUSEADDR = 4,
SO_LINGER = 128,
SO_DONTLINGER = ~SO_LINGER,
SO_OOBINLINE = 256,
SO_ACCEPTCONN = 2,
SO_KEEPALIVE = 8,
SO_DONTROUTE = 16,
SO_TYPE = 4104,
SO_SNDBUF = 4097,
SO_RCVBUF = 4098,
SO_ERROR = 4103,
IP_MULTICAST_TTL = 17,
IP_MULTICAST_LOOP = 18,
IP_ADD_MEMBERSHIP = 19,
IP_DROP_MEMBERSHIP = 20,
TCP_NODELAY = 1,
}
    union linger
{
    struct
{
int l_onoff;
int l_linger;
}
    int[2] array;
}
    enum SocketOptionLevel 
{
SOCKET = 65535,
IP = 0,
TCP = 6,
UDP = 17,
}
}
else
{
    version (linux)
{
    enum SocketOption : int
{
SO_DEBUG = 1,
SO_BROADCAST = 6,
SO_REUSEADDR = 2,
SO_LINGER = 13,
SO_DONTLINGER = ~SO_LINGER,
SO_OOBINLINE = 10,
SO_SNDBUF = 7,
SO_RCVBUF = 8,
SO_ERROR = 4,
SO_ACCEPTCONN = 30,
SO_KEEPALIVE = 9,
SO_DONTROUTE = 5,
SO_TYPE = 3,
IP_MULTICAST_TTL = 33,
IP_MULTICAST_LOOP = 34,
IP_ADD_MEMBERSHIP = 35,
IP_DROP_MEMBERSHIP = 36,
TCP_NODELAY = 1,
}
    union linger
{
    struct
{
int l_onoff;
int l_linger;
}
    int[2] array;
}
    enum SocketOptionLevel 
{
SOCKET = 1,
IP = 0,
TCP = 6,
UDP = 17,
}
}
}
}
}
}
    enum SocketShutdown : int
{
RECEIVE = 0,
SEND = 1,
BOTH = 2,
}
    enum SocketFlags : int
{
NONE = 0,
OOB = 1,
PEEK = 2,
DONTROUTE = 4,
}
    enum SocketType : int
{
STREAM = 1,
DGRAM = 2,
RAW = 3,
RDM = 4,
SEQPACKET = 5,
}
    enum ProtocolType : int
{
IP = 0,
ICMP = 1,
IGMP = 2,
GGP = 3,
TCP = 6,
PUP = 12,
UDP = 17,
IDP = 22,
}
    version (Win32)
{
    enum AddressFamily : int
{
UNSPEC = 0,
UNIX = 1,
INET = 2,
IPX = 6,
APPLETALK = 16,
}
}
else
{
    version (BsdSockets)
{
    version (darwin)
{
    enum AddressFamily : int
{
UNSPEC = 0,
UNIX = 1,
INET = 2,
IPX = 23,
APPLETALK = 16,
}
}
else
{
    version (freebsd)
{
    enum AddressFamily : int
{
UNSPEC = 0,
UNIX = 1,
INET = 2,
IPX = 23,
APPLETALK = 16,
}
}
else
{
    version (linux)
{
    enum AddressFamily : int
{
UNSPEC = 0,
UNIX = 1,
INET = 2,
IPX = 4,
APPLETALK = 5,
}
}
else
{
    version (solaris)
{
    enum AddressFamily : int
{
UNSPEC = 0,
UNIX = 1,
INET = 2,
IPX = 23,
APPLETALK = 16,
INET6 = 26,
}
}
}
}
}
}
}
    class Socket
{
    socket_t sock;
    SocketType type;
    AddressFamily family;
    ProtocolType protocol;
    version (Win32)
{
    private
{
    bool _blocking = true;
}
}
    package
{
    this()
{
}
}
    this(AddressFamily family, SocketType type, ProtocolType protocol, bool create = true)
{
this.type = type;
this.family = family;
this.protocol = protocol;
if (create)
initialize();
}
    private
{
    void initialize(socket_t sock = sock.init);
}
    socket_t fileHandle()
{
return sock;
}
    void reopen(socket_t sock = sock.init)
{
initialize(sock);
}
    bool isAlive()
{
int type,typesize = type.sizeof;
return getsockopt(sock,SocketOptionLevel.SOCKET,SocketOption.SO_TYPE,cast(char*)&type,&typesize) != SOCKET_ERROR;
}
    override 
{
    char[] toString()
{
return "Socket";
}
}
    bool blocking();
    void blocking(bool byes);
    AddressFamily addressFamily()
{
return family;
}
    Socket bind(Address addr)
{
if (SOCKET_ERROR == .bind(sock,addr.name(),addr.nameLen()))
exception("Unable to bind socket: ");
return this;
}
    Socket connect(Address to);
    Socket listen(int backlog)
{
if (SOCKET_ERROR == .listen(sock,backlog))
exception("Unable to listen on socket: ");
return this;
}
    Socket accept()
{
return accept(new Socket);
}
    Socket accept(Socket target);
    Socket shutdown(SocketShutdown how)
{
.shutdown(sock,how);
return this;
}
    Socket setLingerPeriod(int period)
{
linger l;
l.l_onoff = 1;
l.l_linger = cast(ushort)period;
return setOption(SocketOptionLevel.SOCKET,SocketOption.SO_LINGER,l.array);
}
    Socket setAddressReuse(bool enabled)
{
int[1] x = enabled;
return setOption(SocketOptionLevel.SOCKET,SocketOption.SO_REUSEADDR,x);
}
    Socket setNoDelay(bool enabled)
{
int[1] x = enabled;
return setOption(SocketOptionLevel.TCP,SocketOption.TCP_NODELAY,x);
}
    void joinGroup(IPv4Address address, bool onOff);
    void detach();
    Address newFamilyObject();
    static 
{
    char[] hostName()
{
char[64] name;
if (SOCKET_ERROR == .gethostname(name.ptr,name.length))
exception("Unable to obtain host name: ");
return name[0..strlen(name.ptr)].dup;
}
}
    static 
{
    uint hostAddress()
{
NetHost ih = new NetHost;
char[] hostname = hostName();
ih.getHostByName(hostname);
assert(ih.addrList.length);
return ih.addrList[0];
}
}
    Address remoteAddress()
{
Address addr = newFamilyObject();
int nameLen = addr.nameLen();
if (SOCKET_ERROR == .getpeername(sock,addr.name(),&nameLen))
exception("Unable to obtain remote socket address: ");
assert(addr.addressFamily() == family);
return addr;
}
    Address localAddress()
{
Address addr = newFamilyObject();
int nameLen = addr.nameLen();
if (SOCKET_ERROR == .getsockname(sock,addr.name(),&nameLen))
exception("Unable to obtain local socket address: ");
assert(addr.addressFamily() == family);
return addr;
}
    const 
{
    int ERROR = SOCKET_ERROR;
}
    int send(void[] buf, SocketFlags flags = SocketFlags.NONE)
{
return .send(sock,buf.ptr,buf.length,cast(int)flags);
}
    int sendTo(void[] buf, SocketFlags flags, Address to)
{
return .sendto(sock,buf.ptr,buf.length,cast(int)flags,to.name(),to.nameLen());
}
    int sendTo(void[] buf, Address to)
{
return sendTo(buf,SocketFlags.NONE,to);
}
    int sendTo(void[] buf, SocketFlags flags = SocketFlags.NONE)
{
return .sendto(sock,buf.ptr,buf.length,cast(int)flags,null,0);
}
    int receive(void[] buf, SocketFlags flags = SocketFlags.NONE)
{
if (!buf.length)
badArg("Socket.receive :: target buffer has 0 length");
return .recv(sock,buf.ptr,buf.length,cast(int)flags);
}
    int receiveFrom(void[] buf, SocketFlags flags, Address from)
{
if (!buf.length)
badArg("Socket.receiveFrom :: target buffer has 0 length");
assert(from.addressFamily() == family);
int nameLen = from.nameLen();
return .recvfrom(sock,buf.ptr,buf.length,cast(int)flags,from.name(),&nameLen);
}
    int receiveFrom(void[] buf, Address from)
{
return receiveFrom(buf,SocketFlags.NONE,from);
}
    int receiveFrom(void[] buf, SocketFlags flags = SocketFlags.NONE)
{
if (!buf.length)
badArg("Socket.receiveFrom :: target buffer has 0 length");
return .recvfrom(sock,buf.ptr,buf.length,cast(int)flags,null,null);
}
    int getOption(SocketOptionLevel level, SocketOption option, void[] result)
{
int len = result.length;
if (SOCKET_ERROR == .getsockopt(sock,cast(int)level,cast(int)option,result.ptr,&len))
exception("Unable to get socket option: ");
return len;
}
    Socket setOption(SocketOptionLevel level, SocketOption option, void[] value)
{
if (SOCKET_ERROR == .setsockopt(sock,cast(int)level,cast(int)option,value.ptr,value.length))
exception("Unable to set socket option: ");
return this;
}
    protected
{
    static 
{
    void exception(char[] msg);
}
}
    protected
{
    static 
{
    void badArg(char[] msg);
}
}
    static 
{
    int select(SocketSet checkRead, SocketSet checkWrite, SocketSet checkError, timeval* tv);
}
    static 
{
    int select(SocketSet checkRead, SocketSet checkWrite, SocketSet checkError, TimeSpan time)
{
auto tv = toTimeval(time);
return select(checkRead,checkWrite,checkError,&tv);
}
}
    static 
{
    int select(SocketSet checkRead, SocketSet checkWrite, SocketSet checkError)
{
return select(checkRead,checkWrite,checkError,null);
}
}
    static 
{
    timeval toTimeval(TimeSpan time)
{
timeval tv;
tv.tv_sec = cast(uint)time.seconds;
tv.tv_usec = cast(uint)time.micros % 1000000;
return tv;
}
}
}
    abstract 
{
    class Address
{
    protected
{
    sockaddr* name();
}
    protected
{
    int nameLen();
}
    AddressFamily addressFamily();
    char[] toString();
    static 
{
    void exception(char[] msg);
}
}
}
    class UnknownAddress : Address
{
    protected
{
    sockaddr sa;
    sockaddr* name()
{
return &sa;
}
    int nameLen()
{
return sa.sizeof;
}
    public
{
    AddressFamily addressFamily()
{
return cast(AddressFamily)sa.sa_family;
}
    char[] toString()
{
return "Unknown";
}
}
}
}
    class NetHost
{
    char[] name;
    char[][] aliases;
    uint[] addrList;
    protected
{
    void validHostent(hostent* he);
}
    void populate(hostent* he);
    bool getHostByName(char[] name);
    bool getHostByAddr(uint addr);
    bool getHostByAddr(char[] addr);
}
    debug (UnitText)
{
    extern (C) 
{
    int printf(char*,...);
}
    }
    class IPv4Address : Address
{
    protected
{
    char[8] _port;
    struct sockaddr_in
{
    ushort sinfamily = AddressFamily.INET;
    ushort sin_port;
    uint sin_addr;
    char[8] sin_zero = 0;
}
    sockaddr_in sin;
    sockaddr* name()
{
return cast(sockaddr*)&sin;
}
    int nameLen()
{
return sin.sizeof;
}
    public
{
    this()
{
}
    const 
{
    uint ADDR_ANY = 0;
}
    const 
{
    uint ADDR_NONE = cast(uint)-1;
}
    const 
{
    ushort PORT_ANY = 0;
}
    AddressFamily addressFamily()
{
return AddressFamily.INET;
}
    ushort port()
{
return ntohs(sin.sin_port);
}
    uint addr()
{
return ntohl(sin.sin_addr);
}
    this(char[] addr, int port = PORT_ANY);
    this(uint addr, ushort port)
{
sin.sin_addr = htonl(addr);
sin.sin_port = htons(port);
}
    this(ushort port)
{
sin.sin_addr = 0;
sin.sin_port = htons(port);
}
    synchronized 
{
    char[] toAddrString()
{
return .toString(inet_ntoa(sin.sin_addr)).dup;
}
}
    char[] toPortString()
{
return .toString(_port,port());
}
    char[] toString()
{
return toAddrString() ~ ":" ~ toPortString();
}
    static 
{
    uint parse(char[] addr);
}
}
}
}
    debug (Unittest)
{
    }
    class SocketSet
{
    private
{
    uint nbytes;
}
    private
{
    byte* buf;
}
    version (Win32)
{
    uint count()
{
return *cast(uint*)buf;
}
    void count(int setter)
{
*cast(uint*)buf = setter;
}
    socket_t* first()
{
return cast(socket_t*)(buf + (uint).sizeof);
}
}
else
{
    version (Posix)
{
    import tango.core.BitManip;
    uint nfdbits;
    socket_t _maxfd = 0;
    uint fdelt(socket_t s)
{
return cast(uint)s / nfdbits;
}
    uint fdmask(socket_t s)
{
return 1 << cast(uint)s % nfdbits;
}
    uint* first()
{
return cast(uint*)buf;
}
    public
{
    socket_t maxfd()
{
return _maxfd;
}
}
}
}
    public
{
    this(uint max);
    this(SocketSet o);
    this();
    SocketSet dup()
{
return new SocketSet(this);
}
    void reset();
    void add(socket_t s);
    void add(Socket s)
{
add(s.sock);
}
    void remove(socket_t s);
    void remove(Socket s)
{
remove(s.sock);
}
    int isSet(socket_t s);
    int isSet(Socket s)
{
return isSet(s.sock);
}
    uint max()
{
return nbytes / socket_t.sizeof;
}
    fd_set* toFd_set()
{
return cast(fd_set*)buf;
}
}
}
}
