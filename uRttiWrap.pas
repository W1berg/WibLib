// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uRttiWrap;

interface

uses
  uTypes,
  Generics.Collections;

type
  TRttiWrap = class(TInterfacedObject, IRtti)
  private

    type // Workaround for E2506 Method of parameterized type declared in interface section must not use local symbol 'TRttiFieldWrap'
    TRttiFieldWrap = class(TInterfacedObject, IRttiField)
    private
      FName: string;
      FValue: string;
    public
      constructor Create(const AName, AValue: string);
      function Name: string;
      function Value: string;
    end;

  public
    procedure DeclaredMethodsGet(const AClass: TObject; const AList: TList<IRttiMethod>);
    class procedure FieldsDo<T>(const Arg: T; const AProc: TProcArg1<IRttiField>);
  end;

implementation

uses
  Rtti;

type
  TRttiMethodWrap = class(TInterfacedObject, IRttiMethod)
  private
    FClass: TObject;
    FContext: TRttiContext;
    FMethod: TRttiMethod;
  public
    constructor Create(const AClass: TObject; const AI: Integer);
    function ClassName: string;
    function Name: string;
    procedure Invoke;
  end;

constructor TRttiMethodWrap.Create(const AClass: TObject; const AI: Integer);
begin
  FClass := AClass;
  FMethod := FContext.GetType(FClass.ClassInfo).GetDeclaredMethods[AI];
end;

function TRttiMethodWrap.ClassName: string;
begin
  Result := FClass.ClassName;
end;

function TRttiMethodWrap.Name: string;
begin
  Result := FMethod.Name;
end;

procedure TRttiMethodWrap.Invoke;
begin
  FMethod.Invoke(FClass, []);
end;

//

procedure TRttiWrap.DeclaredMethodsGet(const AClass: TObject; const AList: TList<IRttiMethod>);
var
  LContext: TRttiContext;
  LMethodWrap: IRttiMethod;
  I: Integer;
begin
  for I := 0 to high(LContext.GetType(AClass.ClassInfo).GetDeclaredMethods) do
  begin
    LMethodWrap := TRttiMethodWrap.Create(AClass, I);
    AList.Add(LMethodWrap);
  end;
end;

constructor TRttiWrap.TRttiFieldWrap.Create(const AName, AValue: string);
begin
  FName := AName;
  FValue := AValue;
end;

function TRttiWrap.TRttiFieldWrap.Name: string;
begin
  Result := FName;
end;

function TRttiWrap.TRttiFieldWrap.Value: string;
begin
  Result := FValue;
end;

class procedure TRttiWrap.FieldsDo<T>(const Arg: T; const AProc: TProcArg1<IRttiField>);
var
  LContext: TRttiContext;
  LValue: TValue;
  LFieldWrap: IRttiField;
begin
  for var LField in LContext.GetType(TypeInfo(T)).GetFields do
  begin
    LValue := LField.GetValue(@Arg);
    LFieldWrap := TRttiFieldWrap.Create(LField.Name, LValue.ToString);
    AProc(LFieldWrap);
  end;
end;

end.
