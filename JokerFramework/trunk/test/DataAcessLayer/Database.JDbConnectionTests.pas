unit Database.JDbConnectionTests;

interface

uses
  TestFramework, Classes, DataBase.interfaces, SysUtils;

type

  TestCDbConnection = class(TTestCase)
  private
    FCDbConnection: IDBConnection;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure testActive;
    procedure testAutoConnect;
    procedure testInitialized;
  end;

implementation

uses DataBase.JDbConnection, DBXDynalink, DbxFirebird;

procedure TestCDbConnection.SetUp;
begin
  FCDbConnection := JDbConnection.Create;
  FCDbConnection.ConnectionString := 'FBCONNECTION';
end;

procedure TestCDbConnection.TearDown;
begin
  FCDbConnection.Active := False;
end;

procedure TestCDbConnection.testActive;
var
  AObj: TObject;
begin
  CheckFalse(FCDbConnection.Active);
  FCDbConnection.Active := True;
  CheckTrue(FCDbConnection.Active);
  AObj := FCDbConnection.Instance;
  CheckIs(AObj, TDBXDynalinkConnection);
  FCDbConnection.Active := True;
  CheckSame(AObj, FCDbConnection.Instance);
  FCDbConnection.Active := False;
  CheckFalse(FCDbConnection.Active);
  CheckNull(FCDbConnection.Instance);
end;

procedure TestCDbConnection.testAutoConnect;
var
  ADb, Adb2: IDbConnection;
begin
  ADb := JDbConnection.Create;
  ADb.ConnectionString := 'FBCONNECTION';
  CheckFalse(ADb.Active);
  CheckTrue(ADb.AutoConnect);
  ADb.Init;
  CheckTrue(ADb.Active);

  Adb2 := JDbConnection.Create;
  Adb2.ConnectionString := 'FBCONNECTION';
  Adb2.AutoConnect := False;
  CheckFalse(Adb2.AutoConnect);
  CheckFalse(Adb2.Active);
  Adb2.Init;
  CheckFalse(Adb2.Active);
end;

procedure TestCDbConnection.testInitialized;
var
  ADb: IDbConnection;
begin
  ADb := JDbConnection.Create;
  ADb.ConnectionString := 'FBCONNECTION';
  ADb.AutoConnect := False;
  CheckFalse(ADb.IsInitialized);
  ADb.Init;
  CheckTrue(ADb.IsInitialized);
end;

initialization

// Register any test cases with the test runner
RegisterTest(TestCDbConnection.Suite);

end.
