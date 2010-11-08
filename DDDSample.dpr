program DDDSample;

uses
  Forms,
  Domain.Model.Cargo.ValueObject in 'Domain.Model.Cargo.ValueObject.pas',
  Domain.Shared in 'Domain.Shared.pas',
  Domain.Model.Location in 'Domain.Model.Location.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;

end.
