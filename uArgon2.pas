unit uArgon2;

interface

uses
  uTypes;

type
  TArgonPresetRec = record
    Name: TArgonPreset;
    Salt: string;
    Secret: string;
    Additional: string;
    Password: string;

    Parallelism: Integer;
    MemoryKB: Integer;
    Iterations: Integer;
    OutputByteLength: Integer;
  end;

const
  cArgonPresets: array [TArgonPreset] of TArgonPresetRec = ( //

    (name: apMin; //
    Salt: ''; //
    Secret: ''; //
    Additional: ''; //
    Password: ''; //
    Parallelism: 1; //
    MemoryKB: 16; //
    Iterations: 1; //
    OutputByteLength: 5),

    (name: apI6s; //
    Salt: ''; //
    Secret: ''; //
    Additional: ''; //
    Password: ''; //
    Parallelism: 2; //
    MemoryKB: 1000; //
    Iterations: 8; //
    OutputByteLength: 16),

    // https://www.rfc-editor.org/rfc/rfc9106
    (name: apTest1; //
    Salt: '02020202020202020202020202020202'; //
    Secret: '0303030303030303'; //
    Additional: '040404040404040404040404'; //
    Password: '0101010101010101010101010101010101010101010101010101010101010101'; //
    Parallelism: 4; //
    MemoryKB: 32; //
    Iterations: 3; //
    OutputByteLength: 32)

    );

type
  TArgonPara = class(TInterfacedObject, IArgonPara)
  protected
  var
    FSalt: TBytes;
    FSecret: TBytes;
    FAdditional: TBytes;
    FPassword: TBytes;

    FParallelism: Integer;
    FMemoryKB: Integer;
    FIterations: Integer;
    FOutputByteLength: Integer;

    function GetSet(var AOld: TBytes; const ANew: TBytes): TBytes; overload;
    function GetSet(var AOld: Integer; const ANew, AMin: Integer): Integer; overload;

  public
    procedure Burn;
    procedure SetPreset(const AArgonPreset: TArgonPreset);

    function Salt(const ANew: TBytes): TBytes;
    function Secret(const ANew: TBytes): TBytes;
    function Additional(const ANew: TBytes): TBytes;
    function Password(const ANew: TBytes): TBytes;

    function Parallelism(const ANew: Integer): Integer;
    function MemoryKB(const ANew: Integer): Integer;
    function Iterations(const ANew: Integer): Integer;
    function OutputByteLength(const ANew: Integer): Integer;
  end;

  TArgon = class(TArgonPara, IArgon)
  public
    function Hash: TBytes;
  end;

implementation

uses
  HlpIHashInfo,

  HlpArgon2TypeAndVersion,
  HlpPBKDF_Argon2NotBuildInAdapter,

  SysUtils;

function TArgonPara.GetSet(var AOld: TBytes; const ANew: TBytes): TBytes;
begin
  Result := AOld;
  if Assigned(ANew) then
    AOld := ANew;
end;

function TArgonPara.GetSet(var AOld: Integer; const ANew, AMin: Integer): Integer;
begin
  if AOld < AMin then
    AOld := AMin;

  Result := AOld;
  if (cArgonInGetOnly <> ANew) and (AMin <= ANew) then
    AOld := ANew;
end;

procedure TArgonPara.Burn;
begin
  FSalt.Burn;
  FSecret.Burn;
  FAdditional.Burn;
  FPassword.Burn;

  SetPreset(apMin);
end;

procedure TArgonPara.SetPreset(const AArgonPreset: TArgonPreset);
var
  LPreset: TArgonPresetRec;
begin
  LPreset := cArgonPresets[AArgonPreset];

  FSalt.Hex := LPreset.Salt;
  FSecret.Hex := LPreset.Secret;
  FAdditional.Hex := LPreset.Additional;
  FPassword.Hex := LPreset.Password;

  FParallelism := LPreset.Parallelism;
  FMemoryKB := LPreset.MemoryKB;
  FIterations := LPreset.Iterations;
  FOutputByteLength := LPreset.OutputByteLength;
end;

function TArgonPara.Salt(const ANew: TBytes): TBytes;
begin
  Result := GetSet(FSalt, ANew);
end;

function TArgonPara.Secret(const ANew: TBytes): TBytes;
begin
  Result := GetSet(FSecret, ANew);
end;

function TArgonPara.Additional(const ANew: TBytes): TBytes;
begin
  Result := GetSet(FAdditional, ANew);
end;

function TArgonPara.Password(const ANew: TBytes): TBytes;
begin
  Result := GetSet(FPassword, ANew);
end;

function TArgonPara.Parallelism(const ANew: Integer): Integer;
begin
  Result := GetSet(FParallelism, ANew, cArgonPresets[apMin].Parallelism);
end;

function TArgonPara.MemoryKB(const ANew: Integer): Integer;
begin
  Result := GetSet(FMemoryKB, ANew, cArgonPresets[apMin].MemoryKB);
end;

function TArgonPara.Iterations(const ANew: Integer): Integer;
begin
  Result := GetSet(FIterations, ANew, cArgonPresets[apMin].Iterations);
end;

function TArgonPara.OutputByteLength(const ANew: Integer): Integer;
begin
  Result := GetSet(FOutputByteLength, ANew, cArgonPresets[apMin].OutputByteLength);
end;

function ArgonHash(const APara: IArgonPara): TBytes;
var
  LVersion: TArgon2Version;
  LArgon2ParametersBuilder: IArgon2ParametersBuilder;
  LArgon2Parameter: IArgon2Parameters;
  LGenerator: IPBKDF_Argon2;
begin
  LVersion := TArgon2Version.a2vARGON2_VERSION_13;
  LArgon2ParametersBuilder := TArgon2idParametersBuilder.Builder;

  LArgon2ParametersBuilder.WithVersion(LVersion);

  LArgon2ParametersBuilder.WithParallelism(APara.Parallelism);
  LArgon2ParametersBuilder.WithMemoryAsKB(APara.MemoryKB);
  LArgon2ParametersBuilder.WithIterations(APara.Iterations);

  LArgon2ParametersBuilder.WithSalt(APara.Salt);
  LArgon2ParametersBuilder.WithSecret(APara.Secret);
  LArgon2ParametersBuilder.WithAdditional(APara.Additional);

  LArgon2Parameter := LArgon2ParametersBuilder.Build;
  LArgon2ParametersBuilder.Clear;

  LGenerator := TPBKDF_Argon2NotBuildInAdapter.Create(APara.Password, LArgon2Parameter);
  Result := LGenerator.GetBytes(APara.OutputByteLength);

  LArgon2Parameter.Clear;
  LGenerator.Clear;
end;

function TArgon.Hash: TBytes;
begin
  Result := ArgonHash(Self);
end;

end.
