extern(C)
	struct DBusMessage;

alias uint dbus_uint32_t;

extern(C)
	struct DBusMessageIter
	{
		void* dummy1; /**< Don't use this */
		void* dummy2; /**< Don't use this */
		dbus_uint32_t dummy3; /**< Don't use this */
		int dummy4; /**< Don't use this */
		int dummy5; /**< Don't use this */
		int dummy6; /**< Don't use this */
		int dummy7; /**< Don't use this */
		int dummy8; /**< Don't use this */
		int dummy9; /**< Don't use this */
		int dummy10; /**< Don't use this */
		int dummy11; /**< Don't use this */
		int pad1; /**< Don't use this */
		int pad2; /**< Don't use this */
		void* pad3; /**< Don't use this */
	};

extern struct DBusConnection;

/** 
 * Object representing an exception. 
 */
extern(C)
	struct DBusError
	{
		const char* name; /**< public error name field */
		const char* message; /**< public error message field */

		uint dummy1; /**< placeholder */
		uint dummy2; /**< placeholder */
		uint dummy3; /**< placeholder */
		uint dummy4; /**< placeholder */
		uint dummy5; /**< placeholder */

		void* padding1; /**< placeholder */
	};

extern(C)
	void dbus_error_init(DBusError* error);

/** 
 * Well-known bus types. See dbus_bus_get(). 
 */
enum DBusBusType
{
	DBUS_BUS_SESSION, /**< The login session bus */
	DBUS_BUS_SYSTEM, /**< The systemwide bus */
	DBUS_BUS_STARTER /**< The bus that started us, if any */
};

extern(C)
	DBusConnection* dbus_bus_get(DBusBusType type, DBusError* error);

alias dbus_uint32_t dbus_bool_t;

extern(C)
	dbus_bool_t dbus_error_is_set(DBusError* error);

extern(C)
	void dbus_error_free(DBusError* error);

extern(C)
	int dbus_bus_request_name(DBusConnection* connection, char* name, uint flags, DBusError* error);

enum dbus_shared
{
	DBUS_NAME_FLAG_REPLACE_EXISTING = 0x2,
	DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER = 1,
	DBUS_TYPE_STRING = cast(int) 's'
};

extern(C)
	DBusMessage* dbus_message_new_signal(char* path, char* is_interface, char* name);

extern(C)
	void dbus_message_iter_init_append(DBusMessage* message, DBusMessageIter* iter);

extern(C)
	dbus_bool_t dbus_message_iter_append_basic(DBusMessageIter* iter, int type, void* value);

extern(C)
	dbus_bool_t dbus_connection_send(DBusConnection* connection, DBusMessage* message, dbus_uint32_t* client_serial);

extern(C)
	void dbus_connection_flush(DBusConnection* connection);

extern(C)
	void dbus_message_unref(DBusMessage* message);

extern(C)
	void dbus_bus_add_match(DBusConnection* connection, char* rule, DBusError* error);

extern(C)
	dbus_bool_t dbus_connection_read_write(DBusConnection* connection, int timeout_milliseconds);

extern(C)
	DBusMessage* dbus_connection_pop_message(DBusConnection* connection);

extern(C)
	dbus_bool_t dbus_message_is_signal(DBusMessage* message, char* is_interface, char* signal_name);

extern(C)
	dbus_bool_t dbus_message_iter_init(DBusMessage* message, DBusMessageIter* iter);

extern(C)
	int dbus_message_iter_get_arg_type(DBusMessageIter* iter);

extern(C)
	void dbus_message_iter_get_basic(DBusMessageIter* iter, void* value);
