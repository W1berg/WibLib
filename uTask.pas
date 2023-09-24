// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uTask;

interface

uses
  uTypes,
  uTaskRunner;

type

  TTask<T> = class(TTaskRunner, ITask<T>)
  private
    FData: T;
    FProc: TProcArg1<ITask<T>>;

  protected
    procedure Exec; override;

  public
    constructor Create(const ATaskType: TTaskType; const AName: string; const AProc: TProcArg1 < ITask < T >> ); overload;
    constructor Create(const ATaskType: TTaskType; const AName: string; const AProc: TProcArg1<ITask<T>>; const AData: T); overload;
    function Data: T;
    procedure SetData(const AData: T); overload;
  end;

implementation

constructor TTask<T>.Create(const ATaskType: TTaskType; const AName: string; const AProc: TProcArg1 < ITask < T >> );
begin
  inherited Create(ATaskType, AName);
  FProc := AProc;
end;

constructor TTask<T>.Create(const ATaskType: TTaskType; const AName: string; const AProc: TProcArg1<ITask<T>>; const AData: T);
begin
  inherited Create(ATaskType, AName);
  FData := AData;
  FProc := AProc;
end;

function TTask<T>.Data: T;
begin
  Result := FData;
end;

procedure TTask<T>.SetData(const AData: T);
begin
  FData := AData;
end;

procedure TTask<T>.Exec;
begin
  FProc(Self);
  inherited;
end;

end.
