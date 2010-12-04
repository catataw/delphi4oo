unit DataBase.JDbTransaction;

interface

uses System.Base, DataBase.Interfaces;

type
  JDbTransaction = class(TJComponent, IDbTransaction)
  private
    FConnection: IDbConnection;
    FActive: Boolean;
    FTransaction: TObject;
  protected
    procedure Commit;
    procedure Rollback;
    procedure CreateInstance;
    function getActive: Boolean;
    function getConnection: IDbConnection;
    property Active: Boolean read getActive;
    property Connection: IDbConnection read getConnection;
  public
    constructor Create(AConnection: IDbConnection);
  end;

implementation

uses DataBase.Core, DataBase.Mensagens, DBXDynalink, DBXCommon, JBase;

{ CDbTransactionDBX }

procedure JDbTransaction.Commit;
begin
  if Active and Connection.Active then
  begin
    TDBXDynalinkConnection(Connection.Instance).CommitFreeAndNil(TDBXTransaction(FTransaction));
    FActive := false
  end;
  raise CDbException.Create(TJBase.t(rErrorTransactionInactive, [self.classname]))

end;

procedure JDbTransaction.CreateInstance;
begin
  FTransaction := TDBXDynalinkConnection(Connection.Instance).BeginTransaction(0)
end;

procedure JDbTransaction.Rollback;
begin
  if Active and Connection.Active then
  begin
    TDBXDynalinkConnection(Connection.Instance).RollbackFreeAndNil(TDBXTransaction(FTransaction));
    FActive := false
  end;
  raise CDbException.Create(TJBase.t(rErrorTransactionInactive, [self.classname]))
end;

constructor JDbTransaction.Create(AConnection: IDbConnection);
begin
  FConnection := AConnection;
  CreateInstance;
  FActive := True;
end;

function JDbTransaction.getActive: Boolean;
begin
  Result := FActive;
end;

function JDbTransaction.getConnection: IDbConnection;
begin
  Result := FConnection;
end;

end.
