unit EIntf;

interface

uses
  Rtti, SysUtils, Generics.Collections;

type

  EField = class(TRttiField);
  EMethod = class(TRttiMethod);
  EConstrutor = class(TRttiMethod);
  EAnnotation = class(TCustomAttribute);
  EObject = class(TInterfacedObject);
  EList<T> = class(TList<T>);
  EValue = TValue;

  EMatchType = (PERFECT, MATCH, DONT_MATCH);

  EIllegalArgumentException = class(Exception);
  ERttiException = class(Exception);
  EReflectionProviderException = class(ERttiException);
  EMethodNonInterceptedException = class(EReflectionProviderException);

  IFieldSetter = interface
    ['{540D7839-1C4B-42BA-B8B7-BE4CDF2BFFB1}']
    procedure withValue(Value: Tobject);
  end;

  ISetterHandler = interface
    ['{C6B2EE3E-4B08-42B0-8B41-36F76178B3F7}']
    function FieldSetter(fieldName: string): EField; overload;
    function FieldSetter(Field: EField): EField; overload;
  end;

  IGetterHandler = interface
    ['{96AE2CCB-85B1-4176-93EC-7947BCBF1B7A}']
    function FieldGetter(fieldName: string): EField; overload;
    function FieldGetter(Field: EField): EField; overload;
  end;

  IMethodReflector = interface
    ['{BA67F2C6-2DBF-49EA-9979-3C199493BD1E}']
    function withoutArgs(): EMethod;
    function withArgs(Classes: array of EValue): EMethod;
    function withAnyArgs(): EMethod;
  end;

  IFieldReflector = interface
    ['{D7C3F9EC-FDB0-4C12-9C9F-DEF73B0CF55A}']
    function onClass(clazz: TClass): EField;
  end;

  IConstructorReflector<T> = interface
    ['{E40C0BD4-4295-4AA0-961F-93D87AA9C0AF}']
    function withArgs(Classes: array of EValue): EConstrutor;
    function withoutArgs(): EConstrutor;
    function withAnyArgs(): EConstrutor;
  end;

  IParameterizedElementHandler = interface
    ['{86E73F1A-1B31-44D8-8114-2109A75594B1}']
    function atPosition(index: Integer): TClass;
  end;

  IReflectionHandler<T> = interface
    ['{E56C5E39-8C15-4AAC-8EE2-732299150052}']
    function Field(fieldName: string): EField;
    function Method(methodName: String): IMethodReflector;
    function Construct(): IConstructorReflector<T>;
    // function <A> AnnotationHandler<? extends A> annotation(final Class<A> annotation);
    function parentGenericType(): IParameterizedElementHandler;
  end;

  // IMethodAnnotationHandler<T extends Annotation>
  IMethodAnnotationHandler<T> = interface
    ['{8BB73FCE-A32F-48A0-840D-97B904762182}']
    function withArgs(Classes: array of T): T;
    function withoutArgs(): T;

  end;

  IMemberHandler = interface
    ['{69E12745-9311-4271-AA7A-5FD3F294BC03}']
    // public <T extends Annotation> T annotation(final Class<T> annotation);
  end;

  IFieldHandler = interface
    ['{5C399CE5-BCCE-490E-A164-F3F2E8E03905}']
    // public <T extends Annotation> T annotation(Class<T> annotation);
    function genericType(): IParameterizedElementHandler;
  end;

  // IAnnotationHandler<T extends Annotation>
  IAnnotationHandler<T> = interface
    ['{81F8CCFE-9A50-4CC8-9DAC-7582577DA414}']
    function aField(fieldName: String): T;
    function atMethod(methodName: String): IMethodAnnotationHandler<T>;
    function atClass(): T;
  end;

  IAllReflectionHandler<T> = interface
    ['{8E0558E7-D463-4FC9-9AA9-AAC768DDDF99}']
    { public MirrorList<Field> fields();
      public MirrorList<Method> methods();
      public MirrorList<Constructor<T>> constructors();
      public AllAnnotationsHandler annotations();
      public MirrorList<Method> setters();
      public MirrorList<Method> getters(); }
  end;

  IAllMethodAnnotationsHandler = interface
    { public List<Annotation> withoutArgs();
      public List<Annotation> withArgs(final Class<?>... classes); }
  end;

  IAllMemberHandler = interface
    ['{09070944-8133-4C9A-8C7C-C3E109DD673A}']
    function annotations(): EList<EAnnotation>;
  end;

  IAllAnnotationsHandler = interface
    ['{C1921D1B-C432-4268-9965-DD6C8C8DF869}']
    function atClass(): EList<EAnnotation>;
    function aField(fieldName: String): EList<EAnnotation>;
    function atMethod(methodName: String): IAllMethodAnnotationsHandler;
  end;

  IMethodInterceptor = interface
    ['{80099B24-6C66-4A33-860B-ACABD78547A0}']
    function accepts(Method: TMethod): boolean;
    // Object intercepts(final Object target, final Method method, final Object... parameters);
  end;

  IProxyHandler<T> = interface
    ['{F66F4865-8C04-4FEF-A3B0-2F56F570FFF0}']
    function interceptingWith(methodInterceptor: array of IMethodInterceptor): T;
  end;

  IReflectionElementReflectionProvider = interface
    ['{48568FB0-8694-417C-83C0-C14721927786}']
    procedure setAccessible();
  end;


   IMethodReflectionProvider = interface(IReflectionElementReflectionProvider)
    ['{1C38B406-2386-42D6-B00F-0818716FE0BA}']
    // Class<?>[] getParameters();
    // Object invoke(Object[] args);
  end;

  IGenericTypeAccessor = interface
    ['{A665FBD6-2ADC-4B06-9C03-75A2AF1CD8AC}']
    // Type getGenericTypes()
  end;

  IFieldReflectionProvider = interface(IReflectionElementReflectionProvider)
    ['{2BDE9194-8EEF-4502-BDDF-F8523C7616F0}']
    procedure setValue(Value: Tobject);
    function getValue(): Tobject;
  end;

  IClassReflectionProvider<T> = interface
    ['{2DB01D22-9218-45E1-BFC3-7F1D34B50808}']
    { Class<T> reflectClass();
      Field reflecField(String fieldName);
      Method reflectMethod(String methodName, Class<?>[] argumentTypes);
      Constructor<T> reflectConstructor(Class<?>[] argumentTypes);
      List<Field> reflectAllFields();
      List<Method> reflectAllMethods();
      List<Constructor<T>> reflectAllConstructors(); }
  end;

  IReflectionProvider = interface
    ['{CCFD5894-BC21-41DB-875A-0DE4A00D0B57}']
      function getClassReflectionProvider(className: String): IClassReflectionProvider<TObject>;overload;
      function getClassReflectionProvider(clazz:Tclass):IClassReflectionProvider<TObject>;overload;
      //function getConstructorReflectionProvider(Class<T> clazz, Constructor<T> constructor);ConstructorReflectionProvider
      //function getConstructorBypassingReflectionProvider(final Class<T> clazz); ConstructorBypassingReflectionProvider
      function getMethodReflectionProvider(target:TObject;clazz:Tclass; method:EMethod):IMethodReflectionProvider;
      function geFieldReflectionProvider(target :TObject;clazz :Tclass; field:EField):IFieldReflectionProvider;
      //function getAnnotatedElementReflectionProvider(AnnotatedElement element):IAnnotatedElementReflectionProvider;
      //function getParameterizedElementProvider(Accessor :IGenericTypeAccessor):IParameterizedElementReflectionProvider;
      function getClassGenericTypeAccessor(clazz :TClass):IGenericTypeAccessor;
      function geFieldGenericTypeAccessor(field:EField):IGenericTypeAccessor;
      //function getProxyReflectionProvider(Class<?> clazz, List<Class<?>> interfaces,MethodInterceptor... methodInterceptors):ProxyReflectionProvider;
  end;


  IProxyReflectionProvider = interface
    ['{08AE577E-C64B-4EA4-9791-8FE2E9AFE7F1}']
    function createProxy(): Tobject;
  end;

  IParameterizedElementReflectionProvider = interface
    ['{0C4830C3-E9ED-4820-8BEF-41E359AE7B5B}']
    // Class<?> getTypeAtPosition(int index);
  end;


  IConstructorReflectionProvider<T> = interface(IReflectionElementReflectionProvider)
    ['{C49D9FBA-D7BD-48D2-9604-4F687DA6098B}']
    // T instantiate(final Object... args);
    // Class<?>[] getParameters();
  end;

  IConstructorBypassingReflectionProvider<T> = interface
    ['{DB7F15B9-7E79-4EDD-80C4-C5CAFADB8A1C}']
    function bypassConstructor(): T;
  end;



  IAnnotatedElementReflectionProvider = interface
    ['{98B858F1-53B8-454B-89F3-BC8200CC7C29}']

    { List<Annotation> getAnnotations();
      <T extends Annotation> T getAnnotation(Class<T> annotation);
    }
  end;

  IMirrorList<T> = interface
    // extends List<T>
    ['{95E83EE8-C049-4A7B-B2BD-0D23A5B2568F}']
  end;

  IMatcher<T> = interface
    // ['{EB6EBDAB-5A34-4863-BBC0-3431C74FB781}']
    // boolean accepts(T element);
  end;

  { public interface Mapper<F, T> {
    public T map(final F element);
  }

  ISetterMethodHandler = interface
    ['{DF80F7F0-03B5-4552-B57C-4BC75BF510A0}']
    procedure withValue(Value: Tobject);
  end;

  IMethodHandler = interface
    ['{6258F3B6-ACBA-4714-9086-B13C5B8FF65C}']
    function withoutArgs(): Tobject;
    function withArgs(args: array of Tobject): Tobject;
  end;

  IInvocationHandler<T> = interface
    ['{F718FD55-A0A8-4C82-A15B-0A70A35CA34E}']
    function Method(methodName: String): IMethodHandler;
    // function cotr(): IConstructorHandler<T> function method(final method method);
    // function<C> constructor(final Constructor<C>con);ConstructorHandler<C>
    function getterFor(fieldName: String): Tobject; overload;
    function getterFor(Field: EField): Tobject; overload;
    function setterFor(fieldName: String): ISetterMethodHandler; overload;
    function setterFor(Field: EField): ISetterMethodHandler; overload;
  end;

  IConstructorHandler<T> = interface
    ['{808C3B02-CF9B-4B90-9BB6-9085B42597F4}']
    function withoutArgs(): T;
    function withArgs(args: array of Tobject): T;
    function bypasser(): T;
  end;

  IClassController<T> = interface
    ['{3807F5A5-FBEC-4A18-B17C-EEBFE1835D01}']
    function invoke(): IInvocationHandler<T>;
    function setter(): ISetterHandler;
    function getter(): IGetterHandler;
    function reflect(): IReflectionHandler<T>;
    function reflectAll(): IAllReflectionHandler<T>;

  end;

  IMemberController = interface
    ['{81538963-DAA1-4DA7-A1B9-A9C3A89AF916}']
    function reflect(): IMemberHandler;
    function reflectAll(): IAllMemberHandler;
  end;

  IFieldController = interface
    ['{1059DFCB-05F5-46F1-956E-262C41C475A1}']
    function reflect(): IFieldHandler;
    function reflectAll(): IAllMemberHandler;
  end;

  IAccessorsController = interface
    ['{C29DF497-102F-4EB3-9FFD-D587EF78A78F}']
    function invoke(): IInvocationHandler<Tobject>;
    function setter(): ISetterHandler;
    function getter(): IGetterHandler;
  end;

implementation

end.
