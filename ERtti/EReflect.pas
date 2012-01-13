unit EReflect;

interface

uses
  EIntf;

type

  TAllAnnotationsHandler = class(EObject, IAllAnnotationsHandler)
  private
    FClazz: TClass;
    FProvider: IReflectionProvider;
  protected
    function atClass(): EList<EAnnotation>;
    function aField(fieldName: String): EList<EAnnotation>;
    function atMethod(methodName: String): IAllMethodAnnotationsHandler;
  public
    constructor create(provider: IReflectionProvider; clazz: TClass);
  end;

  TAllMemberHandler = class(EObject, IAllMemberHandler)
  private
    // FMember:IAnnotatedElement;
    FProvider: IReflectionProvider;
  protected
    function annotations(): EList<EAnnotation>;
  public
    constructor create(provider: IReflectionProvider { final AnnotatedElement member^ } );
  end;

  TReflectionHandler<T> = class(EObject, IReflectionHandler<T>)
  protected
    function Field(fieldName: string): EField;
    function method(methodName: String): IMethodReflector;
    function Construct(): IConstructorReflector<T>;
    function parentGenericType(): IParameterizedElementHandler;
  end;

  TParameterizedElementHandler = class(EObject, IParameterizedElementHandler)
  protected
    function atPosition(index: Integer): TClass;
  public
    constructor create(provider: IReflectionProvider { , GenericTypeAccessor accessor) } );
  end;

  TMethodReflector = class(EObject, IMethodReflector)
  protected
    function withoutArgs(): EMethod;
    function withArgs(Classes: array of EValue): EMethod;
    function withAnyArgs(): EMethod;
  public
    constructor create(provider: IReflectionProvider; methodName: string { , final Class<?> clazz) } );
  end;

  TFieldReflector = class(EObject, IFieldReflector)
  protected
    function onClass(clazz: TClass): EField;
  public
    constructor create(provider: IReflectionProvider; fieldName: string);
  end;

  TFieldHandler = class(EObject, IFieldHandler)
  protected
    function genericType(): IParameterizedElementHandler;
  public
    constructor create(provider: IReflectionProvider; Fieldzz: EField);
  end;

  TAnnotationHandler = class

  end;

  TConstructorReflector<T> = class(EObject, IConstructorReflector<T>)
  protected
    function withArgs(Classes: array of EValue): EConstrutor;
    function withoutArgs(): EConstrutor;
    function withAnyArgs(): EConstrutor;

  end;

  TAllMethodAnnotationsHandler = class(EObject, IAllMethodAnnotationsHandler)

  end;

  TMemberHandler = class(EObject, IMemberHandler)

  end;

  TAllReflectionHandler<T> = class(EObject, IAllReflectionHandler<T>)

  end;

  TMethodAnnotationHandler<T> = class(EObject, IMethodAnnotationHandler<T>)
  protected
    function withArgs(Classes: array of T): T;
    function withoutArgs(): T;
  end;

implementation

{ TAllAnnotationsHandler }

function TAllAnnotationsHandler.aField(fieldName: String): EList<EAnnotation>;
begin
  { Field field = new Mirror(provider).on(clazz).reflect().field(fieldName);
    if (field == null) {
    throw new IllegalArgumentException("could not find field " + fieldName + " at class " + clazz);

    return provider.getAnnotatedElementReflectionProvider(field).getAnnotations(); }
end;

function TAllAnnotationsHandler.atClass: EList<EAnnotation>;
begin
  // Result := FProvider.getAnnotatedElementReflectionProvider(clazz).getAnnotations();
end;

function TAllAnnotationsHandler.atMethod(methodName: String): IAllMethodAnnotationsHandler;
begin
  // return new DefaultAllMethodAnnotationsHandler(provider, clazz, methodName);
end;

constructor TAllAnnotationsHandler.create(provider: IReflectionProvider; clazz: TClass);
begin
  if (clazz = nil) then
    raise EIllegalArgumentException.create('Argument clazz cannot be null.');

  FProvider := provider;
  FClazz := clazz;
end;

{ TAllMemberHandler }

function TAllMemberHandler.annotations: EList<EAnnotation>;
begin
  // return new BackedMirrorList<Annotation>(provider.getAnnotatedElementReflectionProvider(member).getAnnotations());
end;

{ public List<Annotation> annotationsMatching(final Matcher<Annotation> matcher) {
  return annotations().matching(matcher);
}
constructor TAllMemberHandler.create(provider: IReflectionProvider { final AnnotatedElement member^ } );
begin
  { if (member == null) {
    throw new IllegalArgumentException("Argument member cannot be null");
  }
  FProvider := provider;
  // Fmember = member;
end;

{ TReflectionHandler<T> }

function TReflectionHandler<T>.Construct: IConstructorReflector<T>;
begin

end;

function TReflectionHandler<T>.Field(fieldName: string): EField;
begin

end;

function TReflectionHandler<T>.method(methodName: String): IMethodReflector;
begin
  { if ((fieldName == null) || (fieldName.trim().length() == 0))
    throw new IllegalArgumentException("fieldName cannot be null or empty.");

    return new DefaultFieldReflector(provider, fieldName).onClass(clazz); }
end;

function TReflectionHandler<T>.parentGenericType: IParameterizedElementHandler;
begin

end;

{ TParameterizedElementHandler }

function TParameterizedElementHandler.atPosition(index: Integer): TClass;
begin

end;

constructor TParameterizedElementHandler.create(provider: IReflectionProvider);
begin

end;

{ TMethodReflector }

constructor TMethodReflector.create(provider: IReflectionProvider; methodName: string);
begin

end;

function TMethodReflector.withAnyArgs: EMethod;
begin

end;

function TMethodReflector.withArgs(Classes: array of EValue): EMethod;
begin

end;

function TMethodReflector.withoutArgs: EMethod;
begin

end;

{ TFieldReflector }

constructor TFieldReflector.create(provider: IReflectionProvider; fieldName: string);
begin

end;

function TFieldReflector.onClass(clazz: TClass): EField;
begin

end;

{ TFieldHandler }

constructor TFieldHandler.create(provider: IReflectionProvider; Fieldzz: EField);
begin

end;

function TFieldHandler.genericType: IParameterizedElementHandler;
begin

end;

{ TMethodAnnotationHandler<T> }

function TMethodAnnotationHandler<T>.withArgs(Classes: array of T): T;
begin

end;

function TMethodAnnotationHandler<T>.withoutArgs: T;
begin

end;

{ TConstructorReflector<T> }

function TConstructorReflector<T>.withAnyArgs: EConstrutor;
begin

end;

function TConstructorReflector<T>.withArgs(Classes: array of EValue): EConstrutor;
begin

end;

function TConstructorReflector<T>.withoutArgs: EConstrutor;
begin

end;

end.
