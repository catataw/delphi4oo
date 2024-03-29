program app_1_HelloWorld;

uses
  FastMM4,
  Forms,
  test_1_HelloWorld in 'test_1_HelloWorld.pas' {frmTestHelloWorld},
  OtlCommon in '..\..\OtlCommon.pas',
  OtlTask in '..\..\OtlTask.pas',
  OtlThreadPool in '..\..\OtlThreadPool.pas',
  OtlComm in '..\..\OtlComm.pas',
  DSiWin32 in '..\..\src\DSiWin32.pas',
  GpLists in '..\..\src\GpLists.pas',
  GpStuff in '..\..\src\GpStuff.pas',
  HVStringBuilder in '..\..\src\HVStringBuilder.pas',
  HVStringData in '..\..\src\HVStringData.pas',
  SpinLock in '..\..\src\SpinLock.pas',
  OtlContainers in '..\..\OtlContainers.pas',
  OtlCommBufferTest in '..\..\OtlCommBufferTest.pas',
  OtlEventMonitor in '..\..\OtlEventMonitor.pas',
  OtlTaskControl in '..\..\OtlTaskControl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmTestHelloWorld, frmTestHelloWorld);
  Application.Run;
end.
