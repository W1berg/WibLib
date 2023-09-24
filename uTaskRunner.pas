// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uTaskRunner;

interface

uses
  uTypes,
  uTaskStarter;

type
  TTaskRunner = class abstract(TTaskStarter, ITask)
  private
    FDone, FTerminated: IEvent;
    FStarted, FTicked: Boolean;
    FName: string;

    procedure LogP(const AStr: string; const AFunc: string; const ALogLevel: TLogLevel = llDebug);

  protected
    procedure Exec; override;

  public
    constructor Create(const ATaskType: TTaskType; const AName: string);
    function GetName: string;

    function IsDone: Boolean;
    function IsStarted: Boolean;
    function IsTerminated: Boolean;

    procedure Refresh;
    procedure Run;
    procedure Terminate;
    procedure ThreadSleep(const AMiliSec: Integer);

    function Ticking: Boolean;
    function WaitFor(const AMiliSec: Integer): Boolean;
  end;

implementation

uses
  SysUtils;

constructor TTaskRunner.Create(const ATaskType: TTaskType; const AName: string);
begin
  inherited Create(ATaskType);

  FDone := FGet.Fac.Event;
  FTerminated := FGet.Fac.Event;

  FName := AName;
  LogP(Ord(ATaskType).ToString, 'Create', llInfo);
end;

procedure TTaskRunner.Exec;
begin
  if FTicked and not IsTerminated then // If needs to be refreshed
    Exit;

  FDone.Activate;
  Sync(
    procedure
    begin
      LogP('Done', 'Exec', llInfo);
    end);
end;

function TTaskRunner.GetName: string;
begin
  Result := FName;
end;

function TTaskRunner.IsDone: Boolean;
begin
  Result := FDone.WaitFor(0);
end;

function TTaskRunner.IsStarted: Boolean;
begin
  Result := FStarted;
end;

function TTaskRunner.IsTerminated: Boolean;
begin
  Result := FTerminated.WaitFor(0);
end;

procedure TTaskRunner.LogP(const AStr, AFunc: string; const ALogLevel: TLogLevel);
begin
  Log(AStr, AFunc, 'TTaskRunner:' + FName, ALogLevel);
end;

procedure TTaskRunner.Refresh;
begin
  if not FTicked or IsDone then
    Exit;

  FTicked := False;
  Exec;
end;

procedure TTaskRunner.Run;
begin
  if FStarted then
  begin
    LogP('Already started', 'Run', llWarn);
    Exit;
  end;

  FStarted := True;
  LogP('Starting', 'Run');
  Start;
end;

procedure TTaskRunner.Terminate;
begin
  FTerminated.Activate;
end;

procedure TTaskRunner.ThreadSleep(const AMiliSec: Integer);
begin
  if FTaskType = tcThread then
    FTerminated.WaitFor(AMiliSec);
end;

function TTaskRunner.Ticking: Boolean;
begin
  Result := not(FTicked or IsTerminated);
  FTicked := FTaskType = tcFunc;
end;

function TTaskRunner.WaitFor(const AMiliSec: Integer): Boolean;
begin
  if not FStarted then
    LogP('Not started', 'WaitFor', llWarn);

  Result := FDone.WaitFor(AMiliSec);

  if not Result then
    LogP('Timeout', 'WaitFor', llWarn);
end;

end.
