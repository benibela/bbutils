program tests_bbutils_only;
{$mode objfpc}{$H+}

uses
  {$ifdef ENABLE_CWSTRING} {$ifdef unix}cwstring,{$endif}{$endif}
  bbutils, bbutils_tests, commontestutils, sysutils;

var
  start: TDateTime;
  commonEncodings: array [0..3] of TSystemCodePage = (CP_UTF8, CP_LATIN1, CP_WINDOWS1252, CP_ASCII);
  e: TSystemCodePage;
begin
  start := now;
  {$ifndef DISABLE_BBUTILS_CONVERSIONS }
  {$ifdef FPC_HAS_CPSTRING}
  bbutils.registerFallbackUnicodeConversion;
  {$endif}
  {$else}
  setCodePageCanConvertEncodings := false;
  {$endif}
  {$ifdef FPC_HAS_CPSTRING}
  for e in commonEncodings do begin DefaultSystemCodePage:=e;
  {$endif}
    bbutils_tests.unitTests;
  {$ifdef FPC_HAS_CPSTRING}
  end;
  {$endif}
  writeln('time: ', (now-start)*24*60*60*1000:5:5);
  writeln(globalTestCount, ' tests successful');

end.

