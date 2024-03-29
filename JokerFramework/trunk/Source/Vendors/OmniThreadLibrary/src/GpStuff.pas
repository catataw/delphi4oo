(*:Various stuff with no other place to go.
   @author Primoz Gabrijelcic
   @desc <pre>
   (c) 2010 Primoz Gabrijelcic
   Free for personal and commercial use. No rights reserved.

   Author            : Primoz Gabrijelcic
   Creation date     : 2006-09-25
   Last modification : 2010-02-01
   Version           : 1.20
</pre>*)(*
   History:
     1.20: 2010-02-01
       - OpenArrayToVarArray supports vtUnicodeString variant type.
     1.19a: 2009-11-16
       - IGpTraceable needs GUID.
     1.19: 2009-07-15
       - Added EnumPairs string array enumerator.
       - Added EnumList string enumerator.
     1.18: 2009-05-08
       - TGp4AlignedInt fully changed from working with Cardinal to Integer.
       - Implemented function CAS (compare and swap) in TGp4AlignedInt and
         TGp8AlignedInt64 records. 
     1.17a: 2009-04-21
       - InterlockedIncrement/InterlockedDecrement deal with integers, therefore
         TGp4AlignedInt.Increment/Decrement must return integers.
     1.17: 2009-03-29
       - Implemented IGpTraceable interface.
     1.16: 2009-03-16
       - TGp8AlignedInt.Addr must be PInt64, not PCardinal.
       - TGp8AlignedInt renamed to TGp8AlignedInt64.
     1.15: 2009-03-11
       - Implemented EnumStrings enumerator.
     1.14: 2008-10-26
       - Implemented EnumValues enumerator.
     1.13: 2008-09-09
       - Added >= and <= operators to the TGp4AlignedInt.
     1.12: 2008-07-28
       - Added int64 support to the OpenArrayToVarArray.
     1.11: 2008-07-20
       - Implemented 8-aligned integer, TGp8AlignedInt.
       - TGp4AlignedInt and TGp8AlignedInt ifdef'd to be only available on D2007+.
     1.10: 2008-07-08
       - [GJ] ReverseWord/ReverseDWord rewritten in assembler.
     1.09: 2008-06-19
       - Implemented 4-aligned integer, TGp4AlignedInt.
     1.08: 2008-04-08
       - Declared MaxInt64 constant.
     1.07: 2008-03-31
       - Added function OpenArrayToVarArray, written by Thomas Schubbauer.
     1.06: 2007-06-13
       - ReverseCardinal renamed to ReverseDWord.
       - Added function ReverseWord.
     1.05: 2007-04-12
       - Added function ReverseCardinal.
     1.04: 2007-02-26
       - Added function TableFindEQ.
       - Changed result semantics for TableFind*.
       - Inlined everying that could be inlined.
       - Changed Asgn implementation so that it doesn't trigger BDS2006 codegen bug.
       - Added OffsetPtr method.
     1.03: 2007-02-20
       - Added function TableFindNE.
     1.02: 2007-01-08
       - Implemented IFF64 function.
     1.01: 2007-01-06
       - Moved in stuff from GpIFF.
     1.0: 2006-09-25
       - Released.
*)

unit GpStuff;

interface

uses
  Windows,
  Contnrs,
  DSiWin32;

{$IFDEF ConditionalExpressions}
  {$IF CompilerVersion >= 18} //D2006+
    {$DEFINE GpStuff_Inline}
    {$DEFINE GpStuff_AlignedInt}
    {$DEFINE GpStuff_ValuesEnumerators}
    {$DEFINE GpStuff_Helpers}
  {$IFEND}
{$ENDIF}

const
  MaxInt64 = $7FFFFFFFFFFFFFFF;

{$IFDEF GpStuff_AlignedInt}
type
  TGp4AlignedInt = record
  strict private
    aiData: int64;
    function  GetValue: integer; inline;
    procedure SetValue(value: integer); inline;
  public
    function Addr: PInteger; inline;
    function CAS(oldValue, newValue: integer): boolean;
    function Decrement: integer; inline;
    function Increment: integer; inline;
    class operator Add(const ai: TGp4AlignedInt; i: integer): cardinal; inline;
    class operator Equal(const ai: TGp4AlignedInt; i: integer): boolean; inline;
    class operator GreaterThan(const ai: TGp4AlignedInt; i: integer): boolean; inline;
    class operator GreaterThanOrEqual(const ai: TGp4AlignedInt; i: integer): boolean; inline;
    class operator Implicit(const ai: TGp4AlignedInt): integer; inline;
    class operator Implicit(const ai: TGp4AlignedInt): cardinal; inline;
    class operator Implicit(const ai: TGp4AlignedInt): PInteger; inline;
    class operator LessThan(const ai: TGp4AlignedInt; i: integer): boolean; inline;
    class operator LessThanOrEqual(const ai: TGp4AlignedInt; i: integer): boolean; inline;
    class operator NotEqual(const ai: TGp4AlignedInt; i: integer): boolean; inline;
    class operator Subtract(ai: TGp4AlignedInt; i: integer): cardinal; inline;
    property Value: integer read GetValue write SetValue;
  end; { TGp4AlignedInt }

  TGp8AlignedInt64 = record
  strict private
    aiData: packed record
      DataLo, DataHi: int64;
    end;
    function  GetValue: int64; inline;
    procedure SetValue(value: int64); inline;
  public
    function Addr: PInt64; inline;
    function CAS(oldValue, newValue: int64): boolean;
    function Decrement: int64; inline;
    function Increment: int64; inline;
    property Value: int64 read GetValue write SetValue;
  end; { TGp8AlignedInt64 }

  TGpObjectListHelper = class helper for TObjectList
  public
    function CardCount: cardinal;
  end; { TGpObjectListHelper }
{$ENDIF GpStuff_AlignedInt}

type
  IGpTraceable = interface(IInterface)
    ['{EA2316AC-B5FA-45EA-86E0-9016CD51C336}']
    function  GetTraceReferences: boolean; stdcall;
    procedure SetTraceReferences(const value: boolean); stdcall;
    function  _AddRef: integer; stdcall;
    function  _Release: integer; stdcall;
    function  GetRefCount: integer; stdcall;
    property TraceReferences: boolean read GetTraceReferences write SetTraceReferences;
  end; { IGpTraceable }

  TGpTraceable = class(TInterfacedObject, IGpTraceable)
  private
    gtTraceRef: boolean;
  public
    destructor  Destroy; override;
    function  _AddRef: integer; stdcall;
    function  _Release: integer; stdcall;
    function  GetRefCount: integer; stdcall;
    function  GetTraceReferences: boolean; stdcall;
    procedure SetTraceReferences(const value: boolean); stdcall;
    property TraceReferences: boolean read GetTraceReferences write SetTraceReferences;
  end; { TGpTraceable }

function  Asgn(var output: boolean; const value: boolean): boolean; overload; {$IFDEF GpStuff_Inline}inline;{$ENDIF}
function  Asgn(var output: string; const value: string): string; overload;    {$IFDEF GpStuff_Inline}inline;{$ENDIF}
function  Asgn(var output: integer; const value: integer): integer; overload; {$IFDEF GpStuff_Inline}inline;{$ENDIF}
function  Asgn(var output: real; const value: real): real; overload;          {$IFDEF GpStuff_Inline}inline;{$ENDIF}
function  Asgn64(var output: int64; const value: int64): int64; overload;     {$IFDEF GpStuff_Inline}inline;{$ENDIF}

function  IFF(condit: boolean; iftrue, iffalse: string): string; overload;    {$IFDEF GpStuff_Inline}inline;{$ENDIF}
function  IFF(condit: boolean; iftrue, iffalse: integer): integer; overload;  {$IFDEF GpStuff_Inline}inline;{$ENDIF}
function  IFF(condit: boolean; iftrue, iffalse: real): real; overload;        {$IFDEF GpStuff_Inline}inline;{$ENDIF}
function  IFF(condit: boolean; iftrue, iffalse: boolean): boolean; overload;  {$IFDEF GpStuff_Inline}inline;{$ENDIF}
function  IFF(condit: boolean; iftrue, iffalse: pointer): pointer; overload;  {$IFDEF GpStuff_Inline}inline;{$ENDIF}
function  IFF64(condit: boolean; iftrue, iffalse: int64): int64;              {$IFDEF GpStuff_Inline}inline;{$ENDIF}

function  OffsetPtr(ptr: pointer; offset: integer): pointer;                  {$IFDEF GpStuff_Inline}inline;{$ENDIF}

///<summary>Reverses byte order in a 4-byte number.</summary>
function  ReverseDWord(dw: DWORD): DWORD;
///<summary>Reverses byte order in a 2-byte number.</summary>
function  ReverseWord(w: word): word;

///<summary>Locates specified value in a buffer.</summary>
///<returns>Offset of found value (0..dataLen-1) or -1 if value was not found.</returns>
///<since>2007-02-22</since>
function  TableFindEQ(value: byte; data: PChar; dataLen: integer): integer; assembler;

///<summary>Locates a byte different from the specified value in a buffer.</summary>
///<returns>Offset of first differing value (0..dataLen-1) or -1 if buffer contains only specified values.</returns>
///<since>2007-02-22</since>
function  TableFindNE(value: byte; data: PChar; dataLen: integer): integer; assembler;

///<summary>Converts open variant array to COM variant array.<para>
///  Written by Thomas Schubbauer and published in borland.public.delphi.objectpascal on
///  Thu, 7 May 1998 09:53:33 +0200. Original function name was MakeVariant.</para><para>
///  2008-03-31, Gp: Extended to support vtObject type.
///  2008-07-28, Gp: Extended to support vtInt64 type.</para></summary>
function  OpenArrayToVarArray(aValues: array of const): Variant;

function  FormatDataSize(value: int64): string;

{$IFDEF GpStuff_ValuesEnumerators}
type
  IGpIntegerValueEnumerator = interface 
    function  GetCurrent: integer;
    function  MoveNext: boolean;
    property Current: integer read GetCurrent;
  end; { IGpIntegerValueEnumerator }

  IGpIntegerValueEnumeratorFactory = interface
    function  GetEnumerator: IGpIntegerValueEnumerator;
  end; { IGpIntegerValueEnumeratorFactory }

  IGpStringValueEnumerator = interface
    function  GetCurrent: string;
    function  MoveNext: boolean;
    property Current: string read GetCurrent;
  end; { IGpStringValueEnumerator }

  IGpStringValueEnumeratorFactory = interface
    function  GetEnumerator: IGpStringValueEnumerator;
  end; { IGpStringValueEnumeratorFactory }

  TGpStringPair = class
  private
    kvKey  : string;
    kvValue: string;
  public
    property Key: string read kvKey write kvKey;
    property Value: string read kvValue write kvValue;
  end; { TGpStringPair }

  IGpStringPairEnumerator = interface
    function  GetCurrent: TGpStringPair;
    function  MoveNext: boolean;
    property Current: TGpStringPair read GetCurrent;
  end; { IGpStringPairEnumerator }

  IGpStringPairEnumeratorFactory = interface
    function  GetEnumerator: IGpStringPairEnumerator;
  end; { IGpStringPairEnumeratorFactory }

function EnumValues(const aValues: array of integer): IGpIntegerValueEnumeratorFactory;
function EnumStrings(const aValues: array of string): IGpStringValueEnumeratorFactory;
function EnumPairs(const aValues: array of string): IGpStringPairEnumeratorFactory;
function EnumList(const aList: string; delim: char; const quoteChar: string = '';
  stripQuotes: boolean = true): IGpStringValueEnumeratorFactory;

{$ENDIF GpStuff_ValuesEnumerators}

implementation

uses
{$IFDEF ConditionalExpressions}
  Variants,
{$ENDIF ConditionalExpressions}
  SysUtils,
  Classes;

{$IFDEF GpStuff_ValuesEnumerators}
type
  TGpIntegerValueEnumerator = class(TInterfacedObject, IGpIntegerValueEnumerator)
  private
    iveIndex    : integer;
    iveNumValues: integer;
    iveValues   : PIntegerArray;
  public
    constructor Create(values: PIntegerArray; numValues: integer);
    destructor  Destroy; override;
    function  GetCurrent: integer;
    function  MoveNext: boolean;
    property Current: integer read GetCurrent;
  end; { TGpIntegerValueEnumerator }

  TGpIntegerValueEnumeratorFactory = class(TInterfacedObject, IGpIntegerValueEnumeratorFactory)
  private
    ivefNumValues: integer;
    ivefValues   : PIntegerArray;
  public
    constructor Create(const aValues: array of integer);
    function GetEnumerator: IGpIntegerValueEnumerator;
  end; { TGpIntegerValueEnumeratorFactory }

  TGpStringValueEnumerator = class(TInterfacedObject, IGpStringValueEnumerator)
  private
    sveIndex : integer;
    sveValues: TStringList;
  public
    constructor Create(values: TStringList);
    destructor  Destroy; override;
    function  GetCurrent: string;
    function  MoveNext: boolean;
    property Current: string read GetCurrent;
  end; { TGpStringValueEnumerator }

  TGpStringValueEnumeratorFactory = class(TInterfacedObject, IGpStringValueEnumeratorFactory)
  private
    svefValues_ref: TStringList;
  public
    constructor Create(values: TStringList);
    function  GetEnumerator: IGpStringValueEnumerator;
  end; { TGpStringValueEnumeratorFactory }

  TGpStringPairEnumerator = class(TInterfacedObject, IGpStringPairEnumerator)
  private
    sveCurrentPair: TGpStringPair;
    sveIndex      : integer;
    svePairs      : TStringList;
  public
    constructor Create(values: TStringList);
    destructor  Destroy; override;
    function  GetCurrent: TGpStringPair;
    function  MoveNext: boolean;
    property Current: TGpStringPair read GetCurrent;
  end; { TGpStringPairEnumerator }

  TGpStringPairEnumeratorFactory = class(TInterfacedObject, IGpStringPairEnumeratorFactory)
  private
    svefPairs_ref: TStringList;
  public
    constructor Create(values: TStringList);
    function  GetEnumerator: IGpStringPairEnumerator;
  end; { TGpStringPairEnumeratorFactory }
{$ENDIF GpStuff_ValuesEnumerators}

type
  TDelimiters = array of integer;

//copied from GpString unit
procedure GetDelimiters(const list: string; delim: char; const quoteChar: string;
  addTerminators: boolean; var delimiters: TDelimiters);
var
  chk  : boolean;
  i    : integer;
  idx  : integer;
  quote: char;
  skip : boolean;
begin
  SetLength(delimiters, Length(list)+2); // leave place for terminators
  idx := 0;
  if addTerminators then begin
    delimiters[idx] := 0;
    Inc(idx);
  end;
  skip := false;
  if quoteChar = '' then begin
    chk := false;
    quote := #0; //to keep compiler happy
  end
  else begin
    chk   := true;
    quote := quoteChar[1];
  end;
  for i := 1 to Length(list) do begin
    if chk and (list[i] = quote) then
      skip := not skip
    else if not skip then begin
      if list[i] = delim then begin
        delimiters[idx] := i;
        Inc(idx);
      end;
    end;
  end; //for
  if addTerminators then begin
    delimiters[idx] := Length(list)+1;
    Inc(idx);
  end;
  SetLength(delimiters,idx);
end; { GetDelimiters }

{ exports }

function Asgn(var output: boolean; const value: boolean): boolean; overload;
begin
  output := value;
  Result := output;
end; { Asgn }

function Asgn(var output: string; const value: string): string; overload;
begin
  output := value;
  Result := output;
end; { Asgn }

function Asgn(var output: real; const value: real): real; overload;
begin
  output := value;
  Result := output;
end; { Asgn }

function Asgn(var output: integer; const value: integer): integer; overload;
begin
  output := value;
  Result := output;
end; { Asgn }

function Asgn64(var output: int64; const value: int64): int64; overload;
begin
  output := value;
  Result := output;
end; { Asgn64 }

function IFF(condit: boolean; iftrue, iffalse: string): string;
begin
  if condit then
    Result := iftrue
  else
    Result := iffalse;
end; { IFF }

function IFF(condit: boolean; iftrue, iffalse: integer): integer;
begin
  if condit then
    Result := iftrue
  else
    Result := iffalse;
end; { IFF }

function IFF(condit: boolean; iftrue, iffalse: real): real;
begin
  if condit then
    Result := iftrue
  else
    Result := iffalse;
end; { IFF }

function IFF(condit: boolean; iftrue, iffalse: boolean): boolean;
begin
  if condit then
    Result := iftrue
  else
    Result := iffalse;
end; { IFF }

function IFF(condit: boolean; iftrue, iffalse: pointer): pointer;
begin
  if condit then
    Result := iftrue
  else
    Result := iffalse;
end; { IFF }

function IFF64(condit: boolean; iftrue, iffalse: int64): int64;
begin
  if condit then
    Result := iftrue
  else
    Result := iffalse;
end; { IFF64 }

function OffsetPtr(ptr: pointer; offset: integer): pointer;
begin
  Result := pointer(cardinal(int64(ptr) + offset));
end; { OffsetPtr }

function OpenArrayToVarArray(aValues: array of const): Variant;
var
  i: integer;
begin
  Result := VarArrayCreate([Low(aValues), High(aValues)], varVariant);
  for i := Low(aValues) to High(aValues) do begin
    with aValues[i] do begin
      case VType of
        vtInteger:    Result[i] := VInteger;
        vtBoolean:    Result[i] := VBoolean;
        vtChar:       Result[i] := VChar;
        vtExtended:   Result[i] := VExtended^;
        vtString:     Result[i] := VString^;
        vtPointer:    Result[i] := integer(VPointer);
        vtPChar:      Result[i] := StrPas(VPChar);
        vtAnsiString: Result[i] := string(VAnsiString);
        vtCurrency:   Result[i] := VCurrency^;
        vtVariant:    Result[i] := VVariant^;
        vtObject:     Result[i] := integer(VObject);
        vtInterface:  Result[i] := integer(VInterface);
        vtWideString: Result[i] := WideString(VWideString);
        vtInt64:      Result[i] := VInt64^;
        {$IFDEF UNICODE}
        vtUnicodeString:
                      Result[i] := string(VUnicodeString);
        {$ENDIF UNICODE}
      else
        raise Exception.Create ('OpenArrayToVarArray: invalid data type')
      end; //case
    end; //with
  end; //for i
end; { OpenArrayToVarArray }

function FormatDataSize(value: int64): string;
begin
  if value < 1024*1024 then
    Result := Format('%.1f KB', [value/1024])
  else if value < 1024*1024*1024 then
    Result := Format('%.1f MB', [value/1024/1024])
  else
    Result := Format('%.1f GB', [value/1024/1024/1024]);
end; { FormatDataSize }

function ReverseDWord(dw: cardinal): cardinal;
asm
  bswap eax
end; { ReverseDWord }

function ReverseWord(w: word): word;
asm
   xchg   al, ah
end; { ReverseWord }

function TableFindEQ(value: byte; data: PChar; dataLen: integer): integer; assembler;
asm
      PUSH  EDI
      MOV   EDI,EDX
      REPNE SCASB
      MOV   EAX,$FFFFFFFF
      JNE   @@1
      MOV   EAX,EDI
      SUB   EAX,EDX
      DEC   EAX
@@1:  POP   EDI
end; { TableFindEQ }

function TableFindNE(value: byte; data: PChar; dataLen: integer): integer; assembler;
asm
      PUSH  EDI
      MOV   EDI,EDX
      REPE  SCASB
      MOV   EAX,$FFFFFFFF
      JE    @@1
      MOV   EAX,EDI
      SUB   EAX,EDX
      DEC   EAX
@@1:  POP   EDI
end; { TableFindNE }

{$IFDEF GpStuff_AlignedInt}

{ TGpAlignedInt }

function TGp4AlignedInt.Addr: PInteger;
begin
  Assert(SizeOf(pointer) = SizeOf(cardinal));
  Result := PInteger((cardinal(@aiData) + 3) AND NOT 3);
end; { TGp4AlignedInt.Addr }

function TGp4AlignedInt.CAS(oldValue, newValue: integer): boolean;
begin
  Result := InterlockedCompareExchange(Addr^, newValue, oldValue) = oldValue; 
end; { TGp4AlignedInt.CAS }

function TGp4AlignedInt.Decrement: integer;
begin
  Result := InterlockedDecrement(Addr^);
end; { TGp4AlignedInt.Decrement }

function TGp4AlignedInt.GetValue: integer;
begin
  Result := Addr^;
end; { TGp4AlignedInt.GetValue }

function TGp4AlignedInt.Increment: integer;
begin
  Result := InterlockedIncrement(Addr^);
end; { TGp4AlignedInt.Increment }

procedure TGp4AlignedInt.SetValue(value: integer);
begin
  Addr^ := value;
end; { TGp4AlignedInt.SetValue }

class operator TGp4AlignedInt.Add(const ai: TGp4AlignedInt; i: integer): cardinal;
begin
  Result := cardinal(int64(ai.Value) + i);
end; { TGp4AlignedInt.Add }

class operator TGp4AlignedInt.Equal(const ai: TGp4AlignedInt; i: integer): boolean;
begin
  Result := (ai.Value = i);
end; { TGp4AlignedInt.Equal }

class operator TGp4AlignedInt.GreaterThan(const ai: TGp4AlignedInt; i: integer): boolean;
begin
  Result := (ai.Value > i);
end; { TGp4AlignedInt.GreaterThan }

class operator TGp4AlignedInt.GreaterThanOrEqual(const ai: TGp4AlignedInt; i: integer):
  boolean;
begin
  Result := (ai.Value >= i);
end; { TGp4AlignedInt.GreaterThanOrEqual }

class operator TGp4AlignedInt.Implicit(const ai: TGp4AlignedInt): PInteger;
begin
  Result := ai.Addr;
end; { TGp4AlignedInt.Implicit }

class operator TGp4AlignedInt.Implicit(const ai: TGp4AlignedInt): cardinal;
begin
  Result := ai.Value;
end; { TGp4AlignedInt.Implicit }

class operator TGp4AlignedInt.Implicit(const ai: TGp4AlignedInt): integer;
begin
  Result := integer(ai.Value);
end; { TGp4AlignedInt.Implicit }

class operator TGp4AlignedInt.LessThan(const ai: TGp4AlignedInt; i: integer): boolean;
begin
  Result := (ai.Value < i);
end; { TGp4AlignedInt.LessThan }

class operator TGp4AlignedInt.LessThanOrEqual(const ai: TGp4AlignedInt; i: integer):
  boolean;
begin
  Result := (ai.Value <= i);
end; { TGp4AlignedInt.LessThanOrEqual }

class operator TGp4AlignedInt.NotEqual(const ai: TGp4AlignedInt; i: integer): boolean;
begin
  Result := (ai.Value <> i);
end; { TGp4AlignedInt.NotEqual }

class operator TGp4AlignedInt.Subtract(ai: TGp4AlignedInt; i: integer): cardinal;
begin
  Result := cardinal(int64(ai.Value) - i);
end; { TGp4AlignedInt.Subtract }

{ TGp8AlignedInt64 }

function TGp8AlignedInt64.Addr: PInt64;
begin
  Assert(SizeOf(pointer) = SizeOf(cardinal));
  Result := PInt64((cardinal(@aiData) + 7) AND NOT 7);
end; { TGp8AlignedInt64.Addr }

function TGp8AlignedInt64.CAS(oldValue, newValue: int64): boolean;
begin
  Result := DSiInterlockedCompareExchange64(Addr, newValue, oldValue) = oldValue;
end; { TGp8AlignedInt64.CAS }

function TGp8AlignedInt64.Decrement: int64;
begin
  Result := DSiInterlockedDecrement64(Addr^);
end; { TGp8AlignedInt64.Decrement }

function TGp8AlignedInt64.GetValue: int64;
begin
  Result := Addr^;
end; { TGp8AlignedInt64.GetValue }

function TGp8AlignedInt64.Increment: int64;
begin
  Result := DSiInterlockedIncrement64(Addr^);
end; { TGp8AlignedInt64.Increment }

procedure TGp8AlignedInt64.SetValue(value: int64);
begin
  Addr^ := value;
end; { TGp8AlignedInt64.SetValue }

{$ENDIF GpStuff_AlignedInt}

{$IFDEF GpStuff_AlignedInt}
function TGpObjectListHelper.CardCount: cardinal;
begin
  Result := cardinal(Count);
end; { TGpObjectListHelper.CardCount }
{$ENDIF GpStuff_AlignedInt}

{$IFDEF GpStuff_ValuesEnumerators}

{ TGpIntegerValueEnumerator }

constructor TGpIntegerValueEnumerator.Create(values: PIntegerArray; numValues: integer);
begin
  iveValues := values;
  iveNumValues := numValues;
  iveIndex := -1;
end; { TGpIntegerValueEnumerator.Create }

destructor TGpIntegerValueEnumerator.Destroy;
begin
  FreeMem(iveValues);
  inherited;
end; { pIntegerValueEnumerator.Destroy }

function TGpIntegerValueEnumerator.GetCurrent: integer;
begin
  Result := iveValues^[iveIndex];
end; { TGpIntegerValueEnumerator.GetCurrent }

function TGpIntegerValueEnumerator.MoveNext: boolean;
begin
  Inc(iveIndex);
  Result := (iveIndex < iveNumValues);
end; { TGpIntegerValueEnumerator.MoveNext }

{ TGpStringValueEnumeratorFactory }

constructor TGpIntegerValueEnumeratorFactory.Create(const aValues: array of integer);
var
  dataSize: integer;
begin
  inherited Create;
  ivefNumValues := Length(aValues);
  Assert(ivefNumValues > 0);
  dataSize := ivefNumValues * SizeOf(aValues[0]);
  GetMem(ivefValues, dataSize);
  Move(aValues[0], ivefValues^[0], dataSize);
end; { TGpIntegerValueEnumeratorFactory.Create }

function TGpIntegerValueEnumeratorFactory.GetEnumerator: IGpIntegerValueEnumerator;
begin
  Result := TGpIntegerValueEnumerator.Create(ivefValues, ivefNumValues);
end; { TGpIntegerValueEnumeratorFactory.GetEnumerator }

{ TGpStringValueEnumerator }

constructor TGpStringValueEnumerator.Create(values: TStringList);
begin
  sveValues := values;
  sveIndex := -1;
end; { TGpStringValueEnumerator.Create }

destructor TGpStringValueEnumerator.Destroy;
begin
  FreeAndNil(sveValues);
  inherited;
end; { pIntegerValueEnumerator.Destroy }

function TGpStringValueEnumerator.GetCurrent: string;
begin
  Result := sveValues[sveIndex];
end; { TGpStringValueEnumerator.GetCurrent }

function TGpStringValueEnumerator.MoveNext: boolean;
begin
  Inc(sveIndex);
  Result := (sveIndex < sveValues.Count);
end; { TGpStringValueEnumerator.MoveNext }

{ TGpStringPairEnumeratorFactory }

constructor TGpStringValueEnumeratorFactory.Create(values: TStringList);
begin
  inherited Create;
  svefValues_ref := values;
end; { TGpStringValueEnumeratorFactory.Create }

function TGpStringValueEnumeratorFactory.GetEnumerator: IGpStringValueEnumerator;
begin
  Result := TGpStringValueEnumerator.Create(svefValues_ref); //enumerator takes ownership
end; { TGpStringValueEnumeratorFactory.GetEnumerator }

{ TGpStringPairEnumerator }

constructor TGpStringPairEnumerator.Create(values: TStringList);
begin
  svePairs := values;
  sveIndex := -2;
  sveCurrentPair := TGpStringPair.Create;
end; { TGpStringPairEnumerator.Create }

destructor TGpStringPairEnumerator.Destroy;
begin
  FreeAndNil(sveCurrentPair);
  FreeAndNil(svePairs);
  inherited;
end; { pIntegerPairEnumerator.Destroy }

function TGpStringPairEnumerator.GetCurrent: TGpStringPair;
begin
  sveCurrentPair.Key := svePairs[sveIndex];
  sveCurrentPair.Value := svePairs[sveIndex+1];
  Result := sveCurrentPair;
end; { TGpStringPairEnumerator.GetCurrent }

function TGpStringPairEnumerator.MoveNext: boolean;
begin
  Inc(sveIndex, 2);
  Result := (sveIndex < svePairs.Count);
end; { TGpStringPairEnumerator.MoveNext }

{ TGpStringPairEnumeratorFactory }

constructor TGpStringPairEnumeratorFactory.Create(values: TStringList);
begin
  inherited Create;
  svefPairs_ref := values;
end; { TGpStringPairEnumeratorFactory.Create }

function TGpStringPairEnumeratorFactory.GetEnumerator: IGpStringPairEnumerator;
begin
  Result := TGpStringPairEnumerator.Create(svefPairs_ref); //enumerator takes ownership
end; { TGpStringPairEnumeratorFactory.GetEnumerator }

{ exports }

function EnumValues(const aValues: array of integer): IGpIntegerValueEnumeratorFactory;
begin
  Result := TGpIntegerValueEnumeratorFactory.Create(aValues);
end; { EnumValues }

function EnumStrings(const aValues: array of string): IGpStringValueEnumeratorFactory;
var
  s : string;
  sl: TStringList;
begin
  sl := TStringList.Create;
  for s in aValues do
    sl.Add(s);
  Result := TGpStringValueEnumeratorFactory.Create(sl); //factory takes ownership
end; { EnumValues }

function EnumPairs(const aValues: array of string): IGpStringPairEnumeratorFactory;
var
  s : string;
  sl: TStringList;
begin
  sl := TStringList.Create;
  for s in aValues do
    sl.Add(s);
  Result := TGpStringPairEnumeratorFactory.Create(sl); //factory takes ownership
end; { EnumPairs }

function EnumList(const aList: string; delim: char; const quoteChar: string;
  stripQuotes: boolean): IGpStringValueEnumeratorFactory;
var
  delimiters: TDelimiters;
  iDelim    : integer;
  quote     : char;
  sl        : TStringList;
begin
  sl := TStringList.Create;
  if aList <> '' then begin
    if stripQuotes and (quoteChar <> '') then
      quote := quoteChar[1]
    else begin
      stripQuotes := false;
      quote := #0; //to keep compiler happy;
    end;
    GetDelimiters(aList, delim, quoteChar, true, delimiters);
    for iDelim := Low(delimiters) to High(delimiters) - 1 do begin
      if stripQuotes and
         (aList[delimiters[iDelim  ] + 1] = quote) and
         (aList[delimiters[iDelim+1] - 1] = quote)
      then
        sl.Add(Copy(aList, delimiters[iDelim] + 2, delimiters[iDelim+1] - delimiters[iDelim] - 3))
      else
        sl.Add(Copy(aList, delimiters[iDelim] + 1, delimiters[iDelim+1] - delimiters[iDelim] - 1));
    end;
  end;
  Result := TGpStringValueEnumeratorFactory.Create(sl); //factory takes ownership
end; { EnumList }

{$ENDIF GpStuff_ValuesEnumerators}

{ TGpTraceable }

destructor TGpTraceable.Destroy;
begin
  if gtTraceRef then
    asm int 3; end;
  inherited;
end; { TGpTraceable.Destroy }

function TGpTraceable.GetRefCount: integer;
begin
  Result := RefCount;
end; { TGpTraceable.GetRefCount }

function TGpTraceable.GetTraceReferences: boolean;
begin
  Result := gtTraceRef;
end; { TGpTraceable.GetTraceReferences }

procedure TGpTraceable.SetTraceReferences(const value: boolean);
begin
  gtTraceRef := value;
end; { TGpTraceable.SetTraceReferences }

function TGpTraceable._AddRef: integer;
begin
  Result := inherited _AddRef;
  if gtTraceRef then
    asm int 3; end;
end; { TGpTraceable._AddRef }

function TGpTraceable._Release: integer;
begin
  if gtTraceRef then
    asm int 3; end;
  Result := inherited _Release;
end; { TGpTraceable._Release }

end.
