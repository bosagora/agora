/*******************************************************************************

    DLang bindings for MaxMindDB C library generated with jacob-carlborg/dstep.

    The following simple changes were made after generating the bindings

    1. type `mmdb_uint128_t` is defined as ubyte[16], becuase DLang currently
       doesn't support 16 byte integers natively.

    2. union member of MMDB_entry_data_s had to be aligned manually to 16
       bytes boundary

    3. `import core.stdc.stdarg : va_list` was added

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module mmdb.MaxMindDB;

import core.stdc.stdarg : va_list;
import core.stdc.stdio;
import core.sys.posix.netinet.in_;

extern (C):

/* Request POSIX.1-2008. However, we want to remain compatible with
 * POSIX.1-2001 (since we have been historically and see no reason to drop
 * compatibility). By requesting POSIX.1-2008, we can conditionally use
 * features provided by that standard if the implementation provides it. We can
 * check for what the implementation provides by checking the _POSIX_VERSION
 * macro after including unistd.h. If a feature is in POSIX.1-2008 but not
 * POSIX.1-2001, check that macro before using the feature (or check for the
 * feature directly if possible). */

enum _POSIX_C_SOURCE = 2008_09L;

/* libmaxminddb package version from configure */

/* MSVC doesn't define signed size_t, copy it from configure */

/* MSVC doesn't support restricted pointers */

enum MMDB_DATA_TYPE_EXTENDED = 0;
enum MMDB_DATA_TYPE_POINTER = 1;
enum MMDB_DATA_TYPE_UTF8_STRING = 2;
enum MMDB_DATA_TYPE_DOUBLE = 3;
enum MMDB_DATA_TYPE_BYTES = 4;
enum MMDB_DATA_TYPE_UINT16 = 5;
enum MMDB_DATA_TYPE_UINT32 = 6;
enum MMDB_DATA_TYPE_MAP = 7;
enum MMDB_DATA_TYPE_INT32 = 8;
enum MMDB_DATA_TYPE_UINT64 = 9;
enum MMDB_DATA_TYPE_UINT128 = 10;
enum MMDB_DATA_TYPE_ARRAY = 11;
enum MMDB_DATA_TYPE_CONTAINER = 12;
enum MMDB_DATA_TYPE_END_MARKER = 13;
enum MMDB_DATA_TYPE_BOOLEAN = 14;
enum MMDB_DATA_TYPE_FLOAT = 15;

enum MMDB_RECORD_TYPE_SEARCH_NODE = 0;
enum MMDB_RECORD_TYPE_EMPTY = 1;
enum MMDB_RECORD_TYPE_DATA = 2;
enum MMDB_RECORD_TYPE_INVALID = 3;

/* flags for open */
enum MMDB_MODE_MMAP = 1;
enum MMDB_MODE_MASK = 7;

/* error codes */
enum MMDB_SUCCESS = 0;
enum MMDB_FILE_OPEN_ERROR = 1;
enum MMDB_CORRUPT_SEARCH_TREE_ERROR = 2;
enum MMDB_INVALID_METADATA_ERROR = 3;
enum MMDB_IO_ERROR = 4;
enum MMDB_OUT_OF_MEMORY_ERROR = 5;
enum MMDB_UNKNOWN_DATABASE_FORMAT_ERROR = 6;
enum MMDB_INVALID_DATA_ERROR = 7;
enum MMDB_INVALID_LOOKUP_PATH_ERROR = 8;
enum MMDB_LOOKUP_PATH_DOES_NOT_MATCH_DATA_ERROR = 9;
enum MMDB_INVALID_NODE_NUMBER_ERROR = 10;
enum MMDB_IPV6_LOOKUP_IN_IPV4_DATABASE_ERROR = 11;

alias mmdb_uint128_t = ubyte[16] ;

/* This is a pointer into the data section for a given IP address lookup */
struct MMDB_entry_s
{
    const(MMDB_s)* mmdb;
    uint offset;
}

struct MMDB_lookup_result_s
{
    bool found_entry;
    MMDB_entry_s entry;
    ushort netmask;
}

struct MMDB_entry_data_s
{
    bool has_data;

    align (16)
    union
    {
        uint pointer;
        const(char)* utf8_string;
        double double_value;
        const(ubyte)* bytes;
        ushort uint16;
        uint uint32;
        int int32;
        ulong uint64;

        mmdb_uint128_t uint128;

        bool boolean;
        float float_value;
    }

    /* This is a 0 if a given entry cannot be found. This can only happen
     * when a call to MMDB_(v)get_value() asks for hash keys or array
     * indices that don't exist. */
    uint offset;
    /* This is the next entry in the data section, but it's really only
     * relevant for entries that part of a larger map or array
     * struct. There's no good reason for an end user to look at this
     * directly. */
    uint offset_to_next;
    /* This is only valid for strings, utf8_strings or binary data */
    uint data_size;
    /* This is an MMDB_DATA_TYPE_* constant */
    uint type;
}

/* This is the return type when someone asks for all the entry data in a map or
 * array */
struct MMDB_entry_data_list_s
{
    MMDB_entry_data_s entry_data;
    MMDB_entry_data_list_s* next;
    void* pool;
}

struct MMDB_description_s
{
    const(char)* language;
    const(char)* description;
}

/* WARNING: do not add new fields to this struct without bumping the SONAME.
 * The struct is allocated by the users of this library and increasing the
 * size will cause existing users to allocate too little space when the shared
 * library is upgraded */
struct MMDB_metadata_s
{
    uint node_count;
    ushort record_size;
    ushort ip_version;
    const(char)* database_type;

    struct _Anonymous_0
    {
        size_t count;
        const(char*)* names;
    }

    _Anonymous_0 languages;
    ushort binary_format_major_version;
    ushort binary_format_minor_version;
    ulong build_epoch;

    struct _Anonymous_1
    {
        size_t count;
        MMDB_description_s** descriptions;
    }

    _Anonymous_1 description;
    /* See above warning before adding fields */
}

/* WARNING: do not add new fields to this struct without bumping the SONAME.
 * The struct is allocated by the users of this library and increasing the
 * size will cause existing users to allocate too little space when the shared
 * library is upgraded */
struct MMDB_ipv4_start_node_s
{
    ushort netmask;
    uint node_value;
    /* See above warning before adding fields */
}

/* WARNING: do not add new fields to this struct without bumping the SONAME.
 * The struct is allocated by the users of this library and increasing the
 * size will cause existing users to allocate too little space when the shared
 * library is upgraded */
struct MMDB_s
{
    uint flags;
    const(char)* filename;
    ssize_t file_size;
    const(ubyte)* file_content;
    const(ubyte)* data_section;
    uint data_section_size;
    const(ubyte)* metadata_section;
    uint metadata_section_size;
    ushort full_record_byte_size;
    ushort depth;
    MMDB_ipv4_start_node_s ipv4_start_node;
    MMDB_metadata_s metadata;
    /* See above warning before adding fields */
}

struct MMDB_search_node_s
{
    ulong left_record;
    ulong right_record;
    ubyte left_record_type;
    ubyte right_record_type;
    MMDB_entry_s left_record_entry;
    MMDB_entry_s right_record_entry;
}

int MMDB_open (const char* filename, uint flags, MMDB_s* mmdb);
MMDB_lookup_result_s MMDB_lookup_string (
    const MMDB_s* mmdb,
    const char* ipstr,
    int* gai_error,
    int* mmdb_error);
MMDB_lookup_result_s MMDB_lookup_sockaddr (
    const MMDB_s* mmdb,
    const sockaddr* sockaddr,
    int* mmdb_error);
int MMDB_read_node (
    const MMDB_s* mmdb,
    uint node_number,
    MMDB_search_node_s* node);
int MMDB_get_value (MMDB_entry_s* start, MMDB_entry_data_s* entry_data, ...);
int MMDB_vget_value (
    MMDB_entry_s* start,
    MMDB_entry_data_s* entry_data,
    va_list va_path);
int MMDB_aget_value (
    MMDB_entry_s* start,
    MMDB_entry_data_s* entry_data,
    const char** path);
int MMDB_get_metadata_as_entry_data_list (
    const MMDB_s* mmdb,
    MMDB_entry_data_list_s** entry_data_list);
int MMDB_get_entry_data_list (
    MMDB_entry_s* start,
    MMDB_entry_data_list_s** entry_data_list);
void MMDB_free_entry_data_list (MMDB_entry_data_list_s* entry_data_list);
void MMDB_close (MMDB_s* mmdb);
const(char)* MMDB_lib_version ();
int MMDB_dump_entry_data_list (
    FILE* stream,
    MMDB_entry_data_list_s* entry_data_list,
    int indent);
const(char)* MMDB_strerror (int error_code);

/* MAXMINDDB_H */
