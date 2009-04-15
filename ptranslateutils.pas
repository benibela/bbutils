
unit ptranslateutils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Translations,LResources,gettext,Controls,Menus;

function pascalizeName(const s:string):string;


type

{ TPascalTranslator }
//**If a fallback language exists it must be the source language if you want to translate into the source language
TPascalTranslator=class
private
  funit: string;
  po,pofallback: TPOFile;
  function getBaseTranslation(id,s: string): string; //**< Checks all loaded po files
  function getTranslation(s: string): string;
public
  procedure translate(c: TComponent);
  property translations[s: string]: string read getTranslation;default;
end;

//**This initialize the translator for the given unit. @br Theoretical this translator should be freed at program end, but don't do it, because Windows frees this memory automatically and every translator is created only once
procedure initUnitTranslation(unitname:string; var translator: TPascalTranslator; translationFile: string='');
procedure initGlobalTranslation(podirectory: string; globalTranslationFile: string=''; language:string='';fallBackLanguage:string='');

implementation
uses forms, StdCtrls;

var globalPOFile,globalFallbackPOFile: TPOFile;
    globalTranslationInitialized:boolean=false;
    globalLang,globalFallbacklang: string;
    globalPODirectory:string;

procedure loadPOFiles(fileName:string; out pofile, pofallbackFile: TPOFile);
begin
  pofile:=nil;
  pofallbackFile:=nil;
  if fileName = '' then exit;
  if FileExists(fileName) then pofile:=TPOFile.Create(filename)
  else if FileExists(globalPodirectory+filename) then pOFile:=TPOFile.Create(globalPodirectory+filename)
  else begin
    if (pos('.po',lowercase(filename))=0)  then begin
      if (pos('%s',lowercase(filename))=0)  then
        filename+='.%s';
      filename+='.po';
    end;
    filename:=globalPodirectory+filename;
    if FileExists(format(filename,[globalLang])) then poFile:=TPOFile.Create(format(filename,[globalLang]))
    else pofile:=nil;
    if FileExists(format(filename,[globalFallbacklang])) then pofallbackFile:=TPOFile.Create(format(filename,[globalFallbacklang]))
    else pofallbackFile:=nil;
  end;
end;

function pascalizeName(const s: string): string;
var i:longint;
begin
  result:=s;
  if length(result)>117 then setlength(result,117); //so whole result is 128 bytes long
  for i:=1 to length(result) do
    if not (result[i] in ['_','a'..'z','A'..'Z','0'..'9'])
      then result[i]:='_';
  result:='TR_AUTOGEN_'+result;
end;

procedure initUnitTranslation(unitname: string; var translator: TPascalTranslator; translationFile: string='');
begin
  if translator<>nil then exit;
  translator:=TPascalTranslator.Create;
  translator.funit:=unitname;
  loadPOFiles(translationFile, translator.po,translator.pofallback);
  if globalFallbackPOFile<>nil then Translations.translateUnitResourceStrings(unitname,globalFallbackPOFile);
  if globalPOFile<>nil then  Translations.TranslateUnitResourceStrings(unitname,globalPOFile);
  if translator.pofallback<>nil then Translations.TranslateUnitResourceStrings(unitname,translator.pofallback);
  if translator.po<>nil then Translations.TranslateUnitResourceStrings(unitname,translator.po);
end;

procedure initGlobalTranslation(podirectory: string;
  globalTranslationFile: string; language, fallBackLanguage: string);
var lang, falllang: string;
begin
  if globalTranslationInitialized then exit;
  GetLanguageIDs(lang,falllang);  //ignore lang (country, doesn't need it)
  if language='' then globalLang:=falllang
  else globalLang:=language;
  if fallBackLanguage='' then globalFallbacklang:=falllang
  else globalFallbacklang:=fallBackLanguage;
  globalPODirectory:=IncludeTrailingPathDelimiter(podirectory);
  loadPOFiles(globalTranslationFile,globalPOFile,globalFallbackPOFile);
  globalTranslationInitialized :=true;
end;

{ TPascalTranslator }

function TPascalTranslator.getBaseTranslation(id, s: string): string;
begin
  result:=s;
  if po<>nil then result:=po.Translate(id,s);
  if (result=s) and (pofallback<>nil) then result:=pofallback.Translate(id,s);
  if (result=s) and (globalPOFile<>nil) then result:=globalPOFile.Translate(id,s);
  if (result=s) and (globalFallbackPOFile<>nil) then result:=globalFallbackPOFile.Translate(id,s);
end;

function TPascalTranslator.getTranslation(s: string): string;
begin
  result:=getBaseTranslation(funit+'.'+pascalizeName(s),s);
end;

procedure TPascalTranslator.translate(c: TComponent);
var pre: string;
    i:longint;
begin
  if c = nil then exit;
  if c is tform then begin
    pre:=c.ClassName+'.';
  end else begin
    if not (c.Owner is tform) then exit;
    pre:=c.owner.ClassName+'.'+c.Name+'.';
  end;
  if c is tcontrol then begin
    tcontrol(c).Hint:=getBaseTranslation(pre+'hint',tcontrol(c).Hint);
    if c is tedit then tedit(c).text:=getBaseTranslation(pre+'text',tedit(c).text)
    else tcontrol(c).Caption:=getBaseTranslation(pre+'caption',tcontrol(c).Caption);
    if c is twincontrol then
      for i:=0 to twincontrol(c).ComponentCount-1 do
        translate(twincontrol(c).Components[i]);
  end else if c is tmenuitem then
    tmenuitem(c).Caption:=getBaseTranslation(pre+'caption',tmenuitem(c).Caption);;

end;

end.

