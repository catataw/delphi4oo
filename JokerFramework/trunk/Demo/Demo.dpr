program Demo;

uses
  Classes,
  Forms,
  JBase,
  System.Base,
  Gui.Core,
  UFrmPrincipal in 'views\UFrmPrincipal.pas' { frmPrincipal },
  MainController in 'controllers\MainController.pas';

{$R *.res}

begin

  TJBase.createApplication('TJGUIApplication').run;

end.
