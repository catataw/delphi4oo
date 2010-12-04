unit System.Base;

interface

uses Classes, SysUtils, System.Interfaces;

type

  TJComponent = class(TInterfacedObject, IComponent)
  end;

  TJComponentClass = class of TJComponent;

  TJModule = class abstract(TJComponent)
  private
    FID: string;
    FParentModule: TJModule;
    Fcomponents: TArray<IApplicationComponent>;
  protected
    function GetComponent(Index: string): IApplicationComponent;
    function GetComponents: TArray<IApplicationComponent>;
    procedure setComponent(Index: string; const Value: IApplicationComponent);
    procedure SetComponents(const Value: TArray<IApplicationComponent>);
    procedure preinit; virtual;
    procedure init; virtual;
    procedure configure(AConfig: string);
    procedure preloadComponents;
  public
    function beforeControllerAction(AController: TJComponent; AAction: IAction): Boolean;
    procedure afterControllerAction(AController: TJComponent; AAction: IAction);
    constructor Create(AID: string; AParent: TJModule);
    property ID: string read FID write FID;
    property ParentModule: TJModule read FParentModule;
    property Component[Index: string]: IApplicationComponent read GetComponent write setComponent;
    property Components: TArray<IApplicationComponent>read GetComponents write SetComponents;
  end;

  TJApplication = class abstract(TJModule)
  private
    FName: string;
    function GetDateFormatter: IApplicationComponent;
    function GetNumberFormatter: IApplicationComponent;
    function GetSecurityManager: IApplicationComponent;
  protected
    function getConnection: IApplicationComponent;
    procedure registerCoreComponents; virtual;
  public
    constructor Create(AConfig: string); virtual;
    procedure processRequest; virtual; abstract;
    procedure run;
    function shutdow: Integer;
    property Connection: IApplicationComponent read getConnection;
    property NumberFormatter: IApplicationComponent read GetNumberFormatter;
    property DateFormatter: IApplicationComponent read GetDateFormatter;
    property SecurityManager: IApplicationComponent read GetSecurityManager;
    property Name: string read FName write FName;

  end;

  TJApplicationClass = class of TJApplication;

  TJApplicationComponent = class(TJComponent, IApplicationComponent)
  var
    FInitialized: Boolean;
  protected
    procedure init; virtual;
    function IsInitialized: Boolean;
  end;

  TJAttribute = class(TCustomAttribute)

  end;

  TJModel = class(TJComponent)
  private
    FAttributeNames: TStringList;
    FAttributeLabels: TStringList;
    FErrors: TStringList;
    FScenario: String;
    function getFAttributeLabels: TStringList;
    function getFAttributeNames: TStringList;
    function getFErrors: TStringList;
    function getFValidators: TStringList;
  protected
    function getAttributeNames: TStringList;
    function beforeValidate: Boolean;
    function afterValidate: Boolean;
    function createValidators: TStringList;
  public
    function validate(const Args: array of string): Boolean;
    procedure clearErrors(const Args: array of string);
    function generateAttributeLabel(AName: string): string;
    property AttributeNames: TStringList read getFAttributeNames write FAttributeNames;
    property AttributeLabels: TStringList read getFAttributeLabels write FAttributeLabels;
    property Validators: TStringList read getFValidators;
    property Errors: TStringList read getFErrors write FErrors;
    property Scenario: String read FScenario write FScenario;
  end;

  JException = class(Exception);

implementation

uses JBase, Forms;

{ CApplicationComponent }

procedure TJApplicationComponent.init;
begin
  FInitialized := true;
end;

function TJApplicationComponent.IsInitialized: Boolean;
begin
  Result := FInitialized;
end;

{ CModel }

function TJModel.afterValidate: Boolean;
begin

end;

function TJModel.beforeValidate: Boolean;
begin

end;

procedure TJModel.clearErrors(const Args: array of string);
begin

end;

function TJModel.createValidators: TStringList;
begin

end;

function TJModel.generateAttributeLabel(AName: string): string;
begin

end;

function TJModel.getAttributeNames: TStringList;
begin

end;

function TJModel.getFAttributeLabels: TStringList;
begin
  Result := FAttributeLabels;
end;

function TJModel.getFAttributeNames: TStringList;
begin
  Result := FAttributeNames;
end;

function TJModel.getFErrors: TStringList;
begin
  Result := FErrors;
end;

function TJModel.getFValidators: TStringList;
begin

end;

function TJModel.validate(const Args: array of string): Boolean;
begin

end;

{ JApplication }

constructor TJApplication.Create(AConfig: string);
begin
  TJBase.setApplication(self);
  preinit;
  registerCoreComponents;
  configure(AConfig);
  preloadComponents;
  init;
end;

function TJApplication.getConnection: IApplicationComponent;
begin
  Result := GetComponent('connection');
end;

function TJApplication.GetDateFormatter: IApplicationComponent;
begin

end;

function TJApplication.GetNumberFormatter: IApplicationComponent;
begin

end;

function TJApplication.GetSecurityManager: IApplicationComponent;
begin
  Result := GetComponent('securityManager')
end;

procedure TJApplication.registerCoreComponents;
begin
  // setComponent('connection',IDbConnection);
end;

procedure TJApplication.run;
begin

  processRequest;

end;

function TJApplication.shutdow: Integer;
begin

end;

{ TJModule }

procedure TJModule.afterControllerAction(AController: TJComponent; AAction: IAction);
begin

end;

function TJModule.beforeControllerAction(AController: TJComponent; AAction: IAction): Boolean;
begin
  Result := true;
end;

procedure TJModule.configure(AConfig: string);
begin

end;

constructor TJModule.Create(AID: string; AParent: TJModule);
begin
  FID := AID;
  FParentModule := AParent;
  preinit;
  init;
end;

function TJModule.GetComponent(Index: string): IApplicationComponent;
begin

end;

function TJModule.GetComponents: TArray<IApplicationComponent>;
begin

end;

procedure TJModule.init;
begin

end;

procedure TJModule.preinit;
begin

end;

procedure TJModule.preloadComponents;
begin

end;

procedure TJModule.setComponent(Index: string; const Value: IApplicationComponent);
begin

end;

procedure TJModule.SetComponents(const Value: TArray<IApplicationComponent>);
begin

end;

end.
