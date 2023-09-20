// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uCrit;

interface

uses
  uTypes,
  SyncObjs;

type
  TCrit = class(TInterfacedObject, ICrit)
  private
    FCrit: TCriticalSection;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Enter;
    function EnterTry: Boolean;
    procedure Leave;
  end;

implementation

constructor TCrit.Create;
begin
  FCrit := TCriticalSection.Create;
end;

destructor TCrit.Destroy;
begin
  FCrit.Free;
  inherited;
end;

procedure TCrit.Enter;
begin
  FCrit.Enter;
end;

function TCrit.EnterTry: Boolean;
begin
  Result := FCrit.TryEnter;
end;

procedure TCrit.Leave;
begin
  FCrit.Leave;
end;

end.
