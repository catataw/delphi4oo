unit DataBase.JDbDataReader;

interface

uses Classes, SysUtils, System.Interfaces,  System.Base,System.Common ,DataBase.Interfaces;

type

  JDbDataReader = class(TJComponent, IDbDataReader, Iterator)
  private
    FReader: TObject;
    FIndex: integer;
    FClose: Boolean;
    FRow: TObject;
    function getColumnCount: integer;
    function getIsClosed: Boolean;
    function getRowCount: integer;
    function GetValueByName(const Name: String): JValue;
    function GetValue(const Index: integer): JValue;
  protected
    function Key: integer;
    procedure Next;
    function Valid: Boolean;
    procedure Close;
    procedure Current;
    procedure rewind;
    function Read: TObject;
    property ColumnCount: integer read getColumnCount;
    property IsClosed: Boolean read getIsClosed;
    property RowCount: integer read getRowCount;
    property readColumn[const Name: String]: JValue read GetValueByName; default;
    property readColumn[const Ordinal: integer]: JValue read GetValue; default;
  public
    constructor Create(ADataReader: TObject);
  end;

implementation

uses
  DBXCommon, DBXDynalink;

procedure JDbDataReader.Close;
begin
  TDBXReader(FReader).Close;
  FClose := true;
end;

constructor JDbDataReader.Create(ADataReader: TObject);
begin
  FReader := TDBXReader(ADataReader);
  FIndex := -1;
  FClose := false
end;

procedure JDbDataReader.Current;
begin

end;

function JDbDataReader.getColumnCount: integer;
begin
  result := TDBXReader(FReader).ColumnCount;
end;

function JDbDataReader.getIsClosed: Boolean;
begin
  result := FClose;
end;

function JDbDataReader.getRowCount: integer;
begin

end;

function JDbDataReader.GetValue(const Index: integer): JValue;
begin
  JValue.Null
end;

function JDbDataReader.GetValueByName(const Name: String): JValue;
begin

end;

function JDbDataReader.Key: integer;
begin
  result := FIndex;
end;

procedure JDbDataReader.Next;
begin
  TDBXReader(FReader).Next;
  inc(FIndex);
end;

function JDbDataReader.Read: TObject;
begin
  Result := TDBXDynalinkReader(FReader).Value[0];
end;

procedure JDbDataReader.rewind;
begin
  TDBXReader(FReader).Reset
end;

function JDbDataReader.Valid: Boolean;
begin

end;

end.
