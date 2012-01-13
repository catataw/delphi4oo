unit EInvoke;

interface

uses EIntf;

type
  TConstructorHandlerByArgs<T> = class(EObject, IConstructorHandler<T>)
  protected
    function withoutArgs(): T;
    function withArgs(args: array of Tobject): T;
    function bypasser(): T;
  end;

  TConstructorHandlerByConstructor<T> = class(EObject, IConstructorHandler<T>)
  protected
    function withoutArgs(): T;
    function withArgs(args: array of Tobject): T;
    function bypasser(): T;
  end;

  TInvocationHandler<T> = class(EObject, IInvocationHandler<T>)
  protected
    function method(methodName: String): IMethodHandler;
    // function cotr(): IConstructorHandler<T> function method(final method method);
    // function<C> constructor(final Constructor<C>con);ConstructorHandler<C>
    function getterFor(fieldName: String): Tobject; overload;
    function getterFor(Field: EField): Tobject; overload;
    function setterFor(fieldName: String): ISetterMethodHandler; overload;
    function setterFor(Field: EField): ISetterMethodHandler; overload;
  end;

  TSetterMethodHandler = class(EObject, ISetterMethodHandler)
  protected
    procedure withValue(Value: Tobject);
  end;

  TMethodHandlerByMethod = class(EObject, IMethodHandler)
  protected
    function withoutArgs(): Tobject;
    function withArgs(args: array of Tobject): Tobject;
  end;

  TMethodHandlerByName = class(EObject, IMethodHandler)
  protected
    function withoutArgs(): Tobject;
    function withArgs(args: array of Tobject): Tobject;
  end;

implementation

{ TConstructorHandlerByArgs<T> }

function TConstructorHandlerByArgs<T>.bypasser: T;
begin

end;

function TConstructorHandlerByArgs<T>.withArgs(args: array of Tobject): T;
begin

end;

function TConstructorHandlerByArgs<T>.withoutArgs: T;
begin

end;

{ TConstructorHandlerByConstructor<T> }

function TConstructorHandlerByConstructor<T>.bypasser: T;
begin

end;

function TConstructorHandlerByConstructor<T>.withArgs(args: array of Tobject): T;
begin

end;

function TConstructorHandlerByConstructor<T>.withoutArgs: T;
begin

end;

{ TInvocationHandler<T> }

function TInvocationHandler<T>.getterFor(Field: EField): Tobject;
begin

end;

function TInvocationHandler<T>.getterFor(fieldName: String): Tobject;
begin

end;

function TInvocationHandler<T>.method(methodName: String): IMethodHandler;
begin

end;

function TInvocationHandler<T>.setterFor(Field: EField): ISetterMethodHandler;
begin

end;

function TInvocationHandler<T>.setterFor(fieldName: String): ISetterMethodHandler;
begin

end;

{ TSetterMethodHandler }

procedure TSetterMethodHandler.withValue(Value: Tobject);
begin

end;

{ TMethodHandlerByMethod }

function TMethodHandlerByMethod.withArgs(args: array of Tobject): Tobject;
begin

end;

function TMethodHandlerByMethod.withoutArgs: Tobject;
begin

end;

{ TMethodHandlerByName }

function TMethodHandlerByName.withArgs(args: array of Tobject): Tobject;
begin

end;

function TMethodHandlerByName.withoutArgs: Tobject;
begin

end;

end.
