unit DataBase.Core;

interface

uses Classes, Db, SysUtils, System.Interfaces, System.Base, DataBase.Interfaces, System.Common,
  DataBase.Annotation;

type

  TJEntityClass = class of TJEntity;

  TJDBCommandBuilder = class(TJComponent, IDbCommandBuilder)
  private
    FSchema: IDbSchema;
    FConnection: IDbConnection;
    function applyJoin(ASQL: string; AJoin: string): string;
    function applyCondition(ASQL: string; ACondition: string): string;
    function applyOrder(ASQL: string; AOrderBy: string): string;
    function applyLimit(ASQL: string; Alimit: Integer; AOffset: Integer): string;
    function applyGroup(ASQL: string; AGroup: string): string;
    function applyHaving(ASQL: string; AHaving: string): string;
  protected
    function getConnection: IDbConnection;
    function getSchema: IDbSchema;
    function createFindCommand(ATable: string; ACriteria: ICriteria; AAlias: string = 't'): IDbCommand;
    function createCountCommand(ATable: string; ACriteria: ICriteria; AAlias: string = 't'): IDbCommand;
    function createDeleteCommand(ATable: string; ACriteria: ICriteria): IDbCommand;
    function createInsertCommand(ATable: string; Adata: IEntity): IDbCommand;
    function createUpdateCommand(ATable: string; Adata: IEntity; ACriteria: ICriteria): IDbCommand;
    property Connection: IDbConnection read getConnection;
    property Schema: IDbSchema read getSchema;
  public
    constructor Create(ASchema: IDbSchema);
  end;

  TJCriteria = class(TJComponent, ICriteria)
  private
  protected
    function getcondition: String;
    function getdistinct: Boolean;
    function getgroup: String;
    function gethaving: String;
    function getjoin: String;
    function getlimit: Integer;
    function getoffset: Integer;
    function getorder: string;
    function getselect: String;
    procedure setcondition(Value: String);
    procedure setdistinct(Value: Boolean);
    procedure setgroup(Value: String);
    procedure sethaving(Value: String);
    procedure setjoin(Value: String);
    procedure setlimit(Value: Integer);
    procedure setoffset(Value: Integer);
    procedure setorder(Value: string);
    procedure setselect(Value: String);
    property condition: String read getcondition write setcondition;
    property distinct: Boolean read getdistinct write setdistinct;
    property group: String read getgroup write setgroup;
    property having: String read gethaving write sethaving;
    property join: String read getjoin write setjoin;
    property limit: Integer read getlimit write setlimit;
    property offset: Integer read getoffset write setoffset;
    property order: string read getorder write setorder;
    property select: String read getselect write setselect;
  end;

  TJEntityMetaData = class
  private
    FTableSchema: JDbTableSchema;
  public
    property TableSchema: JDbTableSchema read FTableSchema write FTableSchema;

  end;

  TJReposity<T> = class(TJComponent, IComponent)
  private
    FConnection: IDbConnection;
    FCriteria: ICriteria;
    FEntityMetaData: TJEntityMetaData;
    function getCriteria: ICriteria;
    function getDbConnection: IDbConnection;
  protected
    property Criteria: ICriteria read getCriteria;
    property Connection: IDbConnection read getDbConnection;
    function Save(AModel: T; ARunValidation: Boolean): Boolean;
    function Insert(AModel: T): Boolean;
    function Update(AModel: T): Boolean;
    function UpdateByPk(OID: IIdentifiable; AModel: T; condition: ICriteria): Integer;
    function UpdateAll(AModel: T; condition: ICriteria): Integer;
    function Delete(AModel: T): Boolean;
    function DeleteByPk(OID: IIdentifiable): Integer;
    function DeleteAll(AModel: T): Integer;
    function Find(AModel: T; condition: ICriteria): TArray<T>;
    function FindAll(AModel: T; condition: ICriteria): TArray<T>;
    function FindByPk(AModel: T; OID: IIdentifiable; condition: ICriteria): TArray<T>;
    function FindAllByPk(AModel: T; OID: IIdentifiable; condition: ICriteria): TArray<T>;
    function FindByAttributes(AModel: T; condition: ICriteria): TArray<T>;
    function FindAllByAttributes(AModel: T; condition: ICriteria): TArray<T>;
    function Count(condition: ICriteria): Integer;
    function refresh(AModel: T): Boolean;
  public
    constructor Create(AModel: TJEntityClass);
  end;

  TEntityState = (esDetached, esUnchanged, esNew, esModified, esDeleted);
  TEntityStates = set of TEntityState;

  TJEntity = class(TJComponent, IEntity, IIdentifiable)
  private

  protected
    function GetID: JValue;
    procedure SetID(const Value: JValue);
  public
    property ID: JValue read GetID write SetID;
  end;

  CDbException = class(JException);

implementation

uses
  JBase;

{ JDBCommandBuilder }

function TJDBCommandBuilder.applyCondition(ASQL, ACondition: string): string;
begin
  if ACondition <> emptystr then
  begin
    Result := ASQL + ' WHERE ' + ACondition;
  end
  else
  begin
    Result := ASQL;
  end;
end;

function TJDBCommandBuilder.applyGroup(ASQL, AGroup: string): string;
begin
  if AGroup <> emptystr then
  begin
    Result := ASQL + ' GROUP BY  ' + AGroup;
  end
  else
  begin
    Result := ASQL;
  end;
end;

function TJDBCommandBuilder.applyHaving(ASQL, AHaving: string): string;
begin
  if AHaving <> emptystr then
  begin
    Result := ASQL + ' HAVING  ' + AHaving;
  end
  else
  begin
    Result := ASQL;
  end;
end;

function TJDBCommandBuilder.applyJoin(ASQL, AJoin: string): string;
begin
  if AJoin <> emptystr then
  begin
    Result := ASQL + ' ' + AJoin;
  end
  else
  begin
    Result := ASQL;
  end;
end;

function TJDBCommandBuilder.applyLimit(ASQL: string; Alimit, AOffset: Integer): string;
begin
  Result := ASQL;

  if (Alimit >= 0) then
    Result := Result + ' LIMIT ' + IntToStr(Alimit);

  if (AOffset > 0) then
    Result := Result + ' OFFSET ' + IntToStr(AOffset)
end;

function TJDBCommandBuilder.applyOrder(ASQL, AOrderBy: string): string;
begin
  if AOrderBy <> emptystr then
  begin
    Result := ASQL + ' ORDER BY  ' + AOrderBy;
  end
  else
  begin
    Result := ASQL;
  end;
end;

constructor TJDBCommandBuilder.Create(ASchema: IDbSchema);
begin
  FSchema := ASchema;
  FConnection := ASchema.Connection;
end;

function TJDBCommandBuilder.createCountCommand(ATable: string; ACriteria: ICriteria; AAlias: string): IDbCommand;
var
  ASQL: string;
begin

  if ACriteria.distinct then
    ASQL := 'SELECT DISTINCT'
  else
    ASQL := 'SELECT';

  ASQL := ASQL + ' COUNT(*) FROM ' + ATable;

  ASQL := applyJoin(ASQL, ACriteria.join);
  ASQL := applyCondition(ASQL, ACriteria.condition);
  Result := Connection.createCommand(ASQL);
  // bindValues(Result,ACriteria.params); 
end;

function TJDBCommandBuilder.createDeleteCommand(ATable: string; ACriteria: ICriteria): IDbCommand;
var
  ASQL: string;
begin
  ASQL := 'DELETE FROM ' + ATable;
  ASQL := applyJoin(ASQL, ACriteria.join);
  ASQL := applyCondition(ASQL, ACriteria.condition);
  ASQL := applyGroup(ASQL, ACriteria.group);
  ASQL := applyHaving(ASQL, ACriteria.having);
  ASQL := applyOrder(ASQL, ACriteria.order);
  ASQL := applyLimit(ASQL, ACriteria.limit, ACriteria.offset);
  Result := Connection.createCommand(ASQL);
  // bindValues(Result,ACriteria.params); 
end;

function TJDBCommandBuilder.createFindCommand(ATable: string; ACriteria: ICriteria; AAlias: string): IDbCommand;
var
  ASQL: string;
begin

  if ACriteria.distinct then
    ASQL := 'SELECT DISTINCT'
  else
    ASQL := 'SELECT';

  ASQL := ASQL + ' ' + ACriteria.select + ' FROM ' + ATable;

  ASQL := applyJoin(ASQL, ACriteria.join);
  ASQL := applyCondition(ASQL, ACriteria.condition);
  ASQL := applyGroup(ASQL, ACriteria.group);
  ASQL := applyHaving(ASQL, ACriteria.having);
  ASQL := applyOrder(ASQL, ACriteria.order);
  ASQL := applyLimit(ASQL, ACriteria.limit, ACriteria.offset);
  Result := Connection.createCommand(ASQL);
  // bindValues(Result,ACriteria.params); 

end;

function TJDBCommandBuilder.createInsertCommand(ATable: string; Adata: IEntity): IDbCommand;
begin

end;

function TJDBCommandBuilder.createUpdateCommand(ATable: string; Adata: IEntity; ACriteria: ICriteria): IDbCommand;
begin

end;

function TJDBCommandBuilder.getConnection: IDbConnection;
begin
  Result := FConnection;
end;

function TJDBCommandBuilder.getSchema: IDbSchema;
begin
  Result := FSchema;
end;

{ JEntity }

function TJEntity.GetID: JValue;
begin

end;

procedure TJEntity.SetID(const Value: JValue);
begin

end;

{ TJReposity<T> }

function TJReposity<T>.Count(condition: ICriteria): Integer;
begin

end;

constructor TJReposity<T>.Create(AModel: TJEntityClass);
begin

end;

function TJReposity<T>.Delete(AModel: T): Boolean;
begin

end;

function TJReposity<T>.DeleteAll(AModel: T): Integer;
begin

end;

function TJReposity<T>.DeleteByPk(OID: IIdentifiable): Integer;
begin

end;

function TJReposity<T>.Find(AModel: T; condition: ICriteria): TArray<T>;
begin

end;

function TJReposity<T>.FindAll(AModel: T; condition: ICriteria): TArray<T>;
begin

end;

function TJReposity<T>.FindAllByAttributes(AModel: T; condition: ICriteria): TArray<T>;
begin

end;

function TJReposity<T>.FindAllByPk(AModel: T; OID: IIdentifiable; condition: ICriteria): TArray<T>;
begin

end;

function TJReposity<T>.FindByAttributes(AModel: T; condition: ICriteria): TArray<T>;
begin

end;

function TJReposity<T>.FindByPk(AModel: T; OID: IIdentifiable; condition: ICriteria): TArray<T>;
begin

end;

function TJReposity<T>.getCriteria: ICriteria;
begin
  if Assigned(FCriteria) then
    FCriteria := TJCriteria.Create;
  Result := FCriteria;
end;

function TJReposity<T>.getDbConnection: IDbConnection;
begin
  if not Assigned(FConnection) then
    Result := FConnection
  else
  begin
    if Supports(TJBase.app.Connection, IDbConnection, FConnection) then
    begin
      FConnection.Active := true;
      Result := FConnection
    end
    else
    begin
      raise CDbException.Create('Requires a "db" CDbConnection application component.');
    end;
  end;
end;

function TJReposity<T>.Insert(AModel: T): Boolean;
begin

end;

function TJReposity<T>.refresh(AModel: T): Boolean;
begin

end;

function TJReposity<T>.Save(AModel: T; ARunValidation: Boolean): Boolean;
begin

end;

function TJReposity<T>.Update(AModel: T): Boolean;
begin

end;

function TJReposity<T>.UpdateAll(AModel: T; condition: ICriteria): Integer;
begin

end;

function TJReposity<T>.UpdateByPk(OID: IIdentifiable; AModel: T; condition: ICriteria): Integer;
begin

end;

{ TJCriteria }

function TJCriteria.getcondition: String;
begin

end;

function TJCriteria.getdistinct: Boolean;
begin

end;

function TJCriteria.getgroup: String;
begin

end;

function TJCriteria.gethaving: String;
begin

end;

function TJCriteria.getjoin: String;
begin

end;

function TJCriteria.getlimit: Integer;
begin

end;

function TJCriteria.getoffset: Integer;
begin

end;

function TJCriteria.getorder: string;
begin

end;

function TJCriteria.getselect: String;
begin

end;

procedure TJCriteria.setcondition(Value: String);
begin

end;

procedure TJCriteria.setdistinct(Value: Boolean);
begin

end;

procedure TJCriteria.setgroup(Value: String);
begin

end;

procedure TJCriteria.sethaving(Value: String);
begin

end;

procedure TJCriteria.setjoin(Value: String);
begin

end;

procedure TJCriteria.setlimit(Value: Integer);
begin

end;

procedure TJCriteria.setoffset(Value: Integer);
begin

end;

procedure TJCriteria.setorder(Value: string);
begin

end;

procedure TJCriteria.setselect(Value: String);
begin

end;

function getCriteria: ICriteria;
begin

end;

end.
