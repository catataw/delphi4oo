program app_0_Beep;

uses
  FastMM4,
  Forms,
  test_0_Beep in 'test_0_Beep.pas' {frmTestSimple},
  OtlCommon in '..\..\OtlCommon.pas',
  OtlTask in '..\..\OtlTask.pas',
  OtlThreadPool in '..\..\OtlThreadPool.pas',
  OtlComm in '..\..\OtlComm.pas',
  DSiWin32 in '..\..\src\DSiWin32.pas',
  GpLists in '..\..\src\GpLists.pas',
  GpStuff in '..\..\src\GpStuff.pas',
  HVStringBuilder in '..\..\src\HVStringBuilder.pas',
  HVStringData in '..\..\src\HVStringData.pas',
  SpinLock in '..\..\src\SpinLock.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTestSimple, frmTestSimple);
  Application.Run;
end.
