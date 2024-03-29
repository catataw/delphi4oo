program app_7_InitTest;

uses
  FastMM4,
  Forms,
  test_7_InitTest in 'test_7_InitTest.pas' {frmTestInit},
  OtlCommon in '..\..\OtlCommon.pas',
  OtlTask in '..\..\OtlTask.pas',
  OtlThreadPool in '..\..\OtlThreadPool.pas',
  OtlComm in '..\..\OtlComm.pas',
  OtlContainers in '..\..\OtlContainers.pas',
  OtlTaskControl in '..\..\OtlTaskControl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTestInit, frmTestInit);
  Application.Run;
end.
