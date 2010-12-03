unit Domain.Model.Location;

interface

uses Domain.Shared, Generics.Collections;

type
  Location = class;
  UnLocode = class;

  LocationRepository = interface
    ['{8B6C1FD3-770A-453B-A871-CBDCABE7B7B1}']
    function find(UnLocode: UnLocode): Location;
    function findAll: TList<Location>;
  end;

  Location = class(TInterfacedObject, Entity<Location>)
    function sameIdentityAs(other: Location): boolean;
  end;

  UnLocode = class(TInterfacedObject, ValueObject<UnLocode>)
  private
    Funlocode: string;
  public
    function sameValueAs(other: UnLocode): boolean;
    constructor Create(countryAndLocation: string);
    property UnLocode: string read Funlocode;
  end;

implementation

{ Location }

function Location.sameIdentityAs(other: Location): boolean;
begin
   Result :=true
end;

{ UnLocode }

constructor UnLocode.Create(countryAndLocation: string);
begin
  Funlocode := countryAndLocation;
end;

function UnLocode.sameValueAs(other: UnLocode): boolean;
begin
  Result:=true
end;

end.
