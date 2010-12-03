program DDDSample;

uses
  Forms,
  Domain.Model.Cargo in 'Domain.Model.Cargo.pas',
  Domain.Model.Location in 'Domain.Model.Location.pas',
  Domain.Model.Voyage in 'Domain.Model.Voyage.pas',
  Domain.Shared in 'Domain.Shared.pas',
  Domain.Service in 'Domain.Service.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;

end.
