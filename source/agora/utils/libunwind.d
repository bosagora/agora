/**
 * Basic D language bindings for libunwind
 *
 * There are two available libunwind: The "upstream" one, inherited
 * from HP, which is maintained as a GNU project,
 * and the LLVM one, part of llvm-project, and the default on Mac OSX.
 *
 * They offer a similar interface for C[++] users, but this is based on
 * defines and other header attributes which we cannot reproduce in D.
 * Thus, this header contains bindings for both libraries, and the right
 * version needs to be selected when compiling Druntime.
 *
 * Authors: Mathias 'Geod24' Lang
 * Copyright: D Language Foundation - 2020
 * See_Also:
 *   - https://www.nongnu.org/libunwind/man/libunwind(3).html
 *   - https://clang.llvm.org/docs/Toolchain.html#unwind-library
 */
module agora.utils.libunwind;

// Libunwind supports Windows as well, but we currently use a different
// mechanism for Windows, so the bindings haven't been brought in yet.
version (CRuntime_Musl):

version = DRuntime_Use_LLVM_Libunwind;

import core.stdc.stdio;
import core.stdc.inttypes;

/// Ditto
public class LibunwindHandler : Throwable.TraceInfo
{
    private static struct FrameInfo
    {
        char[1024] buff = void;

        const(char)[] name;
        const(void)* address;
    }

    size_t numframes;
    enum MAXFRAMES = 128;
    FrameInfo[MAXFRAMES] callstack = void;

    /**
     * Create a new instance of this trace handler saving the current context
     *
     * Params:
     *   frames_to_skip = The number of frames leading to this one.
     */
    public this (size_t frames_to_skip = 1) nothrow @nogc
    {
        import core.stdc.string : strlen;

        static assert(typeof(FrameInfo.address).sizeof == unw_word_t.sizeof,
                      "Mismatch in type size for call to unw_get_proc_name");

        unw_context_t context;
        unw_cursor_t cursor;
        unw_getcontext(&context);
        unw_init_local(&cursor, &context);

        while (frames_to_skip > 0 && unw_step(&cursor) > 0)
            --frames_to_skip;

        unw_proc_info_t pip = void;
        foreach (idx, ref frame; this.callstack)
        {
            if (int r = unw_get_proc_name(
                    &cursor, frame.buff.ptr, frame.buff.length,
                    cast(unw_word_t*) &frame.address))
                frame.name = "<ERROR: Unable to retrieve function name>";
            else
                frame.name = frame.buff[0 .. strlen(frame.buff.ptr)];

            if (unw_get_proc_info(&cursor, &pip) == 0)
                frame.address += pip.start_ip;

            this.numframes++;
            if (unw_step(&cursor) <= 0)
                break;
        }
    }

    ///
    override int opApply (scope int delegate(ref const(char[])) dg) const
    {
        return this.opApply((ref size_t, ref const(char[]) buf) => dg(buf));
    }

    ///
    override int opApply (scope int delegate(ref size_t, ref const(char[])) dg) const
    {
        // This will be upstream, but we can't read debug infos yet
        //return traceHandlerOpApplyImpl2(this.callstack[0 .. this.numframes], dg);
        char[1024 + 64] buff;
        foreach (idx, const ref frame; this.callstack[0 .. this.numframes])
        {
            auto ret = snprintf(buff.ptr, buff.length, "[%p] %.*s\n", frame.address,
                                cast(int) frame.name.length, frame.name.ptr);
            if (ret <= 0)
                continue;

            auto lvalue = buff[0 .. ret];
            if (auto r2 = dg(idx, lvalue))
                return r2;
        }
        return 0;
    }

    ///
    override string toString () const
    {
        string buf;
        foreach ( i, line; this )
            buf ~= i ? "\n" ~ line : line;
        return buf;
    }
}

/**
 * Convenience function for power users wishing to test this module
 * See `core.runtime.defaultTraceHandler` for full documentation.
 */
Throwable.TraceInfo libunwindDefaultTraceHandler (void* ptr = null)
{
    // avoid recursive GC calls in finalizer, trace handlers should be made @nogc instead
    import core.memory;
    if (GC.inFinalizer())
        return null;

    return new LibunwindHandler();
}

extern(C):
@system:
@nogc:
nothrow:

/*
 * Bindings for libunwind.h
 */
alias unw_word_t = uintptr_t;

///
struct unw_context_t
{
    version (DRuntime_Use_LLVM_Libunwind)
        ulong[_LIBUNWIND_CONTEXT_SIZE] data = void;
    else
        unw_word_t[UNW_TDEP_CURSOR_LEN] opaque = void;
}

///
struct unw_cursor_t
{
    version (DRuntime_Use_LLVM_Libunwind)
        ulong[_LIBUNWIND_CURSOR_SIZE] data = void;
    else
        unw_tdep_context_t opaque = void;
}

///
struct unw_proc_info_t
{
    unw_word_t  start_ip;         /* start address of function */
    unw_word_t  end_ip;           /* address after end of function */
    unw_word_t  lsda;             /* address of language specific data area, */
    /*  or zero if not used */
    unw_word_t  handler;          /* personality routine, or zero if not used */
    unw_word_t  gp;               /* not used */
    unw_word_t  flags;            /* not used */
    uint        format;           /* compact unwind encoding, or zero if none */
    uint        unwind_info_size; /* size of DWARF unwind info, or zero if none */
    // Note: It's a `void*` with LLVM and a `unw_word_t` with upstream
    unw_word_t  unwind_info;      /* address of DWARF unwind info, or zero */
    // Note: upstream might not have this member at all, or it might be a single
    // byte, however we never pass an array of this type, so this is safe to
    // just use the bigger (LLVM's) value.
    unw_word_t  extra;            /* mach_header of mach-o image containing func */
}

/// Initialize the context at the current call site
int unw_getcontext(unw_context_t*);
/// Initialize a cursor at the call site
int unw_init_local(unw_cursor_t*, unw_context_t*);
/// Goes one level up in the call chain
int unw_step(unw_cursor_t*);
/// Get infos about the current procedure (function)
int unw_get_proc_info(unw_cursor_t*, unw_proc_info_t*);
/// Get the name of the current procedure (function)
int unw_get_proc_name(unw_cursor_t*, char*, size_t, unw_word_t*);

private:

// The API between libunwind and llvm-libunwind is almost the same,
// at least for our use case, and only the struct size change,
// so handle the difference here.
// Upstream: https://github.com/libunwind/libunwind/tree/master/include
// LLVM: https://github.com/llvm/llvm-project/blob/20c926e0797e074bfb946d2c8ce002888ebc2bcd/libunwind/include/__libunwind_config.h#L29-L141
version (X86)
{
    version (DRuntime_Use_LLVM_Libunwind)
    {
        enum _LIBUNWIND_CONTEXT_SIZE = 8;
        enum _LIBUNWIND_CURSOR_SIZE = 15;
    }
    else
    {
        import core.sys.posix.ucontext;
        alias unw_tdep_context_t = ucontext_t;
        enum UNW_TDEP_CURSOR_LEN = 127;
    }
}
else version (X86_64)
{
    version (DRuntime_Use_LLVM_Libunwind)
    {
        version (Win64)
        {
            enum _LIBUNWIND_CONTEXT_SIZE = 54;
// #    ifdef __SEH__
// #      define _LIBUNWIND_CURSOR_SIZE 204
            enum _LIBUNWIND_CURSOR_SIZE = 66;
        } else {
            enum _LIBUNWIND_CONTEXT_SIZE = 21;
            enum _LIBUNWIND_CURSOR_SIZE = 33;
        }
    }
    else
    {
        import core.sys.posix.ucontext;
        alias unw_tdep_context_t = ucontext_t;
        enum UNW_TDEP_CURSOR_LEN = 127;
    }
}
else version (PPC64)
{
    version (DRuntime_Use_LLVM_Libunwind)
    {
        enum _LIBUNWIND_CONTEXT_SIZE = 167;
        enum _LIBUNWIND_CURSOR_SIZE = 179;
    }
    else
    {
        import core.sys.posix.ucontext;
        alias unw_tdep_context_t = ucontext_t;
        enum UNW_TDEP_CURSOR_LEN = 280;
    }
}
else version (PPC)
{
    version (DRuntime_Use_LLVM_Libunwind)
    {
        enum _LIBUNWIND_CONTEXT_SIZE = 117;
        enum _LIBUNWIND_CURSOR_SIZE = 124;
    }
    else
    {
        import core.sys.posix.ucontext;
        alias unw_tdep_context_t = ucontext_t;
        enum UNW_TDEP_CURSOR_LEN = 280;
    }
}
else version (AArch64)
{
    version (DRuntime_Use_LLVM_Libunwind)
    {
        enum _LIBUNWIND_CONTEXT_SIZE = 66;
// #  if defined(__SEH__)
// #    define _LIBUNWIND_CURSOR_SIZE 164
        enum _LIBUNWIND_CURSOR_SIZE = 78;
    }
    else
    {
        enum UNW_TDEP_CURSOR_LEN = 250;

        version (linux)
        {
            import core.sys.posix.signal : sigset_t, stack_t;

            // libunwind has some special tweaking to reduce
            // the size of ucontext_t on Linux.
            struct unw_sigcontext
            {
                ulong fault_address;
                ulong[31] regs;
                ulong sp;
                ulong pc;
                ulong pstate;
                align(16) ubyte[(66 * 8)] reserved;
            }

            struct unw_tdep_context_t
            {
                c_ulong uc_flags;
                void* uc_link;
                stack_t uc_stack;
                sigset_t uc_sigmask;
                unw_sigcontext uc_mcontext;
            }
        }
        else
        {
            import core.sys.posix.ucontext;
            alias unw_tdep_context_t = ucontext_t;
        }
    }
}
else version (ARM)
{
    version (DRuntime_Use_LLVM_Libunwind)
    {
// #  if defined(__SEH__)
// #    define _LIBUNWIND_CONTEXT_SIZE 42
// #    define _LIBUNWIND_CURSOR_SIZE 80
// #  elif defined(__ARM_WMMX)
// #    define _LIBUNWIND_CONTEXT_SIZE 61
// #    define _LIBUNWIND_CURSOR_SIZE 68
        enum _LIBUNWIND_CONTEXT_SIZE = 42;
        enum _LIBUNWIND_CURSOR_SIZE = 49;
    }
    else
    {
        struct unw_tdep_context_t
        {
            c_ulong[16] regs;
        }
        enum UNW_TDEP_CURSOR_LEN = 4096;
    }
}
else version (SPARC)
{
    version (DRuntime_Use_LLVM_Libunwind)
    {
        enum _LIBUNWIND_CONTEXT_SIZE = 16;
        enum _LIBUNWIND_CURSOR_SIZE = 23;
    }
    else
    {
        static assert(0, "SPARC not supported on libunwind upstream, use LLVM's");
    }
}
else version (RISCV64) // 32 is not supported
{
    version (DRuntime_Use_LLVM_Libunwind)
    {
        enum _LIBUNWIND_CONTEXT_SIZE = 64;
        enum _LIBUNWIND_CURSOR_SIZE = 76;
    }
    else
    {
        static assert(0, "RISCV64 not supported on libunwind upstream, use LLVM's");
    }
}
else version (SystemZ)
{
    version (DRuntime_Use_LLVM_Libunwind)
    {
        static assert(0, "s390x/SystemZ not supported on LLVMlibunwind, use upstream's");
    }
    else
    {
        import core.sys.posix.ucontext;
        alias unw_tdep_context_t = ucontext_t;
        enum UNW_TDEP_CURSOR_LEN = 384;
    }
}
else
    /*
     * Libunwind also support OpenRISC 1000 (or1k), hexagon, and MIPS
     * at the time of writing (December 2020).
     */
    static assert(0, "Platform not supported");

// Just a fail-safe in case the combinations above missed something
static assert(is(typeof(UNW_TDEP_CURSOR_LEN)) || is(typeof(_LIBUNWIND_CURSOR_SIZE)));
