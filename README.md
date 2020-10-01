# Unreal.hx - Basic Example Project

The goal of this repo is to provide a basic example project of unreal.hx with the latest supported versions of Unreal and Haxe. As well as documenting issues I came across during the process of creating the project.

I'm using macOS Catalina, so if you're on a different version of Mac or Window some steps may vary.

## Setup

* Download Unreal 4.22.3
* 


## macOS Catalina Issues

* You may encounter an issue where you can't create a new Unreal c++ project. Trying to do this may result in unreal engine saying something along the lines of: `Could not be compiled. Try rebuilding from source manually`. To resolve this try installing a different version of XCode (I ended up settling with 11.7).
* The version of Clang that ships with macOS Catalina doesn't support some stuff to do with threads, so install via brew `brew install llvm` and then update `Plugins/UnrealHx/Haxe/BuildTool/toolchain/mac-libc-toolchain.xml` to point to this version of clang. Just change all instances from `clang++` to `/usr/local/opt/llvm/bin/clang++`
