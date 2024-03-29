(*:Preallocated hasher.
   @author Primoz Gabrijelcic
   @desc <pre>
Copyright (c) 2010, Primoz Gabrijelcic
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
- Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.
- The name of the Primoz Gabrijelcic may not be used to endorse or promote
  products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  Tested with Delphi 2007. Should work with older versions, too.

   Author            : Primoz Gabrijelcic
   Creation date     : 2005-02-24
   Last modification : 2010-01-26
   Version           : 1.05b
</pre>*)(*
   History:
     1.05b: 2010-01-26
       - Fixed a bug in TGpStringTable.SetValue.
     1.05: 2008-11-09
       - Fixed a bug in TGpStringTable.Grow and TGpStringDictionary.Grow which caused
         random memory overwrites.
     1.05: 2008-11-08
       - Added function Count to TGpStringTable, TGpStringDictionary and TGpStringHash.
     1.04: 2008-10-20
       - Added TGpStringTable string storage.
       - Added TGpStringDictionary - a hash that uses TGpStringTable for string storage.
     1.03: 2008-10-04
       - Added support for growing.
     1.02: 2007-12-06
       - Much enhanced TGpStringHash.
       - TGpStringObjectHash class added.
     1.01: 2006-04-13
       - Added simplified constructor.
*)

unit GpStringHash;

interface

{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF (CompilerVersion >= 17)} //Delphi 2005 or newer
    {$DEFINE GpStringHash_Inline}
    {$DEFINE GpStringHash_Enumerators}
  {$IFEND}
{$ENDIF}

type
  PGpHashItem = ^TGpHashItem;
  TGpHashItem = record
    Next : cardinal;
    Key  : string;
    Value: integer;
  end; { TGpHashItem }

  {$IFDEF GpStringHash_Enumerators}
  TGpStringHash = class;

  TGpStringHashEnumerator = class
  private
    sheIndex: cardinal;
    sheHash : TGpStringHash;
  public
    constructor Create(stringHash: TGpStringHash);
    function  GetCurrent: integer;                  {$IFDEF GpLists_Inline}inline;{$ENDIF}
    function  MoveNext: boolean;                    {$IFDEF GpLists_Inline}inline;{$ENDIF}
    property Current: integer read GetCurrent;
  end; { TGpStringHashEnumerator }
  {$ENDIF GpStringHash_Enumerators}

  ///<summary>String-indexed hash of integer items.</summary>
  ///<since>2005-02-24</since>
  TGpStringHash = class
  private
    shBuckets   : array of cardinal;
    shCanGrow   : boolean;
    shFirstEmpty: cardinal;
    shItems     : array of TGpHashItem;
    shNumBuckets: cardinal;
    shSize      : cardinal;
  protected
    function  FindBucket(const key: string): cardinal;
    function  GetHashItem(idxHashItem: cardinal): PGpHashItem;   {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    function  GetItems(const key: string): integer;              {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    procedure Grow;
    procedure SetItems(const key: string; const value: integer); {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    property  HashItems[idxItem: cardinal]: PGpHashItem read GetHashItem;
  public
    constructor Create(numItems: cardinal; canGrow: boolean = false); overload;
    constructor Create(numBuckets, numItems: cardinal; canGrow: boolean = false); overload;
    destructor  Destroy; override;
    procedure Add(const key: string; value: integer);
    function  Count: integer;                                    {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    function  Find(const key: string; var value: integer): boolean;
    {$IFDEF GpStringHash_Enumerators}
    function  GetEnumerator: TGpStringHashEnumerator;            {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    {$ENDIF GpStringHash_Enumerators}
    function  HasKey(const key: string): boolean;                {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    procedure Update(const key: string; value: integer);
    function  ValueOf(const key: string): integer;
    property Items[const key: string]: integer read GetItems write SetItems; default;
  end; { TGpStringHash }

  {$IFDEF GpStringHash_Enumerators}
  TGpStringObjectHashEnumerator = class
  private
    soheStringEnumerator: TGpStringHashEnumerator;
  public
    constructor Create(stringHash: TGpStringHash);
    destructor  Destroy; override;
    function  GetCurrent: TObject;                  {$IFDEF GpLists_Inline}inline;{$ENDIF}
    function  MoveNext: boolean;                    {$IFDEF GpLists_Inline}inline;{$ENDIF}
    property Current: TObject read GetCurrent;
  end; { TGpStringObjectHashEnumerator }
  {$ENDIF GpStringHash_Enumerators}

  ///<summary>String-indexed hash of objects.
  ///    Redirects all operations to the internal TGpStringHash.</summary>
  ///<since>2007-12-06</since>
  TGpStringObjectHash = class
  private
    sohHash       : TGpStringHash;
    sohOwnsObjects: boolean;
  protected
    function  GetObjects(const key: string): TObject;
    procedure SetObjects(const key: string; const value: TObject);  {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
  public
    constructor Create(numItems: cardinal; ownsObjects: boolean = true; canGrow: boolean = false); overload;
    constructor Create(numBuckets, numItems: cardinal; ownsObjects: boolean = true; canGrow: boolean = false); overload;
    destructor  Destroy; override;
    procedure Add(const key: string; value: TObject);               {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    function  Count: integer;                                       {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    function  Find(const key: string; var value: TObject): boolean; {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    {$IFDEF GpStringHash_Enumerators}
    function  GetEnumerator: TGpStringObjectHashEnumerator;         {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    {$ENDIF GpStringHash_Enumerators}
    function  HasKey(const key: string): boolean;                   {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    procedure Update(const key: string; value: TObject);
    function  ValueOf(const key: string): TObject;                  {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    property Objects[const key: string]: TObject read GetObjects write SetObjects; default;
  end; { TGpStringObjectHash }

  {$IFDEF GpStringHash_Enumerators}
  TGpStringTable = class;

  TGpStringTableKV = class
  private
    kvKey  : string;
    kvValue: int64;
  public
    property Key: string read kvKey write kvKey;
    property Value: int64 read kvValue write kvValue;
  end; { TGpStringTableKV }

  TGpStringTableEnumerator = class
  private
    steCurrent: TGpStringTableKV;
    steTable  : PByte;
    steTail   : pointer;
  public
    constructor Create(pTable, pTail: pointer);
    destructor  Destroy; override;
    function  GetCurrent: TGpStringTableKV;
    function  MoveNext: boolean;
    property Current: TGpStringTableKV read GetCurrent;
  end; { TGpStringDictionaryEnumerator }
  {$ENDIF GpStringHash_Enumerators}

  ///<summary>A growable table of strings that doesn't support a Delete operation.
  ///  When string is inserted, its position (relative to the table start) is never
  ///  changed and can be used as a index. TGpStringDictionary uses this class for the
  ///  underlying data structure.
  ///<para>Data layout: [string length:32][string:N][value:8].</para>
  ///</summary>
  ///<since>2008-10-20</since>
  TGpStringTable = class
  private
    stCanGrow : boolean;
    stData    : pointer;
    stDataSize: cardinal;
    stDataTail: PByte;
  protected
    procedure CheckPointer(pData: pointer; dataSize: cardinal);
    function  GetKey(index: cardinal): string;
    function  GetValue(index: cardinal): int64;
    procedure Grow(requiredSize: cardinal);
    procedure SetValue(index: cardinal; const value: int64);
  public
    constructor Create(initialSize: cardinal; canGrow: boolean = true);
    destructor  Destroy; override;
    function  Add(const key: string; value: int64): cardinal;
    procedure Get(index: cardinal; var key: string; var value: int64);
    {$IFDEF GpStringHash_Enumerators}
    function  GetEnumerator: TGpStringTableEnumerator;
    {$ENDIF GpStringHash_Enumerators}
    property Key[index: cardinal]: string read GetKey;
    property Value[index: cardinal]: int64 read GetValue write SetValue;
  end; { TGpStringTable }

  {$IFDEF GpStringHash_Enumerators}
  TGpStringDictionaryEnumerator = TGpStringTableEnumerator;
  {$ENDIF GpStringHash_Enumerators}

  PGpTableHashItem = ^TGpTableHashItem;
  TGpTableHashItem = record
    Next : cardinal;
    Index: cardinal;
  end; { TGpHashItem }

  ///<summary>A dictionary of <string, cardinal, int64> triplets.</summary>
  ///<since>2008-10-20</since>
  TGpStringDictionary = class
  private
    sdBuckets    : array of cardinal;
    sdCanGrow    : boolean;
    sdFirstEmpty : cardinal;
    sdItems      : array of TGpTableHashItem;
    sdNumBuckets : cardinal;
    sdSize       : cardinal;
    sdStringTable: TGpStringTable;
  protected
    function  FindBucket(const key: string): cardinal;
    function  GetHashItem(idxHashItem: cardinal): PGpTableHashItem;{$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    function  GetItems(const key: string): int64;                  {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    procedure Grow;
    procedure SetItems(const key: string; const value: int64);   {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    property  HashItems[idxItem: cardinal]: PGpTableHashItem read GetHashItem;
  public
    constructor Create(initialArraySize: cardinal);
    destructor  Destroy; override;
    function  Add(const key: string; value: int64): cardinal;
    function  Count: integer;                                    {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    function  Find(const key: string; var index: cardinal; var value: int64): boolean;
    procedure Get(index: cardinal; var key: string; var value: int64);
    {$IFDEF GpStringHash_Enumerators}
    function  GetEnumerator: TGpStringDictionaryEnumerator;      {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    {$ENDIF GpStringHash_Enumerators}
    function  HasKey(const key: string): boolean;                {$IFDEF GpStringHash_Inline}inline;{$ENDIF GpStringHash_Inline}
    procedure Update(const key: string; value: int64);
    function  ValueOf(const key: string): int64;
    property Items[const key: string]: int64 read GetItems write SetItems; default;
  end; { TGpStringDictionary }

function GetGoodHashSize(dataSize: cardinal): cardinal;

implementation

uses
  SysUtils,
  DSiWin32;

const
  //List of good hash table sizes, taken from
  //http://planetmath.org/encyclopedia/GoodHashTablePrimes.html
  CGpGoodHashSizes: array [5..30] of cardinal = (53, 97, 193, 389, 769, 1543, 3079, 6151,
    12289, 24593, 49157, 98317, 196613, 393241, 786433, 1572869, 3145739, 6291469,
    12582917, 25165843, 50331653, 100663319, 201326611, 402653189, 805306457, 1610612741);

{$R-,Q-}

function GetGoodHashSize(dataSize: cardinal): cardinal;
var
  iHashSize: integer;
  upper    : cardinal;
begin
  upper := 1 SHL Low(CGpGoodHashSizes);
  for iHashSize := Low(CGpGoodHashSizes) to High(CGpGoodHashSizes) do begin
    Result := CGpGoodHashSizes[iHashSize];
    if dataSize <= upper then
      Exit;
    upper := 2*upper;
  end;
  raise Exception.CreateFmt('GetGoodHashSize: Only data sizes up to %d are supported',
    [upper div 2]);
end; { GetGoodHashSize }

function HashOf(const key: string): cardinal;
asm
      xor       edx,edx         { result := 0 }
      and       eax,eax         { test if 0 }
      jz        @End            { skip if nil }
      mov       ecx,[eax-4]     { ecx := string length }
      jecxz     @End            { skip if length = 0 }
@loop:                          { repeat }
      rol       edx,2           {   edx := (edx shl 2) or (edx shr 30)... }
      xor       dl,[eax]        {   ... xor Ord(key[eax]) }
      inc       eax             {   inc(eax) }
      loop      @loop           { until ecx = 0 }
@End:
      mov       eax,edx         { result := eax }
end; { HashOf }

{$IFDEF GpStringHash_Enumerators}
{ TGpStringHashEnumerator }

constructor TGpStringHashEnumerator.Create(stringHash: TGpStringHash);
begin
  sheIndex := 0;
  sheHash := stringHash;
end; { TGpStringHashEnumerator.Create }

function TGpStringHashEnumerator.GetCurrent: integer;
begin
  Result := sheHash.shItems[sheIndex].Value;
end; { TGpStringHashEnumerator.GetCurrent }

function TGpStringHashEnumerator.MoveNext: boolean;
begin
  Result := sheIndex < (sheHash.shFirstEmpty - 1);
  if Result then
    Inc(sheIndex);
end; { TGpStringHashEnumerator.MoveNext }
{$ENDIF GpStringHash_Enumerators}

{ TGpStringHash }

constructor TGpStringHash.Create(numItems: cardinal; canGrow: boolean);
begin
  Create(GetGoodHashSize(numItems), numItems, canGrow);
end; { TGpStringHash.Create }

constructor TGpStringHash.Create(numBuckets, numItems: cardinal; canGrow: boolean);
begin
  inherited Create;
  SetLength(shBuckets, numBuckets);
  SetLength(shItems, numItems + 1);
  shItems[0].Value := -1; // sentinel for the ValueOf operation
  shSize := numItems;
  shNumBuckets := numBuckets;
  shFirstEmpty := 1;
  shCanGrow := canGrow;
end; { TGpStringHash.Create }

destructor TGpStringHash.Destroy;
begin
  SetLength(shItems, 0);
  SetLength(shBuckets, 0);
  inherited Destroy;
end; { TGpStringHash.Destroy }

procedure TGpStringHash.Add(const key: string; value: integer);
var
  bucket: PGpHashItem;
  hash  : cardinal;
begin
  hash := HashOf(key) mod shNumBuckets;
  if shFirstEmpty > shSize then
    if shCanGrow then
      Grow
    else
      raise Exception.Create('TGpStringHash.Add: Maximum size reached');
  bucket := @(shItems[shFirstEmpty]); // point to an empty slot in the pre-allocated array
  bucket^.Key := key;
  bucket^.Value := value;
  bucket^.Next := shBuckets[hash];
  shBuckets[hash] := shFirstEmpty;
  Inc(shFirstEmpty);
end; { TGpStringHash.Add }

function TGpStringHash.Count: integer;
begin
  Result := shFirstEmpty - 1;
end; { TGpStringHash.Count }

function TGpStringHash.Find(const key: string; var value: integer): boolean;
var
  bucket: integer;
begin
  bucket := FindBucket(key);
  if bucket > 0 then begin
    value := shItems[bucket].Value;
    Result := true;
  end
  else
    Result := false;
end; { TGpStringHash.Find }

{$IFDEF GpStringHash_Enumerators}
function TGpStringHash.GetEnumerator: TGpStringHashEnumerator;
begin
  Result := TGpStringHashEnumerator.Create(Self);
end; { TGpStringHash.GetEnumerator }
{$ENDIF GpStringHash_Enumerators}

function TGpStringHash.FindBucket(const key: string): cardinal;
begin
  Result := shBuckets[HashOf(key) mod shNumBuckets];
  while (Result <> 0) and (shItems[Result].Key <> key) do
    Result := shItems[Result].Next;
end; { TGpStringHash.FindBucket }

function TGpStringHash.GetHashItem(idxHashItem: cardinal): PGpHashItem;
begin
  if idxHashItem > 0 then
    Result := @shItems[idxHashItem]
  else
    Result := nil;
end; { TGpStringHash.GetHashItem }

function TGpStringHash.GetItems(const key: string): integer;
begin
  Result := ValueOf(key);
end; { TGpStringHash.GetItems }

procedure TGpStringHash.Grow;
var
  bucket      : PGpHashItem;
  hash        : cardinal;
  oldBucket   : PGpHashItem;
  oldIndex    : integer;
  shOldBuckets: array of cardinal;
  shOldItems  : array of TGpHashItem;
begin
  SetLength(shOldBuckets, Length(shBuckets));
  Move(shBuckets[0], shOldBuckets[0], Length(shBuckets) * SizeOf(shBuckets[0]));
  SetLength(shOldItems, Length(shItems));
  for oldIndex := 0 to Length(shItems) - 1 do  begin
    shOldItems[oldIndex] := shItems[oldIndex];
    shItems[oldIndex].Key := '';
    shItems[oldIndex].Next := 0;
  end;
  SetLength(shItems, 2*Length(shItems) + 1);
  SetLength(shBuckets, GetGoodHashSize(Length(shItems)));
  FillChar(shBuckets[0], Length(shBuckets) * SizeOf(shBuckets[0]), 0);
  shItems[0].Value := -1; // sentinel for the ValueOf operation
  shSize := Length(shItems) - 1;
  shNumBuckets := Length(shBuckets);
  shFirstEmpty := 1;
  for oldIndex := 1 to Length(shOldItems) - 1 do begin
    oldBucket := @(shOldItems[oldIndex]);
    hash := HashOf(oldBucket.Key) mod shNumBuckets;
    bucket := @(shItems[shFirstEmpty]); // point to an empty slot in the pre-allocated array
    Move(oldBucket^, bucket^, SizeOf(bucket^) - SizeOf(bucket^.Next));
    bucket^.Next := shBuckets[hash];
    shBuckets[hash] := shFirstEmpty;
    Inc(shFirstEmpty);
  end;
  FillChar(shOldItems[0], Length(shOldItems) * SizeOf(shOldItems[0]), 0); //prevent string refcount problems
end; { TGpStringHash.Grow }

function TGpStringHash.HasKey(const key: string): boolean;
begin
  Result := (FindBucket(key) <> 0);
end; { TGpStringHash.HasKey }

procedure TGpStringHash.SetItems(const key: string; const value: integer);
begin
  Update(key, value);
end; { TGpStringHash.SetItems }

procedure TGpStringHash.Update(const key: string; value: integer);
var
  bucket: integer;
begin
  bucket := FindBucket(key);
  if bucket > 0 then
    shItems[bucket].Value := value
  else
    Add(key, value);
end; { TGpStringHash.Update }

function TGpStringHash.ValueOf(const key: string): integer;
var
  bucket: integer;
begin
  bucket := FindBucket(key);
  if bucket > 0 then
    Result := shItems[bucket].Value
  else
    raise Exception.CreateFmt('TGpStringHash.ValueOf: Key %s does not exist', [key]);
end; { TGpStringHash.ValueOf }

{ TGpStringObjectHashEnumerator }

constructor TGpStringObjectHashEnumerator.Create(stringHash: TGpStringHash);
begin
  soheStringEnumerator := TGpStringHashEnumerator.Create(stringHash);
end; { TGpStringObjectHashEnumerator.Create }

destructor TGpStringObjectHashEnumerator.Destroy;
begin
  FreeAndNil(soheStringEnumerator);
  inherited;
end; { TGpStringObjectHashEnumerator.Destroy }

function TGpStringObjectHashEnumerator.GetCurrent: TObject;
begin
  Result := TObject(soheStringEnumerator.GetCurrent);
end; { TGpStringObjectHashEnumerator.GetCurrent }

function TGpStringObjectHashEnumerator.MoveNext: boolean;
begin
  Result := soheStringEnumerator.MoveNext;
end; { TGpStringObjectHashEnumerator.MoveNext }

{ TGpStringObjectHash }

constructor TGpStringObjectHash.Create(numItems: cardinal; ownsObjects, canGrow: boolean);
begin
  inherited Create;
  sohOwnsObjects := ownsObjects;
  sohHash := TGpStringHash.Create(numItems, canGrow);
end; { TGpStringObjectHash.Create }

constructor TGpStringObjectHash.Create(numBuckets, numItems: cardinal; ownsObjects,
  canGrow: boolean);
begin
  inherited Create;
  sohOwnsObjects := ownsObjects;
  sohHash := TGpStringHash.Create(numBuckets, numItems, canGrow);
end; { TGpStringObjectHash.Create }

destructor TGpStringObjectHash.Destroy;
var
  obj: TObject;
begin
  if sohOwnsObjects and assigned(sohHash) then
    for obj in Self do
      obj.Free;
  FreeAndNil(sohHash);
  inherited;
end; { TGpStringObjectHash.Destroy }

procedure TGpStringObjectHash.Add(const key: string; value: TObject);
begin
  sohHash.Add(key, integer(value));
end; { TGpStringObjectHash.Add }

function TGpStringObjectHash.Count: integer;
begin
  Result := sohHash.Count;
end; { TGpStringObjectHash.Count }

function TGpStringObjectHash.Find(const key: string; var value: TObject): boolean;
begin
  Result := sohHash.Find(key, integer(value));
end;  { TGpStringObjectHash.Find }

{$IFDEF GpStringHash_Enumerators}
function TGpStringObjectHash.GetEnumerator: TGpStringObjectHashEnumerator;
begin
  Result := TGpStringObjectHashEnumerator.Create(sohHash);
end; { TGpStringObjectHash.GetEnumerator }
{$ENDIF GpStringHash_Enumerators}

function TGpStringObjectHash.GetObjects(const key: string): TObject;
var
  value: integer;
begin
  if sohHash.Find(key, value) then
    Result := TObject(value)
  else
    Result := nil;
end; { TGpStringObjectHash.GetObjects }

function TGpStringObjectHash.HasKey(const key: string): boolean;
begin
  Result := sohHash.HasKey(key);
end; { TGpStringObjectHash.HasKey }

procedure TGpStringObjectHash.SetObjects(const key: string; const value: TObject);
begin
  Update(key, value);
end; { TGpStringObjectHash.SetObjects }

procedure TGpStringObjectHash.Update(const key: string; value: TObject);
var
  bucket: cardinal;
  item  : PGpHashItem;
begin
  if not sohOwnsObjects then
    sohHash.Update(key, integer(value))
  else begin
    bucket := sohHash.FindBucket(key);
    if bucket > 0 then begin
      item := sohHash.HashItems[bucket];
      if TObject(item.Value) <> value then
        TObject(item.Value).Free;
      item.Value := integer(value);
    end
    else
      sohHash.Add(key, integer(value));
  end;
end; { TGpStringObjectHash.Update }

function TGpStringObjectHash.ValueOf(const key: string): TObject;
begin
  Result := TObject(sohHash.ValueOf(key));
end; { TGpStringObjectHash.ValueOf }

{$IFDEF GpStringHash_Enumerators}
{ TGpStringTableEnumerator }

constructor TGpStringTableEnumerator.Create(pTable, pTail: pointer);
begin
  inherited Create;
  steCurrent := TGpStringTableKV.Create;
  steTable := pTable;
  steTail := pTail;
end; { TGpStringTableEnumerator.Create }

destructor TGpStringTableEnumerator.Destroy;
begin
  FreeAndNil(steCurrent);
  inherited;
end; { TGpStringTableEnumerator.Destroy }

function TGpStringTableEnumerator.GetCurrent: TGpStringTableKV;
var
  lenStr: cardinal;
begin
  lenStr := PCardinal(steTable)^;
  SetLength(steCurrent.kvKey, lenStr);
  Inc(steTable, SizeOf(cardinal));
  if Length(steCurrent.kvKey) > 0 then begin
    Move(steTable^, steCurrent.kvKey[1], lenStr*SizeOf(char));
    Inc(steTable, lenStr*SizeOf(char));
  end;
  steCurrent.kvValue := PInt64(steTable)^;
  Inc(steTable, SizeOf(int64));
  Result := steCurrent;
end; { TGpStringTableEnumerator.GetCurrent }

function TGpStringTableEnumerator.MoveNext: boolean;
begin
  Result := cardinal(steTable) < cardinal(steTail);
end; { TGpStringTableEnumerator.MoveNext }
{$ENDIF GpStringHash_Enumerators}

{ TGpStringTable }

constructor TGpStringTable.Create(initialSize: cardinal; canGrow: boolean);
begin
  inherited Create;
  GetMem(stData, initialSize);
  stDataSize := initialSize;
  stDataTail := stData;
  stCanGrow := canGrow;
end; { TGpStringTable.Create }

destructor TGpStringTable.Destroy;
begin
  DSiFreeMemAndNil(stData);
  inherited;
end; { TGpStringTable.Destroy }

function TGpStringTable.Add(const key: string; value: int64): cardinal;
var
  requiredSize: cardinal;
begin
  if key = '' then
    raise Exception.Create('TGpStringTable.Add: Cannot store empty key');
  Result := cardinal(stDataTail) - cardinal(stData);
  requiredSize := Result + SizeOf(cardinal) + cardinal(Length(key)*SizeOf(char)) + SizeOf(int64);
  if requiredSize > stDataSize then
    Grow(requiredSize);
  PCardinal(stDataTail)^ := Length(key);
  Inc(stDataTail, SizeOf(cardinal));
  Move(key[1], stDataTail^, Length(key)*SizeOf(char));
  Inc(stDataTail, Length(key)*SizeOf(char));
  PInt64(stDataTail)^ := value;
  Inc(stDataTail, SizeOf(int64));
end; { TGpStringTable.Add }

procedure TGpStringTable.CheckPointer(pData: pointer; dataSize: cardinal);
begin
  if (cardinal(pData) + dataSize - cardinal(stData)) > stDataSize then
    raise Exception.Create('TGpStringTable: Invalid index');
end; { TGpStringTable.CheckPointer }

procedure TGpStringTable.Grow(requiredSize: cardinal);
var
  pNewData: pointer;
begin
  if not stCanGrow then
    raise Exception.Create('TGpStringTable.Grow: String table size is fixed');
  requiredSize := Round(requiredSize * 1.6);
  GetMem(pNewData, requiredSize);
  Move(stData^, pNewData^, stDataSize);
  stDataSize := requiredSize;
  stDataTail := PByte(cardinal(stDataTail) - cardinal(stData) + cardinal(pNewData));
  FreeMem(stData);
  stData := pNewData;
end; { TGpStringTable.Grow }

procedure TGpStringTable.Get(index: cardinal; var key: string; var value: int64);
var
  lenStr: cardinal;
  pData : PByte;
begin 
  pData := pointer(cardinal(stData) + index);
  CheckPointer(pData, SizeOf(cardinal));
  lenStr := PCardinal(pData)^;
  Inc(pData, SizeOf(cardinal));
  CheckPointer(pData, lenStr);
  SetLength(key, lenStr);
  if lenStr > 0 then begin
    Move(pData^, key[1], lenStr*SizeOf(char));
    Inc(pData, lenStr*SizeOf(char));
  end;
  CheckPointer(pData, SizeOf(int64));
  value := PInt64(pData)^;
end; { TGpStringTable.Get }

{$IFDEF GpStringHash_Enumerators}
function TGpStringTable.GetEnumerator: TGpStringTableEnumerator;
begin
  Result := TGpStringTableEnumerator.Create(stData, stDataTail);
end; { TGpStringTable.GetEnumerator }
{$ENDIF GpStringHash_Enumerators}

function TGpStringTable.GetKey(index: cardinal): string;
var
  lenStr: cardinal;
  pData : PByte;
begin 
  pData := pointer(cardinal(stData) + index);
  CheckPointer(pData, SizeOf(cardinal));
  lenStr := PCardinal(pData)^;
  Inc(pData, SizeOf(cardinal));
  CheckPointer(pData, lenStr);
  SetLength(Result, lenStr);
  if lenStr > 0 then
    Move(pData^, Result[1], lenStr*SizeOf(char));
end; { TGpStringTable.GetKey }

function TGpStringTable.GetValue(index: cardinal): int64;
var
  lenStr: cardinal;
  pData : PByte;
begin
  pData := pointer(cardinal(stData) + index);
  CheckPointer(pData, SizeOf(cardinal));
  lenStr := PCardinal(pData)^;
  Inc(pData, SizeOf(cardinal));
  CheckPointer(pData, lenStr);
  Inc(pData, lenStr);
  CheckPointer(pData, SizeOf(int64));
  Result := PInt64(pData)^;
end; { TGpStringTable.GetValue }

procedure TGpStringTable.SetValue(index: cardinal; const value: int64);
var
  lenStr: cardinal;
  pData: PByte;
begin
  pData := pointer(cardinal(stData) + index);
  CheckPointer(pData, SizeOf(cardinal));
  lenStr := PCardinal(pData)^;
  Inc(pData, SizeOf(cardinal));
  CheckPointer(pData, lenStr);
  Inc(pData, lenStr);
  CheckPointer(pData, SizeOf(int64));
  PInt64(pData)^ := value;
end; { TGpStringTable.SetValue }

{ TGpStringDictionary }

constructor TGpStringDictionary.Create(initialArraySize: cardinal);
begin
  inherited Create;
  sdStringTable := TGpStringTable.Create(initialArraySize);
  sdNumBuckets := GetGoodHashSize(initialArraySize);
  SetLength(sdBuckets, sdNumBuckets);
  SetLength(sdItems, initialArraySize + 1);
  sdSize := initialArraySize;
  sdFirstEmpty := 1;
  sdCanGrow := true;
end; { TGpStringDictionary.Create }

destructor TGpStringDictionary.Destroy;
begin
  SetLength(sdItems, 0);
  SetLength(sdBuckets, 0);
  FreeAndNil(sdStringTable);
  inherited Destroy;
end; { TGpStringDictionary.Destroy }

function TGpStringDictionary.Add(const key: string; value: int64): cardinal;
var
  bucket: PGpTableHashItem;
  hash  : cardinal;
begin
  hash := HashOf(key) mod sdNumBuckets;
  if sdFirstEmpty > sdSize then
    if sdCanGrow then
      Grow
    else
      raise Exception.Create('TGpStringDictionary.Add: Maximum size reached');
  bucket := @(sdItems[sdFirstEmpty]); // point to an empty slot in the pre-allocated array
  bucket^.Index := sdStringTable.Add(key, value);
  bucket^.Next := sdBuckets[hash];
  sdBuckets[hash] := sdFirstEmpty;
  Inc(sdFirstEmpty);
  Result := bucket^.index;
end; { TGpStringDictionary.Add }

function TGpStringDictionary.Count: integer;
begin
  Result := sdFirstEmpty - 1;
end; { TGpStringDictionary.Count }

function TGpStringDictionary.Find(const key: string; var index: cardinal; var value:
  int64): boolean;
var
  bucket: integer;
begin
  bucket := FindBucket(key);
  if bucket > 0 then begin
    index := sdItems[bucket].Index;
    value := sdStringTable.Value[index];
    Result := true;
  end
  else
    Result := false;
end; { TGpStringDictionary.Find }

function TGpStringDictionary.FindBucket(const key: string): cardinal;
begin
  Result := sdBuckets[HashOf(key) mod sdNumBuckets];
  while (Result <> 0) and (sdStringTable.Key[sdItems[Result].Index] <> key) do
    Result := sdItems[Result].Next;
end; { TGpStringDictionary.FindBucket }

procedure TGpStringDictionary.Get(index: cardinal; var key: string; var value: int64);
begin
  sdStringTable.Get(index, key, value);
end; { TGpStringDictionary.Get }

{$IFDEF GpStringHash_Enumerators}
function TGpStringDictionary.GetEnumerator: TGpStringDictionaryEnumerator;
begin
  Result := sdStringTable.GetEnumerator;
end; { TGpStringDictionary.GetEnumerator }
{$ENDIF GpStringHash_Enumerators}

function TGpStringDictionary.GetHashItem(idxHashItem: cardinal): PGpTableHashItem;
begin
  if idxHashItem > 0 then
    Result := @sdItems[idxHashItem]
  else
    Result := nil;
end; { TGpStringDictionary.GetHashItem }

function TGpStringDictionary.GetItems(const key: string): int64;
begin
  Result := ValueOf(key);
end; { TGpStringDictionary.GetItems }

procedure TGpStringDictionary.Grow;
var
  bucket      : PGpTableHashItem;
  hash        : cardinal;
  oldBucket   : PGpTableHashItem;
  oldIndex    : integer;
  shOldBuckets: array of cardinal;
  shOldItems  : array of TGpTableHashItem;
begin
  SetLength(shOldBuckets, Length(sdBuckets));
  Move(sdBuckets[0], shOldBuckets[0], Length(sdBuckets) * SizeOf(sdBuckets[0]));
  SetLength(shOldItems, Length(sdItems));
  for oldIndex := 0 to Length(sdItems) - 1 do  begin
    shOldItems[oldIndex] := sdItems[oldIndex];
    sdItems[oldIndex].Next := 0;
  end;
  SetLength(sdItems, 2*Length(sdItems) + 1);
  SetLength(sdBuckets, GetGoodHashSize(Length(sdItems)));
  FillChar(sdBuckets[0], Length(sdBuckets) * SizeOf(sdBuckets[0]), 0);
  sdSize := Length(sdItems) - 1;
  sdNumBuckets := Length(sdBuckets);
  sdFirstEmpty := 1;
  for oldIndex := 1 to Length(shOldItems) - 1 do begin
    oldBucket := @(shOldItems[oldIndex]);
    hash := HashOf(sdStringTable.Key[oldBucket.index]) mod sdNumBuckets;
    bucket := @(sdItems[sdFirstEmpty]); // point to an empty slot in the pre-allocated array
    Move(oldBucket^, bucket^, SizeOf(bucket^) - SizeOf(bucket^.Next));
    bucket^.Next := sdBuckets[hash];
    sdBuckets[hash] := sdFirstEmpty;
    Inc(sdFirstEmpty);
  end;
  FillChar(shOldItems[0], Length(shOldItems) * SizeOf(shOldItems[0]), 0); //prevent string refcount problems
end; { TGpStringDictionary.Grow }

function TGpStringDictionary.HasKey(const key: string): boolean;
begin
  Result := (FindBucket(key) <> 0);
end; { TGpStringDictionary.HasKey }

procedure TGpStringDictionary.SetItems(const key: string; const value: int64);
begin
  Update(key, value);
end; { TGpStringDictionary.SetItems }

procedure TGpStringDictionary.Update(const key: string; value: int64);
var
  bucket: integer;
begin
  bucket := FindBucket(key);
  if bucket > 0 then
    sdStringTable.Value[sdItems[bucket].Index] := value
  else
    Add(key, value);
end; { TGpStringDictionary.Update }

function TGpStringDictionary.ValueOf(const key: string): int64;
var
  bucket: integer;
begin
  bucket := FindBucket(key);
  if bucket > 0 then
    Result := sdStringTable.Value[sdItems[bucket].Index]
  else
    raise Exception.CreateFmt('TGpStringDictionary.ValueOf: Key %s does not exist', [key]);
end; { TGpStringDictionary.ValueOf }

end.

