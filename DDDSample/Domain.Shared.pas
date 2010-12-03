unit Domain.Shared;

interface

type

  Entity<T> = interface
    ['{2818236C-F34E-45BD-94E9-DF5F3BF7A3BD}']
    function sameIdentityAs(other: T): boolean;
  end;

  ValueObject<T> = interface
    ['{3EFE323E-78EA-44B9-B615-D1AE7D223F10}']
    function sameValueAs(other: T): boolean;
  end;

  DomainEvent<T> = interface
    ['{8829FB3B-3C6C-43B7-B07F-1EB649D2B77D}']
    function sameEventAs(other: T): boolean;
  end;

  Specification<T> = interface
    ['{57DAF1C4-8828-4414-A23E-4A815651592B}']
    function isSatisfiedBy(T: T): boolean;
    function _And(Specification: Specification<T>): Specification<T>;
    function _OR(Specification: Specification<T>): Specification<T>;
    function _Not(Specification: Specification<T>): Specification<T>;
  end;

  AbstractSpecification<T> = class(TInterfacedObject, Specification<T>)
  public
    function isSatisfiedBy(T: T): boolean; virtual; abstract;
    function _And(Specification: Specification<T>): Specification<T>;
    function _OR(Specification: Specification<T>): Specification<T>;
    function _Not(Specification: Specification<T>): Specification<T>;
  end;

  AndSpecification<T> = class(AbstractSpecification<T>)
  private
    FSpec1, FSpec2: Specification<T>;
  public
    constructor create(spec1: Specification<T>; spec2: Specification<T>);
    function isSatisfiedBy(T: T): boolean; override;
  end;

  OrSpecification<T> = class(AbstractSpecification<T>)
  private
    FSpec1, FSpec2: Specification<T>;
  public
    constructor create(spec1: Specification<T>; spec2: Specification<T>);
    function isSatisfiedBy(T: T): boolean; override;
  end;

  NotSpecification<T> = class(AbstractSpecification<T>)
  private
    FSpec1: Specification<T>;
  public
    constructor create(spec1: Specification<T>);
    function isSatisfiedBy(T: T): boolean; override;
  end;

implementation

{ AbstractSpecification<T> }

function AbstractSpecification<T>._And(Specification: Specification<T>): Specification<T>;
begin
  Result := AndSpecification<T>.create(self, Specification)
end;

function AbstractSpecification<T>._Not(Specification: Specification<T>): Specification<T>;
begin

end;

function AbstractSpecification<T>._OR(Specification: Specification<T>): Specification<T>;
begin

end;

{ AndSpecification<T> }

constructor AndSpecification<T>.create(spec1, spec2: Specification<T>);
begin
  FSpec1 := spec1;
  FSpec2 := spec2;
end;

function AndSpecification<T>.isSatisfiedBy(T: T): boolean;
begin
  Result := FSpec1.isSatisfiedBy(T) and FSpec2.isSatisfiedBy(T);
end;

{ OrSpecification<T> }

constructor OrSpecification<T>.create(spec1, spec2: Specification<T>);
begin
  FSpec1 := spec1;
  FSpec2 := spec2;
end;

function OrSpecification<T>.isSatisfiedBy(T: T): boolean;
begin
  Result := FSpec1.isSatisfiedBy(T) Or FSpec2.isSatisfiedBy(T);
end;

{ NotSpecification<T> }

constructor NotSpecification<T>.create(spec1: Specification<T>);
begin
  FSpec1 := spec1;
end;

function NotSpecification<T>.isSatisfiedBy(T: T): boolean;
begin
  Result := not FSpec1.isSatisfiedBy(T)
end;

end.
