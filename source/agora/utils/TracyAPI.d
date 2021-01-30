/*******************************************************************************

    Binding for Tracy C API

    See_Also:
        https://github.com/wolfpld/tracy

    Copyright:
        Copyright (c) 2021 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.TracyAPI;

extern(C):
@system:
nothrow:
@nogc:


void ___tracy_set_thread_name (const(char)* name);

struct ___tracy_source_location_data
{
    const(char)* name;
    const(char)* function_;
    const(char)* file;
    uint line;
    uint color;
}

struct ___tracy_c_zone_context
{
    uint id;
    int active; // TODO: C int
}

// Some containers don't support storing const types.
// This struct, as visible to user, is immutable, so treat it as if const was declared here.
alias TracyCZoneCtx = const(___tracy_c_zone_context);

void ___tracy_init_thread ();
ulong ___tracy_alloc_srcloc (uint line, const(char)* source, size_t sourceSz,
                             const(char)* function_, size_t functionSz);
ulong ___tracy_alloc_srcloc_name (uint line, const(char)* source, size_t sourceSz,
                                  const(char)* function_, size_t functionSz,
                                  const(char)* name, size_t nameSz);

TracyCZoneCtx ___tracy_emit_zone_begin (const(___tracy_source_location_data)* srcloc, int active);
TracyCZoneCtx ___tracy_emit_zone_begin_callstack (const(___tracy_source_location_data)* srcloc, int depth, int active);
TracyCZoneCtx ___tracy_emit_zone_begin_alloc (ulong srcloc, int active);
TracyCZoneCtx ___tracy_emit_zone_begin_alloc_callstack (ulong srcloc, int depth, int active);
void ___tracy_emit_zone_end (TracyCZoneCtx ctx);
void ___tracy_emit_zone_text (TracyCZoneCtx ctx, const(char)* txt, size_t size);
void ___tracy_emit_zone_name (TracyCZoneCtx ctx, const(char)* txt, size_t size);
void ___tracy_emit_zone_color (TracyCZoneCtx ctx, uint color);
void ___tracy_emit_zone_value (TracyCZoneCtx ctx, ulong value);

// #if defined TRACY_HAS_CALLSTACK && defined TRACY_CALLSTACK
// #  define TracyCZone( ctx, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { NULL, __FUNCTION__,  __FILE__, (uint)__LINE__, 0 }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin_callstack( &TracyConcat(__tracy_source_location,__LINE__), TRACY_CALLSTACK, active);
// #  define TracyCZoneN( ctx, name, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { name, __FUNCTION__,  __FILE__, (uint)__LINE__, 0 }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin_callstack( &TracyConcat(__tracy_source_location,__LINE__), TRACY_CALLSTACK, active);
// #  define TracyCZoneC( ctx, color, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { NULL, __FUNCTION__,  __FILE__, (uint)__LINE__, color }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin_callstack( &TracyConcat(__tracy_source_location,__LINE__), TRACY_CALLSTACK, active);
// #  define TracyCZoneNC( ctx, name, color, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { name, __FUNCTION__,  __FILE__, (uint)__LINE__, color }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin_callstack( &TracyConcat(__tracy_source_location,__LINE__), TRACY_CALLSTACK, active);
// #else
// #  define TracyCZone( ctx, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { NULL, __FUNCTION__,  __FILE__, (uint)__LINE__, 0 }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin( &TracyConcat(__tracy_source_location,__LINE__), active);
// #  define TracyCZoneN( ctx, name, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { name, __FUNCTION__,  __FILE__, (uint)__LINE__, 0 }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin( &TracyConcat(__tracy_source_location,__LINE__), active);
// #  define TracyCZoneC( ctx, color, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { NULL, __FUNCTION__,  __FILE__, (uint)__LINE__, color }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin( &TracyConcat(__tracy_source_location,__LINE__), active);
// #  define TracyCZoneNC( ctx, name, color, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { name, __FUNCTION__,  __FILE__, (uint)__LINE__, color }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin( &TracyConcat(__tracy_source_location,__LINE__), active);
// #endif

alias TracyCZoneEnd = ___tracy_emit_zone_end;
alias TracyCZoneText  = ___tracy_emit_zone_text;
alias TracyCZoneName  = ___tracy_emit_zone_name;
alias TracyCZoneColor = ___tracy_emit_zone_color;
alias TracyCZoneValue = ___tracy_emit_zone_value;

void ___tracy_emit_memory_alloc (const(void)* ptr, size_t size, int secure);
void ___tracy_emit_memory_alloc_callstack (const(void)* ptr, size_t size, int depth, int secure);
void ___tracy_emit_memory_free (const(void)* ptr, int secure);
void ___tracy_emit_memory_free_callstack (const(void)* ptr, int depth, int secure);

void ___tracy_emit_message (const(char)* txt, size_t size, int callstack);
void ___tracy_emit_messageL (const(char)* txt, int callstack);
void ___tracy_emit_messageC (const(char)* txt, size_t size, uint color, int callstack);
void ___tracy_emit_messageLC (const(char)* txt, uint color, int callstack);

// void TracyCAlloc (const(void)* ptr, size_t size) { return ___tracy_emit_memory_alloc(ptr, size, 0); }
// void TracyCFree (const(void)* ptr) { return ___tracy_emit_memory_free(ptr, 0); }
// void TracyCSecureAlloc (const(void)* ptr, size_t size) { return ___tracy_emit_memory_alloc(ptr, size, 1); }
// void TracyCSecureFree (const(void)* ptr) { return ___tracy_emit_memory_free(ptr, 1); }

// void TracyCAllocN(const(void)* ptr, size_t size, name ) ___tracy_emit_memory_alloc_named( ptr, size, 0, name);
// #  define TracyCFreeN( ptr, name ) ___tracy_emit_memory_free_named( ptr, 0, name);
// #  define TracyCSecureAllocN( ptr, size, name ) ___tracy_emit_memory_alloc_named( ptr, size, 1, name);
// #  define TracyCSecureFreeN( ptr, name ) ___tracy_emit_memory_free_named( ptr, 1, name);

// #  define TracyCMessage( txt, size ) ___tracy_emit_message( txt, size, 0);
// #  define TracyCMessageL( txt ) ___tracy_emit_messageL( txt, 0);
// #  define TracyCMessageC( txt, size, color ) ___tracy_emit_messageC( txt, size, color, 0);
// #  define TracyCMessageLC( txt, color ) ___tracy_emit_messageLC( txt, color, 0);


void ___tracy_emit_frame_mark (const(char)* name);
void ___tracy_emit_frame_mark_start (const(char)* name);
void ___tracy_emit_frame_mark_end (const(char)* name);
void ___tracy_emit_frame_image (const(void)* image, ushort w, ushort h, ubyte offset, int flip);

// #define TracyCFrameMark ___tracy_emit_frame_mark( 0);
// #define TracyCFrameMarkNamed( name ) ___tracy_emit_frame_mark( name);
// #define TracyCFrameMarkStart( name ) ___tracy_emit_frame_mark_start( name);
// #define TracyCFrameMarkEnd( name ) ___tracy_emit_frame_mark_end( name);
// #define TracyCFrameImage( image, width, height, offset, flip ) ___tracy_emit_frame_image( image, width, height, offset, flip);


void ___tracy_emit_plot (const(char)* name, double val);
void ___tracy_emit_message_appinfo (const(char)* txt, size_t size);

alias TracyCPlot = ___tracy_emit_plot;
alias TracyCAppInfo = ___tracy_emit_message_appinfo;


// #  define TracyCZoneS( ctx, depth, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { NULL, __FUNCTION__,  __FILE__, (uint)__LINE__, 0 }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin_callstack( &TracyConcat(__tracy_source_location,__LINE__), depth, active);
// #  define TracyCZoneNS( ctx, name, depth, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { name, __FUNCTION__,  __FILE__, (uint)__LINE__, 0 }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin_callstack( &TracyConcat(__tracy_source_location,__LINE__), depth, active);
// #  define TracyCZoneCS( ctx, color, depth, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { NULL, __FUNCTION__,  __FILE__, (uint)__LINE__, color }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin_callstack( &TracyConcat(__tracy_source_location,__LINE__), depth, active);
// #  define TracyCZoneNCS( ctx, name, color, depth, active ) static const struct ___tracy_source_location_data TracyConcat(__tracy_source_location,__LINE__) = { name, __FUNCTION__,  __FILE__, (uint)__LINE__, color }; TracyCZoneCtx ctx = ___tracy_emit_zone_begin_callstack( &TracyConcat(__tracy_source_location,__LINE__), depth, active);

// #  define TracyCAllocS( ptr, size, depth ) ___tracy_emit_memory_alloc_callstack( ptr, size, depth, 0 )
// #  define TracyCFreeS( ptr, depth ) ___tracy_emit_memory_free_callstack( ptr, depth, 0 )
// #  define TracyCSecureAllocS( ptr, size, depth ) ___tracy_emit_memory_alloc_callstack( ptr, size, depth, 1 )
// #  define TracyCSecureFreeS( ptr, depth ) ___tracy_emit_memory_free_callstack( ptr, depth, 1 )

// #  define TracyCAllocNS( ptr, size, depth, name ) ___tracy_emit_memory_alloc_callstack_named( ptr, size, depth, 0, name )
// #  define TracyCFreeNS( ptr, depth, name ) ___tracy_emit_memory_free_callstack_named( ptr, depth, 0, name )
// #  define TracyCSecureAllocNS( ptr, size, depth, name ) ___tracy_emit_memory_alloc_callstack_named( ptr, size, depth, 1, name )
// #  define TracyCSecureFreeNS( ptr, depth, name ) ___tracy_emit_memory_free_callstack_named( ptr, depth, 1, name )

// #  define TracyCMessageS( txt, size, depth ) ___tracy_emit_message( txt, size, depth);
// #  define TracyCMessageLS( txt, depth ) ___tracy_emit_messageL( txt, depth);
// #  define TracyCMessageCS( txt, size, color, depth ) ___tracy_emit_messageC( txt, size, color, depth);
// #  define TracyCMessageLCS( txt, color, depth ) ___tracy_emit_messageLC( txt, color, depth);
