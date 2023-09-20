// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uTestChaCha;

interface

uses
  uTypes,
  uTest;

type
  TTestChaCha = class(TTest)
  private

  public
    procedure InEquOut;
    procedure Vectors;
  end;

implementation

uses
  uChaCha,
  ClpBlockCipherModes,

  Math,
  SysUtils;

type
  TVectorsRec = record
    Key, Iv, Input, KeyStream, Output: string;
  end;

const
  // https://datatracker.ietf.org/doc/html/draft-agl-tls-chacha20poly1305-02
  cVectors: array [0 .. 1] of TVectorsRec = (

    (Key: '0000000000000000000000000000000000000000000000000000000000000000'; //
    Iv: '0000000000000000'; //
    Input: '000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'; //
    KeyStream: '76b8e0ada0f13d90405d6ae55386bd28bdd219b8a08ded1aa836efcc8b770dc7da41597c5157488d7724e03fb8d84a376a43b8f41518a11cc387b669'; //
    Output: ''),

    (Key: '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f'; //
    Iv: '0001020304050607'; //
    Input: ''; //
    KeyStream: //
    'f798a189f195e66982105ffb640bb7757f579da31602fc93ec01ac56' + //
    'f85ac3c134a4547b733b46413042c9440049176905d3be59ea1c53f1' + //
    '5916155c2be8241a38008b9a26bc35941e2444177c8ade6689de9526' + //
    '4986d95889fb60e84629c9bd9a5acb1cc118be563eb9b3a4a472f82e' + //
    '09a7e778492b562ef7130e88dfe031c79db9d4f7c7a899151b9a4750' + //
    '32b63fc385245fe054e3dd5a97a5f576fe064025d3ce042c566ab2c5' + //
    '07b138db853e3d6959660996546cc9c4a6eafdc777c040d70eaf46f7' + //
    '6dad3979e5c5360c3317166a1c894c94a371876a94df7628fe4eaaf2' + //
    'ccb27d5aaae0ad7ad0f9d4b6ad3b54098746d4524d38407a6deb'; //
    Output: '')

    );

procedure TTestChaCha.InEquOut;
var
  LCha: IChaCha;
  LKey, LIv, LIn, LKeyStream, LCipher, LDecrypted: TBytes;
  I, LKeyLength, LRounds: Integer;
const
  cKeyLengths = [16, 32];
  cIvLen = 8;
begin
  LCha := FFac.ChaCha;

  for LRounds := 1 to 16 do
  begin

    for LKeyLength in cKeyLengths do
    begin

      for I := 1 to cStrLen do
      begin
        LKey.Hex := FRnd.GenStr(LKeyLength * 2, cCharsHex);
        LIv.Hex := FRnd.GenStr(cIvLen * 2, cCharsHex);
        LIn.Hex := FRnd.GenStr(I * 2, cCharsHex);

        LCha.Init(LKey, LIv, LRounds * 2);
        LKey.Burn;
        LIv.Burn;

        LKeyStream := LCha.Encrypt(LIn, True);
        LCipher := LCha.ReturnByte(LIn);

        LDecrypted := LCha.Decrypt(LKeyStream, True);
        Equ(LIn, LDecrypted);

        LCha.Reset;

        LDecrypted := LCha.Decrypt(LCipher);
        Equ(LIn, LDecrypted);
      end;
    end;
  end;
end;

procedure TTestChaCha.Vectors;
var
  LCha: IChaCha;
  LKey, LIv, LIn, LKeyStream, LKeyStreamExpected, LOut, LCipher, LDecrypted: TBytes;
begin
  for var LRec in cVectors do
  begin
    LKey.Hex := LRec.Key;
    LIv.Hex := LRec.Iv;
    LIn.Hex := LRec.Input;
    LKeyStreamExpected.Hex := LRec.KeyStream;
    LOut.Hex := LRec.Output;

    if LIn.IsEmpty then
      LIn.Len := Max(LKeyStreamExpected.Len, LOut.Len);

    LCha := FFac.ChaCha;
    LCha.Init(LKey, LIv, 20);

    LKeyStream := LCha.Encrypt(LIn, True);
    Equ(LKeyStream, LKeyStreamExpected);

    //

    if LOut.IsEmpty then
      LOut := LCha.ReturnByte(LIn);

    //

    Check(LCha.Encrypt(LIn, True) <> LKeyStreamExpected);

    LDecrypted := LCha.Decrypt(LKeyStream, True);
    Equ(LIn, LDecrypted);

    //

    LCipher := LCha.Encrypt(LIn);
    Equ(LCipher, LOut);

    Check(LCha.Encrypt(LIn) <> LOut);

    LDecrypted := LCha.Decrypt(LCipher);
    Equ(LIn, LDecrypted);
  end;
end;

initialization

TTest.Add(TTestChaCha.Create);

end.
