unit DataBase.Annotation;

interface

uses Classes, Db, SysUtils, System.Interfaces, System.Base, DataBase.Interfaces, System.Common;

type

  JDbTableSchema = class;

  JDbSchema = class(TJComponent, IDbSchema)
  private
    FConnection: IDbConnection;
    FCommandBuilder: IDbCommandBuilder;
    FTable: TList;
  protected
    function getCommandBuilder: IDbCommandBuilder;
    function getConnection: IDbConnection;
    function getTable(ATable: string): JDbTableSchema;
    function createCommandBuilder: IDbCommandBuilder;
    procedure refresh;
    property Connection: IDbConnection read getConnection;
    property CommandBuilder: IDbCommandBuilder read getCommandBuilder;
    property Table[ATable: string]: JDbTableSchema read getTable;
  public
    constructor Create(AConn: IDbConnection);
  end;


  JDBColumnSchema = class(TJAttribute)
  private
    FName: String;
    FAllowNull: Boolean;
    FDefaultValue: JValue;
    FPrecision: Integer;
    FDbType: string;
    FSize: Integer;
    FScale: Integer;
    FRawName: string;
  public
    constructor Create(AName: String);
    property AllowNull: Boolean read FAllowNull write FAllowNull;
    property DbType: string read FDbType write FDbType;
    property DefaultValue: JValue read FDefaultValue write FDefaultValue;
    property Name: String read FName write FName;
    property Precision: Integer read FPrecision write FPrecision;
    property RawName: string read FRawName;
    property Scale: Integer read FScale write FScale;
    property Size: Integer read FSize write FSize;
  end;

  JDbTableSchema = class(TJAttribute)
  private
    FName: string;
    FPrimaryKeys: TStringList;
    function getPrimaryKey(AIndex: Integer): string;
    procedure setPrimaryKey(AIndex: Integer; const Value: string);

  public
    property Name: string read FName write FName;
    property PrimaryKey[AIndex: Integer]: string read getPrimaryKey write setPrimaryKey;
    property PrimaryKeys: TStringList read FPrimaryKeys;
    constructor Create(AName: String); reintroduce; overload;
    constructor Create(AName: String; APrimaryKeys: string); overload;
  end;

  CBaseActiveRelation = class(TJAttribute)
  private
    FForeignKey: string;
    FClassName: String;
    FNome: String;
    FCondition: string;
    FOrder: string;
    FHaving: string;
    FGroup: string;
    FSelect: String;
  public
    procedure mergeWith(ACriteria: ICriteria);
    property Nome: String read FNome write FNome;
    property Select: String read FSelect write FSelect;
    property Condition: string read FCondition write FCondition;
    property Group: string read FGroup write FGroup;
    property Having: string read FHaving write FHaving;
    property Order: string read FOrder write FOrder;
    property ClassName: String read FClassName write FClassName;
    property ForeignKey: string read FForeignKey write FForeignKey;
    constructor Create(AName: string; AClassName: string; AForeingKey: string); virtual;
  end;

  CStatRelation = class(CBaseActiveRelation)
  private
    FDefaultValue: Integer;
  public
    property DefaultValue: Integer read FDefaultValue write FDefaultValue;
    constructor Create(AName: string; AClassName: string; AForeingKey: string); overload;
    constructor Create(AName: string; AClassName: string; AForeingKey: string; ADefaultValue: Integer); overload;

  end;

  TRelation = (CBelongsToRelation, COneRelation, CManyRelation);

  CActiveRelation = class(CBaseActiveRelation)
  private
    Fonand: String;
    Falias: String;
    FjoinType: String;
    FRelation: TRelation;
  public
    property Relation: TRelation read FRelation write FRelation;
    property joinType: String read FjoinType;
    property onand: String read Fonand;
    property alias: String read Falias;
    constructor Create(AName: string; AClassName: string; AForeingKey: string; ARelation: TRelation); overload;
  end;

  CHasManyRelation = class(CActiveRelation)

  end;

  CManyManyRelation = class(CHasManyRelation)

  end;

implementation

uses DataBase.Core;

{ JDbSchema }

constructor JDbSchema.Create(AConn: IDbConnection);
begin
  FConnection := AConn;
end;

function JDbSchema.createCommandBuilder: IDbCommandBuilder;
begin
  Result := TJDBCommandBuilder.Create(Self);
end;

function JDbSchema.getCommandBuilder: IDbCommandBuilder;
begin
  if Assigned(FCommandBuilder) then
    FCommandBuilder := createCommandBuilder;

  Result := FCommandBuilder

end;

function JDbSchema.getConnection: IDbConnection;
begin
  Result := FConnection;
end;

function JDbSchema.getTable(ATable: string): JDbTableSchema;
begin

end;

procedure JDbSchema.refresh;
begin

end;

{ JDbColumnSchema }

constructor JDBColumnSchema.Create(AName: String);
begin
  FName := AName;
end;

{ JDbTableSchema }

constructor JDbTableSchema.Create(AName: String);
begin
  Create(AName, EmptyStr);
end;

constructor JDbTableSchema.Create(AName: String; APrimaryKeys: string);
var
  I: Integer;
begin
  FName := AName;
  FPrimaryKeys := TStringList.Create;
  FPrimaryKeys.Delimiter := ';';
  if not(APrimaryKeys = EmptyStr) then
    FPrimaryKeys.DelimitedText := APrimaryKeys;

end;

function JDbTableSchema.getPrimaryKey(AIndex: Integer): string;
begin
  Result := FPrimaryKeys.Strings[AIndex];
end;

procedure JDbTableSchema.setPrimaryKey(AIndex: Integer; const Value: string);
begin
  FPrimaryKeys.Add(Value);
end;

{ CBaseActiveRelation }

constructor CBaseActiveRelation.Create(AName, AClassName, AForeingKey: string);
begin
  FNome := AName;
  FClassName := AClassName;
  FForeignKey := AForeingKey;
end;

procedure CBaseActiveRelation.mergeWith(ACriteria: ICriteria);
begin

end;

{ CStatRelation }

constructor CStatRelation.Create(AName, AClassName, AForeingKey: string);
begin
  inherited Create(AName, AClassName, AForeingKey);
  Select := 'COUNT(*)';

end;

constructor CStatRelation.Create(AName, AClassName, AForeingKey: string; ADefaultValue: Integer);
begin
  Self.Create(AName, AClassName, AForeingKey);
  DefaultValue := ADefaultValue;
end;

{ CActiveRelation }

constructor CActiveRelation.Create(AName, AClassName, AForeingKey: string; ARelation: TRelation);
begin
  inherited Create(AName, AClassName, AForeingKey);
  FRelation := ARelation;
end;

end.
