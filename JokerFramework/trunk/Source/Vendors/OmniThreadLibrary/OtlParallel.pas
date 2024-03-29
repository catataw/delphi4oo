///<summary>High-level parallel execution management.
///    Part of the OmniThreadLibrary project. Requires Delphi 2009 or newer.</summary>
///<author>Primoz Gabrijelcic</author>
///<license>
///This software is distributed under the BSD license.
///
///Copyright (c) 2010 Primoz Gabrijelcic
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
///   Creation date     : 2010-01-08
///   Last modification : 2010-01-14
///   Version           : 1.01
///</para><para>
///   History:
///     1.01: 2010-02-02
///       - Implemented ForEach(rangeLow, rangeHigh).
///       - Implemented ForEach.Aggregate.
///       - ForEach optimized for execution on single-core computer.
///       - Implemented Parallel.Join.
///       - Removed Stop method. Loop can be cancelled with a cancellation token.
///     1.0: 2010-01-14
///       - Released.
///</para></remarks>

// http://msdn.microsoft.com/en-us/magazine/cc163340.aspx
// http://blogs.msdn.com/pfxteam/archive/2007/11/29/6558543.aspx
// http://cis.jhu.edu/~dsimcha/parallelFuture.html

(* Things to consider:
   - Support for simpler IEnumerable source (with "lock and fetch a packet" approach).
   - All Parallel stuff should have a "chunk" option (or default).
       int P = 2 * Environment.ProcessorCount; // assume twice the procs for
                                               // good work distribution
       int Chunk = N / P;                      // size of a work chunk
   - Probably we need Parallel.Join.MonitorWith or something like that.

   Can something like this be implemented?:
     "To scale well on multiple processors, TPL uses work-stealing techniques to
      dynamically adapt and distribute work items over the worker threads. The library
      has a task manager that, by default, uses one worker thread per processor. This
      ensures minimal thread switching by the OS. Each worker thread has its own local
      task queue of work to be done. Each worker usually just pushes new tasks onto its
      own queue and pops work whenever a task is done. When its local queue is empty,
      a worker looks for work itself and tries to "steal" work from the queues of
      other workers."
*)

unit OtlParallel;

interface

uses
  SysUtils,
  OtlCommon,
  OtlSync,
  OtlTask;

type
  IOmniParallelLoop = interface;

  TOmniAggregatorDelegate = reference to procedure(var aggregate: TOmniValue;
    const value: TOmniValue);
  TOmniAggregatorIntDelegate = reference to procedure(var aggregate: int64;
    value: int64);

  TOmniIteratorDelegate = reference to procedure(const value: TOmniValue);
  TOmniIteratorIntDelegate = reference to procedure(const value: int64);

  TOmniIteratorAggregateDelegate = reference to function(const value: TOmniValue): TOmniValue;
  TOmniIteratorAggregateIntDelegate = reference to function(const value: int64): int64;

  // *** all loops assume that the enumerator's Take method is threadsafe ***

  IOmniParallelAggregatorLoop = interface ['{C21B781A-5A41-4BB6-9B45-F3E6AC14BE11}']
    function  Execute(loopBody: TOmniIteratorAggregateDelegate): TOmniValue; overload;
    function  Execute(loopBody: TOmniIteratorAggregateIntDelegate): int64; overload;
  end; { IOmniParallelAggregatorLoop }

  // *** assumes that the enumerator's Take method is threadsafe ***
  IOmniParallelLoop = interface ['{ACBFF35A-FED9-4630-B442-1C8B6AD2AABF}']
    function  Aggregate(aggregator: TOmniAggregatorDelegate): IOmniParallelAggregatorLoop ; overload;
    function  Aggregate(aggregator: TOmniAggregatorIntDelegate): IOmniParallelAggregatorLoop ; overload;
    function  Aggregate(aggregator: TOmniAggregatorDelegate;
      defaultAggregateValue: TOmniValue): IOmniParallelAggregatorLoop; overload;
    function  Aggregate(aggregator: TOmniAggregatorIntDelegate;
      defaultAggregateValue: int64): IOmniParallelAggregatorLoop; overload;
    procedure Execute(loopBody: TOmniIteratorDelegate); overload;
    procedure Execute(loopBody: TOmniIteratorIntDelegate); overload;
    function  CancelWith(token: IOmniCancellationToken): IOmniParallelLoop;
    function  NumTasks(taskCount : integer): IOmniParallelLoop;
  end; { IOmniParallelLoop }

  Parallel = class
    class function  ForEach(const enumGen: IOmniValueEnumerable): IOmniParallelLoop; overload;
    class function  ForEach(low, high: int64): IOmniParallelLoop; overload;
    class procedure Join(const task1, task2: TOmniTaskFunction); overload;
    class procedure Join(const task1, task2: TProc); overload;
    class procedure Join(const tasks: array of TOmniTaskFunction); overload;
    class procedure Join(const tasks: array of TProc); overload;
  end; { Parallel }

implementation

uses
  Windows,
  GpStuff,
  OtlTaskControl;

{ TODO 3 -ogabr : Should work with thread-unsafe enumerators }

type
  TOmniParallelLoop = class(TInterfacedObject, IOmniParallelLoop, IOmniParallelAggregatorLoop)
  strict private
    oplAggregate        : TOmniValue;
    oplAggregator       : TOmniAggregatorDelegate;
    oplCancellationToken: IOmniCancellationToken;
    oplEnumGen          : IOmniValueEnumerable;
    oplNumTasks         : integer;
  strict protected
    function Stopped: boolean;
  public
    constructor Create(const enumGen: IOmniValueEnumerable);
    function  Aggregate(aggregator: TOmniAggregatorDelegate): IOmniParallelAggregatorLoop; overload;
    function  Aggregate(aggregator: TOmniAggregatorDelegate; defaultAggregateValue: TOmniValue): IOmniParallelAggregatorLoop; overload;
    function  Aggregate(aggregator: TOmniAggregatorIntDelegate): IOmniParallelAggregatorLoop; overload;
    function  Aggregate(aggregator: TOmniAggregatorIntDelegate; defaultAggregateValue: int64): IOmniParallelAggregatorLoop; overload;
    function  CancelWith(token: IOmniCancellationToken): IOmniParallelLoop;
    function  Execute(loopBody: TOmniIteratorAggregateDelegate): TOmniValue; overload;
    function  Execute(loopBody: TOmniIteratorAggregateIntDelegate): int64; overload;
    procedure Execute(loopBody: TOmniIteratorDelegate); overload;
    procedure Execute(loopBody: TOmniIteratorIntDelegate); overload;
    function  NumTasks(taskCount: integer): IOmniParallelLoop;
  end; { TOmniParallelLoop }

{ Parallel }

class function Parallel.ForEach(const enumGen: IOmniValueEnumerable): IOmniParallelLoop;
begin
  { TODO 3 -ogabr : In Delphi 2010 RTTI could be used to get to the GetEnumerator from base object }
  Result := TOmniParallelLoop.Create(enumGen);
end; { Parallel.ForEach }

class function Parallel.ForEach(low, high: int64): IOmniParallelLoop;
begin
  { TODO 1 : Implement: Parallel.ForEach }
  // this is just a temporary implementation and will be changed
  Result := Parallel.ForEach(CreateEnumerableRange(low, high));
end; { Parallel.ForEach }

class procedure Parallel.Join(const task1, task2: TOmniTaskFunction);
begin
  Join([task1, task2]);
end; { Parallel.Join }

class procedure Parallel.Join(const tasks: array of TOmniTaskFunction);
var
  countStopped: TOmniResourceCount;
  firstTask   : IOmniTaskControl;
  prevTask    : IOmniTaskControl;
  proc        : TOmniTaskFunction;
  task        : IOmniTaskControl;
begin
  if (Environment.Process.Affinity.Count = 1) or (Length(tasks) = 1) then begin
    prevTask := nil;
    for proc in tasks do begin
      task := CreateTask(proc).Unobserved;
      if assigned(prevTask) then
        prevTask.ChainTo(task);
      prevTask := task;
      if not assigned(firstTask) then
        firstTask := task;
    end;
    if assigned(firstTask) then begin
      firstTask.Run;
      prevTask.WaitFor(INFINITE);
    end;
  end
  else begin
    countStopped := TOmniResourceCount.Create(Length(tasks));
    for proc in tasks do
      CreateTask(
        procedure (const task: IOmniTask) begin
          proc(task);
          countStopped.Allocate;
        end
      ).Unobserved
       .Schedule;
    WaitForSingleObject(countStopped.Handle, INFINITE);
  end;
end; { Parallel.Join }

class procedure Parallel.Join(const task1, task2: TProc);
begin
  Join([task1, task2]);
end; { Parallel.Join }

class procedure Parallel.Join(const tasks: array of TProc);
var
  countStopped: TOmniResourceCount;
  proc        : TProc;
begin
  if (Environment.Process.Affinity.Count = 1) or (Length(tasks) = 1) then begin
    for proc in tasks do
      proc;
  end
  else begin
    countStopped := TOmniResourceCount.Create(Length(tasks));
    for proc in tasks do
      CreateTask(
        procedure (const task: IOmniTask) begin
          proc;
          countStopped.Allocate;
        end
      ).Unobserved
       .Schedule;
    WaitForSingleObject(countStopped.Handle, INFINITE);
  end;
end; { Parallel.Join }

{ TOmniParallelLoop }

constructor TOmniParallelLoop.Create(const enumGen: IOmniValueEnumerable);
begin
  inherited Create;
  oplEnumGen := enumGen;
  oplNumTasks := Environment.Process.Affinity.Count;
end; { TOmniParallelLoop.Create }

function TOmniParallelLoop.Aggregate(aggregator: TOmniAggregatorDelegate):
  IOmniParallelAggregatorLoop;
begin
  Result := Aggregate(aggregator, TOmniValue.Null);
end; { TOmniParallelLoop.Aggregate }

function TOmniParallelLoop.Aggregate(aggregator: TOmniAggregatorDelegate;
  defaultAggregateValue: TOmniValue): IOmniParallelAggregatorLoop;
begin
  oplAggregator := aggregator;
  oplAggregate := defaultAggregateValue;
  Result := Self;
end; { TOmniParallelLoop.Aggregate }

function TOmniParallelLoop.Aggregate(aggregator: TOmniAggregatorIntDelegate):
  IOmniParallelAggregatorLoop;
begin
  Result := Aggregate(aggregator, 0);
end; { TOmniParallelLoop.Aggregate }

function TOmniParallelLoop.Aggregate(aggregator: TOmniAggregatorIntDelegate;
  defaultAggregateValue: int64): IOmniParallelAggregatorLoop;
begin
  Result := Aggregate(
    procedure (var aggregate: TOmniValue; const value: TOmniValue)
    var
      aggregateInt: int64;
    begin
      aggregateInt := aggregate.AsInt64;
      aggregator(aggregateInt, value);
      aggregate.AsInt64 := aggregateInt;
    end,
    defaultAggregateValue);
end; { TOmniParallelLoop.Aggregate }

function TOmniParallelLoop.CancelWith(token: IOmniCancellationToken): IOmniParallelLoop;
begin
  oplCancellationToken := token;
  Result := Self;
end; { TOmniParallelLoop.CancelWith }

function TOmniParallelLoop.Execute(loopBody: TOmniIteratorAggregateDelegate): TOmniValue;
var
  aggregate    : TOmniValue;
  countStopped : IOmniResourceCount;
  enumerator   : IOmniValueEnumerator;
  iTask        : integer;
  lockAggregate: IOmniCriticalSection;
  value        : TOmniValue;
begin
  if (oplNumTasks = 1) or (Environment.Thread.Affinity.Count = 1) then begin
    aggregate := TOmniValue.Null;
    enumerator := oplEnumGen.GetEnumerator;
    while (not Stopped) and enumerator.Take(value) do
      oplAggregator(oplAggregate, loopBody(value));
    Result := oplAggregate;
  end
  else begin
    countStopped := TOmniResourceCount.Create(oplNumTasks);
    lockAggregate := CreateOmniCriticalSection;
    for iTask := 1 to oplNumTasks do
      CreateTask(
        procedure (const task: IOmniTask)
        var
          aggregate : TOmniValue;
          value     : TOmniValue;
          enumerator: IOmniValueEnumerator;
        begin
          aggregate := TOmniValue.Null;
          enumerator := oplEnumGen.GetEnumerator;
          while (not Stopped) and enumerator.Take(value) do
            oplAggregator(aggregate, loopBody(value));
          task.Lock.Acquire;
          try
            oplAggregator(oplAggregate, aggregate);
          finally task.Lock.Release; end;
          countStopped.Allocate;
        end,
        'Parallel.ForEach worker #' + IntToStr(iTask)
      ).WithLock(lockAggregate)
       .Unobserved
       .Schedule;
    WaitForSingleObject(countStopped.Handle, INFINITE);
    Result := oplAggregate;
  end;
end; { TOmniParallelLoop.Execute }

function TOmniParallelLoop.Execute(loopBody: TOmniIteratorAggregateIntDelegate): int64;
begin
  Result := Execute(
    function(const value: TOmniValue): TOmniValue
    begin
      Result := loopBody(value);
    end);
end; { TOmniParallelLoop.Execute }

procedure TOmniParallelLoop.Execute(loopBody: TOmniIteratorDelegate);
var
  countStopped: IOmniResourceCount;
  enumerator  : IOmniValueEnumerator;
  iTask       : integer;
  value       : TOmniValue;
begin
  if (oplNumTasks = 1) or (Environment.Thread.Affinity.Count = 1) then begin
    enumerator := oplEnumGen.GetEnumerator;
    while (not Stopped) and enumerator.Take(value) do
      loopBody(value);
  end
  else begin
    countStopped := TOmniResourceCount.Create(oplNumTasks);
    for iTask := 1 to oplNumTasks do
      CreateTask(
        procedure (const task: IOmniTask)
        var
          value     : TOmniValue;
          enumerator: IOmniValueEnumerator;
        begin
          enumerator := oplEnumGen.GetEnumerator;
          while (not Stopped) and enumerator.Take(value) do
            loopBody(value);
          countStopped.Allocate;
        end,
        'Parallel.ForEach worker #' + IntToStr(iTask)
      ).Unobserved
       .Schedule;
    WaitForSingleObject(countStopped.Handle, INFINITE);
  end;
end; { TOmniParallelLoop.Execute }

procedure TOmniParallelLoop.Execute(loopBody: TOmniIteratorIntDelegate);
begin
  Execute(
    procedure (const elem: TOmniValue)
    begin
      loopBody(elem);
    end);
end; { TOmniParallelLoop.Execute }

function TOmniParallelLoop.NumTasks(taskCount: integer): IOmniParallelLoop;
begin
  Assert(taskCount > 0);
  oplNumTasks := taskCount;
  Result := Self;
end; { TOmniParallelLoop.taskCount }

function TOmniParallelLoop.Stopped: boolean;
begin
  Result := (assigned(oplCancellationToken) and oplCancellationToken.IsSignaled);
end; { TOmniParallelLoop.Stopped }

end.
