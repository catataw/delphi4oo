unit DataBase.Interfaces;

interface

uses Classes, Contnrs, System.Interfaces, System.Common;

type

  IDbConnection = interface;
  IDbCommand = interface;
  IDbCommandBuilder = interface;

  IDbTransaction = interface(IComponent)
    ['{534777F4-9567-42D3-AC96-DD89069D4A7F}']
    procedure Commit;
    procedure Rollback;
    function getConnection: IDbConnection;
    function getActive: Boolean;
    property Active: Boolean read getActive;
    property Connection: IDbConnection read getConnection;
  end;

  IDbConnection = interface(IApplicationComponent)
    ['{ACAFB4C1-AEAC-4385-A8EE-BD51CE9BB338}']
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
    procedure BeginTransaction;
    procedure Connect;
    procedure Disconnect;
    function createCommand(ASql: string): IDbCommand;
    property Active: Boolean read getActive write setActive;
    property ConnectionString: string read getConnectionString write setConnectionString;
    property Instance: TObject read getInstance;
    property Password: String read getPassword write setPassword;
    property Transaction: IDbTransaction read getTransaction;
    property UserName: String read getUserName write setUserName;
    property AutoConnect: Boolean read getAutoConnect write setAutoConnect;
  end;

  IDbDataReader = interface(IComponent)
    ['{0B0B6C31-D3FC-4577-B07A-DE89663673D3}']
    function getColumnCount: Integer;
    function getIsClosed: Boolean;
    function getRowCount: Integer;
    function GetValueByName(const Name: String): JValue;
    function GetValue(const Index: Integer): JValue;
    procedure Close;
    function Read: TObject;
    property ColumnCount: Integer read getColumnCount;
    property IsClosed: Boolean read getIsClosed;
    property RowCount: Integer read getRowCount;
    property readColumn[const Name: String]: JValue read GetValueByName;
    property readColumn[const Index: Integer]: JValue read GetValue;
  end;

  IIdentifiable = interface
    ['{180C6E00-3360-4913-B862-090D9F3697FD}']
    function GetID: JValue;
    procedure SetID(const Value: JValue);
    property ID: JValue read GetID write SetID;
  end;

  ICriteria = interface(IComponent)
    ['{9285FF21-2525-4382-B054-AE4A20D09D8A}']
    function getcondition: String;
    function getdistinct: Boolean;
    function getgroup: String;
    function gethaving:String;
    function getjoin:String;
    function getlimit: Integer;
    function getorder: string;
    //function getparams: array of Variant;
    function getselect: String;
    procedure setcondition(Value: String);
    procedure setdistinct(Value: Boolean);
    procedure setgroup(Value: String);
    procedure sethaving(value :String);
    procedure setjoin(value :String);
    procedure setlimit(Value: Integer);
    procedure setorder(Value: string);
    //procedure setparams(Value: array of Variant);
    procedure setselect(Value: String);
    property condition: String read getcondition write setcondition;
    property distinct: Boolean read getdistinct write setdistinct;
    property group: String read getgroup write setgroup;
    property having : String read gethaving write sethaving;
    property join : String read getjoin write setjoin;
    property limit: Integer read getlimit write setlimit;
    property order: string read getorder write setorder;
    procedure setoffset(value :integer);
    function getoffset:integer;
    property offset : integer read getoffset write setoffset;
    //property params: array of Variant read getparams write setparams;
    property select: String read getselect write setselect;
  end;

  IDbSchema = interface(IComponent)
    ['{672F913D-8A2A-4063-B825-5E57A002F282}']
    function createCommandBuilder: IDbCommandBuilder;
    procedure refresh;
    function getConnection: IDbConnection;
    property Connection: IDbConnection read getConnection;
  end;

  IDbCommand = interface(IComponent)
    ['{705A1F8C-3CC3-409B-A38E-CA61B7F1AEFC}']
    function getStatement: TObject;
    function getConnection: IDbConnection;
    function getSql: TStringList;
    function bindParam(AName: string; AValue: Variant): IDbCommand;
    function bindValue(AName: string; AValue: Variant): IDbCommand;
    procedure Cancel;
    procedure Prepare;
    function Execute(const AParams: array of const ): Integer;
    function Query(const AParams: array of const ): IDbDataReader;
    property Sql: TStringList read getSql;
    property Connection: IDbConnection read getConnection;
    property Statement: TObject read getStatement;
  end;

  IReposity<T> = interface(IComponent)
    ['{777C8970-6B67-4477-A447-8E3D358D3173}']
    function Save(AModel: T; ARunValidation: Boolean): Boolean;
    function Insert(AModel: T): Boolean;
    function Update(AModel: T): Boolean;
    function UpdateByPk(OID: IIdentifiable; AModel: T; condition: ICriteria): Integer;
    function UpdateAll(AModel: T; condition: ICriteria): Integer;
    function Delete(AModel: T): Boolean;
    function DeleteByPk(OID: IIdentifiable): Integer;
    function DeleteAll(AModel: T): Integer;
    function Find(AModel: T; condition: ICriteria): TObjectList;
    function FindAll(AModel: T; condition: ICriteria): TObjectList;
    function FindByPk(AModel: T; OID: IIdentifiable; condition: ICriteria): TObjectList;
    function FindAllByPk(AModel: T; OID: IIdentifiable; condition: ICriteria): TObjectList;
    function FindByAttributes(AModel: T; condition: ICriteria): TObjectList;
    function FindAllByAttributes(AModel: T; condition: ICriteria): TObjectList;
    function Count(condition: ICriteria): Integer;
    function refresh(AModel: T): Boolean;
  end;

  IEntity = Interface
    ['{A5D4128D-75EC-4469-AB94-F91075437547}']
  End;

  IDbCommandBuilder = interface(IComponent)
    ['{D3A8C138-C1E8-4112-A7A9-B747070ED3A3}']
    function getConnection: IDbConnection;
    function getSchema: IDbSchema;
    function createFindCommand(ATable: string; ACriteria: ICriteria; AAlias: string = 't'): IDbCommand;
    function createCountCommand(ATable: string; ACriteria: ICriteria; AAlias: string = 't'): IDbCommand;
    function createDeleteCommand(ATable: string; ACriteria: ICriteria): IDbCommand;
    function createInsertCommand(ATable: string; Adata: IEntity): IDbCommand;
    function createUpdateCommand(ATable: string; Adata: IEntity; ACriteria: ICriteria): IDbCommand;
    property Connection: IDbConnection read getConnection;
    property Schema: IDbSchema read getSchema;
  end;

implementation

end.
