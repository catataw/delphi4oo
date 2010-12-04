unit DataBase.AnnotationTests;

interface

uses
  TestFramework, Db, System.Common, Classes, DataBase.Interfaces, SysUtils,
  DataBase.Core, DataBase.Annotation, System.Interfaces, System.Base;

type

 [JDbTableSchema('cliente', 'codigo;aa')]
  TPessoa = class
  private
    FNome: String;
  public
    [JDbColumnSchema('NomeBanCO')]
    property Nome: String read FNome write FNome;
  end;

  TestJDbColumnSchema = class(TTestCase)
  private
    FPessoa: TPessoa;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TesteAttrNome;
    procedure TestTableSchema;
    procedure TestPrimarykey;
  end;

implementation

uses
  Rtti;

procedure TestJDbColumnSchema.SetUp;
begin
  FPessoa := TPessoa.Create;
  FPessoa.Nome:='aaa';
end;

procedure TestJDbColumnSchema.TearDown;
begin
  FPessoa.Destroy;
end;

procedure TestJDbColumnSchema.TesteAttrNome;
var
  objType: TRttiType;
  ctx: TRttiContext;
  Prop: TRttiProperty;
  AColumm: JDbColumnSchema;
  aName: string;
  function GetIniAttribute(Obj: TRttiObject): JDbColumnSchema;
  var
    Attr: TCustomAttribute;
  begin
    for Attr in Obj.GetAttributes do
    begin
      if Attr is JDbColumnSchema then
      begin
        exit(JDbColumnSchema(Attr));
      end;
    end;
    result := nil;
  end;

begin
  ctx := TRttiContext.Create;
  objType := ctx.GetType(FPessoa.ClassInfo);
  for Prop in objType.GetProperties do
  begin
    AColumm := GetIniAttribute(Prop);
    if Assigned(AColumm) then
    begin
      aName := AColumm.Name;
    end;
  end;
  CheckEquals('NomeBanCO', aName);
end;

procedure TestJDbColumnSchema.TestPrimarykey;
var
  objType: TRttiType;
  ctx: TRttiContext;
  Prop: TRttiProperty;
  a: TCustomAttribute;
  aName: string;
begin
  ctx := TRttiContext.Create;
  objType := ctx.GetType(FPessoa.ClassInfo);
  for a in objType.GetAttributes do
    if a is JDbTableSchema then
    begin
      aName := JDbTableSchema(a).PrimaryKey[0];
      Break;
    end;
  CheckEquals('codigo', aName);
end;

procedure TestJDbColumnSchema.TestTableSchema;
var
  objType: TRttiType;
  ctx: TRttiContext;
  Prop: TRttiProperty;
  a: TCustomAttribute;
  aName: string;
begin
  ctx := TRttiContext.Create;
  objType := ctx.GetType(FPessoa.ClassInfo);
  for a in objType.GetAttributes do
    if a is JDbTableSchema then
    begin
      aName := JDbTableSchema(a).Name;
      Break;
    end;
  CheckEquals('cliente', aName);
end;

initialization

RegisterTest(TestJDbColumnSchema.Suite);

end.
