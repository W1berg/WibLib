// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uTestArgon2Aes;

interface

uses
  uTypes,
  uTest;

type
  TCases = record
    Input, OutMin, OutI6s, OutTest1: string;
  end;

  TTestArgonAes = class(TTest)
  private
    function GetStr(const ACipher: string; const AArgonPreset: TArgonPreset): string;

  const
    cCases: array [0 .. 4] of TCases = (

      (Input: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; //
      OutMin: '9A2D98057339F39D631B00073C4D430845A48A90E52F564ADBDBF8B069424075'; //
      OutI6s: 'A38390AAB5CCE33066AF66C933D0E63EE30D6E48A79D76F15F78D11BEE89346C'; //
      OutTest1: '13ECCE0CC08B1FE0E8B29A822D274A09CFB3CD169E27C9FB455C24FDA3C51B9E'),

      (Input: 'abcdefghijklmnopqrstuvwxyz'; //
      OutMin: '38A41298DCD20A49419F40FAACE57FB6744F54EDC0590735C855B2915198A7DC'; //
      OutI6s: '0765E604CAE9D9B43248404A0AA8274969BBACA2D7B41A495E862CC6DCB64B42'; //
      OutTest1: '8004C287924D3648D06793E43CFF2DA2F126B9977FBAFBF689E46207A80C4FF3'),

      (Input: '0123456789'; //
      OutMin: 'A2508EE1025062E79EF7E0B20D2E3577'; //
      OutI6s: '9BD72D06F11848A0FC37E4948A7BE4DB'; //
      OutTest1: '2E9DDD291DFD774CE7F6CDE310EE4569'),

      (Input: '!#$%&()*+,./:;<=>?@[]^_`{|}~"'; //
      OutMin: 'B838F8EEDE5E9BB14EBF82A2408D70340B0B6C60008BD32DEAE9AF9D281B87AF'; //
      OutI6s: '4EB3919C6EFDFA84DA3C32E980D896299396DC962AC6046C101D88D64391B9BD'; //
      OutTest1: '293AECCFC71A1D93A3FBDA751C2ED8259EE6F2EA30D06A4167A4F29DA78747ED'),

      (Input: ' Â‰ˆ≈ƒ÷-ßΩ£\'; //
      OutMin: 'AC535384018BF3E745B5D664113FE883FA754293DB62CB44DEEAD6EDA9E8E89C'; //
      OutI6s: '9E7C5987E3FC964661DE32DB1E93B81B1A35927EF8FC5EBB1E8018C34CC1725E'; //
      OutTest1: 'DE8E34263B69936C00AFD38C4E1FEA64BE2BF9ACB34840B22625585111CEDCF5'));

  public
    procedure ExpectedOut;
    procedure InEquOut;
  end;

implementation

uses
  uTestArgon2,

  Classes,
  SysUtils;

function TTestArgonAes.GetStr(const ACipher: string; const AArgonPreset: TArgonPreset): string;
begin
  case AArgonPreset of
    apMin:
      Result := 'OutMin';
    apI6s:
      Result := 'OutI6s';
    apTest1:
      Result := 'OutTest1';
  end;

  Result := Result + ': ''' + ACipher + '''';
  if AArgonPreset <> high(TArgonPreset) then
    Result := Result + '; //'
  else
    Result := Result + '),';
end;

procedure TTestArgonAes.ExpectedOut;
var
  I: Integer;
  LStr, LName: string;
  LArgonAes: IArgonAes;
  LIn, LDecrypted, LCipher: TBytes;
  LStrList: TStringList;
begin
  LArgonAes := FFac.ArgonAes;
  LStrList := TStringList.Create;
  FGet.Wrap(LStrList);

  for var LCase in cCases do
  begin
    LStrList.Add('');

    for var LArgonPreset := low(TArgonPreset) to high(TArgonPreset) do
    begin
      I := Integer(LArgonPreset);

      LName := '  TArgonPreset(' + I.ToString + ') input: ' + LCase.Input;
      TimeStart(LName);

      LArgonAes.SetPreset(LArgonPreset);
      LArgonAes.Init(TAesMode.amCbcPkcs7);

      LIn.Utf8 := LCase.Input;
      LCipher := LArgonAes.Encrypt(LIn);

      if LArgonPreset = low(TArgonPreset) then
      begin
        LStr := '(Input: ''' + LIn.Utf8 + '''; //';
        LStrList.Add(LStr);
      end;

      LStr := GetStr(LCipher.Hex, LArgonPreset);
      LStrList.Add(LStr);

      case LArgonPreset of
        apMin:
          StartsWith(LCipher.Hex, LCase.OutMin);
        apI6s:
          StartsWith(LCipher.Hex, LCase.OutI6s);
        apTest1:
          StartsWith(LCipher.Hex, LCase.OutTest1);
      else
        Fail('No case for TArgonPreset');
      end;

      LDecrypted := LArgonAes.Decrypt(LCipher);
      Equ(LIn, LDecrypted);

      TimeStop(LName);
    end;

  end;

  LStrList.Text := Copy(LStrList.Text, 1, Length(LStrList.Text) - 3) + ');';
  Log(LStrList);
end;

procedure TTestArgonAes.InEquOut;
var
  LStr: string;
  LArgonAes: IArgonAes;
  LIn, LDecrypted, LCipher: TBytes;
  LStrList: TStringList;
begin
  LArgonAes := FFac.ArgonAes;
  LStrList := TStringList.Create;
  FGet.Wrap(LStrList);

  for var LArgonParameter := low(TArgonParameter) to high(TArgonParameter) do
  begin
    for var I := 1 to cStrLen do
    begin
      if not uTestArgon2.InitArgon(LArgonAes, LArgonParameter, I) then
        Break;

      LIn.Hex := FRnd.GenStr(I * 2, cCharsHex);

      for var LAesMode := low(TAesMode) to high(TAesMode) do
      begin
        if (LAesMode = amCtsNoPad) then
          Continue;

        if LAesMode = TAesMode.amCbcNoPad then
          LIn.LenSetUpTo(16);

        LArgonAes.Init(LAesMode);
        LCipher := LArgonAes.Encrypt(LIn);

        LDecrypted := LArgonAes.Decrypt(LCipher);
        Equ(LIn, LDecrypted);

        LStr := LCipher.Hex;

        if LStrList.IndexOf(LStr) = -1 then
          LStrList.Add(LStr)
        else
          Fail('Duplicate: ' + LStr);
      end;

    end;
  end;
end;

initialization

TTest.Add(TTestArgonAes.Create);

end.
