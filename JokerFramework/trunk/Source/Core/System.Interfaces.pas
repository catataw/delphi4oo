unit System.Interfaces;

interface

uses
  Classes,Rtti;

type

  IComponent = interface
    ['{3074BCF5-C27C-4768-AD07-0B971CDFBCC5}']
  end;

  IApplicationComponent = interface(IComponent)
    ['{BD279FA7-9220-4CE7-B79B-C869E03CAD69}']
    procedure Init;
    function IsInitialized: boolean;
  end;

  Iterator = interface
    ['{9EBC8DF0-6859-46E3-A2F3-8182B32D27B9}']
    function Key: integer;
    procedure Next;
    function Valid: boolean;
    procedure Current;
    procedure rewind;
  end;

  IController = interface
    ['{78723E5E-DB21-4ECF-9E5F-0D8B8593BF59}']
    procedure Init;
    procedure run(AActionID: string);
  end;

  IViewRenderer = interface
    ['{78723E5E-DB21-4ECF-9E5F-0D8B8593BF59}']
    procedure render(AContext: IController; AFile: string; AData: array of TValue; out Return: TValue);
  end;


  IAction = interface
    ['{A1AE00F7-7A22-47FD-BA86-1B1A271B17BD}']
    procedure run;
    function getId: string;
    function getController: IController;
    property Controller: IController read GetController;
    property ID: string read GetID;
  end;

implementation

end.
