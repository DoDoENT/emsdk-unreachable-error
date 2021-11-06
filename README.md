# Inconsistent LTO Unit splitting

Reproducible case for https://github.com/emscripten-core/emscripten/issues/15427

# Before reproducing

Make sure that all submodules are initialized with `git submodule update --init`

# Reproducing the crash

1. Initialize shell for emscripten 2.0.33
2. run `emcmake cmake -GNinja /path/to/this/repository`
3. build with `ninja`
