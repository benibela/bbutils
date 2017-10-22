program tests_bbutils_only;
{$mode objfpc}{$H+}

uses
  {$ifdef ENABLE_CWSTRING} {$ifdef unix}cwstring,{$endif}{$endif}
  bbutils, bbutils_tests, commontestutils, sysutils;

var
  start: TDateTime;
begin
  start := now;
  {$ifndef DISABLE_BBUTILS_CONVERSIONS }
  {$ifdef FPC_HAS_CPSTRING}
  DefaultSystemCodePage := CP_UTF8;
  bbutils.registerFallbackUnicodeConversion;
  {$endif}
  {$else}
  setCodePageCanConvertEncodings := false;
  {$endif}
  bbutils_tests.unitTests;
  writeln('OK  (time: ', (now-start)*24*60*60*1000:5:5,')');
end.

