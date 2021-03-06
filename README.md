# Unreal.hx - Basic Example Project

The goal of this repo is to provide a basic example project of unreal.hx with the latest supported versions of Unreal and Haxe. As well as documenting issues I came across during the project creation process.

This project is based on the default first person shooter template along with some updates from the following c++ tutorial which covers unreal's replication system: `https://www.youtube.com/watch?v=-0iVLPVyvFQ`.

I'm using macOS Catalina, so if you're on a different OS or version of Mac some steps may vary.

## Versions

* Unreal 4.22.3
* vscode
* [Haxe 4.0.0](https://haxe.org/download/version/4.0.0/)
  * hxcpp 4.1.15
  * hxcs 3.4.0

## Setup

* Download and install haxe 4.0.0
	* Install hxcpp `haxelib install hxcpp 4.0.64`
	* Install hxcs `haxelib install hxcs 3.4.0`
* Download and install Unreal 4.22.3
* Download this repo along with the unreal.hx submodule
* Open BattleRoyale.uproject
	* If you see the error: Missing BattleRoyale Modules .. etc ... Would you like to rebuild them now? Press `Yes`
		* If this step fails refer to the issues listed below 
		* or create an issue on the unreal.hx or this repo
* Once the project opens click the arrow next to the play button and select:
	* Run Dedicated Server
	* Number of players: 3
* Press the button compile via Unreal Editor
* Press the play button to test the project

## macOS Catalina Issues

* You may encounter an issue where you can't create a new Unreal c++ project. Trying to do this may result in unreal engine saying something along the lines of: `Could not be compiled. Try rebuilding from source manually`. To resolve this try installing a different version of XCode (I ended up settling with 11.7).
* The version of Clang that ships with macOS Catalina doesn't support some stuff to do with threads, so install via brew `brew install llvm` and then update `Plugins/UnrealHx/Haxe/BuildTool/toolchain/mac-libc-toolchain.xml` to point to this version of clang. Just change all instances of `clang++` to `/usr/local/opt/llvm/bin/clang++`

## Crashing Issue

* If your project crashes and then continues to crash every time you launch the project, delete the `./Binaries/Haxe/` directory and recompile via the unreal editor.


## Build Issues

* If after first openning the project and pressing the compile button nothing happens and you set a warning in the Output Log window `Warning: RebindPackages not possible (no packages specified)`.
	* Close the project
	* Delete the following folders
		* Binaries
		* Intermediate
		* Saved
	* And then open BattleRoyale.uproject to restart the build process.
