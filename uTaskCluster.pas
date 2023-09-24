// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uTaskCluster;

interface

uses
  uTypes,
  uSync,

  Generics.Collections;

type
  TTaskCluster = class(TSync, ITaskCluster)
  private
    FOnAdd: TProcArg1<ITaskAbstract>;
    FTasks: TList<ITaskAbstract>;
    FTerminated: Boolean;

    procedure LogP(const AStr: string; const AFunc: string; const ALogLevel: TLogLevel = llDebug);

  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const ATask: ITaskAbstract);
    procedure DoOnAdd(const AOnAdd: TProcArg1<ITaskAbstract>);
    function GetName: string;

    function IsDone: Boolean;
    function IsStarted: Boolean;
    function IsTerminated: Boolean;

    procedure Refresh;
    procedure Run;

    procedure Terminate;
    function WaitFor(const AMiliSec: Integer): Boolean;
  end;

implementation

uses
  SysUtils;

constructor TTaskCluster.Create;
begin
  inherited;
  FTasks := TList<ITaskAbstract>.Create;
end;

destructor TTaskCluster.Destroy;
begin
  FTasks.Free;
  inherited;
end;

procedure TTaskCluster.DoOnAdd(const AOnAdd: TProcArg1<ITaskAbstract>);
begin
  FOnAdd := AOnAdd;
end;

function TTaskCluster.GetName: string;
begin
  Result := Self.ClassName;
end;

procedure TTaskCluster.Add(const ATask: ITaskAbstract);
begin
  if FTerminated then
    LogP('Already termianted, will reset Terminated and adding', 'Add', llWarn);

  FTerminated := False;

  FTasks.Add(ATask);

  if Assigned(FOnAdd) then
    FOnAdd(ATask);
end;

function TTaskCluster.IsDone: Boolean;
begin
  for var LTask in FTasks do
    if not LTask.IsDone then
      Exit(False);
  Result := True;
end;

function TTaskCluster.IsStarted: Boolean;
begin
  for var LTask in FTasks do
    if not LTask.IsStarted then
      Exit(False);
  Result := True;
end;

function TTaskCluster.IsTerminated: Boolean;
begin
  Result := FTerminated;
end;

procedure TTaskCluster.LogP(const AStr: string; const AFunc: string; const ALogLevel: TLogLevel);
begin
  Log(AStr, AFunc, 'TTaskCluster', ALogLevel, 0);
end;

procedure TTaskCluster.Refresh;
begin
  for var LTask in FTasks do
    LTask.Refresh;
end;

procedure TTaskCluster.Run;
begin
  if FTerminated then
    LogP('Already termianted, will run', 'Run', llWarn);

  for var LTask in FTasks do
    if not LTask.IsStarted then
      LTask.Run;
end;

procedure TTaskCluster.Terminate;
begin
  if FTerminated then
    LogP('Already termianted', 'Terminate', llWarn);

  if not IsStarted then
    LogP('Is not started', 'Terminate', llWarn);

  LogP('Count: ' + FTasks.Count.ToString, 'Terminate');

  FTerminated := True;

  for var LTask in FTasks do
    LTask.Terminate;

  SyncCheck; // Flush Synchronize messages
end;

function TTaskCluster.WaitFor(const AMiliSec: Integer): Boolean;
var
  LDeadLine, LTick, LTimeout: UInt64;
begin
  if not IsStarted then
    LogP('Is not started', 'WaitFor', llWarn);

  LDeadLine := FGet.Ticks64 + AMiliSec;

  for var LTask in FTasks do
  begin
    LTick := FGet.Ticks64;
    LTimeout := LDeadLine - LTick;

    if (LDeadLine < LTick) or (not LTask.WaitFor(LTimeout)) then
      Exit(False);
  end;

  Result := True;
end;

end.
