# WibLib
These are files shared by my other projects

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

Multi-threading related classes:
* `Critical section`
* `Event`
* `Reader/Writer lock (standalone or paired with <T>)`

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

## 🙌 List of planned features
Threading library with configurable single-threaded mode<br>
Saving test timelapses and configuarbly allowing tests by certain timelapse<br>
Cross-platform GetTicks64

## Dependencies
❗ Built with Rad Studio/Delphi 10.4<br>
Cryptograpic library: [CryptoLib4Pascal](https://github.com/Xor-el/CryptoLib4Pascal)