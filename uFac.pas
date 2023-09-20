// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uFac;

interface

uses
  uTypes,
  Classes;

type
  TFac = class(TInterfacedObject, IFac)
  private
    class var FFacMain: IFac;

  var
    FLog: ILog;

  public
    class procedure Init(const ALog: ILog); overload;
    class procedure Init(const ALogProc: TProcArg1<string>); overload;
    class function FacMain: IFac;

    class function Lock<T>(const AReaderCount: Integer): ILock<T>; static;
    class function LockWrap<T: constructor>(const AReaderCount: Integer): ILockWrap<T>; static;

    class function Wrap(const AObj: TObject): IWrap<TObject>; overload; static;
    class function Wrap<T: constructor>: IWrap<T>; overload; static;
    class function Wrap<T: constructor>(const AObj: T): IWrap<T>; overload; static;

    constructor Create(const ALog: ILog); overload;
    constructor Create(const ALogProc: TProcArg1<string>); overload;

    function Aes: IAes;
    function Argon: IArgon;
    function ArgonAes: IArgonAes;
    function ChaCha: IChaCha;
    function Clipboard: IClipboard;
    function Crit: ICrit;
    function Event: IEvent;
    function Log: ILog;
    function LogNew(const ALogProc: TProcArg1<string>): ILog;
    function Rnd: IRnd;
    function Rtti: IRtti;
  end;

implementation

uses
  uAes,
  uArgon2,
  uArgon2Aes,
  uChaCha,
  uClipboard,
  uCrit,
  uEventWrap,
  uLock,
  uLog,
  uRnd,
  uRttiWrap,
  uWrap,

  SysUtils;

class procedure TFac.Init(const ALog: ILog);
begin
  FFacMain := TFac.Create(ALog);
end;

class procedure TFac.Init(const ALogProc: TProcArg1<string>);
begin
  FFacMain := TFac.Create(ALogProc);
end;

class function TFac.FacMain: IFac;
begin
  Result := FFacMain;
end;

class function TFac.Lock<T>(const AReaderCount: Integer): ILock<T>;
begin
  Result := TLock<T>.Create(AReaderCount);
end;

class function TFac.LockWrap<T>(const AReaderCount: Integer): ILockWrap<T>;
begin
  Result := TLockWrap<T>.Create(AReaderCount);
end;

class function TFac.Wrap(const AObj: TObject): IWrap<TObject>;
begin
  Result := TWrap<TObject>.Create(AObj);
end;

class function TFac.Wrap<T>: IWrap<T>;
begin
  Result := TWrap<T>.Create;
end;

class function TFac.Wrap<T>(const AObj: T): IWrap<T>;
begin
  Result := TWrap<T>.Create(AObj);
end;

//

constructor TFac.Create(const ALog: ILog);
begin
  FLog := ALog;
end;

constructor TFac.Create(const ALogProc: TProcArg1<string>);
begin
  FLog := LogNew(ALogProc);
end;

function TFac.Aes: IAes;
begin
  Result := TAes.Create;
end;

function TFac.Argon: IArgon;
begin
  Result := TArgon.Create;
end;

function TFac.ArgonAes: IArgonAes;
begin
  Result := TArgonAes.Create(Self);
end;

function TFac.ChaCha: IChaCha;
begin
  Result := TChaCha.Create;
end;

function TFac.Clipboard: IClipboard;
begin
  Result := TClipboard.Create;
end;

function TFac.Crit: ICrit;
begin
  Result := TCrit.Create;
end;

function TFac.Event: IEvent;
begin
  Result := TEventWrap.Create;
end;

function TFac.Log: ILog;
begin
  Result := FLog;
end;

function TFac.LogNew(const ALogProc: TProcArg1<string>): ILog;
begin
  Result := TLog.Create(ALogProc);
end;

function TFac.Rnd: IRnd;
begin
  Result := TRnd.Create;
end;

function TFac.Rtti: IRtti;
begin
  Result := TRttiWrap.Create;
end;

end.
