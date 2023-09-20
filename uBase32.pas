// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uBase32;

interface

function Base32Encode(const AData: TArray<Byte>; const AWithPad: Boolean = True): TArray<Byte>;
function Base32Decode(const ACipher: TArray<Byte>): TArray<Byte>;

implementation

const
  // cCharsBase32 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  cEncodeMap: array [0 .. 31] of Byte = (

    65, 66, 67, 68, 69, 70, 71, 72, 73, 74, // ABCDEFGHIJ
    75, 76, 77, 78, 79, 80, 81, 82, 83, 84, // KLMNOPQRST
    85, 86, 87, 88, 89, 90, 50, 51, 52, 53, // UVWXYZ2345
    54, 55); // 67

  cDecodeMap: array [50 .. 122] of Byte = (

    26, 27, 28, 29, 30, 31, $0, $0, $0, $0, // 23456789:;
    $0, $0, $0, $0, $0, 00, 01, 02, 03, 04, // <=>?@ABCDE
    05, 06, 07, 08, 09, 10, 11, 12, 13, 14, // FGHIJKLMNO
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, // PQRSTUVWXY
    25, $0, $0, $0, $0, $0, $0, $0, 01, 02, // Z[\]^-.abc
    03, 04, 05, 06, 07, 08, 09, 10, 11, 12, // defghijklm
    13, 14, 15, 16, 17, 18, 19, 20, 21, 22, // nopqrstuvw
    23, 24, 25); // xyz

  cPad = Ord('=');

function GetEncodeBuffer(const ALen: Integer; const AWithPad: Boolean): TArray<Byte>;
var
  LLenNoPad, LPadCount: Integer;
begin
  LLenNoPad := (ALen * 8 + 4) div 5;

  LPadCount := LLenNoPad mod 8;
  LPadCount := Ord(AWithPad) * Ord(LPadCount > 0) * (8 - LPadCount);

  SetLength(Result, LLenNoPad + LPadCount);
  FillChar(Result[LLenNoPad], LPadCount, cPad);
end;

function Base32Encode(const AData: TArray<Byte>; const AWithPad: Boolean): TArray<Byte>;
var
  I: Integer;
  LBuff, LBuffCount: Word;
begin
  Result := GetEncodeBuffer(Length(AData), AWithPad);

  I := 0;
  LBuff := 0;
  LBuffCount := 0;

  for var LInputIndex := 0 to high(AData) do
  begin
    LBuff := LBuff shl 8 or AData[LInputIndex];
    Inc(LBuffCount, 8);

    while LBuffCount >= 5 do
    begin
      Dec(LBuffCount, 5);
      Result[I] := cEncodeMap[LBuff shr LBuffCount and 31]; // Alternative: Ord(cCharsBase32[LBuff shr LBuffCount and 31 + 1]);
      Inc(I);
    end;
  end;

  if LBuffCount > 0 then
    Result[I] := cEncodeMap[LBuff shl (5 - LBuffCount) and 31];
end;

function Base32Decode(const ACipher: TArray<Byte>): TArray<Byte>;
var
  I, LHighNoPad: Integer;
  LBuff, LBuffCount: Word;
begin
  LHighNoPad := high(ACipher); // Fix not getting value in Win32 when array is empty
  for LHighNoPad := LHighNoPad downto 0 do
    if ACipher[LHighNoPad] <> cPad then
      Break;

  SetLength(Result, LHighNoPad * 5 div 8 + Ord(Assigned(ACipher)));

  I := 0;
  LBuff := 0;
  LBuffCount := 0;

  for var LInputIndex := 0 to LHighNoPad do
  begin
    LBuff := LBuff shl 5 or cDecodeMap[ACipher[LInputIndex]]; // Alternative: (Pos(Chr(ACipher[LInputIndex]), cCharsBase32) - 1)
    Inc(LBuffCount, 5);

    if LBuffCount >= 8 then
    begin
      Dec(LBuffCount, 8);
      Result[I] := LBuff shr LBuffCount;
      Inc(I);
    end;
  end;
end;

end.
