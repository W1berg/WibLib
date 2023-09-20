// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uTestArgon2;

interface

uses
  uTypes,
  uTest;

type
  TArgonParameter = (apSalt, apSecret, apAdditional, apPassword, apParallelism, apMemoryKB, apIterations, apOutputByteLength);

  TTestArgon = class(TTest)
  public
    procedure CorrectConst;
    procedure ExpectedRes;
    procedure InChangesOut;
  end;

function InitArgon(const AArgon: IArgon; const AArgonParameter: TArgonParameter; const AI: Integer): Boolean;

implementation

uses
  uArgon2,

  Classes,
  TypInfo,
  SysUtils;

procedure TTestArgon.CorrectConst;
var
  LPreset: TArgonPreset;
begin
  for LPreset := low(TArgonPreset) to high(TArgonPreset) do
  begin
    Equ(LPreset, uArgon2.cArgonPresets[LPreset].Name);
    Check(uArgon2.cArgonPresets[LPreset].Parallelism <= 8);
  end;
end;

procedure TTestArgon.ExpectedRes;
var
  LArgon: IArgon;
  LEn: TBytes;
const
  cExpected = '0D640DF58D78766C08C037A34A8B53C9D01EF0452D75B65EB52520E96B01E659';
begin
  LArgon := FFac.Argon;
  LArgon.SetPreset(apTest1);
  LEn := LArgon.Hash;
  Equ(LEn.Hex, cExpected);
end;

function InitArgon(const AArgon: IArgon; const AArgonParameter: TArgonParameter; const AI: Integer): Boolean;
var
  LBytes: TBytes;
begin
  if AI < 1 then
    raise Exception.Create('AI < 1');

  AArgon.SetPreset(apMin);
  LBytes.Hex := StringOfChar('F', AI * 2);

  case AArgonParameter of
    apSalt:
      AArgon.Salt(LBytes);
    apSecret:
      AArgon.Secret(LBytes);
    apAdditional:
      AArgon.Additional(LBytes);
    apPassword:
      AArgon.Password(LBytes);
    apParallelism:
      AArgon.Parallelism(AI);
    apMemoryKB:
      AArgon.MemoryKB(AI + AArgon.MemoryKB);
    apIterations:
      AArgon.Iterations(AI + AArgon.Iterations);
    apOutputByteLength:
      AArgon.OutputByteLength(AI + AArgon.OutputByteLength);
  else
    raise Exception.Create('No AArgonParameter');
  end;

  Result := (AArgon.Parallelism <= 8);
end;

procedure TTestArgon.InChangesOut;
var
  LArgon: IArgon;
  LStr, LEnumName: string;
  LStrList: TStringList;
begin
  LArgon := FFac.Argon;
  LStrList := TStringList.Create;
  FGet.Wrap(LStrList);

  for var LArgonParameter := low(TArgonParameter) to high(TArgonParameter) do
  begin
    LEnumName := GetEnumName(TypeInfo(TArgonParameter), Ord(LArgonParameter));
    Log(LEnumName, llDebug);

    for var I := 1 to cStrLen do
    begin
      if not InitArgon(LArgon, LArgonParameter, I) then
        Break; // Cant test Parallelism > 8

      if (LArgon.MemoryKB > 1024) or (LArgon.Iterations > 256) then // Takes too long
        Break;

      LStr := LArgon.Hash.Hex;

      if LStrList.IndexOf(LStr) = -1 then
        LStrList.Add(LStr)
      else
        Fail('Duplicate on:' + I.ToString + ' ' + LEnumName);
    end;
  end;
end;

initialization

TTest.Add(TTestArgon.Create);

end.
