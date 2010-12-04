unit JBase;

interface

uses System.Base, Generics.Collections, Classes;

type

  TJBase = class
  class var
    FApp: TJApplication;
    FClassList: TStringList;
  public
    class function createApplication(AClass: string): TJApplication;
    class function app: TJApplication;
    class function setApplication(var AApplication: TJApplication): TJApplication;
    class function t(AMessage: string; const Args: array of const ): string;
    class procedure Trace(AMsg, ACategory: string);
    class procedure registerModule(AModule: TJComponentClass);
    class function findModule(AModule: string): TJComponentClass;
  end;

implementation

uses
  SysUtils, Forms;

{ TJBase }

class function TJBase.app: TJApplication;
begin
  result := FApp;
end;

class function TJBase.createApplication(AClass: string): TJApplication;
var
  AClassApp: TJComponentClass;
begin
  Application.Initialize;
  AClassApp := TJComponentClass(findModule(AClass));
  result := TJApplication(AClassApp.Create);
  Application.run;
end;

class function TJBase.findModule(AModule: string): TJComponentClass;
var
  I: Integer;
begin
  if FClassList <> nil then
  begin
    I := FClassList.IndexOf(AModule);
    if I >= 0 then
    begin
      result := TJComponentClass(FClassList.Objects[I]);
      Exit;
    end;
  end;
  result := nil;
end;

class procedure TJBase.registerModule(AModule: TJComponentClass);
var
  LClassName: string;
  LClass: TJComponentClass;
begin
  LClassName := AModule.ClassName;
  LClass := findModule(LClassName);
  if FClassList = nil then
  begin
    FClassList := TStringList.Create;
    FClassList.Sorted := True;
  end;
  FClassList.AddObject(LClassName, TObject(AModule));

end;

class function TJBase.setApplication(var AApplication: TJApplication): TJApplication;
begin
  if not Assigned(FApp) then
  begin
    FApp := AApplication;
    result := FApp;
  end
  else
    raise JException.Create('application can only be created once');

end;

class function TJBase.t(AMessage: string; const Args: array of const ): string;
begin
  result := Format(AMessage, Args);
end;

class procedure TJBase.Trace(AMsg, ACategory: string);
begin

end;

end.
