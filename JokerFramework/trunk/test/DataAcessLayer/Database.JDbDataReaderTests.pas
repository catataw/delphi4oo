unit Database.JDbDataReaderTests;

interface

uses
  TestFramework,Classes, DataBase.Interfaces, SysUtils,
  System.Interfaces, System.Base;

type
  // Test methods for class JDbDataReader

  TestJDbDataReader = class(TTestCase)
  strict private
    FCDbConnection: IDbConnection;
    FSql: string;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestColumnCoutn;
    procedure testReadColumn;
  end;

implementation

uses DataBase.JDbConnection, DBXDynalink, DbxFirebird, DBXCommon;

procedure TestJDbDataReader.SetUp;
begin
  FCDbConnection := JDbConnection.Create;
  FCDbConnection.ConnectionString := 'TESTE';
  FCDbConnection.Active := true;
  FSql := 'Select * from TESTE';
end;

procedure TestJDbDataReader.TearDown;
begin

end;

procedure TestJDbDataReader.TestColumnCoutn;
var
  AReader: IDbDataReader;
  ACommand: IDbCommand;
begin
  AReader := FCDbConnection.createCommand(FSql).Query([]);
  CheckNotNull(AReader);
  CheckEquals(2,AReader.ColumnCount)
end;

procedure TestJDbDataReader.testReadColumn;
var
  AReader: IDbDataReader;
  ACommand: IDbCommand;
begin
  AReader := FCDbConnection.createCommand(FSql).Query([]);
  CheckNotNull(AReader);
  (AReader as Iterator).Next;
  CheckEquals('',AReader.readColumn[0].AsString);

end;

initialization

// Register any test cases with the test runner
RegisterTest(TestJDbDataReader.Suite);

end.
