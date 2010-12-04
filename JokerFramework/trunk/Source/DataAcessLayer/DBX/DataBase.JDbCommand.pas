unit DataBase.JDbCommand;

interface

uses Classes, System.Base, DataBase.Interfaces;

type

  JDbCommand = class(TJComponent, IDbCommand)
  private
    FConnection: IDbConnection;
    FStatement: TObject;
    FSql: TStringList;
    function queryInternal(const AParams: array of const ): IDbDataReader;
    function getStatement: TObject;
    function getConnection: IDbConnection;
    function getSql: TStringList;
  protected
    function bindParam(AName: string; AValue: Variant): IDbCommand;
    function bindValue(AName: string; AValue: Variant): IDbCommand;
    function Execute(const AParams: array of const ): Integer;
    function Query(const AParams: array of const ): IDbDataReader;
    procedure Cancel;
    procedure CreateStatement;
    procedure prepare;
    property Connection: IDbConnection read getConnection;
    property Sql: TStringList read getSql;
    property Statement: TObject read getStatement;
  public
    constructor Create(AConnection: IDbConnection; ASql: string);
  end;

implementation

uses SysUtils, DBXCommon, DataBase.Core, DataBase.Mensagens, DataBase.JDbTransaction, DataBase.JDbDataReader,
  JBase;

{ CDbCommandDBX }

function JDbCommand.bindParam(AName: string; AValue: Variant): IDbCommand;
begin
  if TDBXCommand(FStatement).IsPrepared then
    prepare;
  Result := Self;
end;

function JDbCommand.bindValue(AName: string; AValue: Variant): IDbCommand;
begin
  if TDBXCommand(FStatement).IsPrepared then
    prepare;
  Result := Self;
end;

procedure JDbCommand.Cancel;
begin
  TDBXCommand(FStatement).Close;
  FStatement.Free;
  FStatement := nil;
end;

procedure JDbCommand.CreateStatement;
begin
  FStatement := (Connection.getInstance as TDBXConnection).CreateCommand;
end;

function JDbCommand.Execute(const AParams: array of const ): Integer;
begin
  try
    prepare;
    TDBXCommand(FStatement).ExecuteUpdate;
    Result := TDBXCommand(FStatement).RowsAffected;
  except
    on E: Exception do
      raise CDbException.Create(TJBase.t(rErrorCommandExecute, [E.Message]));
  end;
end;

procedure JDbCommand.prepare;
begin
  inherited;
  if Assigned(FStatement) then
  begin
    try
      TDBXCommand(FStatement).Text := Sql.Text;
      TDBXCommand(FStatement).prepare;
    except
      on E: Exception do
        raise CDbException.Create(TJBase.t(rErrorCommandPrepare, [E.Message]));
    end;
  end;

end;

function JDbCommand.queryInternal(const AParams: array of const ): IDbDataReader;
begin
  try
    prepare;
    Result := JDbDataReader.Create(TDBXCommand(FStatement).ExecuteQuery);
  except
    on E: Exception do
      raise CDbException.Create(TJBase.t(rErrorCommandExecute, [E.Message]));
  end;
end;

constructor JDbCommand.Create(AConnection: IDbConnection; ASql: string);
begin
  FConnection := AConnection;
  FSql := TStringList.Create;
  FSql.Text := ASql;
  CreateStatement;
end;

function JDbCommand.getConnection: IDbConnection;
begin
  Result := FConnection;
end;

function JDbCommand.getSql: TStringList;
begin
  Result := FSql;
end;

function JDbCommand.getStatement: TObject;
begin
  Result := FStatement;
end;

function JDbCommand.Query(const AParams: array of const ): IDbDataReader;
begin
  Result := Self.queryInternal(AParams);
end;

end.
