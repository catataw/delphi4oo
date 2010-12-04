unit NProvider.Configuration;

interface

uses
  IniFiles,
  Classes,
  NProviderIntf;

type

  TProviderConfigIni = class(TInterfacedObject, IProviderConfig)
  private
    FIniFile: TIniFile;
    FFileName: string;
  Protected
    procedure SetFileName(const Value: string);
    function GetFileName: string;
  public
    procedure Update;
    function ReadString(const Section, Ident, Default: string): string;
    function ReadInteger(const Section, Ident: string; Default: integer): integer;
    procedure WriteSection(const Section, Values: string);
    procedure WriteString(const Section, Ident, Value: string);
    procedure WriteInteger(const Section, Ident: string; Value: integer);
    procedure DeleteKey(const Section, Ident: String);
    procedure ReadSections(var Sections: TStrings);
    procedure ReadSectionValues(const Section: String; Strings: TStrings);
    procedure DeleteSection(const Section: String);
    destructor Destroy; override;
    property FileName: string read GetFileName write SetFileName;
  end;

implementation

uses
  Forms, SysUtils;

{ TProviderConfigIni }

destructor TProviderConfigIni.Destroy;
begin
  if Assigned(FIniFile) then
    FreeAndNil(FIniFile);
  inherited;
end;

function TProviderConfigIni.ReadString(const Section, Ident, Default: string): string;
begin
  try
    Result := FIniFile.ReadString(Section, Ident, Default);
  except
    Result := Default;
  end;
end;

function TProviderConfigIni.ReadInteger(const Section, Ident: string; Default: integer): integer;
begin
  Result := FIniFile.ReadInteger(Section, Ident, Default);
end;

procedure TProviderConfigIni.ReadSectionValues(const Section: String; Strings: TStrings);
begin
  FIniFile.ReadSectionValues(Section, Strings);
end;

procedure TProviderConfigIni.Update;
begin
  if Assigned(FIniFile) then
    FreeAndNil(FIniFile);
  FIniFile := TIniFile.Create(FFileName);
end;

procedure TProviderConfigIni.WriteInteger(const Section, Ident: string; Value: integer);
begin
  FIniFile.WriteInteger(Section, Ident, Value);
end;

procedure TProviderConfigIni.WriteString(const Section, Ident, Value: string);
begin
  FIniFile.WriteString(Section, Ident, Value);
end;

procedure TProviderConfigIni.WriteSection(const Section, Values: string);
var
  vValues: TStrings;
  vI: integer;
begin
  DeleteSection(Section);
  vValues := TStringList.Create;
  vValues.Text := Values;
  try
    for vI := 0 to vValues.Count - 1 do
      WriteString(Section, vValues.Names[vI], vValues.ValueFromIndex[vI]);
  finally
    vValues.Free;
  end;
end;

procedure TProviderConfigIni.DeleteKey(const Section, Ident: String);
begin
  FIniFile.DeleteKey(Section, Ident);
end;

procedure TProviderConfigIni.SetFileName(const Value: string);
begin
  FFileName := Value;
  Update;
end;

procedure TProviderConfigIni.ReadSections(var Sections: TStrings);
begin
  FIniFile.ReadSections(Sections);
end;

procedure TProviderConfigIni.DeleteSection(const Section: String);
begin
  FIniFile.EraseSection(Section);
end;

function TProviderConfigIni.GetFileName: string;
begin
  Result := FFileName;
end;

end.
