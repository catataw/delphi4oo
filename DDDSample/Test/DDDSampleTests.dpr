program DDDSampleTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  TestDomain.Model.Cargo in 'TestDomain.Model.Cargo.pas',
  TestDomain.Shared in 'TestDomain.Shared.pas',
  Domain.Shared in '..\Domain.Shared.pas',
  Domain.Model.Cargo in '..\Domain.Model.Cargo.pas',
  Domain.Model.Location in '..\Domain.Model.Location.pas',
  Domain.Model.Voyage in '..\Domain.Model.Voyage.pas',
  Domain.Service in '..\Domain.Service.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    with TextTestRunner.RunRegisteredTests do
      Free
  else
    GUITestRunner.RunRegisteredTests;
end.

