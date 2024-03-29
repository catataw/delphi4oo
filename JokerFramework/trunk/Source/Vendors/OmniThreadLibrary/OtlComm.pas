///<summary>Two-way intraprocess communication channel. Part of the OmniThreadLibrary project.</summary>
///<author>Primoz Gabrijelcic</author>
///<license>
///This software is distributed under the BSD license.
///
///Copyright (c) 2009, Primoz Gabrijelcic
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
///   Author            : Primoz Gabrijelcic
///   Contributors      : GJ, Lee_Nover
///   Creation date     : 2008-06-12
///   Last modification : 2009-11-13
///   Version           : 1.05
///</para><para>
///   History:
///     1.05: 2009-11-13
///       - Default queue size reduced to 1000 messages.
///     1.04: 2009-04-05
///       - Implemented TOmniMessageQueue.Empty and TryDequeue.
///       - TOmniMessageQueue empties itself before it is destroyed.
///     1.03: 2008-10-05
///       - Added two overloaded versions of IOmniCommunicationEndpoint.ReceivedWait,
///         which are just simple wrappers for WaitForSingleObject(NewMessageEvent) +
///         Receive.
///       - Defined OmniThreadLibrary-reserved message ID $FFFF.
///     1.02: 2008-09-26
///       - Better default queue calculation that takes into account OtlContainers
///         overhead and FastMM4 granulation.
///     1.01: 2008-09-20
///       - Added two TOmniMessage constructors.
///</para></remarks>

unit OtlComm;

interface

uses
  SyncObjs,
  SpinLock,
  GpStuff,
  DSiWin32,
  OtlCommon,
  OtlContainerObserver,
  OtlContainers;

const
  //reserved for internal OTL messaging
  COtlReservedMsgID = $FFFF;
  //Max send wait time
  CMaxSendWaitTime_ms = 100;

  CDefaultQueueSize = 1000;

type
  {$A4}
  TOmniMessage = record
    MsgID  : word;
    MsgData: TOmniValue;
    constructor Create(aMsgID: word; aMsgData: TOmniValue); overload;
    constructor Create(aMsgID: word); overload;
  end; { TOmniMessage }

  TOmniMessageQueue = class;

  IOmniCommunicationEndpoint = interface ['{910D329C-D049-48B9-B0C0-9434D2E57870}']
    function  GetNewMessageEvent: THandle;
    function  GetOtherEndpoint: IOmniCommunicationEndpoint;
    function  GetReader: TOmniMessageQueue;
    function  GetWriter: TOmniMessageQueue;
  //
    function  Receive(var msg: TOmniMessage): boolean; overload;
    function  Receive(var msgID: word; var msgData: TOmniValue): boolean; overload;
    function  ReceiveWait(var msg: TOmniMessage; timeout_ms: cardinal): boolean; overload;
    function  ReceiveWait(var msgID: word; var msgData: TOmniValue; timeout_ms: cardinal): boolean; overload;
    procedure Send(const msg: TOmniMessage); overload;
    procedure Send(msgID: word); overload;
    procedure Send(msgID: word; msgData: array of const); overload;
    procedure Send(msgID: word; msgData: TOmniValue); overload;
    function  SendWait(msgID: word; timeout_ms: cardinal = CMaxSendWaitTime_ms): boolean; overload;
    function  SendWait(msgID: word; msgData: TOmniValue; timeout_ms: cardinal = CMaxSendWaitTime_ms): boolean; overload;
    property NewMessageEvent: THandle read GetNewMessageEvent;
    property OtherEndpoint: IOmniCommunicationEndpoint read GetOtherEndpoint;
    property Reader: TOmniMessageQueue read GetReader;
    property Writer: TOmniMessageQueue read GetWriter;
  end; { IOmniCommunicationEndpoint }

  IOmniTwoWayChannel = interface ['{3ED1AB88-4209-4E01-AA79-A577AD719520}']
    function Endpoint1: IOmniCommunicationEndpoint;
    function Endpoint2: IOmniCommunicationEndpoint;
  end; { IOmniTwoWayChannel }

  {:Fixed-size ring buffer of TOmniMessage data.
    WARNING Supports only one writer and one reader WARNING
  }
  // TODO 1 -oPrimoz Gabrijelcic : Check if 1 reader/1 write warning still applies.
  TOmniMessageQueue = class(TOmniBoundedQueue)
  strict private
    mqWinEventObserver: TOmniContainerWindowsEventObserver;
  strict protected
    procedure AttachWinEventObserver;
  public
    constructor Create(numMessages: integer; createEventObserver: boolean = true);
      reintroduce;
    destructor  Destroy; override;
    function  Dequeue: TOmniMessage; reintroduce;
    function  Enqueue(const value: TOmniMessage): boolean; reintroduce;
    procedure Empty;
    function  GetNewMessageEvent: THandle;
    function  TryDequeue(var msg: TOmniMessage): boolean; reintroduce;
    property EventObserver: TOmniContainerWindowsEventObserver read mqWinEventObserver;
  end; { TOmniMessageQueue }

  function CreateTwoWayChannel(numElements: integer = CDefaultQueueSize;
    taskTerminatedEvent: THandle = 0): IOmniTwoWayChannel;

implementation

uses
  Windows,
  SysUtils,
  Variants,
  {$IFDEF DEBUG}OtlCommBufferTest,{$ENDIF}
  OtlEventMonitor;

type
  IOmniCommunicationEndpointInternal = interface ['{4F872DE9-6E9A-4881-B9EC-E2189DAC00F4}']
    procedure DetachFromQueues;
  end; { IOmniCommunicationEndpointInternal }

  TOmniTwoWayChannel = class;

  TOmniCommunicationEndpoint = class(TInterfacedObject, IOmniCommunicationEndpoint,
    IOmniCommunicationEndpointInternal)
  strict private
    ceOwner_ref              : TOmniTwoWayChannel;
    cePartlyEmptyObserver    : TOmniContainerWindowsEventObserver;
    ceReader_ref             : TOmniMessageQueue;
    ceTaskTerminatedEvent_ref: THandle;
    ceWriter_ref             : TOmniMessageQueue;
  strict protected
    procedure RequirePartlyEmptyObserver;
  protected
    procedure DetachFromQueues;
    function  GetNewMessageEvent: THandle;
    function  GetOtherEndpoint: IOmniCommunicationEndpoint;
    function  GetReader: TOmniMessageQueue;
    function  GetWriter: TOmniMessageQueue;
  public
    constructor Create(owner: TOmniTwoWayChannel; readQueue, writeQueue: TOmniMessageQueue;
      taskTerminatedEvent_ref: THandle);
    destructor  Destroy; override;
    function  Receive(var msg: TOmniMessage): boolean; overload; inline;
    function  Receive(var msgID: word; var msgData: TOmniValue): boolean; overload; inline;
    function  ReceiveWait(var msg: TOmniMessage; timeout_ms: cardinal): boolean; overload; inline;
    function  ReceiveWait(var msgID: word; var msgData: TOmniValue; timeout_ms: cardinal):
      boolean; overload; inline;
    procedure Send(msgID: word); overload; inline;
    procedure Send(msgID: word; msgData: array of const); overload;
    procedure Send(msgID: word; msgData: TOmniValue); overload; inline;
    procedure Send(const msg: TOmniMessage); overload; inline;
    function  SendWait(msgID: word; timeout_ms: cardinal = CMaxSendWaitTime_ms): boolean; overload; inline;
    function  SendWait(msgID: word; msgData: TOmniValue;
      timeout_ms: cardinal = CMaxSendWaitTime_ms): boolean; overload;
    property NewMessageEvent: THandle read GetNewMessageEvent;
    property OtherEndpoint: IOmniCommunicationEndpoint read GetOtherEndpoint;
    property Reader: TOmniMessageQueue read GetReader;
    property Writer: TOmniMessageQueue read GetWriter;
  end; { TOmniCommunicationEndpoint }

  TOmniTwoWayChannel = class(TInterfacedObject, IOmniTwoWayChannel)
  strict private
    twcEndpoint             : array [1..2] of IOmniCommunicationEndpoint;
    twcLock                 : TSynchroObject;
    twcMessageQueueSize     : integer;
    twcTaskTerminatedEvt_ref: THandle;
    twcUnidirQueue          : array [1..2] of TOmniMessageQueue;
  strict protected
    procedure CreateBuffers; inline;
  protected
    function  OtherEndpoint(endpoint: IOmniCommunicationEndpoint): IOmniCommunicationEndpoint;
  public
    constructor Create(messageQueueSize: integer; taskTerminatedEvent: THandle);
    destructor  Destroy; override;
    function Endpoint1: IOmniCommunicationEndpoint; inline;
    function Endpoint2: IOmniCommunicationEndpoint; inline;
  end; { TOmniTwoWayChannel }

{ exports }

function CreateTwoWayChannel(numElements: integer = CDefaultQueueSize;
  taskTerminatedEvent: THandle = 0): IOmniTwoWayChannel;
begin
  Result := TOmniTwoWayChannel.Create(numElements, taskTerminatedEvent);
end; { CreateTwoWayChannel }

{ TOmniMessage }

constructor TOmniMessage.Create(aMsgID: word; aMsgData: TOmniValue);
begin
  MsgID := aMsgID;
  MsgData := aMsgData;
end; { TOmniMessage.Create }

constructor TOmniMessage.Create(aMsgID: word);
begin
  MsgID := aMsgID;
  MsgData := TOmniValue.Null;
end; { TOmniMessage.Create }

{ TOmniMessageQueue }

constructor TOmniMessageQueue.Create(numMessages: integer; createEventObserver: boolean);
begin
  inherited Create(numMessages, SizeOf(TOmniMessage));
  if createEventObserver then
    AttachWinEventObserver;
end; { TOmniMessageQueue.Create }

destructor TOmniMessageQueue.Destroy;
begin
  ContainerSubject.Detach(mqWinEventObserver, coiNotifyOnAllInserts);
  FreeAndNil(mqWinEventObserver);
  Empty;
  inherited;
end; { TOmniMessageQueue.Destroy }

procedure TOmniMessageQueue.AttachWinEventObserver;
begin
  if not assigned(mqWinEventObserver) then begin
    mqWinEventObserver := CreateContainerWindowsEventObserver;
    ContainerSubject.Attach(mqWinEventObserver, coiNotifyOnAllInserts);
  end;
  mqWinEventObserver.Activate;
end; { TOmniMessageQueue.AttachWinEventObserver }

function TOmniMessageQueue.Dequeue: TOmniMessage;
begin
  if not TryDequeue(Result) then
    raise Exception.Create('TOmniMessageQueue.Dequeue: Message queue is empty');
end; { TOmniMessageQueue.Dequeue }

procedure TOmniMessageQueue.Empty;
var
  msg: TOmniMessage;
begin
  while TryDequeue(msg) do
    ;
end; { TOmniMessageQueue.Empty }

function TOmniMessageQueue.Enqueue(const value: TOmniMessage): boolean;
var
  tmp: TOmniMessage;
begin
  tmp := value;
  if tmp.MsgData.IsInterface then
    tmp.MsgData.AsInterface._AddRef;
  Result := inherited Enqueue(tmp);
  if Result then
    tmp.MsgData.RawZero;
end; { TOmniMessageQueue.Enqueue }

function TOmniMessageQueue.GetNewMessageEvent: THandle;
begin
  AttachWinEventObserver;
  Result := mqWinEventObserver.GetEvent;
end; { TOmniMessageQueue.GetNewMessageEvent }

function TOmniMessageQueue.TryDequeue(var msg: TOmniMessage): boolean;
var
  tmp: TOmniMessage;
begin
  tmp.MsgData.RawZero;
  Result := inherited Dequeue(tmp);
  if not Result then
    Exit;
  msg := tmp;
  if tmp.MsgData.IsInterface then
    tmp.MsgData.AsInterface._Release;
end; { TOmniMessageQueue.TryDequeue }

{ TOmniCommunicationEndpoint }

constructor TOmniCommunicationEndpoint.Create(owner: TOmniTwoWayChannel; readQueue,
  writeQueue: TOmniMessageQueue; taskTerminatedEvent_ref: THandle);
begin
  inherited Create;
  ceOwner_ref := owner;
  ceReader_ref := readQueue;
  ceWriter_ref := writeQueue;
  ceTaskTerminatedEvent_ref := taskTerminatedEvent_ref;
end; { TOmniCommunicationEndpoint.Create }

destructor TOmniCommunicationEndpoint.Destroy;
begin
  if assigned(ceWriter_ref) and assigned(ceWriter_ref.ContainerSubject) and
     assigned(cePartlyEmptyObserver) 
  then
    ceWriter_ref.ContainerSubject.Detach(cePartlyEmptyObserver, coiNotifyOnPartlyEmpty);
  FreeAndNil(cePartlyEmptyObserver);
end; { TOmniCommunicationEndpoint.Destroy }

procedure TOmniCommunicationEndpoint.DetachFromQueues;
begin
  ceReader_ref := nil;
  ceWriter_ref := nil;
end; { TOmniCommunicationEndpoint.DetachFromQueues }

function TOmniCommunicationEndpoint.GetNewMessageEvent: THandle;
begin
  Result := ceReader_ref.GetNewMessageEvent;
end; { TOmniCommunicationEndpoint.GetNewMessageEvent }

function TOmniCommunicationEndpoint.GetOtherEndpoint: IOmniCommunicationEndpoint;
begin
  Result := ceOwner_ref.OtherEndpoint(Self);
end; { TOmniCommunicationEndpoint.GetOtherEndpoint }

{ TOmniCommunicationEndpoint.GetNewMessageEvent }

function TOmniCommunicationEndpoint.GetReader: TOmniMessageQueue;
begin
  Result := ceReader_ref;
end; { TOmniCommunicationEndpoint.GetReader }

function TOmniCommunicationEndpoint.Receive(var msgID: word; var msgData:
  TOmniValue): boolean;
var
  msg: TOmniMessage;
begin
  Result := Receive(msg);
  if Result then begin
    msgID := msg.msgID;
    msgData := msg.msgData;
  end;
end; { TOmniCommunicationEndpoint.Receive }

function TOmniCommunicationEndpoint.Receive(var msg: TOmniMessage): boolean;
begin
  Result := ceReader_ref.TryDequeue(msg);
end; { TOmniCommunicationEndpoint.Receive }

function TOmniCommunicationEndpoint.ReceiveWait(var msg: TOmniMessage; timeout_ms:
  cardinal): boolean;
begin
  Result := Receive(msg);
  if (not Result) and (timeout_ms > 0) then begin
    if ceTaskTerminatedEvent_ref = 0 then
      raise Exception.Create('TOmniCommunicationEndpoint.ReceiveWait: <task terminated> event is not set');
    ResetEvent(ceReader_ref.GetNewMessageEvent);
    Result := Receive(msg);
    if not Result then begin
      if DSiWaitForTwoObjects(ceReader_ref.GetNewMessageEvent,
           ceTaskTerminatedEvent_ref, false, timeout_ms) = WAIT_OBJECT_0 then
      begin
        msg := ceReader_ref.Dequeue;
        Result := true;
      end
    end; //if not Result
  end;
end; { TOmniCommunicationEndpoint.ReceiveWait }

function TOmniCommunicationEndpoint.ReceiveWait(var msgID: word; var msgData: TOmniValue;
  timeout_ms: cardinal): boolean;
var
  msg: TOmniMessage;
begin
  Result := ReceiveWait(msg, timeout_ms);
  if Result then begin
    msgID := msg.MsgID;
    msgData := msg.MsgData;
  end;
end; { TOmniCommunicationEndpoint.ReceiveWait }

procedure TOmniCommunicationEndpoint.RequirePartlyEmptyObserver;
begin
  if not assigned(cePartlyEmptyObserver) then begin
    cePartlyEmptyObserver := CreateContainerWindowsEventObserver;
    OtherEndpoint.Reader.ContainerSubject.Attach(cePartlyEmptyObserver, coiNotifyOnPartlyEmpty);
  end
  else begin
    cePartlyEmptyObserver.Deactivate;
    ResetEvent(cePartlyEmptyObserver.GetEvent);
  end;
end; { TOmniCommunicationEndpoint.RequirePartlyEmptyObserver }

procedure TOmniCommunicationEndpoint.Send(const msg: TOmniMessage);
begin
  if not ceWriter_ref.Enqueue(msg) then
    raise Exception.Create('TOmniCommunicationEndpoint.Send: Queue is full');
end;  { TOmniCommunicationEndpoint.Send }

function TOmniCommunicationEndpoint.SendWait(msgID: word; msgData: TOmniValue;
  timeout_ms: cardinal): boolean;
label
  retry;
var
  msg      : TOmniMessage;
  startTime: int64;
  waitTime : integer;
begin
  msg.msgID := msgID;
  msg.msgData := msgData;
  Result := ceWriter_ref.Enqueue(msg);
  if (not Result) and (timeout_ms > 0) then begin
    if ceTaskTerminatedEvent_ref = 0 then
      raise Exception.Create('TOmniCommunicationEndpoint.SendWait: <task terminated> event is not set');
    startTime := GetTickCount;
  retry:
    RequirePartlyEmptyObserver;
    Result := ceWriter_ref.Enqueue(msg);
    if not Result then begin
      while not Result do begin
        waitTime := timeout_ms - DSiElapsedSince(GetTickCount, startTime);
        if (waitTime >= 0) and
           (DSiWaitForTwoObjects(cePartlyEmptyObserver.GetEvent, ceTaskTerminatedEvent_ref,
             false, waitTime) = WAIT_OBJECT_0)
        then begin
          Result := ceWriter_ref.Enqueue(msg);
          if not Result then
            goto retry;
        end
        else
          break; //while
      end; //while
    end; //if not Result
  end;
  if not Result then
    msg.msgData := TOmniValue.Null;
end; { TOmniCommunicationEndpoint.SendWait }

function TOmniCommunicationEndpoint.SendWait(msgID: word;
  timeout_ms: cardinal): boolean;
var
  msg: TOmniMessage;
begin
  msg.msgID := msgID;
  msg.msgData := TOmniValue.Null;
  result := SendWait(msgID, msg.msgData, timeout_ms);
end; { TOmniCommunicationEndpoint.SendWait }

procedure TOmniCommunicationEndpoint.Send(msgID: word; msgData: TOmniValue);
var
  msg: TOmniMessage;
begin
  msg.msgID := msgID;
  msg.msgData := msgData;
  Send(msg);
end; { TOmniCommunicationEndpoint.Send }

procedure TOmniCommunicationEndpoint.Send(msgID: word; msgData: array of const);
begin
  Send(msgID, OpenArrayToVarArray(msgData));
end; { TOmniCommunicationEndpoint.Send }

procedure TOmniCommunicationEndpoint.Send(msgID: word);
begin
  Send(msgID, TOmniValue.Null);
end; { TOmniCommunicationEndpoint.Send }

function TOmniCommunicationEndpoint.GetWriter: TOmniMessageQueue;
begin
  Result := ceWriter_ref;
end; { TOmniCommunicationEndpoint.GetWriter }

{ TOmniTwoWayChannel }

constructor TOmniTwoWayChannel.Create(messageQueueSize: integer; taskTerminatedEvent:
  THandle);
begin
  inherited Create;
  twcMessageQueueSize := messageQueueSize;
  twcLock := TTicketSpinLock.Create;
  twcTaskTerminatedEvt_ref := taskTerminatedEvent;
end; { TOmniTwoWayChannel.Create }

destructor TOmniTwoWayChannel.Destroy;
var
  i: integer;
begin
  for i := 1 to 2 do
    if assigned(twcEndpoint[i]) then
      (twcEndpoint[i] as IOmniCommunicationEndpointInternal).DetachFromQueues;
  for i := 1 to 2 do begin
    twcUnidirQueue[i].Free;
    twcUnidirQueue[i] := nil;
  end;
  FreeAndNil(twcLock);
  inherited;
end; { TOmniTwoWayChannel.Destroy }

procedure TOmniTwoWayChannel.CreateBuffers;
begin
  if twcUnidirQueue[1] = nil then
    twcUnidirQueue[1] := TOmniMessageQueue.Create(twcMessageQueueSize);
  if twcUnidirQueue[2] = nil then
    twcUnidirQueue[2] := TOmniMessageQueue.Create(twcMessageQueueSize);
end; { TOmniTwoWayChannel.CreateBuffers }

function TOmniTwoWayChannel.Endpoint1: IOmniCommunicationEndpoint;
begin
  Assert((cardinal(@twcEndpoint[1]) AND 3) = 0);
  if twcEndpoint[1] = nil then begin
    twcLock.Acquire;
    try
      if twcEndpoint[1] = nil then begin
        CreateBuffers;
        twcEndpoint[1] := TOmniCommunicationEndpoint.Create(Self, twcUnidirQueue[1], twcUnidirQueue[2], twcTaskTerminatedEvt_ref);
      end;
    finally twcLock.Release; end;
  end;
  Result := twcEndpoint[1];
end; { TOmniTwoWayChannel.Endpoint1 }

function TOmniTwoWayChannel.Endpoint2: IOmniCommunicationEndpoint;
begin
  Assert((cardinal(@twcEndpoint[2]) AND 3) = 0);
  if twcEndpoint[2] = nil then begin
    twcLock.Acquire;
    try
      if twcEndpoint[2] = nil then begin
        CreateBuffers;
        twcEndpoint[2] := TOmniCommunicationEndpoint.Create(Self, twcUnidirQueue[2], twcUnidirQueue[1], twcTaskTerminatedEvt_ref);
      end;
    finally twcLock.Release; end;
  end;
  Result := twcEndpoint[2];
end; { TOmniTwoWayChannel.Endpoint2 }

function TOmniTwoWayChannel.OtherEndpoint(endpoint: IOmniCommunicationEndpoint):
  IOmniCommunicationEndpoint;
begin
  if endpoint = Endpoint1 then
    Result := Endpoint2
  else if endpoint = Endpoint2 then
    Result := Endpoint1
  else
    raise Exception.Create('TOmniTwoWayChannel.OtherEndpoint: Invalid endpoint!');
end; { TOmniTwoWayChannel.OtherEndpoint }

end.

