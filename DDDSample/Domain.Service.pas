unit Domain.Service;

interface

uses
  Generics.Collections,
  Domain.Model.Cargo;

type
  RoutingService = interface
    ['{4B395BA9-8B2D-471C-B3D7-086D94AF8F61}']
    function fetchRoutesForSpecification(RouteSpecification: RouteSpecification):TList<Itinerary>;
  end;

implementation

end.
