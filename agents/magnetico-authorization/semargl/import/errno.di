// D import file generated from '/usr/include/d/dmd/tango/stdc/errno.d'
module tango.stdc.errno;
public 
{
    import tango.sys.consts.errno;
}
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
