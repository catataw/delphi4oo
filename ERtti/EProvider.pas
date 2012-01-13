unit EProvider;

interface

uses EIntf;

type

  TMirrorReflectionProvider = class(EObject, IReflectionProvider)
  protected
      function getMethodReflectionProvider(target:TObject;clazz:Tclass; method:EMethod):IMethodReflectionProvider;
      function geFieldReflectionProvider(target :TObject;clazz :Tclass; field:EField):IFieldReflectionProvider;
      function getClassGenericTypeAccessor(clazz :TClass):IGenericTypeAccessor;
      function geFieldGenericTypeAccessor(field:EField):IGenericTypeAccessor;
      function getClassReflectionProvider(className: String): IClassReflectionProvider<TObject>;overload;
      function getClassReflectionProvider(clazz:Tclass):IClassReflectionProvider<TObject>;overload;


  end;

  TConstructorBypassingReflectionProvider<T> = class(EObject, IConstructorBypassingReflectionProvider<T>)
  protected
    function bypassConstructor(): T;
  end;

  TAnnotatedElementReflectionProvider = class(EObject, IAnnotatedElementReflectionProvider)

  end;

  TGenericTypeAccessor = class(EObject, IGenericTypeAccessor)

  end;

  TClassReflectionProvider<T> = class(EObject, IClassReflectionProvider<T>)

  end;

  TConstructorReflectionProvider<T> = class(EObject, IConstructorReflectionProvider<T>)
  protected
    procedure setAccessible();
  end;

  TFieldGenericTypeAccessor = class(EObject, IGenericTypeAccessor)

  end;

  TFieldReflectionProvider = class(EObject, IFieldReflectionProvider)
  protected
    procedure setValue(Value: Tobject);
    function getValue(): Tobject;
    procedure setAccessible();
  end;

  TMethodReflectionProvider = class(EObject, IMethodReflectionProvider)
    protected
        procedure setAccessible();
  end;

  TParameterizedElementReflectionProvider = class(EObject,IParameterizedElementReflectionProvider)

  end;

implementation

{ TConstructorBypassingReflectionProvider<T> }

function TConstructorBypassingReflectionProvider<T>.bypassConstructor: T;
begin

end;

{ TConstructorReflectionProvider<T> }

procedure TConstructorReflectionProvider<T>.setAccessible;
begin

end;

{ TFieldReflectionProvider }

function TFieldReflectionProvider.getValue: Tobject;
begin

end;

procedure TFieldReflectionProvider.setAccessible;
begin

end;

procedure TFieldReflectionProvider.setValue(Value: Tobject);
begin

end;

{ TMethodReflectionProvider }

procedure TMethodReflectionProvider.setAccessible;
begin

end;

{ TMirrorReflectionProvider }

function TMirrorReflectionProvider.geFieldGenericTypeAccessor(field: EField): IGenericTypeAccessor;
begin

end;

function TMirrorReflectionProvider.geFieldReflectionProvider(target: TObject; clazz: Tclass;
  field: EField): IFieldReflectionProvider;
begin

end;

function TMirrorReflectionProvider.getClassGenericTypeAccessor(clazz: TClass): IGenericTypeAccessor;
begin

end;

function TMirrorReflectionProvider.getClassReflectionProvider(className: String): IClassReflectionProvider<TObject>;
begin

end;

function TMirrorReflectionProvider.getClassReflectionProvider(clazz: Tclass): IClassReflectionProvider<TObject>;
begin

end;

function TMirrorReflectionProvider.getMethodReflectionProvider(target: TObject; clazz: Tclass;
  method: EMethod): IMethodReflectionProvider;
begin

end;

end.
