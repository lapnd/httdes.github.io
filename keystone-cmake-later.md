---
layout : default
---

# KEYSTONE (using CMake) for RV32 Build

* * *

**ISSUE: Rust-build on Keystone has errors**

* * *

# I. Install Rustup & LLVM (if not install yet)

### Install llvm-9:

```
$ sudo apt install llvm-9-dev clang-9 libclang-9-dev
```

Then check if llvm-9 is on the PATH or not, if not then find out where is the llvm-9 is installed:
```
$ whereis llvm-9
For example, it printed like this:
llvm-9: /usr/lib/llvm-9 /usr/include/llvm-9
```

Then, add the llvm-9 installed path to the **~/.bashrc**:
```
$ sudo vi ~/.bashrc
And add this line to the end of the file:
export PATH=/usr/lib/llvm-9/bin/:$PATH
```

### Install rust:

```
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
Answer the selection with 1 or simply enter
```

Then add $HOME/.cargo/bin to the PATH as the script said. Or better yet, add this to the **~/.bashrc** to make it persistent:
```
$ sudo vi ~/.bashrc
Then add this line to the end of the file:
$ export PATH=$HOME/.cargo/bin:$PATH
```

To setup Rust:
```
$ rustup toolchain install nightly
$ rustup +nightly component add rust-src
$ rustup +nightly target add riscv64gc-unknown-none-elf
$ cargo +nightly install cargo-xbuild
```

* * *

To make: *(Rust-build currently has issue, so please follow the normal-build)*
- Normal-build:
```
$ cmake ..
$ make -j`nproc`
```
- Rust-build:
```
$ rustup update nightly
$ cmake .. -DUSE_RUST_SM=y -DSM_CONFIGURE_ARGS="--enable-opt=0"
$ make -j`nproc`
```
The second SM_CONFIGURE_ARGS option is temporarily, see [PR#62](https://github.com/keystone-enclave/riscv-pk/pull/62).

* * *
