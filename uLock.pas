// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uLock;

interface

uses
  uTypes,

  Classes,
  Generics.Collections;

type
  TLock = class(TInterfacedObject, ILock)
  private
    FEvent: IEvent;
    FReaders: TList<ICrit>;
    FWriter: ICrit;

  public
    constructor Create(const AReaderCount: Integer);
    destructor Destroy; override;

    function ReaderGet: Integer;
    procedure ReaderRel(const AI: Integer);
    function WriterGet: Boolean;
    procedure WriterRel;
  end;

  TLock<T> = class(TLock, ILock<T>)
  protected
    FData: T;

  public
    function Data: T;
    procedure SetData(const AData: T); overload;
  end;

  TLockWrap<T: constructor> = class(TLock<IWrap<T>>, ILockWrap<T>)
  public
    procedure SetData; overload;
    procedure SetData(const AData: T); overload;
    function Ref: T;
  end;

implementation

constructor TLock.Create(const AReaderCount: Integer);
begin
  FEvent := FGet.Fac.Event;
  FEvent.Activate;

  FReaders := TList<ICrit>.Create;
  FReaders.Add(FGet.Fac.Crit);

  for var I := 2 to AReaderCount do
    FReaders.Add(FGet.Fac.Crit);

  FWriter := FGet.Fac.Crit;
end;

destructor TLock.Destroy;
begin
  FReaders.Free;
  inherited;
end;

function TLock.ReaderGet: Integer;
begin
  FEvent.WaitFor(100);
  for var I := 0 to FReaders.Count - 1 do
    if FReaders[I].EnterTry then
      Exit(I);

  Result := -1;
end;

procedure TLock.ReaderRel(const AI: Integer);
begin
  if AI <> -1 then
    FReaders[AI].Leave;
end;

function TLock.WriterGet: Boolean;
begin
  FEvent.WaitFor(100);
  if not FWriter.EnterTry then
    Exit(False);

  FEvent.Reset;
  Result := True;

  for var LReader in FReaders do
    LReader.Enter;
end;

procedure TLock.WriterRel;
begin
  FWriter.Leave;
  for var LReader in FReaders do
    LReader.Leave;

  FEvent.Activate;
end;

//

function TLock<T>.Data: T;
begin
  Result := FData;
end;

procedure TLock<T>.SetData(const AData: T);
begin
  FData := AData;
end;

//

function TLockWrap<T>.Ref: T;
begin
  Result := Data.Ref;
end;

procedure TLockWrap<T>.SetData;
begin
  FData := FGet.Wrap<T>;
end;

procedure TLockWrap<T>.SetData(const AData: T);
begin
  FData := FGet.Wrap<T>(AData);
end;

end.
