cmake_minimum_required( VERSION 3.12.0 )

include( ${CMAKE_CURRENT_LIST_DIR}/gcc_clang_overrides.cmake )

# In some cases conan will set the "-stdlib" flag. This flag is not used in Emscripten builds.
list( APPEND TNUN_disabled_warnings "-Wno-unused-command-line-argument" )

# determine if fastcomp or upstream backend
string( REPLACE "." ";" VERSION_LIST ${CMAKE_CXX_COMPILER_VERSION} )
list( GET VERSION_LIST 0 clang_major_version  )
set( MB_EMSCRIPTEN_BACKEND "upstream" )
if ( ${clang_major_version} EQUAL 6 )
    set( MB_EMSCRIPTEN_BACKEND "fastcomp" )
    message( FATAL_ERROR "fastcomp emscripten backend is no longer supported!" )
endif()

option( MB_EMSCRIPTEN_COMPILE_TO_WEBASSEMBLY "Compile to WebAssembly, instead of asm.js" ON )
if ( MB_EMSCRIPTEN_COMPILE_TO_WEBASSEMBLY )
    set( MB_EMSCRIPTEN_WASM_OPTION "SHELL:-s WASM=1" )
else()
    set( MB_EMSCRIPTEN_WASM_OPTION "SHELL:-s WASM=0" )
endif()

add_link_options( ${MB_EMSCRIPTEN_WASM_OPTION} )

option( MB_EMSCRIPTEN_ENABLE_PTHREADS "Allow using POSIX threads (currently unsupported in most browsers)" OFF )
if ( MB_EMSCRIPTEN_ENABLE_PTHREADS )
    set( MB_EMSCRIPTEN_THREAD_POOL_SIZE 0 CACHE STRING "Default number of web workers preallocated for emscripten threads at runtime startup. Set to 0 to dynamically spawn web workers and to -1 to use the number equal to number of cores reported by the web browser." )
    mark_as_advanced( MB_EMSCRIPTEN_THREAD_POOL_SIZE )
    add_link_options( "SHELL:-s PTHREAD_POOL_SIZE=${MB_EMSCRIPTEN_THREAD_POOL_SIZE}" )
    set( MB_EMSCRIPTEN_PTHREAD_OPTIONS "SHELL:-s USE_PTHREADS=1" )
    # if demangling is enabled together with threads, this causes browser to hang instead of displaying crash trace
    list( REMOVE_ITEM TNUN_linker_debug_symbols "SHELL:-s DEMANGLE_SUPPORT=1" )
    if ( MB_DEV_RELEASE OR CMAKE_BUILD_TYPE STREQUAL "Debug" )
        add_link_options( "SHELL:-s MALLOC=dlmalloc" )
    endif()
else()
    set( MB_EMSCRIPTEN_PTHREAD_OPTIONS "SHELL:-s USE_PTHREADS=0" )
endif()

add_compile_options( ${MB_EMSCRIPTEN_PTHREAD_OPTIONS} )
add_link_options( ${MB_EMSCRIPTEN_PTHREAD_OPTIONS} )

option( MB_EMSCRIPTEN_ALLOW_MEMORY_GROWTH "Allow growing memory arrays at runtime" ON )

if ( MB_EMSCRIPTEN_ALLOW_MEMORY_GROWTH )
    # https://github.com/emscripten-core/emscripten/blob/1.38.43/src/settings.js#L113
    # https://github.com/emscripten-core/emscripten/blob/1.38.43/tools/file_packager.py#L44
    # https://github.com/emscripten-core/emscripten/issues/5179
    add_link_options( "SHELL:-s ALLOW_MEMORY_GROWTH=1" --no-heap-copy )
endif()

# If MB_EMSCRIPTEN_ALLOW_MEMORY_GROWTH is OFF, this indicates the total memory to be used at runtime.
# If MB_EMSCRIPTEN_ALLOW_MEMORY_GROWTH is ON, this indicates the initial amount of memory before first memory growth will take place.
set( MB_EMSCRIPTEN_TOTAL_MEMORY_MB 200 CACHE STRING "The total/initial amount of memory to use in MB. For more info see https://github.com/emscripten-core/emscripten/blob/1.39.0/src/settings.js#L84" )

math( EXPR MB_TOTAL_MEMORY_BYTES "${MB_EMSCRIPTEN_TOTAL_MEMORY_MB} * 1024 * 1024" )

add_link_options( "SHELL:-s INITIAL_MEMORY=${MB_TOTAL_MEMORY_BYTES}" )

if ( MB_EMSCRIPTEN_ENABLE_PTHREADS )
    math( EXPR MAX_WASM_BYTES "${MB_TOTAL_MEMORY_BYTES} * 4" )
    add_link_options( "SHELL:-s MAXIMUM_MEMORY=${MAX_WASM_BYTES}" )
endif()

# strip does not exist in cmake toolchain and system's strip command does not work with wasm binaries
set( MB_DISABLE_STRIP ON )
# so, in order to make smallest possible wasm binaries, disable generating debug symbols
if ( NOT MB_DEV_RELEASE )
    option( MB_DEBUG_SYMBOLS_IN_RELEASE "Generate debug symbols for easier debugging of release builds" OFF )
endif()

# we do not want to use sanitizers with emscripten
unset( TNUN_compiler_runtime_sanity_checks  )
unset( TNUN_linker_runtime_sanity_checks    )
unset( TNUN_compiler_runtime_integer_checks )
unset( TNUN_linker_runtime_integer_checks   )

# also, coverage will not work with emscripten
unset( TNUN_code_coverage_compiler_flags )
unset( TNUN_code_coverage_linker_flags   )

# https://github.com/emscripten-core/emscripten/issues/8731#issuecomment-719145588
# This makes LTO warnings treated as warnings, at risk that the resulting program may not work.
add_link_options( "SHELL:-s STRICT=0" )

# always disable support for errno
add_link_options( "SHELL:-s SUPPORT_ERRNO=0" )

list( APPEND TNUN_linker_release_flags -O3 )
add_compile_options( -mmutable-globals ) # -mmultivalue

option( MB_EMSCRIPTEN_ADVANCED_FEATURES "Enable advanced WASM features that may increase performance, but may not be available in all browsers" OFF )
if ( MB_EMSCRIPTEN_ADVANCED_FEATURES )
    add_compile_options( -mbulk-memory -mnontrapping-fptoint -msign-ext ) # -mreference-types not yet supported neither in chrome nor in firefox
endif()

option( MB_EMSCRIPTEN_SIMD "Enable SIMD autovectorization" ${MB_EMSCRIPTEN_ADVANCED_FEATURES} )
if ( MB_EMSCRIPTEN_SIMD )
    set( MB_EMSCRIPTEN_SIMD_OPTION -msimd128 )

    TNUN_add_compile_options( Release ${MB_EMSCRIPTEN_SIMD_OPTION} )
    TNUN_add_link_options   ( Release ${MB_EMSCRIPTEN_SIMD_OPTION} )
endif()

