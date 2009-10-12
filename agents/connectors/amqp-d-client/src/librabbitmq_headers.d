// nochanges
extern(C)
	void amqp_dump(void* buffer, size_t len);

// nochanges
extern(C)
	struct amqp_table_t_
	{
		int num_entries;
		amqp_table_entry_t_* entries;
	};

// nochanges
extern(C)
	struct amqp_bytes_t_
	{
		size_t len;
		void* bytes;
	};

alias ushort uint16_t;
alias uint uint32_t;
alias int int32_t;
alias ubyte uint8_t;
alias ulong uint64_t;

alias amqp_bytes_t_ amqp_bytes_t;
alias amqp_table_t_ amqp_table_t;
alias amqp_frame_t_ amqp_frame_t;
alias uint32_t amqp_method_number_t;

typedef uint32_t amqp_flags_t;

//changes
enum amqp_connection_state_enum_
{
	CONNECTION_STATE_IDLE = 0,
	CONNECTION_STATE_WAITING_FOR_HEADER,
	CONNECTION_STATE_WAITING_FOR_BODY,
	CONNECTION_STATE_WAITING_FOR_PROTOCOL_HEADER
};

// add
//#define AMQP_QUEUE_DECLARE_OK_METHOD ((amqp_method_number_t) 0x0032000B) /* 50, 11; 3276811 */ 
extern(C)
	struct amqp_queue_declare_ok_t_
	{
		amqp_bytes_t queue;
		uint32_t message_count;
		uint32_t consumer_count;
	};

//add
//#define AMQP_CHANNEL_OPEN_OK_METHOD ((amqp_method_number_t) 0x0014000B) /* 20, 11; 1310731 */ 
extern(C)
	struct amqp_channel_open_ok_t_
	{
	};

//add	
//#define AMQP_QUEUE_BIND_OK_METHOD ((amqp_method_number_t) 0x00320015) /* 50, 21; 3276821 */ 
extern(C)
	struct amqp_queue_bind_ok_t_
	{
	};

//add
//	#define AMQP_BASIC_CONSUME_OK_METHOD ((amqp_method_number_t) 0x003C0015) /* 60, 21; 3932181 */ 
extern(C)
	struct amqp_basic_consume_ok_t_
	{
		amqp_bytes_t consumer_tag;
	};

//	#define AMQP_EMPTY_BYTES ((amqp_bytes_t) { .len = 0, .bytes = NULL }) 
	
//changes
extern(C)
	struct amqp_connection_state_t_
	{
		amqp_pool_t_ frame_pool;
		amqp_pool_t_ decoding_pool;

		amqp_connection_state_enum_ state;

		int channel_max;
		int frame_max;
		int heartbeat;
		amqp_bytes_t_ inbound_buffer;

		size_t inbound_offset;
		size_t target_size;

		amqp_bytes_t_ outbound_buffer;

		int sockfd;
		amqp_bytes_t_ sock_inbound_buffer;
		size_t sock_inbound_offset;
		size_t sock_inbound_limit;

		amqp_link_t_* first_queued_frame;
		amqp_link_t_* last_queued_frame;
	};

// nochanges
extern(C)
	int amqp_simple_wait_frame(amqp_connection_state_t_* state, amqp_frame_t* decoded_frame);

// nochanges
extern(C)
	struct amqp_basic_properties_t_
	{
		amqp_flags_t _flags;
		amqp_bytes_t content_type;
		amqp_bytes_t content_encoding;
		amqp_table_t headers;
		uint8_t delivery_mode;
		uint8_t priority;
		amqp_bytes_t correlation_id;
		amqp_bytes_t reply_to;
		amqp_bytes_t expiration;
		amqp_bytes_t message_id;

		uint64_t timestamp;
		amqp_bytes_t type;
		amqp_bytes_t user_id;
		amqp_bytes_t app_id;
		amqp_bytes_t cluster_id;
	};

alias amqp_basic_properties_t_ amqp_basic_properties_t;

// nochanges
extern(C)
	void amqp_maybe_release_buffers(amqp_connection_state_t_* state);

// nochanges
extern(C)
	struct amqp_basic_deliver_t
	{
		amqp_bytes_t_ consumer_tag;
		uint64_t delivery_tag;
		amqp_boolean_t redelivered;
		amqp_bytes_t_ exchange;
		amqp_bytes_t_ routing_key;
	};

/*
 typedef struct amqp_frame_t_ {
 uint8_t frame_type; 
 amqp_channel_t channel;
 union {
 amqp_method_t method;
 struct {
 uint16_t class_id;
 uint64_t body_size;
 void *decoded;
 } properties;
 amqp_bytes_t body_fragment;
 struct {
 uint8_t transport_high;
 uint8_t transport_low;
 uint8_t protocol_version_major;
 uint8_t protocol_version_minor;
 } protocol_header;
 } payload;
 } amqp_frame_t;

 */

// nochanges
struct this_struct_reserved_space_for_emulate_union_payload
{
	uint16_t class_id;
	uint64_t body_size;
	void* decoded;
}

// nochanges
extern(C)
	struct amqp_frame_t_
	{
		uint8_t frame_type; /* 0 means no event - uint8_t*/
		amqp_channel_t channel;
		this_struct_reserved_space_for_emulate_union_payload area;
	};

// nochanges
extern(C)
	struct amqp_queue_bind_t
	{
		uint16_t ticket;
		amqp_bytes_t_ queue;
		amqp_bytes_t_ exchange;
		amqp_bytes_t_ routing_key;
		amqp_boolean_t nowait;
		amqp_table_t_ arguments;
	};

// nochanges
extern(C)
	struct amqp_basic_consume_t
	{
		uint16_t ticket;
		amqp_bytes_t_ queue;
		amqp_bytes_t_ consumer_tag;
		amqp_boolean_t no_local;
		amqp_boolean_t no_ack;
		amqp_boolean_t exclusive;
		amqp_boolean_t nowait;
	};

// nochanges
extern(C)
	amqp_bytes_t_ amqp_bytes_malloc_dup(amqp_bytes_t_ src);

/*
 #define AMQP_QUEUE_DECLARE_OK_METHOD ((amqp_method_number_t) 0x0032000B) //* 50, 11; 3276811 *
 typedef struct amqp_queue_declare_ok_t_ {
 amqp_bytes_t queue;
 uint32_t message_count;
 uint32_t consumer_count;
 } amqp_queue_declare_ok_t;
 */
// nochanges
extern(C)
	struct amqp_queue_declare_ok_t
	{
		amqp_bytes_t_ queue;
		uint32_t message_count;
		uint32_t consumer_count;
	};

enum amqp_def
{
	AMQP_REPLY_SUCCESS = 200,
	AMQP_FRAME_BODY = 3,
	AMQP_BASIC_CONTENT_TYPE_FLAG = (1 << 15),
	//	#define AMQP_BASIC_DELIVERY_MODE_FLAG (1 << 12) 
	AMQP_BASIC_DELIVERY_MODE_FLAG = (1 << 12),
	AMQP_FRAME_HEADER = 2,
	AMQP_FRAME_METHOD = 1,

	AMQP_QUEUE_DECLARE_METHOD = cast(amqp_method_number_t) 0x0032000A /* 50, 10; 3276810 */,

	//#define AMQP_QUEUE_DECLARE_OK_METHOD ((amqp_method_number_t) 0x0032000B) /* 50, 11; 3276811 */ 
	AMQP_QUEUE_DECLARE_OK_METHOD = cast(amqp_method_number_t) 0x0032000B /* 50, 11; 3276811 */,
	AMQP_BASIC_CONSUME_METHOD = cast(amqp_method_number_t) 0x003C0014 /* 60, 20; 3932180 */,
	AMQP_BASIC_CONSUME_OK_METHOD = cast(amqp_method_number_t) 0x003C0015 /* 60, 21; 3932181 */,
	AMQP_QUEUE_BIND_METHOD = cast(amqp_method_number_t) 0x00320014 /* 50, 20; 3276820 */,
	AMQP_QUEUE_BIND_OK_METHOD = cast(amqp_method_number_t) 0x00320015 /* 50, 21; 3276821 */,
	AMQP_BASIC_DELIVER_METHOD = cast(amqp_method_number_t) 0x003C003C /* 60, 60; 3932220 */,
	ENOMEM = -500
};

typedef uint16_t amqp_channel_t;

/*
 extern amqp_rpc_reply_t amqp_simple_rpc(amqp_connection_state_t state,
 amqp_channel_t channel,
 amqp_method_number_t request_id,
 amqp_method_number_t expected_reply_id,
 void *decoded_request_method);
 */
// nochanges
extern(C)
	amqp_rpc_reply_t_ amqp_simple_rpc(amqp_connection_state_t_* state, amqp_channel_t channel, amqp_method_number_t request_id,
			amqp_method_number_t expected_reply_id, void* decoded_request_method);

// nochanges
extern(C)
	struct amqp_decimal_t_
	{
		int decimals;
		uint32_t value;
	};

/*
 typedef struct amqp_table_entry_t_ { 
 amqp_bytes_t key; 
 char kind; 
 union { 
 amqp_bytes_t bytes; 
 int32_t i32; 
 amqp_decimal_t decimal; 
 uint64_t u64; 
 amqp_table_t table; 
 } value; 
 } amqp_table_entry_t; 
 */

// nochanges
extern(C)
	struct amqp_table_entry_t_
	{
		amqp_bytes_t_ key;
		char kind;

		amqp_bytes_t_ value_bytes;
		int32_t value_i32;
		amqp_decimal_t_ value_decimal;
		uint64_t value_u64;
		amqp_table_t_ value_table;
	};

// nochanges
extern(C)
	amqp_bytes_t_ amqp_cstring_bytes(char* cstr);

typedef int amqp_boolean_t;

/*
 #define AMQP_QUEUE_DECLARE_METHOD ((amqp_method_number_t) 0x0032000A) //* 50, 10; 3276810 *
 typedef struct amqp_queue_declare_t_ {
 uint16_t ticket;
 amqp_bytes_t queue;
 amqp_boolean_t passive;
 amqp_boolean_t durable;
 amqp_boolean_t exclusive;
 amqp_boolean_t auto_delete;
 amqp_boolean_t nowait;
 amqp_table_t arguments;
 } amqp_queue_declare_t;
 */
// nochanges
extern(C)
	struct amqp_queue_declare_t
	{
		uint16_t ticket;
		amqp_bytes_t_ queue;
		amqp_boolean_t passive;
		amqp_boolean_t durable;
		amqp_boolean_t exclusive;
		amqp_boolean_t auto_delete;
		amqp_boolean_t nowait;
		amqp_table_t_ arguments;
	};

/*
 typedef struct amqp_method_t_ {
 amqp_method_number_t id;
 void *decoded;
 } amqp_method_t;
 */
// nochanges
extern(C)
	struct amqp_method_t_
	{
		amqp_method_number_t id;
		void* decoded;
	};

// nochanges
enum amqp_sasl_method_enum
{
	AMQP_SASL_METHOD_PLAIN = 0
};

/*
 typedef enum amqp_response_type_enum_ { 
 AMQP_RESPONSE_NONE = 0, 
 AMQP_RESPONSE_NORMAL, 
 AMQP_RESPONSE_LIBRARY_EXCEPTION, 
 AMQP_RESPONSE_SERVER_EXCEPTION 
 } amqp_response_type_enum;
 */
// nochanges
enum amqp_response_type_enum
{
	AMQP_RESPONSE_NONE = 0,
	AMQP_RESPONSE_NORMAL,
	AMQP_RESPONSE_LIBRARY_EXCEPTION,
	AMQP_RESPONSE_SERVER_EXCEPTION
};

extern(C)
	amqp_connection_state_t_ amqp_new_connection();

extern(C)
	int amqp_open_socket(char* hostname, int portnumber);

extern(C)
	void amqp_set_sockfd(amqp_connection_state_t_* state, int sockfd);

/*
 extern amqp_rpc_reply_t amqp_login(amqp_connection_state_t state,
 char const *vhost,
 int channel_max,
 int frame_max,
 int heartbeat,
 amqp_sasl_method_enum sasl_method, ...);
 */
// changes
extern(C)
	amqp_rpc_reply_t_ amqp_login(amqp_connection_state_t_* state, char* vhost, int channel_max, int frame_max, int heartbeat,
			amqp_sasl_method_enum sasl_method, ...);

/*
 typedef struct amqp_rpc_reply_t_ {
 amqp_response_type_enum reply_type;
 amqp_method_t reply;
 int library_errno; // if AMQP_RESPONSE_LIBRARY_EXCEPTION, then 0 here means socket EOF 
 } amqp_rpc_reply_t;
 */
// nochanges
extern(C)
	struct amqp_rpc_reply_t_
	{
		amqp_response_type_enum reply_type;
		amqp_method_t_ reply;
		int library_errno; /* if AMQP_RESPONSE_LIBRARY_EXCEPTION, then 0 here means socket EOF */
	};

/*
 typedef struct amqp_link_t_ {
 struct amqp_link_t_ *next;
 void *data;
 } amqp_link_t;
 */
// nochanges
extern(C)
	struct amqp_link_t_
	{
		amqp_link_t_* next;
		void* data;
	};

/*
 typedef struct amqp_pool_blocklist_t_ {
 int num_blocks;
 void **blocklist;
 } amqp_pool_blocklist_t;
 */
// nochanges
extern(C)
	struct amqp_pool_blocklist_t_
	{
		int num_blocks;
		void** blocklist;
	};

/*
 typedef struct amqp_pool_t_ {
 size_t pagesize;

 amqp_pool_blocklist_t pages;
 amqp_pool_blocklist_t large_blocks;

 int next_page;
 char *alloc_block;
 size_t alloc_used;
 } amqp_pool_t;
 */
// nochanges
extern(C)
	struct amqp_pool_t_
	{
		size_t pagesize;

		amqp_pool_blocklist_t_ pages;
		amqp_pool_blocklist_t_ large_blocks;

		int next_page;
		char* alloc_block;
		size_t alloc_used;
	};

/*
 extern int amqp_basic_publish(amqp_connection_state_t state,
 amqp_channel_t channel,
 amqp_bytes_t exchange,
 amqp_bytes_t routing_key,
 amqp_boolean_t mandatory,
 amqp_boolean_t immediate,
 struct amqp_basic_properties_t_ const *properties,
 amqp_bytes_t body);
 */
// changes
extern(C)
	int amqp_basic_publish(amqp_connection_state_t_* state, amqp_channel_t channel, amqp_bytes_t exchange, amqp_bytes_t routing_key,
			amqp_boolean_t mandatory, amqp_boolean_t immediate, amqp_basic_properties_t_* properties, amqp_bytes_t message_body);

/*
 extern struct amqp_channel_open_ok_t_ *amqp_channel_open(amqp_connection_state_t state,
 amqp_channel_t channel);
 */
// add
extern(C)
	amqp_channel_open_ok_t_* amqp_channel_open(amqp_connection_state_t_* state, amqp_channel_t channel);

/*
 extern amqp_rpc_reply_t amqp_channel_close(amqp_connection_state_t state,
 amqp_channel_t channel,
 int code);
 */
// changes
extern(C)
	amqp_rpc_reply_t_ amqp_channel_close(amqp_connection_state_t_* state, amqp_channel_t channel, int code);

// nochanges
extern(C)
	amqp_rpc_reply_t_ amqp_connection_close(amqp_connection_state_t_* state, int code);

// nochanges
extern(C)
	void amqp_destroy_connection(amqp_connection_state_t_* state);

//extern() int shutdown (int __fd, int __how);
extern(C)
	int close(int __fd);

/*
 extern struct amqp_queue_declare_ok_t_ *amqp_queue_declare(amqp_connection_state_t state,
 amqp_channel_t channel,
 amqp_bytes_t queue,
 amqp_boolean_t passive,
 amqp_boolean_t durable,
 amqp_boolean_t exclusive,
 amqp_boolean_t auto_delete,
 amqp_table_t arguments);
 */
// add
extern(C)
	amqp_queue_declare_ok_t_* amqp_queue_declare(amqp_connection_state_t_* state, amqp_channel_t channel, amqp_bytes_t queue, amqp_boolean_t passive,
			amqp_boolean_t durable, amqp_boolean_t exclusive, amqp_boolean_t auto_delete, amqp_table_t arguments);

/*
 extern struct amqp_queue_bind_ok_t_ *amqp_queue_bind(amqp_connection_state_t state,
 amqp_channel_t channel,
 amqp_bytes_t queue,
 amqp_bytes_t exchange,
 amqp_bytes_t routing_key,
 amqp_table_t arguments);
 */
extern(C)
	amqp_queue_bind_ok_t_* amqp_queue_bind(amqp_connection_state_t_* state, amqp_channel_t channel, amqp_bytes_t queue, amqp_bytes_t exchange,
			amqp_bytes_t routing_key, amqp_table_t arguments);

/*
 extern struct amqp_basic_consume_ok_t_ *amqp_basic_consume(amqp_connection_state_t state,
 amqp_channel_t channel,
 amqp_bytes_t queue,
 amqp_bytes_t consumer_tag,
 amqp_boolean_t no_local,
 amqp_boolean_t no_ack,
 amqp_boolean_t exclusive);
 */
extern(C)
	amqp_basic_consume_ok_t_* amqp_basic_consume(amqp_connection_state_t_* state, amqp_channel_t channel, amqp_bytes_t queue,
			amqp_bytes_t consumer_tag, amqp_boolean_t no_local, amqp_boolean_t no_ack, amqp_boolean_t exclusive);
