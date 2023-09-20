// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uArgon2Aes;

interface

uses
  uTypes,
  uArgon2;

type
  TArgonAes = class(TArgon, IArgonAes)
  private
  var
    FAes: IAes;
  public
    constructor Create(const AFac: IFac);

    procedure Init(const AAesMode: TAesMode);

    function Encrypt(const AData: TBytes): TBytes;
    function Decrypt(const ACipher: TBytes): TBytes;
  end;

implementation

constructor TArgonAes.Create(const AFac: IFac);
begin
  FAes := AFac.Aes;
end;

procedure TArgonAes.Init(const AAesMode: TAesMode);
var
  LKey, LIv: TBytes;
begin
  OutputByteLength(32);
  LKey := Hash;

  OutputByteLength(16);
  LIv := Hash;

  FAes.Init(LKey, LIv, AAesMode);
  LKey.Burn;
  LIv.Burn;
end;

function TArgonAes.Encrypt(const AData: TBytes): TBytes;
begin
  Result := FAes.Encrypt(AData, False);
end;

function TArgonAes.Decrypt(const ACipher: TBytes): TBytes;
begin
  Result := FAes.Decrypt(ACipher, False);
end;

end.
