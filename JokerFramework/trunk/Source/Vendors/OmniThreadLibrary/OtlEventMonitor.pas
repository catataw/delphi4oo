///<summary>Event dispatching component. Part of the OmniThreadLibrary project.</summary>
///<author>Primoz Gabrijelcic</author>
///<license>
///This software is distributed under the BSD license.
///
///Copyright (c) 2010, Primoz Gabrijelcic
///All rights reserved.
///
///Redistribution and use in source and binary forms, with or without modification,
///are permitted provided that the following conditions are met:
///- Redistributions of source code must retain the above copyright notice, this
///  list of conditions and the following disclaimer.
///- Redistributions in binary form must reproduce the above copyright notice,
///  this list of conditions and the following disclaimer in the documentation
///  and/or other materials provided with the distribution.
///- The name of the Primoz Gabrijelcic may not be used to endorse or promote
///  products derived from this software without specific prior written permission.
///
///THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
///ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
///WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
///DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
///ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
///(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
///LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
///ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
///(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
///SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
///</license>
///<remarks><para>
///   Home              : http://otl.17slon.com
///   Support           : http://otl.17slon.com/forum/
///   Author            : Primoz Gabrijelcic
///     E-Mail          : primoz@gabrijelcic.org
///     Blog            : http://thedelphigeek.com
///     Web             : http://gp.17slon.com
///   Contributors      : GJ, Lee_Nover
///
///   Creation date     : 2008-06-12
///   Last modification : 2010-03-03
///   Version           : 1.01
///</para><para>
///   History:
///     1.01: 2010-03-03
///       - Implemented TOmniEventMonitorPool, per-thread TOmniEventMonitor allocator.
///     1.0a: 2009-01-26
///       - Pass correct task ID to the OnPoolWorkItemCompleted handler.
///     1.0: 2008-08-26
///       - First official release.
///</para></remarks>

{$WARN SYMBOL_PLATFORM OFF}

unit OtlEventMonitor;

interface

uses
  Messages,
  Classes,
  GpStuff,
  GpLists,
  OtlCommon,
  OtlComm,
  OtlSync,
  OtlTaskControl,
  OtlThreadPool;

type
  TOmniTaskEvent = procedure(const task: IOmniTaskControl) of object;
  TOmniTaskMessageEvent = procedure(const task: IOmniTaskControl; const msg: TOmniMessage) of object;
  TOmniPoolThreadEvent = procedure(const pool: IOmniThreadPool; threadID: integer) of object;
  TOmniPoolWorkItemEvent = procedure(const pool: IOmniThreadPool; taskID: int64) of object;

  TOmniEventMonitor = class(TComponent, IOmniTaskControlMonitor, IOmniThreadPoolMonitor)
  strict private
    emMessageWindow           : THandle;
    emMonitoredPools          : IOmniInterfaceDictionary;
    emMonitoredTasks          : IOmniInterfaceDictionary;
    emOnPoolThreadCreated     : TOmniPoolThreadEvent;
    emOnPoolThreadDestroying  : TOmniPoolThreadEvent;
    emOnPoolThreadKilled      : TOmniPoolThreadEvent;
    emOnPoolWorkItemEvent     : TOmniPoolWorkItemEvent;
    emOnTaskMessage           : TOmniTaskMessageEvent;
    emOnTaskUndeliveredMessage: TOmniTaskMessageEvent;
    emOnTaskTerminated        : TOmniTaskEvent;
    emCurrentMsg              : TOmniMessage;
  strict protected
    procedure WndProc(var msg: TMessage);
  public
    constructor Create(AOwner: TComponent); override; 
    destructor  Destroy; override;
    function  Detach(const task: IOmniTaskControl): IOmniTaskControl; overload;
    function  Detach(const pool: IOmniThreadPool): IOmniThreadPool; overload;
    function  Monitor(const task: IOmniTaskControl): IOmniTaskControl; overload;
    function  Monitor(const pool: IOmniThreadPool): IOmniThreadPool; overload;
  published
    property OnPoolThreadCreated: TOmniPoolThreadEvent read emOnPoolThreadCreated
      write emOnPoolThreadCreated;
    property OnPoolThreadDestroying: TOmniPoolThreadEvent read emOnPoolThreadDestroying
      write emOnPoolThreadDestroying;
    property OnPoolThreadKilled: TOmniPoolThreadEvent read emOnPoolThreadKilled
      write emOnPoolThreadKilled;
    property OnPoolWorkItemCompleted: TOmniPoolWorkItemEvent read emOnPoolWorkItemEvent
      write emOnPoolWorkItemEvent;
    property OnTaskMessage: TOmniTaskMessageEvent read emOnTaskMessage
      write emOnTaskMessage;
    property OnTaskTerminated: TOmniTaskEvent read emOnTaskTerminated
      write emOnTaskTerminated;
    property OnTaskUndeliveredMessage: TOmniTaskMessageEvent
      read emOnTaskUndeliveredMessage write emOnTaskUndeliveredMessage;
  end; { TOmniEventMonitor }

  TOmniEventMonitorClass = class of TOmniEventMonitor;

  ///<summary>A pool of per-thread event monitors.</summary>
  ///<since>2010-03-03</since>
  TOmniEventMonitorPool = class
  strict private
    empListLock    : TOmniCS;
    empMonitorClass: TOmniEventMonitorClass;
    empMonitorList : TGpIntegerObjectList;
  public
    constructor Create;
    destructor  Destroy; override;
    function  Allocate: TOmniEventMonitor;
    procedure Release(monitor: TOmniEventMonitor);
    property MonitorClass: TOmniEventMonitorClass read empMonitorClass write empMonitorClass;
  end; { TOmniEventMonitorPool }

var
  COmniTaskMsg_NewMessage: cardinal;
  COmniTaskMsg_Terminated: cardinal;
  COmniPoolMsg           : cardinal;
  
implementation

uses
  Windows,
  SysUtils,
  DSiWin32;

const
  CMaxReceiveLoop_ms = 5;

type
  ///<summary>Reference counted TOmniEventMonitor.</summary>
  TOmniCountedEventMonitor = class
  strict private
    cemMonitor : TOmniEventMonitor;
    cemRefCount: integer;
  public
    constructor Create(monitor: TOmniEventMonitor);
    destructor  Destroy; override;
    function  Allocate: TOmniEventMonitor;
    procedure Release;
    property Monitor: TOmniEventMonitor read cemMonitor;
    property RefCount: integer read cemRefCount;
  end; { TOmniCountedEventMonitor }

{ TOmniEventMonitor }

constructor TOmniEventMonitor.Create(AOwner: TComponent);
begin
  inherited;
  emMessageWindow := DSiAllocateHWnd(WndProc);
  Win32Check(emMessageWindow <> 0);
  emMonitoredTasks := CreateInterfaceDictionary;
  emMonitoredPools := CreateInterfaceDictionary;
end; { TOmniEventMonitor.Create }

destructor TOmniEventMonitor.Destroy;
var
  intfKV: TOmniInterfaceDictionaryPair;
begin
  for intfKV in emMonitoredTasks do
    (intfKV.Value as IOmniTaskControl).RemoveMonitor;
  emMonitoredTasks.Clear;
  for intfKV in emMonitoredPools do
    (intfKV.Value as IOmniThreadPool).RemoveMonitor;
  emMonitoredPools.Clear;
  if emMessageWindow <> 0 then begin
    DSiDeallocateHWnd(emMessageWindow);
    emMessageWindow := 0;
  end;
  inherited;
end; { TOmniEventMonitor.Destroy }

function TOmniEventMonitor.Detach(const task: IOmniTaskControl): IOmniTaskControl;
begin
  Result := task.RemoveMonitor;
  emMonitoredTasks.Remove(task.UniqueID);
end; { TOmniEventMonitor.Detach }

function TOmniEventMonitor.Detach(const pool: IOmniThreadPool): IOmniThreadPool;
begin
  Result := pool.RemoveMonitor;
  emMonitoredPools.Remove(pool.UniqueID);
end; { TOmniEventMonitor.Detach }

function TOmniEventMonitor.Monitor(const task: IOmniTaskControl): IOmniTaskControl;
begin
  emMonitoredTasks.Add(task.UniqueID, task);
  Result := task.SetMonitor(emMessageWindow);
end; { TOmniEventMonitor.Monitor }

function TOmniEventMonitor.Monitor(const pool: IOmniThreadPool): IOmniThreadPool;
begin
  emMonitoredPools.Add(pool.UniqueID, pool);
  Result := pool.SetMonitor(emMessageWindow);
end; { TOmniEventMonitor.Monitor }

procedure TOmniEventMonitor.WndProc(var msg: TMessage);
var
  endpoint     : IOmniCommunicationEndpoint;
  pool         : IOmniThreadPool;
  task         : IOmniTaskControl;
  timeStart    : int64;
  tpMonitorInfo: TOmniThreadPoolMonitorInfo;

  function ProcessMessages(timeout_ms: integer = CMaxReceiveLoop_ms;
    rearmSelf: boolean = true): boolean;
  begin
    Result := true;
    while task.Comm.Receive(emCurrentMsg) do begin
      if assigned(emOnTaskMessage) then
        emOnTaskMessage(task, emCurrentMsg);
      if DSiElapsedSince(GetTickCount, timeStart) > timeout_ms then begin
        if rearmSelf then
          Win32Check(PostMessage(emMessageWindow, COmniTaskMsg_NewMessage, msg.WParam, msg.LParam));
        Result := false;
        break; //while
      end;
    end; //while
  end; { ProcessMessages }

begin { TOmniEventMonitor.WndProc }
  if msg.Msg = COmniTaskMsg_NewMessage then begin
    if assigned(OnTaskMessage) then begin
      task := emMonitoredTasks.ValueOf(Pint64(@msg.WParam)^) as IOmniTaskControl;
      if assigned(task) then begin
        timeStart := GetTickCount;
        ProcessMessages;
      end;
    end;
    msg.Result := 0;
  end
  else if msg.Msg = COmniTaskMsg_Terminated then begin
    if assigned(OnTaskTerminated) then begin
      task := emMonitoredTasks.ValueOf(Pint64(@msg.WParam)^) as IOmniTaskControl;
      if assigned(task) then begin
        endpoint := (task as IOmniTaskControlSharedInfo).SharedInfo.CommChannel.Endpoint1;
        while endpoint.Receive(emCurrentMsg) do
          if Assigned(emOnTaskMessage) then
            emOnTaskMessage(task, emCurrentMsg);
        endpoint := (task as IOmniTaskControlSharedInfo).SharedInfo.CommChannel.Endpoint2;
        while endpoint.Receive(emCurrentMsg) do
          if Assigned(emOnTaskUndeliveredMessage) then
            emOnTaskUndeliveredMessage(task, emCurrentMsg);
        if Assigned(emOnTaskTerminated) then
          OnTaskTerminated(task);
        Detach(task);
      end;
    end;
    msg.Result := 0;
  end
  else if msg.Msg = COmniPoolMsg then begin
    tpMonitorInfo := TOmniThreadPoolMonitorInfo(msg.LParam);
    try
      pool := emMonitoredPools.ValueOf(tpMonitorInfo.UniqueID) as IOmniThreadPool;
      if assigned(pool) then begin
        if tpMonitorInfo.ThreadPoolOperation = tpoCreateThread then begin
          if assigned(OnPoolThreadCreated) then
            OnPoolThreadCreated(pool, tpMonitorInfo.ThreadID);
        end
        else if tpMonitorInfo.ThreadPoolOperation = tpoDestroyThread then begin
          if assigned(OnPoolThreadDestroying) then
            OnPoolThreadDestroying(pool, tpMonitorInfo.ThreadID);
        end
        else if tpMonitorInfo.ThreadPoolOperation = tpoKillThread then begin
          if assigned(OnPoolThreadKilled) then
            OnPoolThreadKilled(pool, tpMonitorInfo.ThreadID);
        end
        else if tpMonitorInfo.ThreadPoolOperation = tpoWorkItemCompleted then begin
          if assigned(OnPoolWorkItemCompleted) then
            OnPoolWorkItemCompleted(pool, tpMonitorInfo.TaskID);
        end;
      end;
    finally FreeAndNil(tpMonitorInfo); end;
  end
  else
    msg.Result := DefWindowProc(emMessageWindow, msg.Msg, msg.WParam, msg.LParam);
end; { TOmniEventMonitor.WndProc }

{ TOmniCountedEventMonitor }

constructor TOmniCountedEventMonitor.Create(monitor: TOmniEventMonitor);
begin
  inherited Create;
  cemMonitor := monitor;
  cemRefCount := 1;
end; { TOmniCountedEventMonitor.Create }

destructor TOmniCountedEventMonitor.Destroy;
begin
  FreeAndNil(cemMonitor);
  inherited;
end; { TOmniCountedEventMonitor.Destroy }

function TOmniCountedEventMonitor.Allocate: TOmniEventMonitor;
begin
  if cemRefCount = 0 then
    cemMonitor := TOmniEventMonitor.Create(nil);
  Inc(cemRefCount);
  Result := cemMonitor;
end; { TOmniCountedEventMonitor.Allocate }

procedure TOmniCountedEventMonitor.Release;
begin
  Assert(cemRefCount > 0);
  Dec(cemRefCount);
  if cemRefCount = 0 then
    FreeAndNil(cemMonitor);
end; { TOmniCountedEventMonitor.Release }

{ TOmniEventMonitorPool }

constructor TOmniEventMonitorPool.Create;
begin
  inherited Create;
  empMonitorList := TGpIntegerObjectList.Create;
  empMonitorList.Sorted := true;
end; { TOmniEventMonitorPool.Create }

destructor TOmniEventMonitorPool.Destroy;
begin
  FreeAndNil(empMonitorList);
  inherited;
end; { TOmniEventMonitorPool.Destroy }

///<summary>Returns monitor associated with the current thread. Allocates new monitor if
///    no monitor has been associated with this thread.</summary>
function TOmniEventMonitorPool.Allocate: TOmniEventMonitor;
var
  monitorInfo: TOmniCountedEventMonitor;
begin
  empListLock.Acquire;
  try
    monitorInfo := TOmniCountedEventMonitor(empMonitorList.FetchObject(integer(GetCurrentThreadID)));
    if assigned(monitorInfo) then
      monitorInfo.Allocate
    else begin
      monitorInfo := TOmniCountedEventMonitor.Create(MonitorClass.Create(nil));
      empMonitorList.AddObject(integer(GetCurrentThreadID), monitorInfo);
    end;
    Result := monitorInfo.Monitor;
  finally empListLock.Release; end;
end; { TOmniEventMonitorPool.Allocate }

///<summary>Releases monitor from the current thread. If monitor is no longer in use,
///    destroys the monitor.</summary>
///<since>2010-03-03</since>
procedure TOmniEventMonitorPool.Release(monitor: TOmniEventMonitor);
var
  idxMonitor : integer;
  monitorInfo: TOmniCountedEventMonitor;
begin
  empListLock.Acquire;
  try
    idxMonitor := empMonitorList.IndexOf(integer(GetCurrentThreadID));
    if idxMonitor < 0 then
      raise Exception.CreateFmt(
        'TOmniEventMonitorPool.Release: Monitor is not allocated for thread %d',
        [GetCurrentThreadID]);
    monitorInfo := TOmniCountedEventMonitor(empMonitorList.Objects[idxMonitor]);
    Assert(monitorInfo.Monitor = monitor);
    monitorInfo.Release;
    if monitorInfo.RefCount = 0 then
      empMonitorList.Delete(idxMonitor);
  finally empListLock.Release; end;
end; { TOmniEventMonitorPool.Release }

initialization
  COmniTaskMsg_NewMessage := RegisterWindowMessage('Gp/OtlTaskEvents/NewMessage');
  Win32Check(COmniTaskMsg_NewMessage <> 0);
  COmniTaskMsg_Terminated := RegisterWindowMessage('Gp/OtlTaskEvents/Terminated');
  Win32Check(COmniTaskMsg_Terminated <> 0);
  COmniPoolMsg := RegisterWindowMessage('Gp/OtlThreadPool');
  Win32CHeck(COmniPoolMsg <> 0);
end.
