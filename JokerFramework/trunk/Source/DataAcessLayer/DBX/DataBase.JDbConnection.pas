unit DataBase.JDbConnection;

interface

uses Classes, SysUtils, System.Base, DBXCommon, DataBase.interfaces;

type

  JDbConnection = class(TJApplicationComponent, IDbConnection)
  private
    FActive: Boolean;
    FAutoConnect: Boolean;
    FConnectionString: string;
    FPassword: String;
    FUserName: String;
    FConnection: TObject;
    FTransaction: IDbTransaction;
    function getActive: Boolean;
    function getAutoConnect: Boolean;
    function getConnectionString: string;
    function getInstance: TObject;
    function getPassword: String;
    function getTransaction: IDbTransaction;
    function getUserName: String;
    procedure setActive(AValue: Boolean);
    procedure setAutoConnect(const Value: Boolean);
    procedure setConnectionString(const Value: string);
    procedure setPassword(const Value: String);
    procedure setUserName(const Value: String);
  protected
    function createCommand(ASql: string): IDbCommand;
    procedure BeginTransaction;
    procedure Connect;
    procedure CreateInstance;
    procedure Disconnect;
    procedure Init; override;
    property Active: Boolean read getActive write setActive;
    property AutoConnect: Boolean read getAutoConnect write setAutoConnect;
    property ConnectionString: string read getConnectionString write setConnectionString;
    property Instance: TObject read getInstance;
    property Password: String read getPassword write setPassword;
    property Transaction: IDbTransaction read getTransaction;
    property UserName: String read getUserName write setUserName;
  public
    constructor create; reintroduce;
  end;

implementation

uses DBXDynalink, DbxFirebird, DataBase.Core, DataBase.Mensagens, DataBase.JDbCommand,
  DataBase.JDbTransaction, JBase;

{ CDbConnectionDBX }

procedure JDbConnection.BeginTransaction;
begin
  inherited;
  if Active then
  begin
    FTransaction := JDbTransaction.create(self);
  end
  else
  begin
    raise CDbException.create(TJBase.t(rErrorConnectionOpenDb, [self.classname]))
  end;
end;

function JDbConnection.createCommand(ASql: string): IDbCommand;
begin
  if Active then
    result := JDbCommand.create(self, ASql)
  else
    raise CDbException.create(TJBase.t(rErrorConnectionInactive, [self.classname]));
end;

procedure JDbConnection.CreateInstance;
var
  ConnectionFactory: TDBXConnectionFactory;
  //ConnectionProps: TDBXProperties;
begin
  if ConnectionString <> EmptyStr then
  begin
    ConnectionFactory := TDBXConnectionFactory.GetConnectionFactory;
    //ConnectionProps := ConnectionFactory.GetConnectionProperties(ConnectionString);
    // ConnectionProps.Add('username',UserName);
    // ConnectionProps.Add('passoword',Password);
    // ConnectionProps.Add('ConnectionName ',ConnectionString);
    FConnection := ConnectionFactory.GetConnection(ConnectionString, UserName, Password);
  end;
end;

procedure JDbConnection.Connect;
begin
  if not Assigned(FConnection) then
  begin
    if FConnectionString = EmptyStr then
      raise Exception.create(TJBase.t(rErrorConnectionStringCannotEmpty, [self.classname]));
    try
      TJBase.Trace('Opening DB connection', self.UnitName + '.' + self.classname);
      CreateInstance;
      FActive := True;
    except
      on E: CDbException do
        E.Message := TJBase.t(rErrorConnectionOpenDb, [E.Message]);
    end;
  end;

end;

constructor JDbConnection.create;
begin
  FAutoConnect := True;
end;

procedure JDbConnection.Disconnect;
begin
  TJBase.Trace('Closing DB connection', self.UnitName + '.' + self.classname);
  if Assigned(FConnection) then
  begin
    TJComponent(FConnection).Free;
    FConnection := nil;
  end;
  FActive := false;
end;

function JDbConnection.getActive: Boolean;
begin
  result := FActive;
end;

function JDbConnection.getAutoConnect: Boolean;
begin
  result := FAutoConnect
end;

function JDbConnection.getConnectionString: string;
begin
  result := FConnectionString
end;

function JDbConnection.getInstance: TObject;
begin
  result := FConnection;
end;

function JDbConnection.getPassword: String;
begin
  result := FPassword
end;

function JDbConnection.getTransaction: IDbTransaction;
begin
  result := FTransaction;
end;

function JDbConnection.getUserName: String;
begin
  result := FUserName
end;

procedure JDbConnection.Init;
begin
  inherited;
  if AutoConnect then
    setActive(True);
end;

procedure JDbConnection.setActive(AValue: Boolean);
begin
  if AValue <> FActive then
  begin
    if AValue then
      Connect
    else
      Disconnect
  end;
end;

procedure JDbConnection.setAutoConnect(const Value: Boolean);
begin
  FAutoConnect := Value;
end;

procedure JDbConnection.setConnectionString(const Value: string);
begin
  FConnectionString := Value;
end;

procedure JDbConnection.setPassword(const Value: String);
begin
  FPassword := Value;
end;

procedure JDbConnection.setUserName(const Value: String);
begin
  FUserName := Value
end;

end.
