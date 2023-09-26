# WibLib
Delphi library that are used by my other Delphi [projects](https://github.com/W1berg?tab=repositories)

## ⚡ Features
Convenient wrappers for:
* `Aes`
* `Argon2`
* `ChaCha`

Symbiotic Argon2Aes class

Base32 encoding/decoding with:
* `Optional padding`
* `Encoding/decoding maps`
* `No resizing of buffer`

Log class injected with log procedures per log type

Obfuscation for Rtti functions:
* `GetDeclaredMethods`
* `GetFields`

Testing framework, optionally inherited from TestCase in the TestFramework unit

TBytes record helper with various quality of life functions and supporting:
* `Add/Pop <T>`
* `Burn (Anti-forensic)`
* `Base32 encoded string`
* `Base64 encoded string`
* `Bits (TBits class with optional interface wrapper)`
* `Numbers list by bits per number`
* `Hex encoded string`
* `RawByteString`
* `Stream (with optional interface wrapper)`
* `Utf8 encoded string`
* `Try functions for failable encodings`

Generic interface wrapper automating freeing of all <T: constructor> types

Multi-threading related classes:
* `Critical section`
* `Event`
* `Reader/Writer lock (standalone or paired with <T>)`

### ⚡ Thread Tasks
The task classes dynamically runs any function or inherited class in modes:
* `Regular function call, refreshed instead of looping until terminated`
* `Function running in thread`

The task cluster class registers tasks or other task clusters to dynamically run the program in modes:
* `Single-threaded`
* `Main-thread and worker-thread`
* `Main-thread and worker-thread for every cluster`
* `Multi-threaded`

## 🙌 List of planned features
* `Saving test timelapses and configuarbly allowing tests by certain timelapse`
* `Cross-platform GetTicks64`

## Dependencies
❗ Built with Rad Studio/Delphi 10.4<br>
Cryptograpic library: [CryptoLib4Pascal](https://github.com/Xor-el/CryptoLib4Pascal)