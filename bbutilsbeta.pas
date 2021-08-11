{
Copyright (C) 2017 - 2020  Benito van der Zander (BeniBela)
                           benito@benibela.de
                           www.benibela.de

This file is distributed under under the same license as Lazarus and the LCL itself:

This file is distributed under the Library GNU General Public License
with the following modification:

As a special exception, the copyright holders of this library give you
permission to link this library with independent modules to produce an
executable, regardless of the license terms of these independent modules,
and to copy and distribute the resulting executable under terms of your choice,
provided that you also meet, for each linked independent module, the terms
and conditions of the license of that module. An independent module is a
module which is not derived from or based on this library. If you modify this
library, you may extend this exception to your version of the library, but
you are not obligated to do so. If you do not wish to do so, delete this
exception statement from your version.

}

(***
  @abstract(Some useful functions or classes)@br

  These are some things that might be added to bbutils, or changed, or discarded.
*)

unit bbutilsbeta;

{$mode objfpc}{$H+}{$ModeSwitch advancedrecords}
{$ifdef FPC_HAS_CPSTRING}
{$define HAS_TYPEHELPERS}
{$ModeSwitch typehelpers}
{$endif}

interface

uses bbutils, sysutils;

//** A generic enumerator that works for any fixed-length collection.
//** @br Drawback: It is always slower than an enumerator custom written for a class. It should use SizeInt, but it cannot use sizeint, when the collection (e.g. TStringList) does not use SizeInt
type
 generic TCommonEnumerator<T> = class
   type TGetCallback = function (i: integer): T of object;
 private
   fpos, flast: integer;
   fget: TGetCallback;
   function GetCurrent: T; inline;
 public
   constructor create(count: integer; callback: TGetCallback);
   function MoveNext: Boolean;
   property Current: T read GetCurrent;
   function GetEnumerator: TCommonEnumerator;
 end;


  {$ifdef HAS_TYPEHELPERS}
  (**
  An array view represents a subsequence of an array.

  The view is read-only and can only shrink.
  All functions work with any pointer, such that pointers outside the view either give an empty view or keep the view unchanged.

  Function Move* remove elements from the beginning, functions Cut* remove elements from the end, i.e.:

  |--------cutBefore(x)--------||-----------------------moveTo(x)-----------------|
  ppppppppppppppppppppppppppppppxxxxxxxxxxxxxxxxxxxxxxsssssssssssssssssssssssssssss  <- the initial array view
  |-------------------cutAfter(x)--------------------||-------moveAfter(x)--------|


  Function View* return a new view. To and From are inclusive, while Until and Behind are exclusive, i.e.:

  |--------viewUntil(x)--------||-----------------------viewFrom(x)---------------|
  ppppppppppppppppppppppppppppppxxxxxxxxxxxxxxxxxxxxxxsssssssssssssssssssssssssssss  <- the initial array view
  |--------------------viewTo(x)---------------------||-------viewBehind(x)-------|

  *)
  generic TArrayView<TElement> = object
    type PElement = ^TElement;
  protected
    procedure initStartCapped(oldstart, start, anend: pchar);
    procedure initEndCapped(start, newend, oldend: pchar);
   type TArrayViewEnumerator = object
    protected
      data, dataend: pelement;
      function first: TElement; inline;
    public
      function moveNext: boolean; inline;
      property current: TElement read first;
    end;
  public
    data: pelement; //first element
    dataend: pelement; //after last element
    function length: SizeInt;
    function isEmpty: boolean; inline;
    function isInBounds(target: PElement): boolean; inline;
    function isOnBounds(target: PElement): boolean; inline;
    function offsetOf(target: PElement): SizeInt; inline;

    function getEnumerator: TArrayViewEnumerator; inline;

    function moveBy(delta: SizeInt): boolean;
    procedure moveTo(target: PElement);
    procedure moveAfter(target: PElement);

    function cutBy(delta: SizeInt): boolean;
    procedure cutBefore(target: PElement);
    procedure cutAfter(target: PElement);

    function count(const e: TElement): SizeInt;

    //** copy and cutAfter
    function viewTo(newLast: PElement): TArrayView;
    //** copy and cutBefore
    function viewUntil(newEnd: PElement): TArrayView;
    //** copy and moveTo
    function viewFrom(newStart: PElement): TArrayView;
    //** copy and moveAfter
    function viewBehind(newStartSkip: PElement): TArrayView;
  end;

  TCharArrayView = object(specialize TArrayView<char>)
  private
    function moveToFound(target: pchar): boolean; inline;
  public
    procedure init(const buffer: string);
    procedure init(const buffer: TBytes);
    function ToString: string;

    function length: SizeInt; reintroduce;

    function contains(const s: string): boolean; inline;
    function beginsWith(const s: string): boolean; inline;
    //function beginsWithI(const s: string): boolean; inline;
    function endsWith(const expectedEnd: string): boolean; inline;


    function find(searched: pchar; searchedLength: SizeInt): pchar;
    function find(const s: string): pchar;
    function findLast(searched: pchar; searchedLength: SizeInt): pchar;
    function findLast(const s: string): pchar;

    function moveToFind(const s: string): boolean;
    function moveAfterFind(const s: string): boolean;
    function moveToFindLast(const s: string): boolean;
    function moveAfterFindLast(const s: string): boolean;

    //finds #13 or #10  (implicit #13#10)
    function findLineBreak: pchar;
    function moveToLineBreak: boolean;
    function moveAfterLineBreak: boolean;

    function cutBeforeFind(const s: string): boolean;
    function cutAfterFind(const s: string): boolean;
    function cutBeforeFindLast(const s: string): boolean;
    function cutAfterFindLast(const s: string): boolean;

    procedure trim(const trimCharacters: TCharSet = [#0..' ']);
    procedure trimLeft(const trimCharacters: TCharSet = [#0..' ']);
    procedure trimRight(const trimCharacters: TCharSet = [#0..' ']);
    procedure trim(trimChar: char);
    procedure trimLeft(trimChar: char);
    procedure trimRight(trimChar: char);

    function viewTo(newLast: pchar): TCharArrayView; reintroduce;
    function viewUntil(newEnd: pchar): TCharArrayView; reintroduce;
    function viewFrom(newStart: pchar): TCharArrayView; reintroduce;
    function viewBehind(newStartSkip: pchar): TCharArrayView; reintroduce;
  end;

  TStringView = TCharArrayView;

  TBB2StringHelper = type helper (TBBStringHelper) for ansistring
    function unsafeView: TStringView;
    function unsafeViewTo(newLast: pchar): TStringView;
    function unsafeViewUntil(newEnd: pchar): TStringView;
    function unsafeViewFrom(newStart: pchar): TStringView;
    function unsafeViewBehind(newStartSkip: pchar): TStringView;
  end;
  TBBPcharHelper = type helper for pchar
    function nilMeansInfinity: pchar;
  end;

  TBB2BytesHelper = type helper for TBytes
    function unsafeView: TCharArrayView;
  end;

  TCriticalSectionHelper = {$if FPC_FULLVERSION >= 030200}type{$else}record{$endif} helper for TRTLCriticalSection
    procedure init;
    procedure enter;
    procedure leave;
    procedure done;
  end;

  {$endif}

function objInheritsFrom(o: TObject; c: TClass): boolean; inline;


implementation

function objInheritsFrom(o: TObject; c: TClass): boolean;
begin
  result := assigned(o) and o.InheritsFrom(c);
end;







function TCommonEnumerator.GetCurrent: T;
begin
  result := fget(fpos);
end;

constructor TCommonEnumerator.create(count: integer; callback: TGetCallback);
begin
  fpos := -1;
  flast := count - 1;
  fget := callback;
end;

function TCommonEnumerator.MoveNext: Boolean;
begin
  inc(fpos);
  result := fpos <= flast;
end;

function TCommonEnumerator.GetEnumerator: TCommonEnumerator;
begin
  result := self;
end;









{$ifdef HAS_TYPEHELPERS}

function TArrayView.TArrayViewEnumerator.first: TElement;
begin
  result := data^;
end;

function TArrayView.TArrayViewEnumerator.moveNext: boolean;
begin
  inc(data);
  result := data < dataend;
end;


procedure TArrayView.initStartCapped(oldstart, start, anend: pchar);
begin
  dataend := anend;
  if start < oldstart then data := oldstart
  else if start > anend then data := anend
  else data := start;
end;

procedure TArrayView.initEndCapped(start, newend, oldend: pchar);
begin
  data := start;
  if newend > oldend then dataend := oldend
  else if newend < start then dataend := start
  else dataend := newend;
end;

{$PUSH}
{$R-}
function TArrayView.length: SizeInt;
begin
  result := SizeUInt(pchar(dataend) - pchar(data)) div SizeUInt(sizeof(TElement));
end;
{$POP}

function TArrayView.isEmpty: boolean;
begin
  result := data >= dataend;
end;

function TArrayView.isInBounds(target: PElement): boolean;
begin
  result := (data <= target) and (target < dataend);
end;

function TArrayView.isOnBounds(target: PElement): boolean;
begin
  result := (data <= target) and (target <= dataend);
end;

function TArrayView.offsetOf(target: PElement): SizeInt;
begin
  result := target - data;
end;


function TArrayView.moveBy(delta: SizeInt): boolean;
begin
  data := data + delta;
  result := data < dataend;
  if not result then data := dataend;
end;


function TArrayView.getEnumerator: TArrayViewEnumerator;
begin
  result.data := data - 1;
  result.dataend := dataend;
end;

procedure TArrayView.moveTo(target: PElement);
begin
  if target <= data then exit;
  if target >= dataend then data := dataend
  else data := target;
end;


procedure TArrayView.moveAfter(target: PElement);
begin
  moveTo(target + 1);
end;


function TArrayView.cutBy(delta: SizeInt): boolean;
begin
  dataend := dataend - delta;
  result := data < dataend;
  if not result then dataend := data;
end;

procedure TArrayView.cutBefore(target: PElement);
begin
  if target >= dataend then exit;
  if target <= data then dataend := data
  else dataend := target;
end;

procedure TArrayView.cutAfter(target: PElement);
begin
  cutBefore(target + 1);
end;

function TArrayView.count(const e: TElement): SizeInt;
var
  p, &end: PElement;
begin
  p := data;
  &end := dataend;
  result := 0;
  while p < &end do begin
    if p^ = e then
      inc(result);
    inc(p);
  end;
end;

function TArrayView.viewTo(newLast: PElement): TArrayView;
begin
  result.initEndCapped(data, newLast + 1, dataend);
end;

function TArrayView.viewUntil(newEnd: PElement): TArrayView;
begin
  result.initEndCapped(data, newEnd, dataend);
end;

function TArrayView.viewFrom(newStart: PElement): TArrayView;
begin
  result.initStartCapped(data, newStart, dataend);
end;

function TArrayView.viewBehind(newStartSkip: PElement): TArrayView;
begin
  result.initStartCapped(data, newStartSkip + 1, dataend);
end;





function TCharArrayView.moveToFound(target: pchar): boolean;
begin
  result := target <> nil;
  if result then data := target;
end;

procedure TCharArrayView.init(const buffer: string);
begin
  data := pchar(buffer);
  dataend := data + system.length(buffer);
end;

procedure TCharArrayView.init(const buffer: TBytes);
begin
  if system.length(buffer) = 0 then self := default(TCharArrayView)
  else begin
    data := @buffer[0];
    dataend := data + system.length(buffer);
  end;
end;

function TCharArrayView.ToString: string;
begin
  result := strFromPchar(data, length);
end;

function TCharArrayView.length: SizeInt;
begin
  result := dataend - data;
end;


function TCharArrayView.contains(const s: string): boolean;
begin
  result := find(s) <> nil;
end;

function TCharArrayView.beginsWith(const s: string): boolean;
var
  expectedLength: SizeInt;
begin
  expectedLength := system.length(s);
  result := (expectedLength <= length)
            and ((s = '') or (CompareByte(PByte(data)^, pbyte(s)^, expectedLength ) = 0));
end;

function TCharArrayView.endsWith(const expectedEnd: string): boolean;
var
  strLength, expectedLength: SizeInt;
begin
  expectedLength := system.length(expectedEnd);
  strLength := length;
  result := ( length >= expectedLength ) and
            ( (expectedEnd='') or
              (CompareByte(data[strLength-expectedLength], PByte(expectedEnd)^, expectedLength) = 0) );
end;

function TCharArrayView.find(searched: pchar; searchedLength: SizeInt): pchar;
var
  last: pchar;
begin
  if searchedLength <= 0 then exit(data);
  if data + searchedLength > dataend then exit(nil);
  last := dataend - searchedLength;
  result := data;
  while result <= last do begin
    if result^ = searched^ then
      if CompareByte(result^, searched^, searchedLength) = 0 then
        exit;
    inc(result);
  end;
  result := nil;
end;

function TCharArrayView.find(const s: string): pchar;
begin
  result := find(pchar(s), system.length(s));
end;

function TCharArrayView.findLast(searched: pchar; searchedLength: SizeInt): pchar;
var
  first: pchar;
begin
  if searchedLength <= 0 then exit(dataend); //carefully it is not in bounds
  if data + searchedLength > dataend then exit(nil);
  result := dataend - searchedLength;
  first := data;
  while result >= first do begin
    if result^ = searched^ then
      if CompareByte(result^, searched^, searchedLength) = 0 then
        exit;
    dec(result);
  end;
  result := nil;
end;

function TCharArrayView.findLast(const s: string): pchar;
begin
  result := findLast(pchar(s), system.length(s));
end;


function TCharArrayView.moveToFind(const s: string): boolean;
begin
  result := moveToFound(find(s));
end;

function TCharArrayView.moveAfterFind(const s: string): boolean;
var
  target: PChar;
begin
  target := find(s);
  result := target <> nil;
  if result then
    data := target + system.length(s);
end;

function TCharArrayView.moveToFindLast(const s: string): boolean;
var
  target: PChar;
begin
  target := findLast(s);
  result := target <> nil;
  if result then
    data := target;
end;

function TCharArrayView.moveAfterFindLast(const s: string): boolean;
var
  target: PChar;
begin
  target := findLast(s);
  result := target <> nil;
  if result then
    data := target + system.length(s);
end;


function TCharArrayView.findLineBreak: pchar;
begin
  result := data;
  while result < dataend do begin
    if result^ in [#10,#13] then exit;
    inc(result);
  end;
  result := nil;
end;

function TCharArrayView.moveToLineBreak: boolean;
begin
  result := moveToFound(findLineBreak);
end;

function TCharArrayView.moveAfterLineBreak: boolean;
var
  target: PChar;
begin
  target := findLineBreak();
  result := target <> nil;
  if result then begin
    if (target^ = #13) and ((target + 1)^ = #10) then inc(target, 2)
    else inc(target);
    data := target;
  end;
end;

function TCharArrayView.cutBeforeFind(const s: string): boolean;
var
  target: PChar;
begin
  target := find(s);
  result := target <> nil;
  if result then
    dataend := target;
end;

function TCharArrayView.cutAfterFind(const s: string): boolean;
var
  target: PChar;
begin
  target := find(s);
  result := target <> nil;
  if result then
    dataend := target + system.length(s);
end;

function TCharArrayView.cutBeforeFindLast(const s: string): boolean;
var
  target: PChar;
begin
  target := findLast(s);
  result := target <> nil;
  if result then
    dataend := target;
end;

function TCharArrayView.cutAfterFindLast(const s: string): boolean;
var
  target: PChar;
begin
  target := findLast(s);
  result := target <> nil;
  if result then
    dataend := target + system.length(s);
end;

procedure TCharArrayView.trim(const trimCharacters: TCharSet = [#0..' ']);
var
  l: SizeInt;
begin
  l := length;
  strlTrim(data, l, trimCharacters);
  dataend := data + l;
end;

procedure TCharArrayView.trimLeft(const trimCharacters: TCharSet);
var
  l: SizeInt;
begin
  l := length;
  strlTrimLeft(data, l, trimCharacters);
  dataend := data + l;
end;

procedure TCharArrayView.trimRight(const trimCharacters: TCharSet);
var
  l: SizeInt;
begin
  l := length;
  strlTrimRight(data, l, trimCharacters);
  dataend := data + l;
end;

procedure TCharArrayView.trim(trimChar: char);
begin
  trimLeft(trimChar);
  trimRight(trimChar);
end;

procedure TCharArrayView.trimLeft(trimChar: char);
begin
  trimLeft([trimChar]);
end;

procedure TCharArrayView.trimRight(trimChar: char);
begin
  trimRight([trimChar]);
end;

function TCharArrayView.viewTo(newLast: pchar): TCharArrayView;
begin
  result.initEndCapped(data, newLast + 1, dataend);
end;

function TCharArrayView.viewUntil(newEnd: pchar): TCharArrayView;
begin
  result.initEndCapped(data, newEnd, dataend);
end;

function TCharArrayView.viewFrom(newStart: pchar): TCharArrayView;
begin
  result.initStartCapped(data, newStart, dataend);
end;

function TCharArrayView.viewBehind(newStartSkip: pchar): TCharArrayView;
begin
  result.initStartCapped(data, newStartSkip + 1, dataend);
end;

function TBB2StringHelper.unsafeView: TStringView;
begin
  result.init(self);
end;

function TBB2StringHelper.unsafeViewTo(newLast: pchar): TStringView;
begin
  result := unsafeView.viewTo(newLast);
end;

function TBB2StringHelper.unsafeViewUntil(newEnd: pchar): TStringView;
begin
  result := unsafeView.viewUntil(newEnd);
end;

function TBB2StringHelper.unsafeViewFrom(newStart: pchar): TStringView;
begin
  result := unsafeView.viewFrom(newStart);
end;

function TBB2StringHelper.unsafeViewBehind(newStartSkip: pchar): TStringView;
begin
  result := unsafeView.viewBehind(newStartSkip);
end;

function TBB2BytesHelper.unsafeView: TCharArrayView;
begin
  result.init(self);
end;


function TBBPcharHelper.nilMeansInfinity: pchar;
begin
  if self = nil then result := pchar(high(PtrUInt))
  else result := self;
end;


procedure TCriticalSectionHelper.init;
begin
  InitCriticalSection(self);
end;

procedure TCriticalSectionHelper.enter;
begin
  EnterCriticalSection(self)
end;

procedure TCriticalSectionHelper.leave;
begin
  LeaveCriticalSection(self);
end;

procedure TCriticalSectionHelper.done;
begin
  DoneCriticalSection(self);
end;

{$endif}

end.
