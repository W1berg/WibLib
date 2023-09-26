// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uTaskStarter;

interface

uses
  uTypes,
  uSync,

  Classes;

type
  TTaskStarter = class abstract(TSync)
  private
    FThread: TThread;

  protected
    FTaskType: TTaskType;
    procedure Exec; virtual; abstract;
    procedure Start;

  public
    constructor Create(const ATaskType: TTaskType);
  end;

implementation

constructor TTaskStarter.Create(const ATaskType: TTaskType);
begin
  inherited Create;

  FTaskType := ATaskType;
  if FTaskType = tcFunc then
    Exit;

  FThread := TThread.CreateAnonymousThread(Exec);
  FThread.FreeOnTerminate := True;
end;

procedure TTaskStarter.Start;
begin
  if FTaskType = tcFunc then
    Exec
  else
    FThread.Start;
end;

end.
