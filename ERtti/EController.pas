unit EController;

interface

uses EIntf;

type

  TAccessorsController = class(EObject, IAccessorsController)
  protected
    function invoke(): IInvocationHandler<Tobject>;
    function setter(): ISetterHandler;
    function getter(): IGetterHandler;
  end;

  TClassController<T> = class(EObject, IClassController<T>)
  protected
    function invoke(): IInvocationHandler<T>;
    function setter(): ISetterHandler;
    function getter(): IGetterHandler;
    function reflect(): IReflectionHandler<T>;
    function reflectAll(): IAllReflectionHandler<T>;
  end;

  TFieldController = class(EObject, IFieldController)
  protected
    function reflect(): IFieldHandler;
    function reflectAll(): IAllMemberHandler;
  end;

  TMemberController = class(EObject, IMemberController)
  protected
    function reflect(): IMemberHandler;
    function reflectAll(): IAllMemberHandler;
  end;

  TProxyHandler<T> = class(EObject, IProxyHandler<T>)
  protected
    function interceptingWith(methodInterceptor: array of IMethodInterceptor): T;
  end;

implementation

{ TAccessorsController }

function TAccessorsController.getter: IGetterHandler;
begin

end;

function TAccessorsController.invoke: IInvocationHandler<Tobject>;
begin

end;

function TAccessorsController.setter: ISetterHandler;
begin

end;

{ TFieldController }

function TFieldController.reflect: IFieldHandler;
begin

end;

function TFieldController.reflectAll: IAllMemberHandler;
begin

end;

{ TMemberController }

function TMemberController.reflect: IMemberHandler;
begin

end;

function TMemberController.reflectAll: IAllMemberHandler;
begin

end;

{ TClassController<T> }

function TClassController<T>.getter: IGetterHandler;
begin

end;

function TClassController<T>.invoke: IInvocationHandler<T>;
begin

end;

function TClassController<T>.reflect: IReflectionHandler<T>;
begin

end;

function TClassController<T>.reflectAll: IAllReflectionHandler<T>;
begin

end;

function TClassController<T>.setter: ISetterHandler;
begin

end;

{ TProxyHandler<T> }

function TProxyHandler<T>.interceptingWith(methodInterceptor: array of IMethodInterceptor): T;
begin

end;

end.
