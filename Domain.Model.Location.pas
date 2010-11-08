unit Domain.Model.Location;

interface

uses Domain.Shared;

type
  Location = class(TInterfacedObject, Entity<Location>)
    function sameIdentityAs(other: Location): boolean;
  end;

implementation

{ Location }

function Location.sameIdentityAs(other: Location): boolean;
begin

end;

end.
