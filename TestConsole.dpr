program TestConsole;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  uAes in 'uAes.pas',
  uArgon2 in 'uArgon2.pas',
  uArgon2Aes in 'uArgon2Aes.pas',
  uBase32 in 'uBase32.pas',
  uChaCha in 'uChaCha.pas',
  uClipboard in 'uClipboard.pas',
  uCrit in 'uCrit.pas',
  uData in 'uData.pas',
  uEventWrap in 'uEventWrap.pas',
  uFac in 'uFac.pas',
  uLock in 'uLock.pas',
  uLog in 'uLog.pas',
  uRnd in 'uRnd.pas',
  uRttiWrap in 'uRttiWrap.pas',
  uTest in 'uTest.pas',
  uTypes in 'uTypes.pas',
  uWrap in 'uWrap.pas',
  uTestAes in 'Test\uTestAes.pas',
  uTestArgon2 in 'Test\uTestArgon2.pas',
  uTestArgon2Aes in 'Test\uTestArgon2Aes.pas',
  uTestChaCha in 'Test\uTestChaCha.pas',
  uTestChaChaEngine in 'Test\uTestChaChaEngine.pas',
  uTestData in 'Test\uTestData.pas';

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    // TObject.Create;

    FGet.Init(
      procedure(const AStr: string)
      begin
        write(AStr + SLineBreak);
      end);

    TTest.RunTests(FGet.Fac);

  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;

  WriteLn('Exit');
  ReadLn;

end.
