// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uTest;

interface

uses
  uTypes,
  // TestFramework,

  Classes,
  Generics.Collections;

type
  TTestCaseMock = class
  public
    constructor Create(const AStr: string = '');
  end;

  // TTest = class(TTestCase)
  TTest = class(TTestCaseMock)
  private
  class var
    FLog: ILog;
    FTests: TObjectList<TTest>;

    FFailCount, FSkips: Integer;
    FFailLogs, FLogsAtEnd: TStringList;
    FTicks: TDictionary<string, Int64>;

  var
    FClassName: string;
    FMethodName: string;

    // const
    // cAllowedExpectedTestTimeMs = 400;
    // cAllowedExpectedTestTimeMs = 10000;

  protected
  class var
    FFac: IFac;
    FRnd: IRnd;

  const
    cRuns = 100;
    cStrLen = 64;
    cStrLenRuns = cStrLen * cRuns div 10;

  public
    class constructor Create;
    class destructor Destroy;

    class procedure Add(const ATest: TTest);
    class function RunTests(const AFac: IFac): Integer;

    constructor Create;

    procedure Check(const ABool: Boolean; AStr: string = ''); reintroduce;
    procedure CheckEquals(const A, B: Variant; const AStr: string = '');
    procedure CheckTrue(const ABool: Boolean; AStr: string = ''); reintroduce;

    function Equ(const A, B: array of Byte): Boolean; overload;
    function Equ(const A, B: TBytes): Boolean; overload;
    function Equ(const A: TBytes; const AHexStr: string): Boolean; overload;

    function Equ(const A, B: Variant): Boolean; overload;
    function Equ(const A, B: string): Boolean; overload;

    procedure Fail(const AStr: string = '');

    procedure Log(const AStr: string; const ALogLevel: TLogLevel = llTest); overload;
    procedure Log(const AList: TStringList; const ALogLevel: TLogLevel = llTest); overload;

    function Run: Integer;

    function StartsWith(const A, B: TBytes): Boolean; overload;
    function StartsWith(const A, B: Variant): Boolean; overload;
    function StartsWith(const A, B: string): Boolean; overload;
    procedure Status(const AStr: string);

    procedure TimeStart(const AKey: string);
    procedure TimeStop(const AKey: string);
  end;

implementation

uses
  Math,
  SysUtils,
  Variants;

class constructor TTest.Create;
begin
  FTests := TObjectList<TTest>.Create;

  FFailLogs := TStringList.Create;
  FLogsAtEnd := TStringList.Create;
  FTicks := TDictionary<string, Int64>.Create;
end;

class destructor TTest.Destroy;
begin
  FTests.Free;

  FFailLogs.Free;
  FLogsAtEnd.Free;
  FTicks.Free;
end;

class procedure TTest.Add(const ATest: TTest);
begin
  FTests.Add(ATest)
end;

class function TTest.RunTests(const AFac: IFac): Integer;

  procedure Log(const AStr: string = ''); overload;
  begin
    FLog.Log(AStr, 'RunTests', 'TTest', llInfo);
  end;

  procedure Log(const AList: TStringList); overload;
  begin
    FLog.Log(AList, 'RunTests', 'TTest', llInfo);
  end;

var
  LMethodsInClass: Integer;
  LTicks, LTicksTotal: Int64;
begin
  Result := 0;
  FFailCount := 0;
  FSkips := 0;
  LTicksTotal := 0;

  FFac := FGet.Fac;
  FLog := FFac.Log;
  FRnd := FFac.Rnd;

  FFailLogs.Clear;
  FLogsAtEnd.Clear;
  FTicks.Clear;

  for var LTest in FTests do
  begin
    Log(LTest.ClassName);

    LTicks := FGet.Ticks64;

    LMethodsInClass := LTest.Run;
    Result := Result + LMethodsInClass;

    LTicks := FGet.Ticks64 - LTicks;
    LTicksTotal := LTicksTotal + LTicks;

    FLogsAtEnd.Add(LTicks.ToString + 'ms ' + LTest.FClassName + ': ' + LMethodsInClass.ToString);
    FLog.Log;
  end;

  Result := Result - FSkips;

  Log('cRuns: ' + TTest.cRuns.ToString);
  Log('cStrLen: ' + TTest.cStrLen.ToString);
  Log('cStrLenRuns: ' + TTest.cStrLenRuns.ToString);
  Log(FLogsAtEnd);
  Log(FFailLogs);
  Log('Fail count: ' + FFailCount.ToString);
  Log('Methods tested: ' + Result.ToString);
  Log('Methods skipped: ' + FSkips.ToString);
  Log('Ticks total: ' + LTicksTotal.ToString);
end;

constructor TTestCaseMock.Create(const AStr: string);
begin
end;

constructor TTest.Create;
begin
  inherited Create('');
end;

procedure TTest.Check(const ABool: Boolean; AStr: string);
begin
  CheckTrue(ABool, AStr);
end;

procedure TTest.CheckEquals(const A, B: Variant; const AStr: string);
begin
  if not Equ(A, B) then
    Log(AStr);
end;

procedure TTest.CheckTrue(const ABool: Boolean; AStr: string);
begin
  if not ABool then
    Fail(AStr);
end;

function TTest.Equ(const A, B: array of Byte): Boolean;
var
  LData1, LData2: TBytes;
begin
  LData1.SetArr(A);
  LData2.SetArr(B);

  Result := Equ(LData1, LData2);
end;

function TTest.Equ(const A, B: TBytes): Boolean;
begin
  Result := Equ(A.Hex, B.Hex);
end;

function TTest.Equ(const A: TBytes; const AHexStr: string): Boolean;
begin
  Result := Equ(A.Hex, AHexStr.ToUpper);
end;

function TTest.Equ(const A, B: Variant): Boolean;
begin
  Result := VarSameValue(A, B);
  if Result <> Equ(VarToStr(A), VarToStr(B)) then
    raise Exception.Create('VarSameValue <> Equ');
end;

function TTest.Equ(const A, B: string): Boolean;
var
  LStr: string;
  // LData1, LData2: TBytes;
const
  cDelim = ' equ ';
begin
  LStr := sLineBreak + A + cDelim + sLineBreak + B;
  Result := A = B;

  if Result then
  begin
    Log('Pass ' + LStr, llTestPass);
    Exit;
  end;

  Fail(LStr);

  // LData1.Utf8 := VarToStr(A);
  // LData2.Utf8 := VarToStr(B);
  //
  // FFailLogs.Add(LData1.Hex + cDelim + LData2.Hex);
  //
  // for var I := low(string) to Min(high(A), high(B)) do
  // if A[I] <> B[I] then
  // FFailLogs.Add(Ord(A[I]).ToString + ' <> ' + Ord(B[I]).ToString);
end;

procedure TTest.Fail(const AStr: string);
begin
  Log(AStr, llTestFail);
end;

procedure TTest.Log(const AList: TStringList; const ALogLevel: TLogLevel);
begin
  if ALogLevel <> llTest then
    FLog.Log(AList, FMethodName, FClassName, ALogLevel);
end;

procedure TTest.Log(const AStr: string; const ALogLevel: TLogLevel);
begin
  case ALogLevel of
    llTest:
      begin
        // FLog.Log(AStr, FMethodName, FClassName, ALogLevel);
      end;

    llTestPass:
      begin
        // FLog.Log(AStr, FMethodName, FClassName, ALogLevel);
      end;
    llTestFail:
      begin
        Inc(FFailCount);
        FFailLogs.Add(FClassName + '.' + FMethodName + ': ' + AStr);
        try
          if FFailCount = 1 then
            raise Exception.Create(AStr + ': Failed test, check callstack');
        except
          on E: Exception do
            // Nothing
        end;
      end;
  else
    FLog.Log(AStr, FMethodName, FClassName, ALogLevel);
  end;
end;

function TTest.Run: Integer;
var
  LMethods: TList<IRttiMethod>;
  LStr: string;
begin
  FTicks.Clear;

  LMethods := TList<IRttiMethod>.Create;
  FGet.Wrap(LMethods);

  FFac.Rtti.DeclaredMethodsGet(Self, LMethods);
  Result := LMethods.Count;

  for var AMethod in LMethods do
  begin
    FClassName := AMethod.ClassName;
    FMethodName := AMethod.Name;
    LStr := FClassName + ' ' + FMethodName;

    TimeStart(LStr);
    AMethod.Invoke;
    TimeStop(LStr);
  end;
end;

function TTest.StartsWith(const A, B: TBytes): Boolean;
begin
  Result := StartsWith(A.Hex, B.Hex);
end;

function TTest.StartsWith(const A, B: Variant): Boolean;
begin
  Result := StartsWith(VarToStr(A), VarToStr(B));
end;

function TTest.StartsWith(const A, B: string): Boolean;
var
  L1, L2, LStr: string;
const
  cDelim = ' StartsWith ';
begin
  Result := L1.StartsWith(L2);
  LStr := L1 + cDelim + L2;

  if Result then
    Log('Pass: ' + LStr, llTestPass)
  else
    Log('Fail: ' + LStr, llTestFail);
end;

procedure TTest.Status(const AStr: string);
begin
  Log(AStr, llTest);
end;

procedure TTest.TimeStart(const AKey: string);
begin
  FTicks.Add(AKey, FGet.Ticks64);
end;

procedure TTest.TimeStop(const AKey: string);
var
  I: Int64;
begin
  I := FGet.Ticks64 - FTicks[AKey];
  Log(I.ToString + 'ms', llInfo);
end;

end.
