unit Domain.Model.Voyage;

interface

uses Domain.Shared;

type
  Voyage = class(TInterfacedObject, Entity<Voyage>)
    function sameIdentityAs(other: Voyage): boolean;
  end;

implementation

{ Location }

function Voyage.sameIdentityAs(other: Voyage): boolean;
begin

end;

end.
