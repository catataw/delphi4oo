unit Domain.Model.Cargo;

interface

uses Generics.Collections,
  Domain.Shared,
  Domain.Model.Location,
  Domain.Model.Voyage;

type

  TransportStatus = (NOT_RECEIVED, IN_PORT, ONBOARD_CARRIER, CLAIMED, UNKNOWN);
  RoutingStatus = (NOT_ROUTED, ROUTED, MISROUTED);

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

  HandlingActivity = class(TInterfacedObject, ValueObject<HandlingActivity>)
    function sameValueAs(other: HandlingActivity): Boolean;
  end;

  Leg = class(TInterfacedObject, ValueObject<Leg>)
  private
    FloadLocation: Location;
    FunloadLocation: Location;
    FloadTime: TDate;
    FunloadTime: TDate;
    Fvoyage: Voyage;
  public
    function sameValueAs(other: Leg): Boolean;
    property Voyage: Voyage read Fvoyage;
    property loadLocation: Location read FloadLocation;
    property unloadLocation: Location read FunloadLocation;
    property loadTime: TDate read FloadTime;
    property unloadTime: TDate read FunloadTime;
    constructor create(Voyage: Voyage; loadLocation: Location; unloadLocation: Location; loadTime: TDate;
      unloadTime: TDate);
  end;

  Itinerary = class(TInterfacedObject, ValueObject<Itinerary>)
  private
    FLegs: TList<Leg>;
    function getLegs: TList<Leg>;
  public
    constructor create(legs: TList<Leg>);
    function sameValueAs(other: Itinerary): Boolean;
    property legs: TList<Leg>read getLegs;
    function initialDepartureLocation: Location;
    function finalArrivalLocation: Location;
    function finalArrivalDate: TDate;
    function lastLeg: Leg;
    function isExpected: Boolean;
  end;

  RouteSpecification = class(AbstractSpecification<Itinerary>, ValueObject<RouteSpecification>)
  private
    FOrigin: Location;
    FDestination: Location;
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
  Result := ((not Assigned(T)) and (origin.sameIdentityAs(T.initialDepartureLocation)) and
    (destination.sameIdentityAs(T.finalArrivalLocation)) and (arrivalDeadline < T.finalArrivalDate));
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

function Itinerary.finalArrivalDate: TDate;
begin

end;

function Itinerary.finalArrivalLocation: Location;
begin
  if legs.Count = 0 then
    Result := nil
  else
    Result := lastLeg.unloadLocation;

end;

function Itinerary.getLegs: TList<Leg>;
begin
  Result := FLegs;
end;

function Itinerary.initialDepartureLocation: Location;
begin
  if legs.Count = 0 then
    Result := nil
  else
    Result := legs.Items[0].loadLocation;
end;

function Itinerary.isExpected: Boolean;
begin

end;

function Itinerary.lastLeg: Leg;
begin
  if legs.Count = 0 then
    Result := nil
  else
    Result := legs.Items[legs.Count - 1];
end;

function Itinerary.sameValueAs(other: Itinerary): Boolean;
begin

end;

{ Leg }

constructor Leg.create(Voyage: Voyage; loadLocation, unloadLocation: Location; loadTime, unloadTime: TDate);
begin
  Fvoyage := Voyage;
  FloadLocation := loadLocation;
  FunloadLocation := unloadLocation;
  FloadTime := loadTime;
  FunloadTime := unloadTime;
end;

function Leg.sameValueAs(other: Leg): Boolean;
begin

end;

{ HandlingActivity }

function HandlingActivity.sameValueAs(other: HandlingActivity): Boolean;
begin

end;

end.
