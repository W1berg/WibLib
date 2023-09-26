// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uSync;

interface

uses
  uTypes,
  Classes;

type
  TSync = class abstract(TInterfacedObject, ISync)
  private
    FLog: ILog;

    procedure SyncP(const AProc: TThreadProcedure);

  public
    constructor Create;

    procedure Log(const AStr: string = ''; const AFunc: string = ''; const AClass: string = ''; const ALogLevel: TLogLevel = llDebug; const ADate: TDateTime = 0);
    procedure LogSet(const ALogProc: TProcArg1<string>); overload;
    procedure LogSet(const ALog: ILog); overload;

    procedure Sync(const AProc: TProcArg0);
    procedure SyncCheck;
  end;

implementation

function GetThreadId: Cardinal;
begin
  Result := TThread.Current.ThreadID;
end;

function IsMainThread: Boolean;
begin
  Result := GetThreadId = MainThreadID;
end;

//

constructor TSync.Create;
begin
  FLog := FGet.Fac.Log;
end;

procedure TSync.Log(const AStr, AFunc, AClass: string; const ALogLevel: TLogLevel; const ADate: TDateTime);
begin
  if IsMainThread then
    FLog.Log(AStr, AFunc, AClass, ALogLevel, ADate)
  else
    SyncP(
      procedure
      begin
        FLog.Log(AStr, AFunc, AClass, ALogLevel, ADate);
      end);
end;

procedure TSync.LogSet(const ALogProc: TProcArg1<string>);
begin
  FLog := FGet.Fac.LogNew(ALogProc);
end;

procedure TSync.LogSet(const ALog: ILog);
begin
  FLog := ALog;
end;

procedure TSync.SyncP(const AProc: TThreadProcedure);
begin
  TThread.Synchronize(TThread.Current, AProc); // Blocks thread
end;

procedure TSync.Sync(const AProc: TProcArg0);
begin
  if IsMainThread then
    AProc
  else
    SyncP(
      procedure
      begin
        AProc;
      end);
end;

procedure TSync.SyncCheck;
begin
  if IsMainThread then
    CheckSynchronize;
end;

end.
