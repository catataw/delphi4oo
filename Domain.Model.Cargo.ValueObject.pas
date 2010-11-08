unit Domain.Model.Cargo.ValueObject;

interface

uses Generics.Collections, Domain.Shared, Domain.Model.Location;

type
  TransportStatus = (NOT_RECEIVED, IN_PORT, ONBOARD_CARRIER, CLAIMED, UNKNOWN);

  TrackingId = class(TInterfacedObject, ValueObject<TrackingId>)
  private
    FID: string;
  public
    constructor create(ID: String);
    property ID: String read FID;
    function Equals(Obj: TObject): Boolean; override;
    function sameValueAs(other: TrackingId): Boolean;
  end;

  Cargo = class(TInterfacedObject, Entity<Cargo>)
    function sameIdentityAs(other: Cargo): Boolean;
  end;

  Leg = class(TInterfacedObject, ValueObject<Leg>)
    function sameValueAs(other: Leg): Boolean;
  end;

  Itinerary = class(TInterfacedObject, ValueObject<Itinerary>)
  private
    FLegs: TList<Leg>;
    function getLegs: TList<Leg>;
  public
    constructor create(legs: TList<Leg>);
    function sameValueAs(other: Itinerary): Boolean;
    property legs: TList<Leg>read getLegs;
  end;

  RouteSpecification = class(AbstractSpecification<Itinerary>, ValueObject<RouteSpecification>)
  private
    FOrigin, FDestination: Location;
    FArrivalDeadline: TDate;
  public
    constructor create(origin, destination: Location; arrivalDeadline: TDate);
    function sameValueAs(other: RouteSpecification): Boolean;
    function isSatisfiedBy(T: Itinerary): Boolean; override;
    property origin: Location read FOrigin;
    property destination: Location read FDestination;
    property arrivalDeadline: TDate read FArrivalDeadline;
  end;

implementation

{ TrackingId }

constructor TrackingId.create(ID: String);
begin
  FID := ID
end;

function TrackingId.Equals(Obj: TObject): Boolean;
begin
  Result := self.ClassType = Obj.ClassType;
  Result := Assigned(Obj);
  Result := sameValueAs(TrackingId(Obj))
end;

function TrackingId.sameValueAs(other: TrackingId): Boolean;
begin
  Result := (Assigned(other)) and (self.ID = other.ID);
end;

{ RouteSpecification }

constructor RouteSpecification.create(origin, destination: Location; arrivalDeadline: TDate);
begin
  FOrigin := origin;
  FDestination := destination;
  FArrivalDeadline := arrivalDeadline;
end;

function RouteSpecification.isSatisfiedBy(T: Itinerary): Boolean;
begin
  // origin.sameIdentityAs(T);
end;

function RouteSpecification.sameValueAs(other: RouteSpecification): Boolean;
begin

end;

{ Cargo }

function Cargo.sameIdentityAs(other: Cargo): Boolean;
begin

end;

{ Itinerary }

constructor Itinerary.create(legs: TList<Leg>);
begin
  FLegs := legs;
end;

function Itinerary.getLegs: TList<Leg>;
begin
  Result := FLegs;
end;

function Itinerary.sameValueAs(other: Itinerary): Boolean;
begin

end;

{ Leg }

function Leg.sameValueAs(other: Leg): Boolean;
begin

end;

end.
