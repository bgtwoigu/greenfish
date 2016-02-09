(*
    Greenfish Icon Editor Pro
    Copyright (c) 2012-13 B. Szalkai

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)
program gfie;

uses
  Interfaces, SysUtils, Forms, Controls, Graphics,
  Main in 'Main.pas' {frmMain},
  dlgColor in 'ColorFrame.pas' {frmColor},
  ieShared in 'ieShared.pas',
  dlgToolbar in 'ToolbarFrame.pas' {frmToolbar},
  dlgDoc in 'dlgDoc.pas' {frmDoc},
  DocClass in 'DocClass.pas',
  dlgDocPage in 'dlgDocPage.pas' {frmDocPage},
  ColQuant in 'ColQuant.pas',
  dlgToolSet in 'ToolSetFrame.pas' {frmToolSet},
  dlgText in 'dlgText.pas' {frmText},
  dlgTransform in 'dlgTransform.pas' {frmTransform},
  ImageTransform in 'ImageTransform.pas',
  Filters in 'Filters.pas',
  dlgBlur in 'dlgBlur.pas' {frmBlur},
  dlgExposure in 'dlgExposure.pas' {frmExposure},
  dlgRGBChannels in 'dlgRGBChannels.pas' {frmRGBChannels},
  dlgHueSaturation in 'dlgHueSaturation.pas' {frmHueSaturation},
  dlgShadow in 'dlgShadow.pas' {frmShadow},
  dlgMatte in 'dlgMatte.pas' {frmRemoveMatte},
  dlgOpacity in 'dlgOpacity.pas' {frmOpacity},
  dlgCreateIcon in 'dlgCreateIcon.pas' {frmCreateIcon},
  dlgTest in 'dlgTest.pas' {frmTest},
  PNG in 'PNG.pas',
  dlgPrint in 'dlgPrint.pas' {frmPrint},
  XPM in 'XPM.pas',
  dlgSplash in 'dlgSplash.pas' {frmSplash},
  dlgUnsharpMask in 'dlgUnsharpMask.pas' {frmUnsharpMask},
  dlgPreferences in 'dlgPreferences.pas' {frmPreferences},
  dlgGlow in 'dlgGlow.pas' {frmGlow},
  FileAssoc in 'FileAssoc.pas',
  dlgBevel in 'dlgBevel.pas' {frmBevel},
  ShellEx in 'ShellEx.pas',
  gfMath in 'gfMath.pas',
  LangPack in 'LangPack.pas',
  dlgBatchConvert in 'dlgBatchConvert.pas' {frmBatchConvert},
  {$IFDEF WINDOWS} DdeServer in 'DdeServer.pas', {$ENDIF}
  dlgLanguage in 'dlgLanguage.pas' {frmLanguage},
  ColSpaces in 'ColSpaces.pas',
  StreamEx in 'StreamEx.pas',
  RIFF in 'RIFF.pas',
  GIF in 'GIF.pas',
  dlgMetadata in 'dlgMetadata.pas' {frmMetadata},
  ResList in 'ResList.pas',
  dlgResProp in 'dlgResProp.pas' {frmResProp},
  FloatFormula in 'FloatFormula.pas',
  dlgFormulae in 'dlgFormulae.pas' {frmFormulae},
  BMP in 'BMP.pas',
  PCX in 'PCX.pas',
  Layers in 'Layers.pas',
  BlendModes in 'BlendModes.pas',
  ICO in 'ICO.pas',
  ANI in 'ANI.pas',
  UndoObject in 'UndoObject.pas',
  dlgLayerProp in 'dlgLayerProp.pas' {frmLayerProp},
  dlgLayers in 'dlgLayers.pas' {frmLayers},
  gfDataTree in 'gfDataTree.pas',
  GFIEFormat in 'GFIEFormat.pas',
  dlgLib in 'dlgLib.pas' {frmLib},
  dlgCellGrid in 'dlgCellGrid.pas' {frmCellGrid},
  fnvHash, BitmapEx, bmExUtils, gfcomp, printer4lazarus, CIntf, Locales,
  Jpeg2000, ICNS, FilterDialog, dlgSaveOptions, FastDiv, dlgStartupFrame,
  dlgDebug, PixelFormats, dlgCreateMacIcon, dlgExeFormat
  {$I _LResources.inc};

{$IFDEF MSWINDOWS}
{$R *.res}
{$ENDIF}

procedure DoCreateForm(FormClass: TFormClass; var Reference);
begin
  with Application do CreateForm(FormClass, Reference);
  frmSplash.IncProgress;
end;

var
  _iec: TieCursor;

begin
  Application.Title:='Greenfish Icon Editor Pro';
  DefaultFormatSettings.DecimalSeparator := '.';
  Randomize;

  Application.Initialize;

  {$I misc.lrs}
  // load cursor resources
  Screen.Cursors[crHandPoint] := LoadCursorFromLazarusResource('handpoint');
  for _iec in TieCursor do
    Screen.Cursors[ieCursorBase + Ord(_iec)] :=
      LoadCursorFromLazarusResource(ieCursorRes[_iec]);

  // Parameter /uninstall: remove system dependencies
  if UpperCase(ParamStr(1)) = '/UNINSTALL' then
  begin
{$IFDEF WINDOWS}
    UnAssociateAll;
{$ENDIF}
    Exit;
  end;
  VerboseMode := UpperCase(ParamStr(1)) = '/VERBOSE';

  Application.CreateForm(TfrmMain, frmMain);
  if EnableDebug then DoCreateForm(TfrmDebug, frmDebug);
  frmSplash := TfrmSplash.Create(Application);
  frmSplash.MaxProgress := 28;
  frmSplash.RedrawSplash;

  // load preferences
  try
    prefLoad;
  except
  end;

  // important forms
  DoCreateForm(TfrmDocPage, frmDocPage);
  DoCreateForm(TfrmLayerProp, frmLayerProp);
  DoCreateForm(TfrmPreferences, frmPreferences);
  DoCreateForm(TfrmTest, frmTest);
  DoCreateForm(TfrmText, frmText);

  // not so important forms
  DoCreateForm(TfrmBatchConvert, frmBatchConvert);
  DoCreateForm(TfrmBevel, frmBevel);
  DoCreateForm(TfrmBlur, frmBlur);
  DoCreateForm(TfrmCellGrid, frmCellGrid);
  DoCreateForm(TfrmCreateIcon, frmCreateIcon);
  DoCreateForm(TfrmExposure, frmExposure);
  DoCreateForm(TfrmFormulae, frmFormulae);
  DoCreateForm(TfrmGlow, frmGlow);
  DoCreateForm(TfrmHueSaturation, frmHueSaturation);
  DoCreateForm(TfrmLanguage, frmLanguage);
  DoCreateForm(TfrmMetadata, frmMetadata);
  DoCreateForm(TfrmOpacity, frmOpacity);
  DoCreateForm(TfrmPrint, frmPrint);
  DoCreateForm(TfrmRemoveMatte, frmRemoveMatte);
  DoCreateForm(TfrmResProp, frmResProp);
  DoCreateForm(TfrmRGBChannels, frmRGBChannels);
  DoCreateForm(TfrmSaveOptions, frmSaveOptions);
  DoCreateForm(TfrmShadow, frmShadow);
  DoCreateForm(TfrmTransform, frmTransform);
  DoCreateForm(TfrmUnsharpMask, frmUnsharpMask);
  DoCreateForm(TfrmCreateMacIcon, frmCreateMacIcon);
  DoCreateForm(TfrmExeFormat, frmExeFormat);

  // loaded
  frmSplash.tmFadeOut.Enabled := True;
  if VerboseMode then Log('About to run application');
  Application.Run;

  // save preferences
  try
    prefSave;
  except
  end;
end.
