unit uAes;

interface

uses
  uTypes,

  ClpIBufferedCipher,
  ClpIParametersWithIV;

type
  TAesModeRec = record
    Mode: TAesMode;
    Algo: string;
  end;

const
  cAesModes: array [TAesMode] of TAesModeRec = (

    (Mode: amCbcNoPad; //
    Algo: 'AES/CBC/NOPADDING'),

    (Mode: amCbcPkcs7; //
    Algo: 'AES/CBC/PKCS7PADDING'),

    (Mode: amCtrNoPad; //
    Algo: 'AES/CTR/NOPADDING'),

    (Mode: amCtsNoPad; //
    Algo: 'AES/CTS/NOPADDING')

    );

type
  TAes = class(TInterfacedObject, IAes)
  private
    FCipher: IBufferedCipher;
    FPara: IParametersWithIV;

    function Crypt(const ABytes: TBytes; const AEncrypt: Boolean): TBytes;

  public
    procedure Init(const AKey, AIv: TBytes; const AAesMode: TAesMode);
    function Encrypt(const AData: TBytes; const AWithMac: Boolean): TBytes;
    function Decrypt(const ACipher: TBytes; const AWithMac: Boolean): TBytes;
  end;

implementation

uses
  ClpIBlockCipher,

  ClpAesEngine,
  ClpBlockCipherModes,
  ClpBufferedBlockCipher,
  // ClpCipherUtilities,
  ClpKeyParameter,
  ClpPaddedBufferedBlockCipher,
  ClpPaddingModes,
  ClpParametersWithIV,

  Hash,
  SysUtils;

procedure TAes.Init(const AKey, AIv: TBytes; const AAesMode: TAesMode);
var
  BlockCipher: IBlockCipher;
begin
  BlockCipher := TAesEngine.Create;

  case AAesMode of
    amCbcNoPad:
      begin
        BlockCipher := TCbcBlockCipher.Create(BlockCipher);
        FCipher := TBufferedBlockCipher.Create(BlockCipher);
      end;

    amCbcPkcs7:
      begin
        BlockCipher := TCbcBlockCipher.Create(BlockCipher);
        FCipher := TPaddedBufferedBlockCipher.Create(BlockCipher, TPkcs7Padding.Create);
      end;

    amCtrNoPad:
      begin
        BlockCipher := TSicBlockCipher.Create(BlockCipher);
        FCipher := TBufferedBlockCipher.Create(BlockCipher);
      end;

    amCtsNoPad:
      begin
        BlockCipher := TCbcBlockCipher.Create(BlockCipher);
        FCipher := TCtsBlockCipher.Create(BlockCipher);
      end;
  end;

  // FCipher := TCipherUtilities.GetCipher(cAesModes[AAesMode].Algo);
  FPara := TParametersWithIV.Create(TKeyParameter.Create(AKey, 0, AKey.Len), AIv);
end;

function TAes.Crypt(const ABytes: TBytes; const AEncrypt: Boolean): TBytes;
// var
// LLen: Integer;
// const
// cMultiPass = True;
begin
  FCipher.Init(AEncrypt, FPara);
  Result := FCipher.DoFinal(ABytes); // Single Pass

  // if cMultiPass then
  // begin
  // SetLength(Result, ACipher.GetOutputSize(AData.Len));
  // LLen := ACipher.ProcessBytes(AData, 0, AData.Len, Result, 0);
  // LLen := LLen + ACipher.DoFinal(Result, LLen);
  //
  // if not AEncrypt then
  // SetLength(Result, LLen); // Remove padding
  // end;
end;

function TAes.Encrypt(const AData: TBytes; const AWithMac: Boolean): TBytes;
begin
  if AData.Len = 0 then
    Exit(nil);

  Result := Crypt(AData, True);

  if AWithMac then
    Result := Result + THashSHA2.GetHMACAsBytes(Result, FPara.GetIV, SHA512_256);
end;

function EndsWith(const A, B: TBytes): Boolean;
var
  I, LOff: Integer;
begin
  LOff := A.Len - B.Len;

  if LOff < 0 then
    Exit(False);

  for I := 0 to B.High_ do
    if A[I + LOff] <> B[I] then
      Exit(False);

  Result := True;
end;

procedure CheckMac(const ACipherNoMac, ACipherWithMac, AIv: TBytes);
var
  LMac: TBytes;
begin
  LMac := THashSHA2.GetHMACAsBytes(ACipherNoMac, AIv, SHA512_256);

  if not EndsWith(ACipherWithMac, LMac) then
    raise Exception.Create('Bad mac');
end;

function TAes.Decrypt(const ACipher: TBytes; const AWithMac: Boolean): TBytes;
var
  LCipher: TBytes;
const
  cMacLen = 32;
begin
  if ACipher.Len = 0 then
    Exit(nil);

  LCipher := ACipher;

  if AWithMac then
  begin
    LCipher.Len := LCipher.Len - cMacLen;
    CheckMac(LCipher, ACipher, FPara.GetIV);
  end;

  Result := Crypt(LCipher, False);
end;

end.
