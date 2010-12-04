unit UFrmPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids;

type
  TfrmPrincipal = class(TForm)
    salvar: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    procedure salvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TfrmPrincipal.salvarClick(Sender: TObject);
begin
  // sendCommand(Pessoa/Salvar,[aaa=hau hau, eeee=hau ha, cccc=hua hau, eeee=hauh a])
end;

initialization

RegisterClass(TfrmPrincipal);

end.
