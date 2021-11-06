/**
 *
 *  Created on: 22/11/2016
 *      Author: dodo
 *
 * Copyright (c)2016 Microblink Ltd. All rights reserved.
 *
 * ANY UNAUTHORIZED USE OR SALE, DUPLICATION, OR DISTRIBUTION
 * OF THIS PROGRAM OR ANY OF ITS PARTS, IN SOURCE OR BINARY FORMS,
 * WITH OR WITHOUT MODIFICATION, WITH THE PURPOSE OF ACQUIRING
 * UNLAWFUL MATERIAL OR ANY OTHER BENEFIT IS PROHIBITED!
 * THIS PROGRAM IS PROTECTED BY COPYRIGHT LAWS AND YOU MAY NOT
 * REVERSE ENGINEER, DECOMPILE, OR DISASSEMBLE IT.
 */

#pragma once

#ifdef _MSC_VER

#define MB_DISABLE_WARNING_PUSH __pragma( warning( push ) )
#define MB_DISABLE_WARNING_POP   __pragma( warning( pop  ) )

#define MB_DISABLE_WARNING_MSVC( w )  __pragma( warning( disable: w ) )
#define MB_DISABLE_WARNING_GCC( w )
#define MB_DISABLE_WARNING_CLANG( w )
#define MB_DISABLE_WARNING_GCC_OR_CLANG( w )

#else

#define MB_STRINGIFY( a ) #a

#define MB_DISABLE_WARNING_MSVC( w )

#ifdef __clang__

#define MB_DISABLE_WARNING_PUSH _Pragma( "clang diagnostic push" )
#define MB_DISABLE_WARNING_POP   _Pragma( "clang diagnostic pop"  )

#define MB_DISABLE_WARNING_GCC( w )
#define MB_DISABLE_WARNING_CLANG( w ) _Pragma ( MB_STRINGIFY( clang diagnostic ignored w ) )

#define MB_DISABLE_WARNING_GCC_OR_CLANG( w ) MB_DISABLE_WARNING_CLANG( w )

#else

#define MB_DISABLE_WARNING_PUSH _Pragma( "GCC diagnostic push" )
#define MB_DISABLE_WARNING_POP   _Pragma( "GCC diagnostic pop"  )

#define MB_DISABLE_WARNING_GCC( w ) _Pragma ( MB_STRINGIFY( GCC diagnostic ignored w ) )
#define MB_DISABLE_WARNING_CLANG( w )

#define MB_DISABLE_WARNING_GCC_OR_CLANG( w ) MB_DISABLE_WARNING_GCC( w )

#endif


#endif
