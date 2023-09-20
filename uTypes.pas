// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uTypes;

interface

uses
  Classes,
  Generics.Collections;

const
  cCharsBase32 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  cCharsBase32Set = ['2' .. '7', '=', 'A' .. 'Z'];

  cCharsBase64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
  cCharsBase64Set = ['+', '/' .. '9', '=', 'A' .. 'Z', 'a' .. 'z'];

  cCharsHex = '0123456789ABCDEF';
  cCharsHexUpLow = '0123456789ABCDEFabcdef';
  cCharsHexSet = ['0' .. '9', 'A' .. 'F', 'a' .. 'f'];

  cArgonInGetOnly = -1;
  cCharAnsiHigh = 255;
  cCharUtf8High = 55295; // 55295< cause problems
  cCharPrintLow = 32;
  cCharPrintHigh = 126;

  cIntMin = -2147483648;
  cIntMax = 2147483647;

type
  TAesMode = (amCbcNoPad, amCbcPkcs7, amCtrNoPad, amCtsNoPad);
  TArgonPreset = (apMin, apI6s, apTest1);

  TBytes = TArray<Byte>;

  TEncName = (en32, en64, enHex, enUtf8);

  TEnc = record
    Name: TEncName;
    Chars: string;
    CharPad: AnsiChar;
    CharsPerValue: Integer;
    CharSet: set of AnsiChar;
    CharHigh: Integer;
  end;

  TFuncArg0<T> = reference to function: T;
  TFuncArg1<T, T2> = reference to function(const Arg: T): T2;

  TLogLevel = (llTest, llTestPass, llTestFail, llDebug, llInfo, llWarn, llDebugRaise, llError);

  TProcArg0 = reference to procedure;
  TProcArg1<T> = reference to procedure(const Arg: T);

  TTaskType = (tcFunc, tcThread);

  // Interfaces used in several categories

  ILogBasic = interface
    ['{A698E38A-E1CF-4F74-BA8F-3BC9ECAAE0C9}']
    procedure Log(const AStr: string = ''; const AFunc: string = ''; const AClass: string = ''; const ALogLevel: TLogLevel = llDebug; const ADate: TDateTime = 0);
  end;

  ILog = interface(ILogBasic)
    ['{34617521-CAFF-4E07-A5DD-855322DA10BD}']
    procedure Log(const AList: TStrings); overload;
    procedure Log(const AList: TStrings; const AFunc: string; const AClassName: string = ''; const ALogLevel: TLogLevel = llDebug; const ADate: TDateTime = 0); overload;
  end;

  IWrap<T: constructor> = interface
    ['{57053D4A-BDF4-4116-AE64-ACAA198B9A15}']
    function Ref: T;
  end;

  // Encryption

  IAes = interface
    ['{BC2FDB55-046E-47FB-AC9E-F4E35E14B0A1}']
    procedure Init(const AKey, AIv: TBytes; const AAesMode: TAesMode);
    function Encrypt(const AData: TBytes; const AWithMac: Boolean): TBytes;
    function Decrypt(const ACipher: TBytes; const AWithMac: Boolean): TBytes;
  end;

  IArgonPara = interface
    ['{29A356E2-C1A2-4206-A874-1D011C13140E}']
    procedure Burn;
    procedure SetPreset(const AArgonPreset: TArgonPreset);

    function Salt(const ANew: TBytes = nil): TBytes;
    function Secret(const ANew: TBytes = nil): TBytes;
    function Additional(const ANew: TBytes = nil): TBytes;
    function Password(const ANew: TBytes = nil): TBytes;

    function Parallelism(const ANew: Integer = cArgonInGetOnly): Integer;
    function MemoryKB(const ANew: Integer = cArgonInGetOnly): Integer;
    function Iterations(const ANew: Integer = cArgonInGetOnly): Integer;
    function OutputByteLength(const ANew: Integer = cArgonInGetOnly): Integer;
  end;

  IArgon = interface(IArgonPara)
    ['{ED7C21B6-C6B4-4447-8A59-9DD2117411C0}']
    function Hash: TBytes;
  end;

  IArgonAes = interface(IArgon)
    ['{BC2FDB55-046E-47FB-AC9E-F4E35E14B0A1}']
    procedure Init(const AAesMode: TAesMode);

    function Encrypt(const AData: TBytes): TBytes;
    function Decrypt(const ACipher: TBytes): TBytes;
  end;

  IChaCha = interface
    ['{1CE79AE9-5F38-44B2-92E1-4292F481BEBD}']
    procedure Init(const AKey, AIv: TBytes; const ARounds: Integer = 20);

    function Encrypt(const AData: TBytes; const AKeyStream: Boolean = False): TBytes;
    function Decrypt(const ACipher: TBytes; const AKeyStream: Boolean = False): TBytes;

    procedure Reset;
    function ReturnByte(const AData: TBytes): TBytes;
  end;

  // Rtti

  IRttiField = interface
    ['{E7B494BB-FE15-443A-945A-84274D5D1810}']
    function Name: string;
    function Value: string;
  end;

  IRttiMethod = interface
    ['{970D07D7-C52E-4A10-BBCF-5BB6EDB4C4E9}']
    function ClassName: string;
    function Name: string;
    procedure Invoke;
  end;

  IRtti = interface
    ['{6442FDF6-59D7-463E-B291-D707225C3BD3}']
    procedure DeclaredMethodsGet(const AClass: TObject; const AList: TList<IRttiMethod>);
  end;

  // Threading tools

  ICrit = interface
    ['{E04355A9-338A-4FC0-B7A1-5CFFF5C74170}']
    procedure Enter;
    function EnterTry: Boolean;
    procedure Leave;
  end;

  IEvent = interface
    ['{2B955D6C-95CB-4B34-9988-1AFDF07D72EE}']
    procedure Activate;
    procedure Reset;
    function WaitFor(const AMiliSec: Integer): Boolean;
  end;

  ILock = interface
    ['{196E2093-CFC4-475B-9CC7-1E05D790E034}']
    function ReaderGet: Integer;
    procedure ReaderRel(const AI: Integer);
    function WriterGet: Boolean;
    procedure WriterRel;
  end;

  ILock<T> = interface(ILock)
    ['{8D933458-D5DE-4FBA-A069-BC4864C69F92}']
    function Data: T;
  end;

  ILockWrap<T: constructor> = interface(ILock < IWrap < T >> )
    ['{312BB110-96AD-4E45-983D-AE86EEDAF7A5}']
    function Ref: T;
    procedure SetData; overload;
    procedure SetData(const AData: T); overload;
  end;

  // Other

  IClipboard = interface
    ['{5A7EEDB5-F5B9-40E0-A951-4B520E30826D}']
    function GetStr: string;
    procedure SetStr(const AStr: string);
  end;

  IRnd = interface
    ['{596CD1E8-4920-48F0-AA22-407A397F383C}']
    function GenChar(const AHigh: Integer = cCharPrintHigh): Char; overload;
    function GenChar(const ALow, AHigh: Integer): Char; overload;

    function GenInt(const AHigh: Integer = cIntMax): Integer; overload;
    function GenInt(const ALow, AHigh: Integer): Integer; overload;

    function GenStr(const ALength, AHigh: Integer): string; overload;
    function GenStr(const ALength: Integer; const ACharset: string; const AHigh: Integer = cCharPrintHigh): string; overload;
    function GenStr(const ALength: Integer; ALow: Integer = cCharPrintLow; AHigh: Integer = cCharPrintHigh): string; overload;
  end;

  // Interfaces using interfaces in several categories

  IFac = interface
    ['{84EA6D7A-71AF-4788-A7A7-DE7D638360CE}']
    function Aes: IAes;
    function Argon: IArgon;
    function ArgonAes: IArgonAes;
    function ChaCha: IChaCha;
    function Clipboard: IClipboard;
    function Crit: ICrit;
    function Event: IEvent;
    function Log: ILog;
    function LogNew(const ALogProc: TProcArg1<string>): ILog;
    function Rnd: IRnd;
    function Rtti: IRtti;
  end;

  // Helpers

  TBytesHelper = record helper for TBytes
  private const
    cBadEncStr = 'Bad encoding';

    function GetBase32: string;
    function GetBase64: string;
    function GetBits: TBits;
    function GetBitsWrap: IWrap<TBits>;
    function GetHex: string;
    function GetRaw: RawByteString;
    function GetStream: TStream; overload;
    function GetStreamWrap: IWrap<TStream>;
    function GetUtf8: string;

    function LenGet: Integer;
    procedure LenSet(const ALength: Integer);

    procedure SetBase32(const ASource: string);
    procedure SetBase64(const ASource: string);
    procedure SetBits(const ASource: TBits);
    procedure SetHex(const ASource: string);
    procedure SetRaw(const ASource: RawByteString);
    procedure SetStream(const ASource: TStream);
    procedure SetUtf8(const ASource: string);
  public
    procedure Add<T>(const Arg: T);
    function Pop<T>: T;

    procedure Burn;
    procedure FillArr(var ADest: array of Byte);

    function GetAs(const AEncName: TEncName): string;
    procedure GetNums(const ANums: TList<Integer>; const ABitsPerNum: Integer);
    procedure GetStream(const ADest: TStream); overload;

    function High_: Integer;
    function IsEmpty: Boolean;
    procedure LenSetUpTo(const AMultipleOf: Integer);

    procedure SetArr(const ASource: array of Byte);
    function SetAsTry(const AEncName: TEncName; const ASource: string): Boolean;

    function SetBase32Try(const ASource: string): Boolean;
    function SetBase64Try(const ASource: string): Boolean;
    function SetHexTry(const ASource: string): Boolean;
    function SetUtf8Try(const ASource: string): Boolean;

    property B32: string read GetBase32 write SetBase32;
    property B64: string read GetBase64 write SetBase64;
    property Bits: TBits read GetBits write SetBits;
    property BitsWrap: IWrap<TBits> read GetBitsWrap;
    property Hex: string read GetHex write SetHex;
    property Len: Integer read LenGet write LenSet;
    property Raw: RawByteString read GetRaw write SetRaw;
    property Stream: TStream read GetStream write SetStream;
    property StreamWrap: IWrap<TStream> read GetStreamWrap;
    property Utf8: string read GetUtf8 write SetUtf8;
  end;

  // Records

  TGet = record
  public
    procedure Init(const ALogProc: TProcArg1<string>);
    function Fac: IFac;

    function Lock<T>(const AReaderCount: Integer = 2): ILock<T>;
    function LockWrap<T: constructor>(const AReaderCount: Integer = 2): ILockWrap<T>; overload;

    function Ticks64: Int64;

    function Wrap(const AObj: TObject): IWrap<TObject>; overload;
    function Wrap<T: constructor>: IWrap<T>; overload;
    function Wrap<T: constructor>(const AObj: T): IWrap<T>; overload;
  end;

var
  FGet: TGet;

implementation

uses
  uData,
  uFac,

  SysUtils;

procedure TBytesHelper.Add<T>(const Arg: T);
var
  LLen, LSize: Integer;
  LP: Pointer;
begin
  LLen := Self.Len;
  LSize := SizeOf(T);

  Self.Len := LLen + LSize;
  Move(Arg, Self[LLen], LSize);
end;

function TBytesHelper.Pop<T>: T;
var
  LLen, LSize: Integer;
begin
  LLen := Self.Len;
  LSize := SizeOf(T);

  Move(Self[LLen - LSize], Result, LSize);
  Self.Len := LLen - LSize;
end;

procedure TBytesHelper.Burn;
begin
  FillChar(Self[0], Self.Len, 0);
  Finalize(Self);
end;

procedure TBytesHelper.FillArr(var ADest: array of Byte);
begin
  uData.FillArr(Self, ADest);
end;

function TBytesHelper.GetAs(const AEncName: TEncName): string;
begin
  Result := uData.GetAs(AEncName, Self);
end;

function TBytesHelper.GetBase32: string;
begin
  Result := uData.GetBase32(Self);
end;

function TBytesHelper.GetBase64: string;
begin
  Result := uData.GetBase64(Self);
end;

function TBytesHelper.GetBits: TBits;
begin
  Result := uData.GetBits(Self);
end;

function TBytesHelper.GetBitsWrap: IWrap<TBits>;
begin
  Result := FGet.Wrap<TBits>(GetBits);
end;

function TBytesHelper.GetHex: string;
begin
  Result := uData.GetHex(Self);
end;

procedure TBytesHelper.GetNums(const ANums: TList<Integer>; const ABitsPerNum: Integer);
begin
  uData.GetNums(Self, ANums, ABitsPerNum);
end;

function TBytesHelper.GetRaw: RawByteString;
begin
  Result := uData.GetRaw(Self);
end;

function TBytesHelper.GetStream: TStream;
begin
  Result := TMemoryStream.Create;
  uData.GetStream(Self, Result);
end;

procedure TBytesHelper.GetStream(const ADest: TStream);
begin
  uData.GetStream(Self, ADest);
end;

function TBytesHelper.GetStreamWrap: IWrap<TStream>;
begin
  Result := FGet.Wrap<TStream>(GetStream);
end;

function TBytesHelper.GetUtf8: string;
begin
  Result := uData.GetUtf8(Self);
end;

function TBytesHelper.High_: Integer;
begin
  Result := high(Self);
end;

function TBytesHelper.IsEmpty: Boolean;
begin
  Result := Self.Len = 0;
end;

function TBytesHelper.LenGet: Integer;
begin
  Result := Length(Self);
end;

procedure TBytesHelper.LenSet(const ALength: Integer);
begin
  SetLength(Self, ALength);
end;

procedure TBytesHelper.LenSetUpTo(const AMultipleOf: Integer);
begin
  Self.Len := (Self.Len + AMultipleOf - 1) div AMultipleOf * AMultipleOf;
end;

procedure TBytesHelper.SetArr(const ASource: array of Byte);
begin
  uData.SetArr(ASource, Self);
end;

function TBytesHelper.SetAsTry(const AEncName: TEncName; const ASource: string): Boolean;
begin
  Result := uData.SetAsTry(AEncName, ASource, Self);
end;

procedure TBytesHelper.SetBase32(const ASource: string);
begin
  if not uData.SetBase32(ASource, Self) then
    raise Exception.Create(cBadEncStr);
end;

function TBytesHelper.SetBase32Try(const ASource: string): Boolean;
begin
  Result := uData.SetBase32(ASource, Self);
end;

procedure TBytesHelper.SetBase64(const ASource: string);
begin
  if not uData.SetBase64(ASource, Self) then
    raise Exception.Create(cBadEncStr);
end;

function TBytesHelper.SetBase64Try(const ASource: string): Boolean;
begin
  Result := uData.SetBase64(ASource, Self);
end;

procedure TBytesHelper.SetBits(const ASource: TBits);
begin
  uData.SetBits(ASource, Self);
end;

procedure TBytesHelper.SetHex(const ASource: string);
begin
  if not uData.SetHex(ASource, Self) then
    raise Exception.Create(cBadEncStr);
end;

function TBytesHelper.SetHexTry(const ASource: string): Boolean;
begin
  Result := uData.SetHex(ASource, Self);
end;

procedure TBytesHelper.SetRaw(const ASource: RawByteString);
begin
  uData.SetRaw(ASource, Self);
end;

procedure TBytesHelper.SetStream(const ASource: TStream);
begin
  uData.SetStream(ASource, Self);
end;

procedure TBytesHelper.SetUtf8(const ASource: string);
begin
  if not uData.SetUtf8(ASource, Self) then
    raise Exception.Create(cBadEncStr);
end;

function TBytesHelper.SetUtf8Try(const ASource: string): Boolean;
begin
  Result := uData.SetUtf8(ASource, Self);
end;

//

procedure TGet.Init(const ALogProc: TProcArg1<string>);
begin
  TFac.Init(ALogProc);
end;

function TGet.Lock<T>(const AReaderCount: Integer): ILock<T>;
begin
  Result := TFac.Lock<T>(AReaderCount);
end;

function TGet.LockWrap<T>(const AReaderCount: Integer): ILockWrap<T>;
begin
  Result := TFac.LockWrap<T>(AReaderCount);
end;

function TGet.Wrap(const AObj: TObject): IWrap<TObject>;
begin
  Result := TFac.Wrap<TObject>(AObj);
end;

function TGet.Wrap<T>: IWrap<T>;
begin
  Result := TFac.Wrap<T>;
end;

function TGet.Wrap<T>(const AObj: T): IWrap<T>;
begin
  Result := TFac.Wrap<T>(AObj);
end;

function TGet.Fac: IFac;
begin
  Result := TFac.FacMain;
end;

function TGet.Ticks64: Int64;
begin
  Result := TThread.GetTickCount;
end;

end.
