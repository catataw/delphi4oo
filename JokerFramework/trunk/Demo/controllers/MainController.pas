unit MainController;

interface

uses
  Gui.Core;

type

  TMainController = class(TJController)
  public
    procedure ActionPrincipal;
    procedure ActionSalvar;
  end;

implementation

uses JBase;

{ TControllerPrincipal }

procedure TMainController.ActionPrincipal;
begin
  render('frmPrincipal', [])
end;

procedure TMainController.ActionSalvar;
begin
{create pessoas = new
 pessoas.atributos = Paramentros
 repositorio.save(Pessoas);
}

end;

initialization

TJBase.registerModule(TMainController);

end.
