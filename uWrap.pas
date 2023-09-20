// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uWrap;

interface

uses
  uTypes;

type
  TWrap<T: constructor> = class(TInterfacedObject, IWrap<T>)
  private
    FObj: T;

    procedure IfNilRaise(var AObj);
    procedure FreeNil(var AObj);

  public
    constructor Create; overload;
    constructor Create(const AObj: T); overload;
    destructor Destroy; override;

    function Ref: T;
  end;

implementation

constructor TWrap<T>.Create;
begin
  FObj := T.Create;
  IfNilRaise(FObj);
end;

constructor TWrap<T>.Create(const AObj: T);
begin
  FObj := AObj;
end;

destructor TWrap<T>.Destroy;
begin
  FreeNil(FObj);
  inherited;
end;

procedure TWrap<T>.IfNilRaise(var AObj);
begin
  if TObject(AObj) = nil then
    FGet.Fac.Log.Log('T.Create failed', 'IfNilRaise', 'TWrap', llDebugRaise);
end;

procedure TWrap<T>.FreeNil(var AObj);
begin
  if TObject(AObj) <> nil then
  begin
    TObject(AObj).Free;
    TObject(AObj) := nil;
  end;
end;

function TWrap<T>.Ref: T;
begin
  Result := FObj;
end;

end.
