unit uChaCha;

interface

uses
  uTypes,
  uTest,

  ClpIChaChaEngine;

type
  TChaCha = class(TInterfacedObject, IChaCha)
  private
    FCha: IChaChaEngine;
    FEncrypt: Boolean;

    function Crypt(const AData: TBytes; const AKeyStream, AEncrypt: Boolean): TBytes;

  public
    procedure Init(const AKey, AIv: TBytes; const ARounds: Integer = 20);

    function Encrypt(const AData: TBytes; const AKeyStream: Boolean): TBytes;
    function Decrypt(const ACipher: TBytes; const AKeyStream: Boolean): TBytes;

    procedure Reset;
    function ReturnByte(const APlain: TBytes): TBytes;
  end;

implementation

uses
  ClpIKeyParameter,
  ClpIParametersWithIV,

  ClpChaChaEngine,
  ClpKeyParameter,
  ClpParametersWithIV,

  SysUtils;

procedure TChaCha.Init(const AKey, AIv: TBytes; const ARounds: Integer);
var
  LKey: IKeyParameter;
  LKeyIv: IParametersWithIV;
begin
  if (not AKey.Len in [16, 32]) or (AIv.Len <> 8) or (ARounds < 1) then
    raise Exception.Create('Bad init');

  LKey := TKeyParameter.Create(AKey);
  LKeyIv := TParametersWithIV.Create(LKey, AIv);

  FEncrypt := True;
  FCha := TChaChaEngine.Create(ARounds);
  FCha.Init(True, LKeyIv);
end;

procedure TChaCha.Reset;
begin
  FCha.Reset;
end;

function TChaCha.ReturnByte(const APlain: TBytes): TBytes;
begin
  if APlain.IsEmpty then
    Exit;

  Result.Len := APlain.Len;

  for var I := 0 to Result.High_ do
    Result[I] := FCha.ReturnByte(APlain[I]);
end;

function TChaCha.Crypt(const AData: TBytes; const AKeyStream, AEncrypt: Boolean): TBytes;
begin
  if AEncrypt <> FEncrypt then
  begin
    FEncrypt := AEncrypt;
    FCha.Reset;
  end;

  Result.Len := AData.Len;
  FCha.ProcessBytes(AData, 0, AData.Len, Result, 0); // Get KeyStream

  if AKeyStream then
    Exit;

  Result := ReturnByte(AData); // Get Cipher
end;

function TChaCha.Encrypt(const AData: TBytes; const AKeyStream: Boolean): TBytes;
begin
  if AData.Len > 0 then
    Result := Crypt(AData, AKeyStream, True);
end;

function TChaCha.Decrypt(const ACipher: TBytes; const AKeyStream: Boolean): TBytes;
begin
  if ACipher.Len > 0 then
    Result := Crypt(ACipher, AKeyStream, False);
end;

end.
