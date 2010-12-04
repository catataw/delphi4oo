unit Database.JDbCommandTests;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework, SysUtils, Classes, System.Base, DataBase.Interfaces;

type
  // Test methods for class CDbCommand

  TestJDbCommand = class(TTestCase)
  private
    FCDbConnection: IDbConnection;
    FSql: string;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure testGetText;
    procedure testConnection;
    procedure testPrepare;
    procedure testCancel;
    procedure testExecute;
    procedure testQuery;
  end;

implementation

uses DataBase.JDbConnection, DataBase.JDbDataReader, DBXDynalink, DbxFirebird, DBXCommon;

procedure TestJDbCommand.SetUp;
begin
  FCDbConnection := JDbConnection.Create;
  FCDbConnection.ConnectionString := 'TESTE';
  FCDbConnection.Active := true;
  FSql := 'Select * from TESTE';
end;

procedure TestJDbCommand.TearDown;
begin
  FCDbConnection.Active := False;
end;

procedure TestJDbCommand.testCancel;
var
  ACommand: IDbCommand;
begin
  ACommand := FCDbConnection.createCommand(FSql);
  ACommand.Prepare;
  CheckIs(ACommand.Statement, TDBXCommand);
  ACommand.Cancel;
  CheckNull(ACommand.Statement);
end;

procedure TestJDbCommand.testConnection;
var
  ACommand: IDbCommand;
begin
  ACommand := FCDbConnection.createCommand(FSql);
  CheckSame(FCDbConnection, ACommand.getConnection);
end;

procedure TestJDbCommand.testExecute;
var
  ACommand: IDbCommand;
  ASql: string;
begin
  ASql := 'insert into teste(id,nome) values(1,' + QuotedStr('a') + ')';
  ACommand := FCDbConnection.createCommand(ASql);
  CheckEquals(1, ACommand.Execute([]));
  CheckEquals(1, ACommand.Execute([]));
  ASql := 'Select * from teste';
  ACommand := FCDbConnection.createCommand(ASql);
  CheckEquals(0, ACommand.Execute([]));
end;

procedure TestJDbCommand.testGetText;
var
  ACommand: IDbCommand;
begin
  ACommand := FCDbConnection.createCommand(FSql);
  CheckEquals(FSql+#13#10, ACommand.Sql.Text);
end;

procedure TestJDbCommand.testPrepare;
var
  ACommand: IDbCommand;
begin
  ACommand := FCDbConnection.createCommand(FSql);
  CheckNotNull(ACommand.Statement);
  ACommand.Prepare;
  CheckIs(ACommand.Statement, TDBXCommand);
end;

procedure TestJDbCommand.testQuery;
var
  AReader: IDbDataReader;
  ACommand: IDbCommand;
  ASql: string;
begin
  ASql := 'Select * from teste';
  AReader := FCDbConnection.createCommand(ASql).Query([]);
  CheckNotNull(AReader);

  ASql := 'Select * from teste';
  ACommand := FCDbConnection.createCommand(ASql);
  ACommand.Prepare;
  AReader := ACommand.Query([]);
  CheckNotNull(AReader);

end;

initialization

// Register any test cases with the test runner
RegisterTest(TestJDbCommand.Suite);

end.