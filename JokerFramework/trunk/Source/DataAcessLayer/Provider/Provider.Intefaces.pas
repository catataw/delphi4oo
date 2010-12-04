unit NProviderIntf;

interface

uses
  Classes;

type
 // ICriteria = Interface;

  IConnection = interface
    ['{1CAF6BC7-CD74-435E-A1C2-864A21F23B15}']
    procedure Connect;
    procedure Disconnect;
    function Connected: boolean;
    function Instance: TComponent;
    procedure StartTransaction;
    procedure Rollback;
    procedure Commit;
    function InTransaction: Boolean;
    procedure LoadFromString(const Value: String);
  end;


  IProviderConfig = interface
    ['{8E1C3877-1341-4D2E-AC3C-F175FFB87444}']
    procedure Update;
    procedure SetFileName(const Value: string);
    function ReadString(const Section, Ident, Default: string): string;
    function ReadInteger(const Section, Ident: string; Default: integer): integer;
    function GetFileName: string;
    procedure WriteSection(const Section, Values: string);
    procedure WriteString(const Section, Ident, Value: string);
    procedure WriteInteger(const Section, Ident: string; Value: integer);
    procedure DeleteKey(const Section, Ident: String);
    procedure ReadSections(var Sections: TStrings);
    procedure ReadSectionValues(const Section: String; Strings: TStrings);
    procedure DeleteSection(const Section: String);
    property FileName: string read GetFileName write SetFileName;
  end;

implementation

end.
