unit EList;

interface

uses EIntf;

type
  TSameNameMatcher = class(EObject, IMatcher<EMethod>)
  public
    constructor create(methodName: string);
  end;

  TEqualMethodRemover = class(EObject, IMatcher<EMethod>)
  end;

  TBackedMirrorList = class

  end;

implementation

{ TSameNameMatcher }

constructor TSameNameMatcher.create(methodName: string);
begin

end;

end.
