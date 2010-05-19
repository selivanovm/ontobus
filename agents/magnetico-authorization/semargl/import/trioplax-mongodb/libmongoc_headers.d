/* always non-zero */
enum mongo_exception_type{
    MONGO_EXCEPT_NETWORK=1,
        MONGO_EXCEPT_FIND_ERR
        };
        
alias int socklen_t;
alias int bson_bool_t;

alias byte int8_t;
alias ubyte uint8_t;

alias short int16_t;
alias ushort uint16_t;

alias int int32_t;
alias uint uint32_t;

alias long int64_t;
alias ulong uint64_t;
        
enum: int
{
        AF_UNSPEC =     0,
        AF_UNIX =       1,
        AF_INET =       2,
        AF_IPX =        4,
        AF_APPLETALK =  5,
        AF_INET6 =      10,
        // ...

        PF_UNSPEC =     AF_UNSPEC,
        PF_UNIX =       AF_UNIX,
        PF_INET =       AF_INET,
        PF_IPX =        AF_IPX,
        PF_APPLETALK =  AF_APPLETALK,
        PF_INET6 =      AF_INET6,
}

enum bson_type
{
    bson_eoo=0 ,
    bson_double=1,
    bson_string=2,
    bson_object=3,
    bson_array=4,
    bson_bindata=5,
    bson_undefined=6,
    bson_oid=7,
    bson_bool=8,
    bson_date=9,
    bson_null=10,
    bson_regex=11,
    bson_dbref=12, /* deprecated */
    bson_code=13,
    bson_symbol=14,
    bson_codewscope=15,
    bson_int = 16,
    bson_timestamp = 17,
    bson_long = 18
};



extern(C) struct mongo_connection_options {
    byte host[255];
    int port;
};

extern(C) struct mongo_connection { 
    mongo_connection_options* left_opts; /* always current server */ 
    mongo_connection_options* right_opts; /* unused with single server */ 
    sockaddr_in sa; 
    socklen_t addressSize; 
    int sock; 
    bson_bool_t connected; 
    mongo_exception_context exception; 
}; 

extern(C) struct sockaddr_in
{
        int16_t sin_family = AF_INET;
        uint16_t sin_port;
        in_addr sin_addr;
        ubyte[8] sin_zero;
};

extern(C) struct jmp_buf
{
    ulong D2, D3, D4, D5, D6, D7;
    ulong A2, A3, A4, A5, A6, A7;
    ulong PC;
};

extern(C) struct mongo_exception_context{ 
  jmp_buf base_handler; 
  jmp_buf *penv; 
  int caught; 
  mongo_exception_type type; 
}; 

extern(C) union in_addr
{
	private union _S_un_t
	{
		private struct _S_un_b_t
		{
			uint8_t s_b1, s_b2, s_b3, s_b4;
		}
		_S_un_b_t S_un_b;
		
		private struct _S_un_w_t
		{
			uint16_t s_w1, s_w2;
		}
		_S_un_w_t S_un_w;
		
		uint32_t S_addr;
	}
	_S_un_t S_un;
	
	uint32_t s_addr;
	
	struct
	{
		uint8_t s_net, s_host;
		
		union
		{
			uint16_t s_imp;
			
			struct
			{
				uint8_t s_lh, s_impno;
			}
		}
	}
}

extern(C) struct bson{
    char * data;
    bson_bool_t owned;
    };
        
extern(C) struct mongo_cursor{
    mongo_reply * mm; /* message is owned by cursor */
    mongo_connection * conn; /* connection is *not* owned by cursor */
    const char* ns; /* owned by cursor */
    bson current;
};

extern(C) struct mongo_reply_fields{ 
    int flag; /* non-zero on failure */ 
    int64_t cursorID; 
    int start; 
    int num; 
}; 
 
extern(C) struct mongo_reply{ 
    mongo_header head; 
    mongo_reply_fields fields; 
    char objs; 
}; 

extern(C) struct mongo_header{
    int len;
    int id;
    int responseTo;
    int op;
};

enum mongo_conn_return {
    mongo_conn_success = 0,
    mongo_conn_bad_arg,
    mongo_conn_no_socket,
    mongo_conn_fail,
    mongo_conn_not_master /* leaves conn connected to slave */
};


extern(C) struct bson_buffer{
    char * buf;
    char * cur;
    int bufSize;
    bson_bool_t finished;
    int stack[32];
    int stackPos;
};

extern(C) union bson_oid_t{ 
    char bytes[12]; 
    int ints[3]; 
}; 

extern(C) struct bson_iterator{ 
    const char * cur; 
    bson_bool_t first; 
};

alias int64_t bson_date_t; /* milliseconds since epoch UTC */

extern (C):

version( Windows )
{
    alias int   c_long;
    alias uint  c_ulong;
}
else
{
  static if( (void*).sizeof > int.sizeof )
  {
    alias long  c_long;
    alias ulong c_ulong;
  }
  else
  {
    alias int   c_long;
    alias uint  c_ulong;
  }
}

alias c_long time_t;
 
/** 
 * @param options can be null 
 */
extern(C) mongo_conn_return mongo_connect( mongo_connection * conn , mongo_connection_options * options );
extern(C) mongo_conn_return mongo_connect_pair( mongo_connection * conn , mongo_connection_options * left, mongo_connection_options * right );
extern(C) mongo_conn_return mongo_reconnect( mongo_connection * conn ); /* you will need to reauthenticate after calling */
extern(C) bson_bool_t mongo_disconnect( mongo_connection * conn ); /* use this if you want to be able to reconnect */
extern(C) bson_bool_t mongo_destroy( mongo_connection * conn ); /* you must call this even if connection failed */

extern(C) bson_bool_t mongo_cmd_drop_collection(mongo_connection * conn, char * db, char * collection, bson * _out);

extern(C) bson_buffer * bson_buffer_init( bson_buffer * b );
extern(C) bson_buffer * bson_ensure_space( bson_buffer * b , int bytesNeeded );

extern(C) bson_buffer * bson_append_oid( bson_buffer * b , char * name , bson_oid_t* oid ); 
extern(C) bson_buffer * bson_append_new_oid( bson_buffer * b , char * name ); 
extern(C) bson_buffer * bson_append_int( bson_buffer * b , char * name , int i ); 
extern(C) bson_buffer * bson_append_long( bson_buffer * b , char * name , int64_t i );
extern(C) bson_buffer * bson_append_double( bson_buffer * b , char * name , double d );
extern(C) bson_buffer * bson_append_string( bson_buffer * b , char * name , char * str );
extern(C) bson_buffer * bson_append_symbol( bson_buffer * b , char * name , char * str );
extern(C) bson_buffer * bson_append_code( bson_buffer * b , char * name , char * str );
extern(C) bson_buffer * bson_append_code_w_scope( bson_buffer * b , char * name , char * code , bson * _scope);
extern(C) bson_buffer * bson_append_binary( bson_buffer * b, char * name, char type, char * str, int len );
extern(C) bson_buffer * bson_append_bool( bson_buffer * b , char * name , bson_bool_t v );
extern(C) bson_buffer * bson_append_null( bson_buffer * b , char * name );
extern(C) bson_buffer * bson_append_undefined( bson_buffer * b , char * name );
extern(C) bson_buffer * bson_append_regex( bson_buffer * b , char * name , char * pattern, char * opts );
extern(C) bson_buffer * bson_append_bson( bson_buffer * b , char * name , bson* bson);
extern(C) bson_buffer * bson_append_element( bson_buffer * b, char * name_or_null, bson_iterator* elem);

/* these both append a bson_date */
extern(C) bson_buffer * bson_append_date(bson_buffer * b, char * name, bson_date_t millis);
extern(C) bson_buffer * bson_append_time_t(bson_buffer * b, char * name, time_t secs);

extern(C) bson_buffer * bson_append_start_object( bson_buffer * b , char * name );
extern(C) bson_buffer * bson_append_start_array( bson_buffer * b , char * name );
extern(C) bson_buffer * bson_append_finish_object( bson_buffer * b );

extern(C) bson * bson_from_buffer(bson * b, bson_buffer * buf);

/* ---------------------------- 
   CORE METHODS - insert update remove query getmore 
   ------------------------------ */
    
extern(C) void mongo_insert( mongo_connection * conn , char * ns , bson * data );
extern(C) void mongo_insert_batch( mongo_connection * conn , char * ns , bson ** data , int num );

static const int MONGO_UPDATE_UPSERT = 0x1;
static const int MONGO_UPDATE_MULTI = 0x2;
extern(C) void mongo_update(mongo_connection* conn, char* ns, bson* cond, bson* op, int flags);
    
extern(C) void mongo_remove(mongo_connection* conn, char* ns, bson* cond);

extern(C) mongo_cursor* mongo_find(mongo_connection* conn, char* ns, bson* query, bson* fields ,int nToReturn ,int nToSkip, int options);
extern(C) bson_bool_t mongo_cursor_next(mongo_cursor* cursor);
extern(C) void mongo_cursor_destroy(mongo_cursor* cursor);
    
/* out can be NULL if you don't care about results. useful for commands */
extern(C) bson_bool_t mongo_find_one(mongo_connection* conn, char* ns, bson* query, bson* fields, bson* _out);
    
extern(C) int64_t mongo_count(mongo_connection* conn, char* db, char* coll, bson* query);



extern(C) void bson_destroy( bson * b );


/* ---------------------------- 
   HIGHER LEVEL - indexes - command helpers eval 
      ------------------------------ */
          
 /* Returns true on success */
 /* WARNING: Unlike other drivers these do not cache results */
          
static const int MONGO_INDEX_UNIQUE = 0x1;
static const int MONGO_INDEX_DROP_DUPS = 0x2;
extern (C)  bson_bool_t mongo_create_index(mongo_connection * conn, char * ns, bson * key, int options, bson * _out);
extern (C)  bson_bool_t mongo_create_simple_index(mongo_connection * conn, char * ns, char* field, int options, bson * _out);





extern (C) void bson_iterator_init( bson_iterator * i , char * bson );

/* more returns true for eoo. best to loop with bson_iterator_next(&it) */
extern (C) bson_bool_t bson_iterator_more( bson_iterator * i );
extern (C) bson_type bson_iterator_next( bson_iterator * i );

          
extern (C) bson_type bson_iterator_type(bson_iterator * i );
extern (C) char * bson_iterator_key(bson_iterator * i );
extern (C) char * bson_iterator_value(bson_iterator * i );
/* these convert to the right type (return 0 if non-numeric) */

extern (C) double bson_iterator_double( bson_iterator * i );
extern (C) int bson_iterator_int( bson_iterator * i );
extern (C) int64_t bson_iterator_long( bson_iterator * i );

/* false: boolean false, 0 in any type, or null */
/* true: anything else (even empty strings and objects) */
extern (C) bson_bool_t bson_iterator_bool( bson_iterator * i );

/* these assume you are using the right type */
extern (C) double bson_iterator_double_raw( bson_iterator * i );
extern (C) int bson_iterator_int_raw( bson_iterator * i );
extern (C) int64_t bson_iterator_long_raw( bson_iterator * i );
extern (C) bson_bool_t bson_iterator_bool_raw( bson_iterator * i );
extern (C) bson_oid_t* bson_iterator_oid( bson_iterator * i );

/* these can also be used with bson_code and bson_symbol*/
extern (C) char * bson_iterator_string( bson_iterator * i );
extern (C) int bson_iterator_string_len( bson_iterator * i );

/* str must be at least 24 hex chars + null byte */
extern (C) void bson_oid_from_string(bson_oid_t* oid, char* str);
extern (C) void bson_oid_to_string(bson_oid_t* oid, char* str);
extern (C) void bson_oid_gen(bson_oid_t* oid);

/* these work with bson_object and bson_array */
extern (C) void bson_iterator_subobject(bson_iterator * i, bson * sub);
extern (C) void bson_iterator_subiterator(bson_iterator * i, bson_iterator * sub);
