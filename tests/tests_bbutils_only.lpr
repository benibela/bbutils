program tests_bbutils_only;
{$mode objfpc}{$H+}

uses
  {$ifdef unix}cwstring,{$endif}
  bbutils_tests, sysutils;

var
  start: TDateTime;
begin
  start := now;
  bbutils_tests.unitTests;
  writeln('OK  (time: ', (now-start)*24*60*60*1000:5:5,')');
end.

