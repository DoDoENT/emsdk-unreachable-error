# emsdk-unreachable-error
Reproducible case for https://github.com/emscripten-core/emscripten/issues/9443#issuecomment-802857751

# Before reproducing

Make sure that all submodules are initialized with `git submodule update --init`

# Reproducing the crash

1. Initialize shell for emscripten 2.0.15
2. run `emcmake cmake -GNinja /path/to/this/repository`
3. build with `ninja`
4. run `emrun --browser chrome ./SweatShop.html`
5. application crashes with `Uncaught RuntimeError: unreachable`

# Prove that it works with older emsripten

1. Initialize another shell for emscripten 2.0.14 (or older)
2. repeat steps 2 - 4 from above
3. application works correctly
