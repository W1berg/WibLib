// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uTestData;

interface

uses
  uTypes,
  uTest;

type
  TTestData = class(TTest)
  private
    FData1, FData2: TBytes;

    procedure DataConverse(var AData: TBytes; const AUseUtf8: Boolean = True); overload;
    procedure DataConverse(const AUseUtf8: Boolean = True); overload;
    function GetBadChars(const AEnc: TEnc): string;
  public
    procedure CorrectConst;
    procedure HexCase;
    procedure InEquOut;
    procedure ResultCheck;
    procedure Vectors;
  end;

implementation

uses
  uData,

  Classes,
  SysUtils;

procedure TTestData.CorrectConst;
var
  LEnc: TEnc;
  LCharSet: set of AnsiChar;
begin
  for var LEncName := low(TEncName) to high(TEncName) do
  begin
    LEnc := cEnc[LEncName];
    Equ(LEnc.Name, LEncName);

    LCharSet := [];
    if LEnc.CharPad <> #0 then
      Include(LCharSet, LEnc.CharPad);

    for var I := low(LEnc.Chars) to high(LEnc.Chars) do
      Include(LCharSet, AnsiChar(LEnc.Chars[I]));

    Check(LCharSet = LEnc.CharSet);
  end;
end;

procedure TTestData.DataConverse(var AData: TBytes; const AUseUtf8: Boolean);
var
  LData: TBytes;
  LEncNum: Integer;
  LEncName: TEncName;
  LArr: array of Byte;
  LBits: IWrap<TBits>;
  LStream: IWrap<TStream>;
const
  cEncNameHigh = Ord(high(TEncName));
begin
  LData := AData;
  AData := nil;

  for var I := 0 to 15 do
  begin
    LEncNum := FRnd.GenInt(cEncNameHigh + 3);

    LEncName := TEncName(LEncNum);
    if (LEncName = enUtf8) and not AUseUtf8 then
      Continue;

    case LEncNum of
      0 .. cEncNameHigh:
        begin
          LData.SetAsTry(LEncName, LData.GetAs(LEncName));
        end;

      cEncNameHigh + 1:
        begin
          SetLength(LArr, LData.Len);
          LData.FillArr(LArr);
          LData.SetArr(LArr);
        end;

      cEncNameHigh + 2:
        begin
          LBits := LData.BitsWrap;
          LData.Bits := LBits.Ref;
        end;

      cEncNameHigh + 3:
        begin
          LStream := LData.StreamWrap;
          LData.Stream := LStream.Ref;
        end
    else
      raise Exception.Create('Missing test');
    end;
  end;

  AData := LData;
end;

procedure TTestData.DataConverse(const AUseUtf8: Boolean);
begin
  DataConverse(FData1, AUseUtf8);
end;

procedure TTestData.HexCase;
var
  LHexUp, LHexLow: string;
begin
  for var I := 0 to cRuns do
  begin
    LHexUp := FRnd.GenStr(cStrLen, cCharsHexUpLow).ToUpper;
    LHexLow := LHexUp.ToLower;

    FData1.Hex := LHexUp;
    FData2.Hex := LHexLow;

    Equ(FData1, FData2);
  end;
end;

procedure TTestData.InEquOut;
var
  I, LLen: Integer;
  LStr: string;
  LArr, LArr2: array of Byte;
begin;
  for I := 0 to cStrLenRuns do
  begin
    for var LEnc in cEnc do
    begin
      LLen := (I mod (cStrLen div LEnc.CharsPerValue)) * LEnc.CharsPerValue;
      LStr := FRnd.GenStr(LLen, LEnc.Chars, LEnc.CharHigh);

      Check(FData1.SetAsTry(LEnc.Name, LStr));
      DataConverse(LEnc.Name = enUtf8);

      if LEnc.Name = enHex then
        LStr := LStr.ToUpper;

      Equ(FData1.GetAs(LEnc.Name), LStr);
    end;
  end;

  for I := 0 to cStrLenRuns do
  begin
    LLen := I mod cStrLen;

    SetLength(LArr, LLen);
    FillChar(LArr[0], LLen, FRnd.GenInt(255));

    FData1.SetArr(LArr);

    SetLength(LArr2, LLen);
    FData1.FillArr(LArr2);

    Equ(LArr, LArr2);
  end;
end;

function TTestData.GetBadChars(const AEnc: TEnc): string;
var
  LLow, LHigh: Integer;
  LCh: Char;
begin
  Result := '';

  if AEnc.Name = enUtf8 then
  begin
    LLow := cCharUtf8High + 1;
    LHigh := Ord(high(Char));
  end
  else
  begin
    LLow := 0;
    LHigh := AEnc.CharHigh * 2;
  end;

  for var I := 0 to 15 do
  begin
    LCh := FRnd.GenChar(LLow, LHigh);

    if AEnc.CharSet <> [] then
    begin
      while CharInSet(LCh, AEnc.CharSet) do
        LCh := FRnd.GenChar(LLow, LHigh);

      Result := Result + FRnd.GenChar(AEnc.CharHigh + 1, Ord(high(Char)));
    end;

    Result := Result + LCh;
  end;
end;

procedure TTestData.ResultCheck;
var
  LLen: Integer;
  LStr, LBadChars: string;
  LCh: Char;
begin
  for var LEnc in cEnc do
  begin
    for var I := 0 to cStrLenRuns do
    begin
      LLen := I mod cStrLen;
      LStr := FRnd.GenStr(LLen, LEnc.Chars);
      Equ(FData1.SetAsTry(LEnc.Name, LStr), (LLen = 0) or (LLen mod LEnc.CharsPerValue = 0));

      if LLen < LEnc.CharsPerValue then
      begin
        LLen := LEnc.CharsPerValue;
        LStr := FRnd.GenStr(LLen, LEnc.Chars);
      end;

      LBadChars := GetBadChars(LEnc);
      for LCh in LBadChars do
      begin
        LStr[LLen - LEnc.CharsPerValue + 1] := LCh;
        Equ(FData1.SetAsTry(LEnc.Name, LStr), False);
      end;
    end;
  end;
end;

procedure TTestData.Vectors;
type
  TCase = record
    Input, Output: string;
  end;
const
  cVectorsBase32: array [0 .. 6] of TCase = (

    (Input: ''; //
    Output: ''),

    (Input: 'f'; //
    Output: 'MY======'),

    (Input: 'fo'; //
    Output: 'MZXQ===='),

    (Input: 'foo'; //
    Output: 'MZXW6==='),

    (Input: 'foob'; //
    Output: 'MZXW6YQ='),

    (Input: 'fooba'; //
    Output: 'MZXW6YTB'),

    (Input: 'foobar'; //
    Output: 'MZXW6YTBOI======'));

  cVectorsBase64: array [0 .. 9] of TCase = (

    (Input: ''; //
    Output: ''),

    (Input: 'f'; //
    Output: 'Zg=='),

    (Input: 'fo'; //
    Output: 'Zm8='),

    (Input: 'foo'; //
    Output: 'Zm9v'),

    (Input: 'foob'; //
    Output: 'Zm9vYg=='),

    (Input: 'fooba'; //
    Output: 'Zm9vYmE='),

    (Input: 'foobar'; //
    Output: 'Zm9vYmFy'),

    (Input: 'Hello, World!'; //
    Output: 'SGVsbG8sIFdvcmxkIQ=='),

    (Input: 'This is a test.'; //
    Output: 'VGhpcyBpcyBhIHRlc3Qu'),

    (Input: 'abcdefghijklmnopqrstuvwxyz'; //
    Output: 'YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXo='));

  procedure DoCases(const AEncName: TEncName; const ACases: array of TCase);
  begin
    for var LCase in ACases do
    begin
      FData1.Utf8 := LCase.Input;
      DataConverse;
      Equ(FData1.GetAs(AEncName), LCase.Output);
      Equ(FData1.Utf8, LCase.Input);
    end;
  end;

begin
  DoCases(en32, cVectorsBase32);
  DoCases(en64, cVectorsBase64);
end;

initialization

TTest.Add(TTestData.Create);

end.
