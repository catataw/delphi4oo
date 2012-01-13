unit ERtti;

interface

uses
  EIntf;

type

  TERtti = record
  private
    FCachedProvider : IReflectionProvider;
    FProvider :IReflectionProvider;
  public
    class function from(AObject: TObject): IAccessorsController; overload; static;
    class function from<T>(className: string): IClassController<T>; overload; static;
    class function from<T>(clazz: TClass): IClassController<T>; overload; static;
    class function from(AField: EField): IFieldController; overload; static;
    class function reflectClass(className : string):TClass;static;
    // function O(member:AnnotatedElement):IMemberController;
  end;

implementation

uses
  EController;

{ ERtti }

class function TERtti.from(AObject: TObject): IAccessorsController;
begin

end;

class function TERtti.from(AField: EField): IFieldController;
begin

end;

class function TERtti.from<T>(clazz: TClass): IClassController<T>;
begin
   Result := TClassController<T>.Create();
end;

class function TERtti.reflectClass(className: string): TClass;
begin
   Result :=FProvider. getClassReflectionProvider(className).reflectClass();
end;

class function TERtti.from<T>(className: string): IClassController<T>;
begin
   result := TERtti.from<T>(TERtti.reflectClass(className));
end;

end.
