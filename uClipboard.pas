// Copyright (C) 2023 Pontus Wiberg <wiberg.public@outlook.com>
// Licensed under GPLv2 or later version. Contact for any licensing concerns

unit uClipboard;

interface

uses
  uTypes;

type
  TClipboard = class(TInterfacedObject, IClipboard)
  private
    // {$IFDEF FMX}
    // var
    // FClip: IFMXClipboardService;
    // {$ELSE}
    // {$ENDIF}
  public
    constructor Create;

    function GetStr: string;
    procedure SetStr(const AStr: string);
  end;

implementation

uses
  // {$IFDEF FMX}
  // FMX.Platform,
  // {$ELSE}
  // {$ENDIF}
  SysUtils;

constructor TClipboard.Create;
begin
  // {$IFDEF FMX}
  // if not TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, FClip) then
  // raise Exception.Create('not TPlatformServices.Current.SupportsPlatformService');
  // {$ELSE}
  raise Exception.Create('No def');
  // {$ENDIF}
end;

function TClipboard.GetStr: string;
begin
  // {$IFDEF FMX}
  // if FClip.Clipboard.IsType<string>(False) then
  // Result := FClip.Clipboard.ToString;
  // {$ELSE}
  // {$ENDIF}
end;

procedure TClipboard.SetStr(const AStr: string);
begin
  // {$IFDEF FMX}
  // FClip.SetClipboard(AStr);
  // {$ELSE}
  // {$ENDIF}
end;

end.
