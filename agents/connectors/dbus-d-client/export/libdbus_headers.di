// D import file generated from 'src/libdbus_headers.d'
extern (C) 
{
    struct DBusMessage;
}
alias uint dbus_uint32_t;
extern (C) 
{
    struct DBusMessageIter
{
    void* dummy1;
    void* dummy2;
    dbus_uint32_t dummy3;
    int dummy4;
    int dummy5;
    int dummy6;
    int dummy7;
    int dummy8;
    int dummy9;
    int dummy10;
    int dummy11;
    int pad1;
    int pad2;
    void* pad3;
}
}
extern 
{
    struct DBusConnection;
}
extern (C) 
{
    struct DBusError
{
    const 
{
    char* name;
}
    const 
{
    char* message;
}
    uint dummy1;
    uint dummy2;
    uint dummy3;
    uint dummy4;
    uint dummy5;
    void* padding1;
}
}
extern (C) 
{
    void dbus_error_init(DBusError* error);
}
enum DBusBusType 
{
DBUS_BUS_SESSION,
DBUS_BUS_SYSTEM,
DBUS_BUS_STARTER,
}
extern (C) 
{
    DBusConnection* dbus_bus_get(DBusBusType type, DBusError* error);
}
alias dbus_uint32_t dbus_bool_t;
extern (C) 
{
    dbus_bool_t dbus_error_is_set(DBusError* error);
}
extern (C) 
{
    void dbus_error_free(DBusError* error);
}
extern (C) 
{
    int dbus_bus_request_name(DBusConnection* connection, char* name, uint flags, DBusError* error);
}
enum dbus_shared 
{
DBUS_NAME_FLAG_REPLACE_EXISTING = 2,
DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER = 1,
DBUS_TYPE_STRING = cast(int)'s',
}
extern (C) 
{
    DBusMessage* dbus_message_new_signal(char* path, char* is_interface, char* name);
}
extern (C) 
{
    void dbus_message_iter_init_append(DBusMessage* message, DBusMessageIter* iter);
}
extern (C) 
{
    dbus_bool_t dbus_message_iter_append_basic(DBusMessageIter* iter, int type, void* value);
}
extern (C) 
{
    dbus_bool_t dbus_connection_send(DBusConnection* connection, DBusMessage* message, dbus_uint32_t* client_serial);
}
extern (C) 
{
    void dbus_connection_flush(DBusConnection* connection);
}
extern (C) 
{
    void dbus_message_unref(DBusMessage* message);
}
extern (C) 
{
    void dbus_bus_add_match(DBusConnection* connection, char* rule, DBusError* error);
}
extern (C) 
{
    dbus_bool_t dbus_connection_read_write(DBusConnection* connection, int timeout_milliseconds);
}
extern (C) 
{
    DBusMessage* dbus_connection_pop_message(DBusConnection* connection);
}
extern (C) 
{
    dbus_bool_t dbus_message_is_signal(DBusMessage* message, char* is_interface, char* signal_name);
}
extern (C) 
{
    dbus_bool_t dbus_message_iter_init(DBusMessage* message, DBusMessageIter* iter);
}
extern (C) 
{
    int dbus_message_iter_get_arg_type(DBusMessageIter* iter);
}
extern (C) 
{
    void dbus_message_iter_get_basic(DBusMessageIter* iter, void* value);
}
