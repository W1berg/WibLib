// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uLog;

interface

uses
  uTypes,
  Classes,
  Generics.Collections;

type
  TLog = class(TInterfacedObject, ILog)

  private
  var
    FDic: TDictionary<TLogLevel, TProcArg1<string>>;
    FLogProc: TProcArg1<string>;

  public
    constructor Create(const ALogProc: TProcArg1<string>);
    destructor Destroy; override;

    procedure Log(const AList: TStrings); overload;
    procedure Log(const AList: TStrings; const AFunc: string; const AClassName: string; const ALogLevel: TLogLevel; const ADate: TDateTime); overload;
    procedure Log(const AStr: string; const AFunc: string; const AClassName: string; const ALogLevel: TLogLevel; const ADate: TDateTime); overload;

    procedure SetLogForLevel(const ALogLevel: TLogLevel; const ALogProc: TProcArg1<string>);
  end;

implementation

uses
{$IF Defined(DEBUG)}
  SysUtils,
{$ENDIF}
  DateUtils;

constructor TLog.Create(const ALogProc: TProcArg1<string>);
begin
  FDic := TDictionary < TLogLevel, TProcArg1 < string >>.Create;
  FLogProc := ALogProc;

{$IF Defined(DEBUG)}
  SetLogForLevel(llDebugRaise,
    procedure(const AStr: string)
    begin
      try
        raise Exception.Create(AStr);
      except
      end;
    end);
{$ENDIF}
end;

destructor TLog.Destroy;
begin
  FDic.Free;
  inherited;
end;

procedure TLog.Log(const AList: TStrings);
begin
  for var LStr in AList do
    FLogProc(LStr);
end;

procedure TLog.Log(const AList: TStrings; const AFunc, AClassName: string; const ALogLevel: TLogLevel; const ADate: TDateTime);
begin
  for var LStr in AList do
    FLogProc(AClassName + ' ' + AFunc + ' ' + LStr);
end;

procedure TLog.Log(const AStr: string; const AFunc: string; const AClassName: string; const ALogLevel: TLogLevel; const ADate: TDateTime);
var
  LLogProc: TProcArg1<string>;
begin
  if not FDic.TryGetValue(ALogLevel, LLogProc) then
    LLogProc := FLogProc;

  // LLog(DateTimeToStr(ADate) + ' ' + Integer(ALogLevel).ToString + ' ' + AClass + ' ' + AFunc + ' ' + AStr);
  // LLog(Integer(ALogLevel).ToString + ' ' + AClass + ' ' + AFunc + ' ' + AStr);
  LLogProc(AClassName + ' ' + AFunc + ' ' + AStr);
end;

procedure TLog.SetLogForLevel(const ALogLevel: TLogLevel; const ALogProc: TProcArg1<string>);
begin
  FDic.AddOrSetValue(ALogLevel, ALogProc);
end;

end.
