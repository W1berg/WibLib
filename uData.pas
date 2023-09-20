// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uData;

interface

uses
  uTypes,
  Classes,
  Generics.Collections;

procedure FillArr(const ASource: TBytes; var Arr: array of Byte);
function GetAs(const AEncName: TEncName; const ASource: TBytes): string;

function GetBase32(const ASource: TBytes): string;
function GetBase64(const ASource: TBytes): string;
function GetBits(const ASource: TBytes): TBits;
function GetHex(const ASource: TBytes): string;
procedure GetNums(const ASource: TBytes; const ANums: TList<Integer>; const ABitsPerNum: Integer);
procedure GetStream(const ASource: TBytes; const ADest: TStream);
function GetRaw(const ASource: TBytes): RawByteString;
function GetUtf8(const ASource: TBytes): string;

procedure SetArr(const ASource: array of Byte; var ADest: TBytes);
function SetAsTry(const AEncName: TEncName; const ASource: string; var ADest: TBytes): Boolean;

function SetBase32(const ASource: string; var ADest: TBytes): Boolean;
function SetBase64(const ASource: string; var ADest: TBytes): Boolean;
procedure SetBits(const ASource: TBits; var ADest: TBytes);
function SetHex(const ASource: string; var ADest: TBytes): Boolean;
procedure SetStream(const ASource: TStream; var ADest: TBytes);
procedure SetRaw(const ASource: RawByteString; var ADest: TBytes);
function SetUtf8(const ASource: string; var ADest: TBytes): Boolean;

const
  cEnc: array [TEncName] of TEnc = (

    (name: en32; //
    Chars: cCharsBase32; //
    CharPad: '='; //
    CharsPerValue: 8; //
    CharSet: cCharsBase32Set; //
    CharHigh: Ord('Z')),

    (name: en64; //
    Chars: cCharsBase64; //
    CharPad: '='; //
    CharsPerValue: 4; //
    CharSet: cCharsBase64Set; //
    CharHigh: Ord('z')),

    (name: enHex; //
    Chars: cCharsHexUpLow; //
    CharsPerValue: 2; //
    CharSet: cCharsHexSet; //
    CharHigh: Ord('f')),

    (name: enUtf8; //
    CharsPerValue: 1; //
    CharHigh: cCharUtf8High));

implementation

uses
  uBase32,
  NetEncoding,
  SysUtils;

const
  cEncMissing = 'Enc missing';

procedure FillArr(const ASource: TBytes; var Arr: array of Byte);
var
  LLen, LLenArr: Integer;
begin
  LLen := ASource.Len;
  LLenArr := Length(Arr);
  LLen := LLen * Ord(LLen <= LLenArr) + LLenArr * Ord(LLen > LLenArr);

  Move(ASource[0], Arr[0], LLen);
  FillChar(Arr[LLen], (LLenArr - LLen), 0);
end;

function GetAs(const AEncName: TEncName; const ASource: TBytes): string;
begin
  case AEncName of
    en32:
      Result := GetBase32(ASource);
    en64:
      Result := GetBase64(ASource);
    enHex:
      Result := GetHex(ASource);
    enUtf8:
      Result := GetUtf8(ASource);
  else
    raise Exception.Create(cEncMissing);
  end;
end;

function GetBase32(const ASource: TBytes): string;
begin
  Result := TEncoding.UTF8.GetString(Base32Encode(ASource, True));
end;

function GetBase64(const ASource: TBytes): string;
begin
  Result := TNetEncoding.Base64.EncodeBytesToString(ASource);
end;

function GetBits(const ASource: TBytes): TBits;
begin
  Result := TBits.Create;
  Result.Size := ASource.Len * 8;

  for var I := 0 to ASource.High_ do
    for var J := 0 to 7 do
      Result[I * 8 + J] := ((ASource[I] shr (7 - J)) and $1) = 1;
end;

function GetHex(const ASource: TBytes): string;
var
  LLen: Integer;
begin
  LLen := ASource.Len;
  SetLength(Result, LLen * 2);
  BinToHex(ASource, PChar(Result), LLen);
end;

function BitsToNum(const LBits: TBits; const AStart, ACount: Integer): Integer;
begin
  Result := 0;
  for var I := AStart to AStart + ACount - 1 do
    Result := Result shl 1 or Ord(LBits[I]);
end;

procedure GetNums(const ASource: TBytes; const ANums: TList<Integer>; const ABitsPerNum: Integer);
var
  LBits: IWrap<TBits>;
  I, LNum: Integer;
begin
  LBits := ASource.BitsWrap;
  // LBits.Ref.Size := LBits.Ref.Size - (LBits.Ref.Size mod ABitsPerNum);

  I := 0;
  while I <= LBits.Ref.Size - ABitsPerNum do
  begin
    LNum := BitsToNum(LBits.Ref, I, ABitsPerNum);
    ANums.Add(LNum);
    I := I + ABitsPerNum;
  end;
end;

function GetRaw(const ASource: TBytes): RawByteString;
var
  LLen: Integer;
begin
  LLen := ASource.Len;
  SetLength(Result, LLen);
  Move(ASource[0], Result[low(Result)], LLen);
end;

procedure GetStream(const ASource: TBytes; const ADest: TStream);
begin
  ADest.Size := ASource.Len;
  ADest.Position := 0;
  ADest.WriteBuffer(ASource, ASource.Len);
  ADest.Position := 0;
end;

function GetUtf8(const ASource: TBytes): string;
begin
  Result := TEncoding.UTF8.GetString(ASource);
end;

procedure SetArr(const ASource: array of Byte; var ADest: TBytes);
begin
  ADest.Len := Length(ASource);
  Move(ASource[0], ADest[0], SizeOf(ASource));
end;

function SetAsTry(const AEncName: TEncName; const ASource: string; var ADest: TBytes): Boolean;
begin
  case AEncName of
    en32:
      Result := SetBase32(ASource, ADest);
    en64:
      Result := SetBase64(ASource, ADest);
    enHex:
      Result := SetHex(ASource, ADest);
    enUtf8:
      Result := SetUtf8(ASource, ADest);
  else
    raise Exception.Create(cEncMissing);
  end;
end;

function CharsInSet(const AStr: string; const AChars: TSysCharSet): Boolean;
begin
  for var LCh in AStr do
    if not CharInSet(LCh, AChars) then
      Exit(False);
  Result := True;
end;

function IsValid(const ASource: string; AEnc: TEnc): Boolean;
begin
  Result := (ASource.Length mod AEnc.CharsPerValue = 0) and CharsInSet(ASource, AEnc.CharSet);
end;

function SetBase32(const ASource: string; var ADest: TBytes): Boolean;
begin
  Result := IsValid(ASource, cEnc[en32]);
  if Result then
    ADest := Base32Decode(TEncoding.UTF8.GetBytes(ASource));
end;

function SetBase64(const ASource: string; var ADest: TBytes): Boolean;
begin
  Result := IsValid(ASource, cEnc[en64]);
  if Result then
    ADest := TNetEncoding.Base64.DecodeStringToBytes(ASource);
end;

procedure SetBits(const ASource: TBits; var ADest: TBytes);
begin
  ADest.Len := (ASource.Size + 7) div 8;

  for var I := 0 to ADest.High_ do
  begin
    ADest[I] := 0;
    for var J := 0 to 7 do
      if ASource[I * 8 + J] then
        ADest[I] := ADest[I] or (1 shl (7 - J));
  end;
end;

function SetHex(const ASource: string; var ADest: TBytes): Boolean;
var
  LLen: Integer;
begin
  Result := IsValid(ASource, cEnc[enHex]);
  if not Result then
    Exit;

  LLen := ASource.Length;
  ADest.Len := LLen div 2;
  HexToBin(PChar(ASource), ADest[0], LLen);
end;

procedure SetRaw(const ASource: RawByteString; var ADest: TBytes);
var
  LLen: Integer;
begin
  LLen := Length(ASource);
  ADest.Len := LLen;
  Move(ASource[low(ASource)], ADest[0], LLen);
end;

procedure SetStream(const ASource: TStream; var ADest: TBytes);
begin
  ADest.Len := ASource.Size;
  ASource.Position := 0;
  ASource.ReadBuffer(ADest, ASource.Size);
  ASource.Position := 0;
end;

function IsUtf8(const AStr: string): Boolean;
begin
  for var LCh in AStr do
    if Ord(LCh) > cCharUtf8High then
      Exit(False);
  Result := True;
end;

function SetUtf8(const ASource: string; var ADest: TBytes): Boolean;
begin
  Result := IsUtf8(ASource);
  if Result then
    ADest := TEncoding.UTF8.GetBytes(ASource);
end;

end.
