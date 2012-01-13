unit EMatcher;

interface

uses EIntf;

type
  ClassArrayMatcher = class
  public
    constructor create(baseClasses: array of TClass);
  end;

  TGetterMatcher = class(EObject, IMatcher<EMethod>)
  end;

  TSetterMatcher = class(EObject, IMatcher<EMethod>)
  end;

implementation

{ ClassArrayMatcher }

constructor ClassArrayMatcher.create(baseClasses: array of TClass);
begin

end;

end.
