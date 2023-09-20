// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uRnd;

interface

uses
  uTypes;

type
  TRnd = class(TInterfacedObject, IRnd)
  public
    function GenChar(const AHigh: Integer): Char; overload;
    function GenChar(const ALow, AHigh: Integer): Char; overload;

    function GenInt(const AHigh: Integer): Integer; overload;
    function GenInt(const ALow, AHigh: Integer): Integer; overload;

    function GenStr(const ALength, AHigh: Integer): string; overload;
    function GenStr(const ALength: Integer; const ACharset: string; const AHigh: Integer): string; overload;
    function GenStr(const ALength: Integer; ALow: Integer; AHigh: Integer): string; overload;
  end;

implementation

uses
  Classes,
  SysUtils;

function TRnd.GenChar(const AHigh: Integer): Char;
begin
  Result := Chr(GenInt(AHigh));
end;

function TRnd.GenChar(const ALow, AHigh: Integer): Char;
begin
  Result := Chr(GenInt(ALow, AHigh));
end;

function TRnd.GenInt(const AHigh: Integer): Integer;
begin
  Result := Random(AHigh + 1); // IntMax + 1 still produce range 0 - IntMax
end;

function TRnd.GenInt(const ALow, AHigh: Integer): Integer;
begin
  if ALow > AHigh then
    raise Exception.Create('ALow > AHigh');

  Result := GenInt(AHigh - ALow) + ALow;
end;

function TRnd.GenStr(const ALength, AHigh: Integer): string;
begin
  Result := GenStr(ALength, 0, AHigh);
end;

function TRnd.GenStr(const ALength: Integer; const ACharset: string; const AHigh: Integer): string;
var
  LSetLast: Integer;
begin
  LSetLast := ACharset.Length - 1;
  if LSetLast < 0 then
    Exit(GenStr(ALength, 0, AHigh));

  SetLength(Result, ALength);
  for var I := low(Result) to high(Result) do
    Result[I] := ACharset.Chars[GenInt(LSetLast)];
end;

function TRnd.GenStr(const ALength: Integer; ALow, AHigh: Integer): string;
begin
  if (ALow < 0) or (AHigh < 1) or (AHigh > cCharUtf8High) then
    raise Exception.Create('GenStr bad arg');

  SetLength(Result, ALength);
  for var I := low(Result) to high(Result) do
    Result[I] := GenChar(ALow, AHigh);
end;

end.
