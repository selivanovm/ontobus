// D import file generated from '/usr/include/d/tango-dmd/tango/stdc/errno.d'
module tango.stdc.errno;
private
{
    extern (C) 
{
    int getErrno();
}
    extern (C) 
{
    int setErrno(int);
}
}
int errno()
{
return getErrno();
}
int errno(int val)
{
return setErrno(val);
}
extern (C) 
{
    version (Win32)
{
    const EPERM = 1;
    const ENOENT = 2;
    const ESRCH = 3;
    const EINTR = 4;
    const EIO = 5;
    const ENXIO = 6;
    const E2BIG = 7;
    const ENOEXEC = 8;
    const EBADF = 9;
    const ECHILD = 10;
    const EAGAIN = 11;
    const ENOMEM = 12;
    const EACCES = 13;
    const EFAULT = 14;
    const EBUSY = 16;
    const EEXIST = 17;
    const EXDEV = 18;
    const ENODEV = 19;
    const ENOTDIR = 20;
    const EISDIR = 21;
    const EINVAL = 22;
    const ENFILE = 23;
    const EMFILE = 24;
    const ENOTTY = 25;
    const EFBIG = 27;
    const ENOSPC = 28;
    const ESPIPE = 29;
    const EROFS = 30;
    const EMLINK = 31;
    const EPIPE = 32;
    const EDOM = 33;
    const ERANGE = 34;
    const EDEADLK = 36;
    const ENAMETOOLONG = 38;
    const ENOLCK = 39;
    const ENOSYS = 40;
    const ENOTEMPTY = 41;
    const EILSEQ = 42;
    const EDEADLOCK = EDEADLK;
}
else
{
    version (linux)
{
    const EPERM = 1;
    const ENOENT = 2;
    const ESRCH = 3;
    const EINTR = 4;
    const EIO = 5;
    const ENXIO = 6;
    const E2BIG = 7;
    const ENOEXEC = 8;
    const EBADF = 9;
    const ECHILD = 10;
    const EAGAIN = 11;
    const ENOMEM = 12;
    const EACCES = 13;
    const EFAULT = 14;
    const ENOTBLK = 15;
    const EBUSY = 16;
    const EEXIST = 17;
    const EXDEV = 18;
    const ENODEV = 19;
    const ENOTDIR = 20;
    const EISDIR = 21;
    const EINVAL = 22;
    const ENFILE = 23;
    const EMFILE = 24;
    const ENOTTY = 25;
    const ETXTBSY = 26;
    const EFBIG = 27;
    const ENOSPC = 28;
    const ESPIPE = 29;
    const EROFS = 30;
    const EMLINK = 31;
    const EPIPE = 32;
    const EDOM = 33;
    const ERANGE = 34;
    const EDEADLK = 35;
    const ENAMETOOLONG = 36;
    const ENOLCK = 37;
    const ENOSYS = 38;
    const ENOTEMPTY = 39;
    const ELOOP = 40;
    const EWOULDBLOCK = EAGAIN;
    const ENOMSG = 42;
    const EIDRM = 43;
    const ECHRNG = 44;
    const EL2NSYNC = 45;
    const EL3HLT = 46;
    const EL3RST = 47;
    const ELNRNG = 48;
    const EUNATCH = 49;
    const ENOCSI = 50;
    const EL2HLT = 51;
    const EBADE = 52;
    const EBADR = 53;
    const EXFULL = 54;
    const ENOANO = 55;
    const EBADRQC = 56;
    const EBADSLT = 57;
    const EDEADLOCK = EDEADLK;
    const EBFONT = 59;
    const ENOSTR = 60;
    const ENODATA = 61;
    const ETIME = 62;
    const ENOSR = 63;
    const ENONET = 64;
    const ENOPKG = 65;
    const EREMOTE = 66;
    const ENOLINK = 67;
    const EADV = 68;
    const ESRMNT = 69;
    const ECOMM = 70;
    const EPROTO = 71;
    const EMULTIHOP = 72;
    const EDOTDOT = 73;
    const EBADMSG = 74;
    const EOVERFLOW = 75;
    const ENOTUNIQ = 76;
    const EBADFD = 77;
    const EREMCHG = 78;
    const ELIBACC = 79;
    const ELIBBAD = 80;
    const ELIBSCN = 81;
    const ELIBMAX = 82;
    const ELIBEXEC = 83;
    const EILSEQ = 84;
    const ERESTART = 85;
    const ESTRPIPE = 86;
    const EUSERS = 87;
    const ENOTSOCK = 88;
    const EDESTADDRREQ = 89;
    const EMSGSIZE = 90;
    const EPROTOTYPE = 91;
    const ENOPROTOOPT = 92;
    const EPROTONOSUPPORT = 93;
    const ESOCKTNOSUPPORT = 94;
    const EOPNOTSUPP = 95;
    const EPFNOSUPPORT = 96;
    const EAFNOSUPPORT = 97;
    const EADDRINUSE = 98;
    const EADDRNOTAVAIL = 99;
    const ENETDOWN = 100;
    const ENETUNREACH = 101;
    const ENETRESET = 102;
    const ECONNABORTED = 103;
    const ECONNRESET = 104;
    const ENOBUFS = 105;
    const EISCONN = 106;
    const ENOTCONN = 107;
    const ESHUTDOWN = 108;
    const ETOOMANYREFS = 109;
    const ETIMEDOUT = 110;
    const ECONNREFUSED = 111;
    const EHOSTDOWN = 112;
    const EHOSTUNREACH = 113;
    const EALREADY = 114;
    const EINPROGRESS = 115;
    const ESTALE = 116;
    const EUCLEAN = 117;
    const ENOTNAM = 118;
    const ENAVAIL = 119;
    const EISNAM = 120;
    const EREMOTEIO = 121;
    const EDQUOT = 122;
    const ENOMEDIUM = 123;
    const EMEDIUMTYPE = 124;
    const ECANCELED = 125;
    const ENOKEY = 126;
    const EKEYEXPIRED = 127;
    const EKEYREVOKED = 128;
    const EKEYREJECTED = 129;
    const EOWNERDEAD = 130;
    const ENOTRECOVERABLE = 131;
}
else
{
    version (darwin)
{
    const EPERM = 1;
    const ENOENT = 2;
    const ESRCH = 3;
    const EINTR = 4;
    const EIO = 5;
    const ENXIO = 6;
    const E2BIG = 7;
    const ENOEXEC = 8;
    const EBADF = 9;
    const ECHILD = 10;
    const EDEADLK = 11;
    const ENOMEM = 12;
    const EACCES = 13;
    const EFAULT = 14;
    const EBUSY = 16;
    const EEXIST = 17;
    const EXDEV = 18;
    const ENODEV = 19;
    const ENOTDIR = 20;
    const EISDIR = 21;
    const EINVAL = 22;
    const ENFILE = 23;
    const EMFILE = 24;
    const ENOTTY = 25;
    const ETXTBSY = 26;
    const EFBIG = 27;
    const ENOSPC = 28;
    const ESPIPE = 29;
    const EROFS = 30;
    const EMLINK = 31;
    const EPIPE = 32;
    const EDOM = 33;
    const ERANGE = 34;
    const EAGAIN = 35;
    const EWOULDBLOCK = EAGAIN;
    const EINPROGRESS = 36;
    const EALREADY = 37;
    const ENOTSOCK = 38;
    const EDESTADDRREQ = 39;
    const EMSGSIZE = 40;
    const EPROTOTYPE = 41;
    const ENOPROTOOPT = 42;
    const EPROTONOSUPPORT = 43;
    const ENOTSUP = 45;
    const EOPNOTSUPP = ENOTSUP;
    const EAFNOSUPPORT = 47;
    const EADDRINUSE = 48;
    const EADDRNOTAVAIL = 49;
    const ENETDOWN = 50;
    const ENETUNREACH = 51;
    const ENETRESET = 52;
    const ECONNABORTED = 53;
    const ECONNRESET = 54;
    const ENOBUFS = 55;
    const EISCONN = 56;
    const ENOTCONN = 57;
    const ETIMEDOUT = 60;
    const ECONNREFUSED = 61;
    const ELOOP = 62;
    const ENAMETOOLONG = 63;
    const EHOSTUNREACH = 65;
    const ENOTEMPTY = 66;
    const EDQUOT = 69;
    const ESTALE = 70;
    const ENOLCK = 77;
    const ENOSYS = 78;
    const EOVERFLOW = 84;
    const ECANCELED = 89;
    const EIDRM = 90;
    const ENOMSG = 91;
    const EILSEQ = 92;
    const EBADMSG = 94;
    const EMULTIHOP = 95;
    const ENODATA = 96;
    const ENOLINK = 97;
    const ENOSR = 98;
    const ENOSTR = 99;
    const EPROTO = 100;
    const ETIME = 101;
    const ELAST = 101;
}
else
{
    version (freebsd)
{
    const EPERM = 1;
    const ENOENT = 2;
    const ESRCH = 3;
    const EINTR = 4;
    const EIO = 5;
    const ENXIO = 6;
    const E2BIG = 7;
    const ENOEXEC = 8;
    const EBADF = 9;
    const ECHILD = 10;
    const EDEADLK = 11;
    const ENOMEM = 12;
    const EACCES = 13;
    const EFAULT = 14;
    const ENOTBLK = 15;
    const EBUSY = 16;
    const EEXIST = 17;
    const EXDEV = 18;
    const ENODEV = 19;
    const ENOTDIR = 20;
    const EISDIR = 21;
    const EINVAL = 22;
    const ENFILE = 23;
    const EMFILE = 24;
    const ENOTTY = 25;
    const ETXTBSY = 26;
    const EFBIG = 27;
    const ENOSPC = 28;
    const ESPIPE = 29;
    const EROFS = 30;
    const EMLINK = 31;
    const EPIPE = 32;
    const EDOM = 33;
    const ERANGE = 34;
    const EAGAIN = 35;
    const EWOULDBLOCK = EAGAIN;
    const EINPROGRESS = 36;
    const EALREADY = 37;
    const ENOTSOCK = 38;
    const EDESTADDRREQ = 39;
    const EMSGSIZE = 40;
    const EPROTOTYPE = 41;
    const ENOPROTOOPT = 42;
    const EPROTONOSUPPORT = 43;
    const ENOTSUP = 45;
    const EOPNOTSUPP = ENOTSUP;
    const EAFNOSUPPORT = 47;
    const EADDRINUSE = 48;
    const EADDRNOTAVAIL = 49;
    const ENETDOWN = 50;
    const ENETUNREACH = 51;
    const ENETRESET = 52;
    const ECONNABORTED = 53;
    const ECONNRESET = 54;
    const ENOBUFS = 55;
    const EISCONN = 56;
    const ENOTCONN = 57;
    const ESHUTDOWN = 58;
    const ETOOMANYREFS = 59;
    const ETIMEDOUT = 60;
    const ECONNREFUSED = 61;
    const ELOOP = 62;
    const ENAMETOOLONG = 63;
    const EHOSTUNREACH = 65;
    const ENOTEMPTY = 66;
    const EPROCLIM = 67;
    const EUSERS = 68;
    const EDQUOT = 69;
    const ESTALE = 70;
    const EREMOTE = 71;
    const EBADRPC = 72;
    const ERPCMISMATCH = 73;
    const EPROGUNAVAIL = 74;
    const EPROGMISMATCH = 75;
    const EPROCUNAVAIL = 76;
    const ENOLCK = 77;
    const ENOSYS = 78;
    const EFTYPE = 79;
    const EAUTH = 80;
    const ENEEDAUTH = 81;
    const EIDRM = 82;
    const ENOMSG = 83;
    const EOVERFLOW = 84;
    const ECANCELED = 85;
    const EILSEQ = 86;
    const ENOATTR = 87;
    const EDOOFUS = 88;
    const EBADMSG = 89;
    const EMULTIHOP = 90;
    const ENOLINK = 91;
    const EPROTO = 92;
    const ELAST = 92;
}
else
{
    version (solaris)
{
    enum 
{
EPERM = 1,
ENOENT = 2,
ESRCH = 3,
EINTR = 4,
EIO = 5,
ENXIO = 6,
E2BIG = 7,
ENOEXEC = 8,
EBADF = 9,
ECHILD = 10,
EAGAIN = 11,
ENOMEM = 12,
EACCES = 13,
EFAULT = 14,
ENOTBLK = 15,
EBUSY = 16,
EEXIST = 17,
EXDEV = 18,
ENODEV = 19,
ENOTDIR = 20,
EISDIR = 21,
EINVAL = 22,
ENFILE = 23,
EMFILE = 24,
ENOTTY = 25,
ETXTBSY = 26,
EFBIG = 27,
ENOSPC = 28,
ESPIPE = 29,
EROFS = 30,
EMLINK = 31,
EPIPE = 32,
EDOM = 33,
ERANGE = 34,
ENOMSG = 35,
EIDRM = 36,
ECHRNG = 37,
EL2NSYNC = 38,
EL3HLT = 39,
EL3RST = 40,
ELNRNG = 41,
EUNATCH = 42,
ENOCSI = 43,
EL2HLT = 44,
EDEADLK = 45,
ENOLCK = 46,
ECANCELED = 47,
ENOTSUP = 48,
EDQUOT = 49,
EBADE = 50,
EBADR = 51,
EXFULL = 52,
ENOANO = 53,
EBADRQC = 54,
EBADSLT = 55,
EDEADLOCK = 56,
EBFONT = 57,
EOWNERDEAD = 58,
ENOTRECOVERABLE = 59,
ENOSTR = 60,
ENODATA = 61,
ETIME = 62,
ENOSR = 63,
ENONET = 64,
ENOPKG = 65,
EREMOTE = 66,
ENOLINK = 67,
EADV = 68,
ESRMNT = 69,
ECOMM = 70,
EPROTO = 71,
ELOCKUNMAPPED = 72,
ENOTACTIVE = 73,
EMULTIHOP = 74,
EBADMSG = 77,
ENAMETOOLONG = 78,
EOVERFLOW = 79,
ENOTUNIQ = 80,
EBADFD = 81,
EREMCHG = 82,
ELIBACC = 83,
ELIBBAD = 84,
ELIBSCN = 85,
ELIBMAX = 86,
ELIBEXEC = 87,
EILSEQ = 88,
ENOSYS = 89,
ELOOP = 90,
ERESTART = 91,
ESTRPIPE = 92,
ENOTEMPTY = 93,
EUSERS = 94,
ENOTSOCK = 95,
EDESTADDRREQ = 96,
EMSGSIZE = 97,
EPROTOTYPE = 98,
ENOPROTOOPT = 99,
EPROTONOSUPPORT = 120,
ESOCKTNOSUPPORT = 121,
EOPNOTSUPP = 122,
EPFNOSUPPORT = 123,
EAFNOSUPPORT = 124,
EADDRINUSE = 125,
EADDRNOTAVAIL = 126,
ENETDOWN = 127,
ENETUNREACH = 128,
ENETRESET = 129,
ECONNABORTED = 130,
ECONNRESET = 131,
ENOBUFS = 132,
EISCONN = 133,
ENOTCONN = 134,
ESHUTDOWN = 143,
ETOOMANYREFS = 144,
ETIMEDOUT = 145,
ECONNREFUSED = 146,
EHOSTDOWN = 147,
EHOSTUNREACH = 148,
EWOULDBLOCK = EAGAIN,
EALREADY = 149,
EINPROGRESS = 150,
ESTALE = 151,
}
}
}
}
}
}
}
