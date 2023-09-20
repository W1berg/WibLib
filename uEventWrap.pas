// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uEventWrap;

interface

uses
  uTypes,
  SyncObjs;

type
  TEventWrap = class(TInterfacedObject, IEvent)
  private
    FEvent: TEvent;
    FSignaled: Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Activate;
    procedure Reset;
    function WaitFor(const AMiliSec: Integer): Boolean;
  end;

implementation

constructor TEventWrap.Create;
begin
  FEvent := TEvent.Create(nil, True, False, '');
end;

destructor TEventWrap.Destroy;
begin
  FEvent.Free;
  inherited;
end;

procedure TEventWrap.Activate;
begin
  FSignaled := True;
  FEvent.SetEvent;
end;

procedure TEventWrap.Reset;
begin
  FSignaled := False;
  FEvent.ResetEvent;
end;

function TEventWrap.WaitFor(const AMiliSec: Integer): Boolean;
begin
  Result := FSignaled or ((AMiliSec > 0) and (FEvent.WaitFor(AMiliSec) = wrSignaled));
end;

end.
