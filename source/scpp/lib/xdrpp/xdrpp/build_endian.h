// -*- C++ -*-
// Warning: Make sure to edit xdrc_endian.h.in, not xdrc_endian.h.

/** \file build_endian.h Endianness of build machine.  Don't include
 *  this file directly (as it doesn't exist on Windows), include
 *  <xdrpp/endian.h>, instead.  */

//! Default value set on build machine, but can be overridden (by
//! defining WORDS_BIGENDIAN to 0 or 1) in case of cross-compilation.
#define XDRPP_WORDS_BIGENDIAN 0
