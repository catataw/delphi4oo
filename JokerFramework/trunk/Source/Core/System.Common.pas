unit System.Common;

interface

uses Classes, SysUtils, Rtti;

type

  JValue = packed record
  private
    ovData: int64;
    ovIntf: IInterface;
    ovType: (ovtNull, ovtBoolean, ovtInteger, ovtDouble, ovtExtended, ovtString, ovtObject, ovtInterface, ovtVariant,
      ovtWideString, ovtPointer);
    function GetAsBoolean: boolean; inline;
    function GetAsCardinal: cardinal; inline;
    function GetAsDouble: Double;
    function GetAsExtended: Extended;
    function GetAsInt64: int64; inline;
    function GetAsInteger: integer; inline;
    function GetAsInterface: IInterface; inline;
    function GetAsObject: TObject; inline;
    function GetAsPointer: pointer;
    function GetAsString: string;
    function GetAsVariant: Variant;
    function GetAsVariantArr(idx: integer): Variant; inline;
    function GetAsWideString: WideString;
    procedure SetAsBoolean(const value: boolean); inline;
    procedure SetAsCardinal(const value: cardinal); inline;
    procedure SetAsDouble(value: Double); inline;
    procedure SetAsExtended(value: Extended);
    procedure SetAsInt64(const value: int64); inline;
    procedure SetAsInteger(const value: integer); inline;
    procedure SetAsInterface(const value: IInterface); inline;
    procedure SetAsObject(const value: TObject); inline;
    procedure SetAsPointer(const value: pointer); inline;
    procedure SetAsString(const value: string);
    procedure SetAsVariant(const value: Variant);
    procedure SetAsWideString(const value: WideString);
  public
    procedure Clear; inline;
    function IsBoolean: boolean; inline;
    function IsEmpty: boolean; inline;
    function IsFloating: boolean; inline;
    function IsInteger: boolean; inline;
    function IsInterface: boolean; inline;
    function IsObject: boolean; inline;
    function IsPointer: boolean; inline;
    function IsString: boolean; inline;
    function IsVariant: boolean; inline;
    function IsWideString: boolean; inline;
    class function Null: JValue; static;
    class function From<T>(const value: T): JValue; static;
    function RawData: PInt64; inline;
    procedure RawZero; inline;
    class operator Equal(const a: JValue; i: integer): boolean;
    class operator Equal(const a: JValue; const s: string): boolean;
    class operator Implicit(const a: boolean): JValue;
    class operator Implicit(const a: Double): JValue;
    class operator Implicit(const a: Extended): JValue;
    class operator Implicit(const a: integer): JValue;
    class operator Implicit(const a: int64): JValue;
    class operator Implicit(const a: pointer): JValue;
    class operator Implicit(const a: string): JValue;
    class operator Implicit(const a: IInterface): JValue;
    class operator Implicit(const a: TObject): JValue;
    class operator Implicit(const a: JValue): int64;
    class operator Implicit(const a: JValue): TObject;
    class operator Implicit(const a: JValue): Double;
    class operator Implicit(const a: JValue): Extended;
    class operator Implicit(const a: JValue): string;
    class operator Implicit(const a: JValue): integer;
    class operator Implicit(const a: JValue): pointer;
    class operator Implicit(const a: JValue): WideString;
    class operator Implicit(const a: JValue): boolean;
    class operator Implicit(const a: JValue): IInterface;
    class operator Implicit(const a: WideString): JValue;
    class operator Implicit(const a: Variant): JValue;
    property AsBoolean: boolean read GetAsBoolean write SetAsBoolean;
    property AsCardinal: cardinal read GetAsCardinal write SetAsCardinal;
    property AsDouble: Double read GetAsDouble write SetAsDouble;
    property AsExtended: Extended read GetAsExtended write SetAsExtended;
    property AsInt64: int64 read GetAsInt64 write SetAsInt64;
    property AsInteger: integer read GetAsInteger write SetAsInteger;
    property AsInterface: IInterface read GetAsInterface write SetAsInterface;
    property AsObject: TObject read GetAsObject write SetAsObject;
    property AsPointer: pointer read GetAsPointer write SetAsPointer;
    property AsString: string read GetAsString write SetAsString;
    property AsVariant: Variant read GetAsVariant write SetAsVariant;
    property AsVariantArr[idx: integer]: Variant read GetAsVariantArr; default;
    property AsWideString: WideString read GetAsWideString write SetAsWideString;
  end;

implementation

uses
  Variants;

type
  IOmniStringData = interface
    ['{21E52E56-390C-4066-B9FC-83862FFBCBF3}']
    function GetValue: string;
    procedure SetValue(const value: string);
    property value: string read GetValue write SetValue;
  end; { IOmniStringData }

  TOmniStringData = class(TInterfacedObject, IOmniStringData)
  strict private
    osdValue: string;
  public
    constructor Create(const value: string);
    function GetValue: string;
    procedure SetValue(const value: string);
    property value: string read GetValue write SetValue;
  end; { TOmniStringData }

  IOmniWideStringData = interface
    ['{B303DB23-4A06-4D25-814A-8A9EDC90D066}']
    function GetValue: WideString;
    procedure SetValue(const value: WideString);
    property value: WideString read GetValue write SetValue;
  end; { IOmniWideStringData }

  TOmniWideStringData = class(TInterfacedObject, IOmniWideStringData)
  strict private
    osdValue: WideString;
  public
    constructor Create(const value: WideString);
    function GetValue: WideString;
    procedure SetValue(const value: WideString);
    property value: WideString read GetValue write SetValue;
  end; { TOmniWideStringData }

  IOmniVariantData = interface
    ['{65311D7D-67F1-452E-A0BD-C90596671FC8}']
    function GetValue: Variant;
    procedure SetValue(const value: Variant);
    property value: Variant read GetValue write SetValue;
  end; { IOmniVariantData }

  TOmniVariantData = class(TInterfacedObject, IOmniVariantData)
  strict private
    ovdValue: Variant;
  public
    constructor Create(const value: Variant);
    function GetValue: Variant;
    procedure SetValue(const value: Variant);
    property value: Variant read GetValue write SetValue;
  end; { TOmniVariantData }

  IOmniExtendedData = interface
    ['{B6CD371F-A461-436A-8767-9BCA194B1D0E}']
    function GetValue: Extended;
    procedure SetValue(const value: Extended);
    property value: Extended read GetValue write SetValue;
  end; { IOmniExtendedData }

  TOmniExtendedData = class(TInterfacedObject, IOmniExtendedData)
  strict private
    oedValue: Extended;
  public
    constructor Create(const value: Extended);
    function GetValue: Extended;
    procedure SetValue(const value: Extended);
    property value: Extended read GetValue write SetValue;
  end; { TOmniExtendedData }

  { TOmniStringData }

constructor TOmniStringData.Create(const value: string);
begin
  inherited Create;
  osdValue := value;
end; { TOmniStringData.Create }

function TOmniStringData.GetValue: string;
begin
  Result := osdValue;
end; { TOmniStringData.GetValue }

procedure TOmniStringData.SetValue(const value: string);
begin
  osdValue := value;
end; { TOmniStringData.SetValue }

{ TOmniWideStringData }

constructor TOmniWideStringData.Create(const value: WideString);
begin
  inherited Create;
  osdValue := value;
end; { TOmniWideStringData.Create }

function TOmniWideStringData.GetValue: WideString;
begin
  Result := osdValue;
end; { TOmniWideStringData.GetValue }

procedure TOmniWideStringData.SetValue(const value: WideString);
begin
  osdValue := value;
end; { TOmniWideStringData.SetValue }

{ TOmniVariantData }

constructor TOmniVariantData.Create(const value: Variant);
begin
  inherited Create;
  ovdValue := value;
end; { TOmniVariantData.Create }

function TOmniVariantData.GetValue: Variant;
begin
  Result := ovdValue;
end; { TOmniVariantData.GetValue }

procedure TOmniVariantData.SetValue(const value: Variant);
begin
  ovdValue := value;
end; { TOmniVariantData.SetValue }

{ TOmniExtendedData }

constructor TOmniExtendedData.Create(const value: Extended);
begin
  inherited Create;
  oedValue := value;
end; { TOmniExtendedData.Create }

function TOmniExtendedData.GetValue: Extended;
begin
  Result := oedValue;
end; { TOmniExtendedData.GetValue }

procedure TOmniExtendedData.SetValue(const value: Extended);
begin
  oedValue := value;
end; { TOmniExtendedData.SetValue }

{ TOmniValue }

procedure JValue.Clear;
begin
  ovData := 0;
  ovIntf := nil;
  ovType := ovtNull;
end; { TOmniValue.Clear }

function JValue.GetAsBoolean: boolean;
begin
  if ovType <> ovtBoolean then
    raise Exception.Create('TOmniValue cannot be converted to boolean');
  Result := PByte(RawData)^ <> 0;
end; { TOmniValue.GetAsBoolean }

function JValue.GetAsCardinal: cardinal;
begin
  Result := AsInt64;
end; { TOmniValue.GetAsCardinal }

function JValue.GetAsDouble: Double;
begin
  case ovType of
    ovtInteger:
      Result := AsInt64;
    ovtDouble:
      Result := PDouble(RawData)^;
    ovtExtended:
      Result := (ovIntf as IOmniExtendedData).value;
  else
    raise Exception.Create('TOmniValue cannot be converted to double');
  end;
end; { TOmniValue.GetAsDouble }

function JValue.GetAsExtended: Extended;
begin
  case ovType of
    ovtInteger:
      Result := AsInt64;
    ovtDouble:
      Result := PDouble(RawData)^;
    ovtExtended:
      Result := (ovIntf as IOmniExtendedData).value;
  else
    raise Exception.Create('TOmniValue cannot be converted to extended');
  end;
end; { TOmniValue.GetAsExtended }

function JValue.GetAsInt64: int64;
begin
  if IsInteger then
    Result := ovData
  else if IsEmpty then
    Result := 0
  else
    raise Exception.Create('TOmniValue cannot be converted to int64');
end; { TOmniValue.GetAsInt64 }

function JValue.GetAsInteger: integer;
begin
  Result := AsInt64;
end; { TOmniValue.GetAsInteger }

function JValue.GetAsInterface: IInterface;
begin
  if IsInterface then
    Result := ovIntf
  else if IsEmpty then
    Result := nil
  else
    raise Exception.Create('TOmniValue cannot be converted to interface');
end; { TOmniValue.GetAsInterface }

function JValue.GetAsObject: TObject;
begin
  if IsObject then
    Result := TObject(RawData^)
  else if IsEmpty then
    Result := nil
  else
    raise Exception.Create('TOmniValue cannot be converted to object');
end; { TOmniValue.GetAsObject }

function JValue.GetAsPointer: pointer;
begin
  if IsPointer or IsObject then
    Result := pointer(RawData^)
  else if IsEmpty then
    Result := nil
  else
    raise Exception.Create('TOmniValue cannot be converted to pointer');
end; { TOmniValue.GetAsPointer }

function JValue.GetAsString: string;
begin
  case ovType of
    ovtNull:
      Result := '';
    ovtBoolean:
      Result := BoolToStr(AsBoolean, true);
    ovtInteger:
      Result := IntToStr(ovData);
    ovtDouble, ovtExtended:
      Result := FloatToStr(AsExtended);
    ovtString:
      Result := (ovIntf as IOmniStringData).value;
    ovtWideString:
      Result := (ovIntf as IOmniWideStringData).value;
  else
    raise Exception.Create('TOmniValue cannot be converted to string');
  end;
end; { TOmniValue.GetAsString }

function JValue.GetAsVariant: Variant;
begin
  if IsVariant then
    Result := (ovIntf as IOmniVariantData).value
  else if IsEmpty then
    Result := Variants.Null
  else
    raise Exception.Create('TOmniValue cannot be converted to variant');
end; { TOmniValue.GetAsVariant }

function JValue.GetAsVariantArr(idx: integer): Variant;
begin
  Result := AsVariant[idx];
end; { TOmniValue.GetAsVariantArr }

function JValue.GetAsWideString: WideString;
begin
  if ovType = ovtWideString then
    Result := (ovIntf as IOmniWideStringData).value
  else
    Result := GetAsString;
end; { TOmniValue.GetAsWideString }

function JValue.IsBoolean: boolean;
begin
  Result := (ovType = ovtBoolean);
end; { TOmniValue.IsBoolean }

function JValue.IsEmpty: boolean;
begin
  Result := (ovType = ovtNull);
end; { TOmniValue.IsEmpty }

function JValue.IsFloating: boolean;
begin
  Result := (ovType in [ovtDouble, ovtExtended]);
end; { TOmniValue.IsFloating }

function JValue.IsInteger: boolean;
begin
  Result := (ovType = ovtInteger);
end; { TOmniValue.IsInteger }

function JValue.IsInterface: boolean;
begin
  Result := (ovType = ovtInterface);
end; { TOmniValue.IsInterface }

function JValue.IsObject: boolean;
begin
  Result := (ovType = ovtObject);
end; { TOmniValue.IsObject }

function JValue.IsPointer: boolean;
begin
  Result := (ovType = ovtPointer);
end; { TOmniValue.IsPointer }

function JValue.IsString: boolean;
begin
  Result := (ovType = ovtString);
end; { TOmniValue.IsString }

function JValue.IsVariant: boolean;
begin
  Result := (ovType = ovtVariant);
end; { TOmniValue.IsVariant }

function JValue.IsWideString: boolean;
begin
  Result := (ovType = ovtWideString);
end; { TOmniValue.IsWideString }

class function JValue.Null: JValue;
begin
  Result.ovType := ovtNull;
end; { TOmniValue.Null }

function JValue.RawData: PInt64;
begin
  Result := @ovData;
end; { TOmniValue.RawData }

procedure JValue.RawZero;
begin
  ovData := 0;
  pointer(ovIntf) := nil;
  ovType := ovtNull;
end; { TOmniValue.RawZero }

procedure JValue.SetAsBoolean(const value: boolean);
begin
  PByte(RawData)^ := Ord(value);
  ovType := ovtBoolean;
end; { TOmniValue.SetAsBoolean }

procedure JValue.SetAsCardinal(const value: cardinal);
begin
  AsInt64 := value;
end; { TOmniValue.SetAsCardinal }

procedure JValue.SetAsDouble(value: Double);
begin
  PDouble(RawData)^ := value;
  ovType := ovtDouble;
end; { TOmniValue.SetAsDouble }

procedure JValue.SetAsExtended(value: Extended);
begin
  ovIntf := TOmniExtendedData.Create(value);
  ovType := ovtExtended;
end; { TOmniValue.SetAsExtended }

procedure JValue.SetAsInt64(const value: int64);
begin
  ovData := value;
  ovType := ovtInteger;
end; { TOmniValue.SetAsInt64 }

procedure JValue.SetAsInteger(const value: integer);
begin
  AsInt64 := value;
end; { TOmniValue.SetAsInteger }

procedure JValue.SetAsInterface(const value: IInterface);
begin
  ovIntf := value;
  ovType := ovtInterface;
end; { TOmniValue.SetAsInterface }

procedure JValue.SetAsObject(const value: TObject);
begin
  RawData^ := int64(value);
  ovType := ovtObject;
end; { TOmniValue.SetAsObject }

procedure JValue.SetAsPointer(const value: pointer);
begin
  RawData^ := int64(value);
  ovType := ovtPointer;
end; { TOmniValue.SetAsPointer }

procedure JValue.SetAsString(const value: string);
begin
  ovIntf := TOmniStringData.Create(value);
  ovType := ovtString;
end; { TOmniValue.SetAsString }

procedure JValue.SetAsVariant(const value: Variant);
begin
  ovIntf := TOmniVariantData.Create(value);
  ovType := ovtVariant;
end; { TOmniValue.SetAsVariant }

procedure JValue.SetAsWideString(const value: WideString);
begin
  ovIntf := TOmniWideStringData.Create(value);
  ovType := ovtWideString;
end; { TOmniValue.SetAsWideString }

class operator JValue.Equal(const a: JValue; i: integer): boolean;
begin
  Result := (a.AsInteger = i);
end; { TOmniValue.Equal }

class operator JValue.Equal(const a: JValue; const s: string): boolean;
begin
  Result := (a.AsString = s);
end;

class function JValue.From<T>(const value: T): JValue;
begin

end;

{ TOmniValue.Equal }

class operator JValue.Implicit(const a: boolean): JValue;
begin
  Result.AsBoolean := a;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: Double): JValue;
begin
  Result.AsDouble := a;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: Extended): JValue;
begin
  Result.AsExtended := a;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: integer): JValue;
begin
  Result.AsInteger := a;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: int64): JValue;
begin
  Result.AsInt64 := a;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: string): JValue;
begin
  Result.AsString := a;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: IInterface): JValue;
begin
  Result.AsInterface := a;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: TObject): JValue;
begin
  Result.AsObject := a;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: JValue): WideString;
begin
  Result := a.AsWideString;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: JValue): Extended;
begin
  Result := a.AsExtended;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: JValue): int64;
begin
  Result := a.AsInt64;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: JValue): boolean;
begin
  Result := a.AsBoolean;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: JValue): Double;
begin
  Result := a.AsDouble;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: JValue): integer;
begin
  Result := a.AsInteger;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: JValue): IInterface;
begin
  Result := a.AsInterface;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: JValue): TObject;
begin
  Result := a.AsObject;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: JValue): string;
begin
  Result := a.AsString;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: WideString): JValue;
begin
  Result.AsWideString := a;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: Variant): JValue;
begin
  Result.AsVariant := a;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: pointer): JValue;
begin
  Result.AsPointer := a;
end; { TOmniValue.Implicit }

class operator JValue.Implicit(const a: JValue): pointer;
begin
  Result := a.AsPointer;
end; { TOmniValue.Implicit }

end.
