unit TestERtti;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework, EIntf, ERtti;

type
  // Test methods for class TERtti

  TestTERtti = class(TTestCase)
  strict private

  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestO;
    procedure TestO1;
    procedure TestO2;
  end;

implementation

procedure TestTERtti.SetUp;
begin

end;

procedure TestTERtti.TearDown;
begin

end;

procedure TestTERtti.TestO;
var
  ReturnValue: IAccessorsController;
  AObject: TObject;
begin
  // TODO -oMarcelo Fernandes -cTesteUnitario: Setup method call parameters
 // ReturnValue := FERtti.O(AObject);
  // TODO: Validate method results
end;

procedure TestTERtti.TestO1;
var
  AObject: TObject;
begin
     TERtti.from(AObject).invoke.Method('').withoutArgs;

end;

procedure TestTERtti.TestO2;
var
  ReturnValue: IFieldController;
  AField: EField;
begin
  // TODO: Setup method call parameters
  //ReturnValue := ERtti.from(AField)
  // TODO: Validate method results
end;

initialization

// Register any test cases with the test runner
RegisterTest(TestTERtti.Suite);

end.
