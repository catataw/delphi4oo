program JokerFrameworkTests;

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  Database.JDbConnectionTests in 'DataAcessLayer\Database.JDbConnectionTests.pas',
  Database.JDbCommandTests in 'DataAcessLayer\Database.JDbCommandTests.pas',
  Database.JDbDataReaderTests in 'DataAcessLayer\Database.JDbDataReaderTests.pas',
  DataBase.AnnotationTests in 'DataAcessLayer\DataBase.AnnotationTests.pas',
  DataBase.Annotation in '..\Source\DataAcessLayer\DataBase.Annotation.pas',
  DataBase.Core in '..\Source\DataAcessLayer\DataBase.Core.pas',
  DataBase.JDbTransaction in '..\Source\DataAcessLayer\DBX\DataBase.JDbTransaction.pas',
  DataBase.JDbCommand in '..\Source\DataAcessLayer\DBX\DataBase.JDbCommand.pas',
  DataBase.JDbConnection in '..\Source\DataAcessLayer\DBX\DataBase.JDbConnection.pas',
  DataBase.JDbDataReader in '..\Source\DataAcessLayer\DBX\DataBase.JDbDataReader.pas';

{R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    with TextTestRunner.RunRegisteredTests do
      Free
  else
    GUITestRunner.RunRegisteredTests;
end.

