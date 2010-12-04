unit Gui.Core;

interface

uses
  Classes, Rtti, System.Base, System.Interfaces, SysUtils, Controls;

type

  TJGUIApplication = class(TJApplication)
  private
    FDefaultController: string;
    FController: IController;
    FLayout : string;
    FLayoutInstance : TControl;
    function GetAuthManager: IApplicationComponent;
    function getDefaultController: string;
    function GetLayout: string;
    function getLayoutInstance: TControl;
    procedure setLayoutInstance(const Value: TControl);
  protected
    function parseActionParams(APathInfo: string): string;
    function getSession: IApplicationComponent;
    function getUser: IApplicationComponent;
    procedure registerCoreComponents; override;
    procedure Init; override;
  public
    constructor create;reintroduce;overload;
    function createController(ARoute: string; AOwner: TJModule = nil): IController;
    function findModule(AID: string): TJModule;
    procedure processRequest; override;
    procedure runController(ARoute: string);
    procedure createRoute(ACommand: string); overload;
    procedure createRoute(ACommand: string; args: array of TObject); overload;
    property DefaultController: string read getDefaultController write FDefaultController;
    property Session: IApplicationComponent read getSession;
    property User: IApplicationComponent read getUser;
    property AuthManager: IApplicationComponent read GetAuthManager;
    property Controller: IController read FController write FController;
    property Layout: string read GetLayout;
    property LayoutInstance: TControl read getLayoutInstance write setLayoutInstance;

  end;

  TJBaseController = class abstract(TJComponent, IController)
  protected
    procedure Init; virtual; abstract;
    procedure run(AActionID: string); virtual; abstract;
  public
    function getView(AViewName: string): string; virtual; abstract;
    function renderFile(AViewName: string; AData: array of TValue; AReturn: Boolean = false): TComponent;
    function renderInternal(AViewName: string; AData: array of TValue; AReturn: Boolean = false): TComponent;
  end;

  TJAction = class abstract(TJComponent, IAction)
  private
    FID: string;
    FController: TJBaseController;
  protected
    function getId: string;
    function getController: IController;
    procedure run; virtual;
  public
    property ID: String read getId;
    property Controller: IController read getController;
    constructor create(AController: IController; AID: string);
  end;

  TJInlineAction = class(TJAction)
  protected
    procedure run; override;
  end;

  TJController = class(TJBaseController)
  private
    FDefaultAction: string;
    FAction: IAction;
    FModule: TJModule;
    FID: string;
  public
    // function actions:
    // function createActionFromMap
    // function processOutput(AOutput : TComponent):TComponent
    constructor create(AID: string; AModule: TJModule = nil);
    function beforeAction(AAction: IAction): Boolean;
    function createAction(AActionID: string): IAction;
    function render(AView: string; AData: array of TValue; Return: Boolean = false): TControl;
    function renderPartial(AView: string; AData: array of TValue; Return: Boolean = false): TControl;
    procedure afterAction(AAction: IAction);
    procedure Init; override;
    procedure missingAction(AActionID: string);
    procedure run(AActionID: string); override;
    procedure runAction(AAction: IAction);
    procedure runActionWithFilters(AAction: IAction);
    procedure SendCommand(ACommand: string); overload;
    procedure SendCommand(ACommand: string; args: array of TObject); overload;
    property Action: IAction read FAction write FAction;
    property DefaultAction: string read FDefaultAction write FDefaultAction;
    property ID: string read FID;
    property Module: TJModule read FModule;
  end;

  TJControllerClass = class of TJController;

implementation

uses JBase, Forms;

{ TJGUIApplication }

constructor TJGUIApplication.create;
begin
  //inherited;
end;

function TJGUIApplication.createController(ARoute: string; AOwner: TJModule = nil): IController;
var
  Owner: TJModule;
  Route: string;
  ID, className: string;
  AClassController: TJComponentClass;
begin
  if Trim(ARoute) = emptystr then
    Route := DefaultController;
  if not Assigned(AOwner) then
    Owner := nil;

  Route := Route + '/';
  ID := Copy(Route, 0, pos('/', Route) - 1);
  className := 'T' + ID + 'Controller';
  AClassController := TJBase.findModule(className);
  if Assigned(AClassController) then
    result := TJControllerClass(AClassController).create(ID, Owner);

end;

function TJGUIApplication.findModule(AID: string): TJModule;
begin

end;

function TJGUIApplication.GetAuthManager: IApplicationComponent;
begin
  result := GetComponent('authManager')

end;

function TJGUIApplication.getDefaultController: string;
begin
  if FDefaultController = emptystr then
    result := 'Main'
  else
    result := FDefaultController;
end;

function TJGUIApplication.GetLayout: string;
begin
  Result := FLayout;
end;

function TJGUIApplication.getLayoutInstance: TControl;
begin
 if Assigned(FLayoutInstance) then
   Result := FLayoutInstance;
 else
 begin
   
 end;
 
end;

function TJGUIApplication.getSession: IApplicationComponent;
begin
  result := GetComponent('session')
end;

function TJGUIApplication.getUser: IApplicationComponent;
begin
  result := GetComponent('user')
end;

procedure TJGUIApplication.Init;
begin
  inherited;

end;

function TJGUIApplication.parseActionParams(APathInfo: string): string;
begin

end;

procedure TJGUIApplication.processRequest;
var
  Route: string;
begin
  inherited;
  // =$this->getUrlManager()->parseUrl($this->getRequest());
  runController(Route)
end;

procedure TJGUIApplication.registerCoreComponents;
begin
  inherited;
  // session
  // user
  // authManager
end;

procedure TJGUIApplication.runController(ARoute: string);
var
  AController, AOldController: IController;
begin
  AController := createController(ARoute);
  AOldController := FController;
  FController := AController;
  if Assigned(AController) then
  begin
    AController.Init;
    AController.run(parseActionParams(ARoute));
    FController := AOldController;
  end
  else
    raise JException.create('Unable to resolve the request');

end;

procedure TJGUIApplication.setLayoutInstance(const Value: TControl);
begin
  
end;

procedure TJGUIApplication.createRoute(ACommand: string);
begin

end;

procedure TJGUIApplication.createRoute(ACommand: string; args: array of TObject);
begin

end;

{ TJBaseController }

function TJBaseController.renderFile(AViewName: string; AData: array of TValue; AReturn: Boolean): TComponent;
begin

end;

function TJBaseController.renderInternal(AViewName: string; AData: array of TValue; AReturn: Boolean): TComponent;
begin

end;

{ TJAction }

constructor TJAction.create(AController: IController; AID: string);
begin
  FID := AID;
  FController := AController as TJBaseController;
end;

function TJAction.getController: IController;
begin
  result := FController;
end;

function TJAction.getId: string;
begin
  result := FID;
end;

procedure TJAction.run;
begin

end;

procedure TJController.afterAction(AAction: IAction);
begin

end;

function TJController.beforeAction(AAction: IAction): Boolean;
begin
  result := true;
end;

constructor TJController.create(AID: string; AModule: TJModule = nil);
begin
  FDefaultAction := 'principal';
  FID := AID;
  FModule := AModule
end;

function TJController.createAction(AActionID: string): IAction;
var
  ActionID: string;
begin
  if (AActionID = emptystr) then
    ActionID := DefaultAction;
  // if(method_exists($this,'action'.$actionID) && strcasecmp($actionID,'s')) then
  result := TJInlineAction.create(self, ActionID);
  // else
  // return $this->createActionFromMap($this->actions(),$actionID,$actionID);
end;

procedure TJController.Init;
begin

end;

procedure TJController.missingAction(AActionID: string);
begin

end;

function TJController.render(AView: string; AData: array of TValue; Return: Boolean): TControl;
var
  output:TControl;
begin
  output := TForm(renderPartial(AView,AData,Return));
  if Return then
    Result := output
  else
  begin
    (output as TForm).ShowModal;
  end;
 end;

function TJController.renderPartial(AView: string; AData: array of TValue; Return: Boolean): TControl;
var
  lFormClass: TFormClass;
begin
  lFormClass := TFormClass(GetClass('T'+AView));
  if lFormClass = nil then
    Result := nil
  else
    Result := TForm(lFormClass.Create(Application));

end;

procedure TJController.run(AActionID: string);
var
  AAction: IAction;
  parent: TJModule;
begin
  AAction := createAction(AActionID);
  if Assigned(AAction) then
  begin
    parent := Module;
    if not Assigned(parent) then
    begin
      parent := TJBase.FApp;
    end;
    if parent.beforeControllerAction(self, AAction) then
    begin
      runActionWithFilters(AAction); // $this->filters()
      parent.afterControllerAction(self, AAction);
    end;
  end
  else
  begin
    missingAction(AActionID);
  end;

end;

procedure TJController.runAction(AAction: IAction);
var
  PriorAction: IAction;
begin
  PriorAction := Action;
  Action := AAction;
  if beforeAction(AAction) then
  begin
    AAction.run;
    afterAction(AAction);
  end;
  Action := PriorAction;
end;

procedure TJController.runActionWithFilters(AAction: IAction);
begin
  runAction(AAction);
end;

procedure TJController.SendCommand(ACommand: string);
begin

end;

procedure TJController.SendCommand(ACommand: string; args: array of TObject);
begin

end;

{ TJInlineAction }

procedure TJInlineAction.run;
var
  method: string;
var
  ctx: TRttiContext;
  m: TRttiMethod;
  objType: TRttiType;
begin
  method := 'Action' + getId;
  ctx := TRttiContext.create;
  objType:= ctx.GetType(FController.ClassType);
  m := objType.GetMethod(method);
  m.Invoke(FController,[]);
end;

initialization

TJBase.registerModule(TJGUIApplication);

finalization

// UnRegisterClass(TJGUIApplication);

end.
