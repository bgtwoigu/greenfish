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
unit LangPack;

interface

uses
  LclIntf, LclType, FileUtil,
  SysUtils, Classes, PixelFormats, DocClass, ieShared, Forms, Controls, Dialogs,
  dlgDebug;

// when loading tool names from the language pack
const
  sExecExt = '*.exe;*.dll;*.scr;*.cpl;*.ocx;*.vbx;*.bpl;*.icl;*.il';

  ToolNameRes: array[TDrawTool] of string = ('SEL_RECT', 'SEL_ELLIPSE',
    'LASSO', 'WAND', 'SEL_PENCIL', 'TRANSFORM', 'CROP', 'HOTSPOT',
    'EYEDROPPER', 'RETOUCH', 'RECT', 'ELLIPSE', 'LINE', 'TEXT', 'PENCIL',
    'BRUSH', 'ERASER', 'RECOLOR', 'BUCKET', 'GRADIENT', 'NONE');

type
  TlpEntry = record
    Id: string;
    Data: string;
  end;

var
  // database
  lpRes: array of TlpEntry;

  // strings loaded from lang. packs
  pf32ToStr: array[TPixelFormat32] of string;
  ToolName: array[TDrawTool] of string;
  MsgDataLoss: array[TieDataLoss] of string;

function lpGet(const Id: string): string;
procedure lpLoad(const fn: string);
procedure lpApplyToUI;
//function lpShortCutToText(ShortCut: TShortCut): string;

function QueryOverwrite(const FileName: string): boolean;
// Displays a "Do you want to save changes?" dialog
function QuerySaveChanges(const FileName: string): integer;

implementation

uses
  dlgBatchConvert, dlgBevel, dlgBlur, dlgCellGrid, dlgCreateIcon, dlgDoc, dlgDocPage,
  dlgExposure, dlgFormulae, dlgGlow, dlgHueSaturation, dlgLanguage, dlgLayerProp,
  dlgLib, Main, dlgMetadata, dlgOpacity, dlgPreferences, dlgPrint, dlgMatte,
  dlgResProp, dlgRGBChannels, dlgShadow,
  dlgTest, dlgText, dlgTransform, dlgUnsharpMask,
  dlgSaveOptions, dlgStartupFrame, dlgCreateMacIcon, dlgExeFormat;

function lpGet;
var
  Lo, Hi, Mid: integer;

begin
  Result := '[' + Id + ' not in language pack]';

  if (Length(lpRes) <> 0) and (Id >= lpRes[0].Id) and
    (Id <= lpRes[Length(lpRes) - 1].Id) then
  // find the corresponding entry using binary search
  begin
    Lo := 0; Hi := Length(lpRes) - 1;

    while Hi - Lo > 1 do
    begin
      Mid := (Lo + Hi) div 2;
      if Id < lpRes[Mid].Id then Hi := Mid - 1 else Lo := Mid;
    end;

    if lpRes[Lo].Id = Id then Result := lpRes[Lo].Data else
    if lpRes[Hi].Id = Id then Result := lpRes[Hi].Data;
  end;
//  if result[1]='[' then log(id+' is missing!');
end;

procedure lpLoad;
var
  f: textfile;
  Count, i, j, p: integer;
  tmp: TlpEntry;
  s: string;
  
begin
  // read entries from the file
  SetLength(lpRes, 0);
  Count := 0;
  AssignFile(f, fn);
  Reset(f);
  try
    while not Eof(f) do
    begin
      Readln(f, s);
      p := Pos('=', s);
      if (p <> 0) and (s[1] <> ';') then
      begin
        inc(Count);
        if Count > Length(lpRes) then SetLength(lpRes, Count or $ff);

        with lpRes[Count - 1] do
        begin
          Id := Copy(s, 1, p-1);
          Data := StringReplace(Copy(s, p+1, Length(s) - p),
            '<br>', LineEnding, [rfReplaceAll]);
        end;
      end; // if s is OK
    end; // while not eof
  finally
    CloseFile(f);
  end;
  SetLength(lpRes, Count);

  // sort entries by Id
  for i := 0 to Count - 2 do
  begin
    p := i;
    for j := i + 1 to Count - 1 do if lpRes[j].Id < lpRes[p].Id then p := j;
    if p <> i then
    begin
      tmp := lpRes[i];
      lpRes[i] := lpRes[p];
      lpRes[p] := tmp;
    end;
  end;
end;

function lpResourceIterator(Name, Value: string; Hash: integer; arg: Pointer): string;
begin
  // MessageDlg
  if Name = 'lclstrconsts.rsmbok' then Result := lpGet('B_OK') else
  if Name = 'lclstrconsts.rsmbcancel' then Result := lpGet('B_CANCEL') else
  if Name = 'lclstrconsts.rsmbyes' then Result := lpGet('B_YES') else
  if Name = 'lclstrconsts.rsmbno' then Result := lpGet('B_NO') else
  if Name = 'lclstrconsts.rsmball' then Result := lpGet('B_ALL') else
  if Name = 'lclstrconsts.rsmbclose' then Result := lpGet('B_CLOSE') else
  if Name = 'lclstrconsts.rsmtconfirmation' then Result := lpGet('MSG_CONFIRMATION') else
  // Menu key shortcuts
  if Name = 'lclstrconsts.smkcctrl' then Result := lpGet('KEY_CTRL')+'+' else
  if Name = 'lclstrconsts.smkcalt' then Result := lpGet('KEY_ALT')+'+' else
  if Name = 'lclstrconsts.smkcshift' then Result := lpGet('KEY_SHIFT')+'+' else
  if Name = 'lclstrconsts.smkcdel' then Result := lpGet('KEY_DEL') else
  if Name = 'lclstrconsts.smkcenter' then Result := lpGet('KEY_ENTER') else
    Result := '';
end;

procedure lpApplyToUI;
var
  i: integer;
  dt: TDrawTool;
  s, fltAll, fltGraphic, fltLibraryOpen, fltLibrarySave: string;
  frm: TDocumentFrame;

begin
  // load strings from database
  // UI resource strings
  SetUnitResourceStrings('LclStrConsts', lpResourceIterator, nil);

  // pixel format names
  pf32ToStr[pf32_1bit] := lpGet('PF_1_BIT');
  pf32ToStr[pf32_4bit] := lpGet('PF_16_COLORS');
  pf32ToStr[pf32_8bit] := lpGet('PF_256_COLORS');
  pf32ToStr[pf32_24Bit] := lpGet('PF_24_BIT');
  pf32ToStr[pf32_32Bit] := lpGet('PF_32_BIT');

  // tool names
  for dt in TDrawTool do ToolName[dt] := lpGet('TOOL_' + ToolNameRes[dt]);

  // data loss messages
  MsgDataLoss[dlMultiPage] := lpGet('MSG_DL_MULTIPAGE');
  MsgDataLoss[dlLayers] := lpGet('MSG_DL_LAYERS');
  MsgDataLoss[dlSize256] := lpGet('MSG_DL_SIZE_256');
  MsgDataLoss[dlTransparency] := lpGet('MSG_DL_TRANSPARENCY');
  MsgDataLoss[dlColorDepth] := lpGet('MSG_DL_COLOR_DEPTH');
  MsgDataLoss[dlIcns] := lpGet('MSG_DL_ICNS');

  // frmBatchConvert
  with frmBatchConvert do
  begin
    Caption := lpGet('MI_FILE_BATCH_CONVERT');

    gbFiles.Caption := lpGet('BC_FILES');
    bAdd.Caption := lpGet('B_ADD')+'...';
    bClear.Caption := lpGet('B_CLEAR');

    gbSettings.Caption := lpGet('BC_SETTINGS');
    lFormat.Caption := lpGet('BC_FORMAT')+':';
    SetComboItems(cbFormat, lpGet('FF_GFIE')+LineEnding+
      lpGet('FF_ICO')+LineEnding+lpGet('FF_CUR')+LineEnding+
      lpGet('FF_ANI')+LineEnding+lpGet('FF_ICNS')+LineEnding+
      lpGet('FF_PNG')+LineEnding+lpGet('FF_XPM')+LineEnding+
      lpGet('FF_BMP')+LineEnding+lpGet('FF_JPEG')+LineEnding+
      lpGet('FF_GIF')+LineEnding+lpGet('FF_JPEG_2000')+LineEnding+
      {lpGet('FF_TGA')+LineEnding+}lpGet('FF_PCX'));
    lFolder.Caption := lpGet('BC_FOLDER')+':';
    
    cbOpen.Caption := lpGet('BC_OPEN');
    bIconFormats.Caption := lpGet('BC_ICON_FORMATS')+'...';
    bSaveOptions.Caption := lpGet('SO_TITLE')+'...';

    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmBevel
  with frmBevel do
  begin
    Caption := lpGet('MI_FLT_BEVEL');
    alSize.Caption := lpGet('LABEL_SIZE')+':';
    alAngle.Caption := lpGet('LABEL_ANGLE_DEGREES')+':';
    alBlur.Caption := lpGet('LABEL_BLUR')+':';
    alIntensity.Caption := lpGet('LABEL_INTENSITY')+':';
    cbToric.Caption := lpGet('LABEL_TORIC');
    cbPreview.Caption := lpGet('B_PREVIEW');
    bReset.Caption := lpGet('B_RESET');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmBlur
  with frmBlur do
  begin
    Caption := lpGet('MI_FLT_BLUR_CUSTOM');
    rbGaussian.Caption := lpGet('LABEL_GAUSSIAN_BLUR');
    alGaussianRadius.Caption := lpGet('LABEL_RADIUS')+':';
    rbBox.Caption := lpGet('LABEL_BOX_BLUR');
    alBoxRadius.Caption := lpGet('LABEL_RADIUS')+':';
    cbToric.Caption := lpGet('LABEL_TORIC');
    cbPreview.Caption := lpGet('B_PREVIEW');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmCellGrid
  with frmCellGrid do
  begin
    Caption := lpGet('MI_VIEW_CELL_GRID');
    cbEnabled.Caption := lpGet('CG_ENABLED');
    gbSize.Caption := lpGet('CG_SIZE');
    gbSpacing.Caption := lpGet('CG_SPACING');
    gbOffset.Caption := lpGet('CG_OFFSET');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmColor
  with frmMain.frmColor do
  begin
    Caption := lpGet('MI_VIEW_COLOR_PICKER');

    pbForeColor.Hint := lpGet('HINT_CP_FORE_COLOR');
    pbBackColor.Hint := lpGet('HINT_CP_BACK_COLOR');
    sbSwapColors.Hint := lpGet('HINT_CP_SWAP_COLORS');
    sbDefault.Hint := lpGet('HINT_CP_DEFAULT');
    sbTransparent.Hint := lpGet('HINT_CP_TRANSPARENT');
    sbInverted.Hint := lpGet('HINT_CP_INVERTED');

    //tsHSBMap.Caption := lpGet('TAB_HSB_MAP');
    //tsSwatches.Caption := lpGet('TAB_SWATCHES');
    iNextPage.Hint := lpGet('HINT_CP_TOGGLE_CHOOSER');
    Swatches.Hint := lpGet('HINT_CP_SWATCHES');
    sbSwatchLoad.Hint := lpGet('HINT_CP_SWATCH_LOAD');
    sbSwatchSave.Hint := lpGet('HINT_CP_SWATCH_SAVE');

    lRed.Caption := lpGet('LABEL_R')+':';
    lGreen.Caption := lpGet('LABEL_G')+':';
    lBlue.Caption := lpGet('LABEL_B')+':';
    lAlpha.Caption := lpGet('LABEL_A')+':';

    s := lpGet('HINT_CP_RED');
    lRed.Hint := s; sbRed.Hint := s; neRed.Hint := s;
    s := lpGet('HINT_CP_GREEN');
    lGreen.Hint := s; sbGreen.Hint := s; neGreen.Hint := s;
    s := lpGet('HINT_CP_BLUE');
    lBlue.Hint := s; sbBlue.Hint := s; neBlue.Hint := s;
    s := lpGet('HINT_CP_ALPHA');
    lAlpha.Hint := s; sbAlpha.Hint := s; neAlpha.Hint := s;
    s := lpGet('HINT_CP_HTML');
    lHTML.Hint := s; eHTML.Hint := s;

    imWCP.Hint := lpGet('HINT_CP_WCP');
  end;

  // frmCreateIcon
  with frmCreateIcon do
  begin
    Caption := lpGet('MI_ICON_CREATE_WIN');
    lInfo.Caption := lpGet('CI_SELECT_FORMATS')+':';
    lBW.Caption := pf32ToStr[pf32_1bit];
    l16Colors.Caption := pf32ToStr[pf32_4bit];
    l256Colors.Caption := pf32ToStr[pf32_8bit];
    l24Bit.Caption := pf32ToStr[pf32_24Bit];
    l32Bit.Caption := pf32ToStr[pf32_32Bit];

    bReset.Caption := lpGet('B_RESET');
    bNone.Caption := lpGet('B_NONE');
    bAll.Caption := lpGet('B_ALL');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmCreateMacIcon
  frmCreateMacIcon.ApplyLanguagePack;

  // frmDoc
  for i := 0 to frmMain.pc.PageCount - 1 do
  begin
    if not (frmMain.pc.Pages[i] is TDocumentTab) then Continue;

    frm := TDocumentTab(frmMain.pc.Pages[i]).Frame;
    if frm = nil then Continue;
    if frm is TGraphicFrame then
      (frm as TGraphicFrame).ApplyLanguagePack else
    if frm is TLibraryFrame then
      (frm as TLibraryFrame).ApplyLanguagePack;
  end;

  // frmDocPage
  with frmDocPage do
  begin
    lSize.Caption := lpGet('LABEL_SIZE')+':';
    SetComboItems(cbSize,
      Format('16 x 16 (%s)'+LineEnding+
        '20 x 20'+LineEnding+
        '24 x 24 (%s)'+LineEnding+
        '32 x 32 (%s)'+LineEnding+
        '48 x 48 (%s)'+LineEnding+
        '64 x 64 (%s)'+LineEnding+
        '256 x 256 (%s)'+LineEnding+
        '512 x 512 (%s)'+LineEnding+
        '1024 x 1024 (%s)'+LineEnding+
        '%s',
        [lpGet('PG_SIZE_SMALLEST'), lpGet('PG_SIZE_TOOLBAR'),
         lpGet('PG_SIZE_SMALL'), lpGet('PG_SIZE_MEDIUM'),
         lpGet('PG_SIZE_LARGE'), lpGet('PG_SIZE_HUGE_VISTA'),
         lpGet('PG_SIZE_APPLE'), lpGet('PG_SIZE_APPLE'),
         lpGet('PG_CUSTOM_SIZE')]));

    gbCustomSize.Caption := lpGet('PG_CUSTOM_SIZE');
    alWidth.Caption := lpGet('LABEL_WIDTH')+':';
    alHeight.Caption := lpGet('LABEL_HEIGHT')+':';
    cbSquare.Caption := lpGet('PG_SQUARE');

    lCR.Caption := lpGet('PG_CR')+':';
    SetComboItems(cbCR,
      lpGet('PG_CR_BW')+LineEnding+
      lpGet('PG_CR_16_WIN')+LineEnding+lpGet('PG_CR_16_MAC')+LineEnding+
      lpGet('PG_CR_256_ADAPT')+LineEnding+lpGet('PG_CR_256_MAC')+LineEnding+
      lpGet('PG_CR_24')+LineEnding+lpGet('PG_CR_32'));

    gbAnimation.Caption := lpGet('PG_ANIMATION');
    alFrameRate.Caption := lpGet('PG_FRAME_RATE')+':';

    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');

    cbCreateFrom.Caption := lpGet('PG_CREATE_FROM_SELECTED');

    gbWhenResizing.Caption := lpGet('PG_WHEN_RESIZING');
    rbStretch.Caption := lpGet('PG_STRETCH');
    rbCrop.Caption := lpGet('PG_CROP');
    iaCrop.Hint := lpGet('PG_IMAGE_ANCHORS');
  end;

  // frmExeFormat
  with frmExeFormat do
  begin
    Caption := lpGet('IF_TITLE');
    bOK.Caption := lpGet('B_OK');
  end;

  // frmExposure
  with frmExposure do
  begin
    Caption := lpGet('MI_FLT_EXPOSURE');
    lGamma.Caption := lpGet('LABEL_GAMMA')+':';
    lBrightness.Caption := lpGet('LABEL_BRIGHTNESS')+':';
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
    bReset.Caption := lpGet('B_RESET');
  end;

  // frmFormulae
  with frmFormulae do
  begin
    Caption := lpGet('MI_FLT_FORMULAE');
    cbPreview.Caption := lpGet('B_PREVIEW');
    bReset.Caption := lpGet('B_RESET');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmGlow
  with frmGlow do
  begin
    Caption := lpGet('MI_FLT_GLOW');
    alRadius.Caption := lpGet('LABEL_RADIUS')+':';
    lColor.Caption := lpGet('LABEL_COLOR')+':';
    alIntensity.Caption := lpGet('LABEL_INTENSITY')+':';
    gbKind.Caption := lpGet('LABEL_KIND');
    cbInnerGlow.Caption := lpGet('LABEL_INNER_GLOW');
    cbOuterGlow.Caption := lpGet('LABEL_OUTER_GLOW');
    cbToric.Caption := lpGet('LABEL_TORIC');
    cbPreview.Caption := lpGet('B_PREVIEW');
    bReset.Caption := lpGet('B_RESET');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmHueSaturation
  with frmHueSaturation do
  begin
    Caption := lpGet('MI_FLT_HS');
    alHue.Caption := lpGet('LABEL_HUE_SHIFT')+':';
    alSat.Caption := lpGet('LABEL_SATURATION')+':';
    bReset.Caption := lpGet('B_RESET');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmLanguage
  with frmLanguage do
  begin
    Caption := lpGet('MI_SET_LANGUAGE');
    lLangPack.Caption := lpGet('LABEL_LANG_PACK')+':';
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmLayerProp
  with frmLayerProp do
  begin
    Caption := lpGet('MI_LAYERS_PROP');
    lName.Caption := lpGet('LP_NAME')+':';
    cbVisible.Caption := lpGet('LP_VISIBLE');
    alOpacity.Caption := lpGet('LABEL_OPACITY')+':';
    lBlendMode.Caption := lpGet('LP_BLEND_MODE')+':';
    SetComboItems(cbBlendMode,
      lpGet('LP_BM_NORMAL')+LineEnding+
      lpGet('LP_BM_MASK')+LineEnding+
      lpGet('LP_BM_BEHIND')+LineEnding+
      lpGet('LP_BM_DISSOLVE')+LineEnding+
      lpGet('LP_BM_HUE')+LineEnding+
      lpGet('LP_BM_HUE_SHIFT')+LineEnding+
      lpGet('LP_BM_SAT')+LineEnding+
      lpGet('LP_BM_DARKEN')+LineEnding+
      lpGet('LP_BM_MULTIPLY')+LineEnding+
      lpGet('LP_BM_COLOR_BURN')+LineEnding+
      lpGet('LP_BM_LINEAR_BURN')+LineEnding+
      lpGet('LP_BM_DARKER_COLOR')+LineEnding+
      lpGet('LP_BM_LIGHTEN')+LineEnding+
      lpGet('LP_BM_SCREEN')+LineEnding+
      lpGet('LP_BM_COLOR_DODGE')+LineEnding+
      lpGet('LP_BM_LINEAR_DODGE')+LineEnding+
      lpGet('LP_BM_LIGHTER_COLOR')+LineEnding+
      lpGet('LP_BM_OVERLAY')+LineEnding+
      lpGet('LP_BM_SOFT_LIGHT')+LineEnding+
      lpGet('LP_BM_HARD_LIGHT')+LineEnding+
      lpGet('LP_BM_VIVID_LIGHT')+LineEnding+
      lpGet('LP_BM_LINEAR_LIGHT')+LineEnding+
      lpGet('LP_BM_PIN_LIGHT')+LineEnding+
      lpGet('LP_BM_HARD_MIX')+LineEnding+
      lpGet('LP_BM_DIFFERENCE')+LineEnding+
      lpGet('LP_BM_EXCLUSION')
    );
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmLayers
  with frmMain.frmLayers do
  begin
    Caption := lpGet('MI_VIEW_LAYERS');
    sbNew.Hint := lpGet('MI_LAYERS_NEW');
    sbDelete.Hint := lpGet('MI_LAYERS_DELETE');
    sbProp.Hint := lpGet('MI_LAYERS_PROP');
    sbMergeSelected.Hint := lpGet('MI_LAYERS_MERGE_SELECTED');
    lb.Hint := lpGet('MI_VIEW_LAYERS');
  end;

  // frmMain
  with frmMain do
  begin
    miFile.Caption := lpGet('MI_FILE');
    miNewGraphic.Caption := lpGet('MI_FILE_NEW_GRAPHIC')+'...';
    miNewLibrary.Caption := lpGet('MI_FILE_NEW_LIBRARY');
    miOpen.Caption := lpGet('MI_FILE_OPEN')+'...';
    miRecentFiles.Caption := lpGet('MI_FILE_RECENT_FILES');
    miClearList.Caption := lpGet('MI_FILE_RF_CLEAR');
    miBatchConvert.Caption := lpGet('MI_FILE_BATCH_CONVERT')+'...';
    miClose.Caption := lpGet('MI_FILE_CLOSE');
    miCloseAll.Caption := lpGet('MI_FILE_CLOSE_ALL');
    miSave.Caption := lpGet('MI_FILE_SAVE');
    miSaveAs.Caption := lpGet('MI_FILE_SAVE_AS')+'...';
    miSaveACopy.Caption := lpGet('MI_FILE_SAVE_COPY')+'...';
    miSaveAll.Caption := lpGet('MI_FILE_SAVE_ALL');
    miRevert.Caption := lpGet('MI_FILE_REVERT');
    miMetadata.Caption := lpGet('MI_FILE_METADATA')+'...';
    miPrint.Caption := lpGet('MI_FILE_PRINT')+'...';
    miExit.Caption := lpGet('MI_FILE_EXIT');

    miEdit.Caption := lpGet('MI_EDIT');
    miCut.Caption := lpGet('MI_EDIT_CUT');
    miCopy.Caption := lpGet('MI_EDIT_COPY');
    miPaste.Caption := lpGet('MI_EDIT_PASTE');
    miPasteAsPage.Caption := lpGet('MI_EDIT_PASTE_PAGE');
    miPasteAsDoc.Caption := lpGet('MI_EDIT_PASTE_DOC');
    miDelete.Caption := lpGet('MI_EDIT_DELETE');
    miSelectAll.Caption := lpGet('MI_EDIT_SEL_ALL');
    miDeselectAll.Caption := lpGet('MI_EDIT_SEL_NONE');
    miInvertSelection.Caption := lpGet('MI_EDIT_SEL_INVERT');
    miLoadSelection.Caption := lpGet('MI_EDIT_SEL_LOAD')+'...';
    miSaveSelection.Caption := lpGet('MI_EDIT_SEL_SAVE')+'...';
    miCropTransparency.Caption := lpGet('MI_EDIT_CROP_TRANSPARENCY');
    miTransform.Caption := lpGet('MI_EDIT_TRANSFORM');
    miXformSel.Caption := lpGet('MI_EDIT_SEL_TRANSFORM')+'...';
    miFlipHoriz.Caption := lpGet('MI_EDIT_FLIP_HORIZ');
    miFlipVert.Caption := lpGet('MI_EDIT_FLIP_VERT');
    miRotate90Left.Caption := lpGet('MI_EDIT_ROTATE_LEFT');
    miRotate90Right.Caption := lpGet('MI_EDIT_ROTATE_RIGHT');
    miRotate180.Caption := lpGet('MI_EDIT_ROTATE_180');

    miView.Caption := lpGet('MI_VIEW');
    miZoomIn.Caption := lpGet('MI_VIEW_ZOOM_IN');
    miZoomOut.Caption := lpGet('MI_VIEW_ZOOM_OUT');
    mi100Percent.Caption := lpGet('MI_VIEW_100_PERCENT');
    miFitWindow.Caption := lpGet('MI_VIEW_FIT_WINDOW');
    miGrid.Caption := lpGet('MI_VIEW_GRID');
    miCellGrid.Caption := lpGet('MI_VIEW_CELL_GRID')+'...';
    miCenterLines.Caption := lpGet('MI_VIEW_CENTER_LINES');
    miViewPages.Caption := lpGet('MI_VIEW_PAGES');
    miPanelLeft.Caption := lpGet('MI_VIEW_PANEL_LEFT');
    miPanelRight.Caption := lpGet('MI_VIEW_PANEL_RIGHT');
    miStartupScreen.Caption := lpGet('MI_VIEW_STARTUP_SCREEN');

    miFilters.Caption := lpGet('MI_FLT');
    miGrayscale.Caption := lpGet('MI_FLT_GRAYSCALE');
    miInvert.Caption := lpGet('MI_FLT_INVERT');
    miSolarize.Caption := lpGet('MI_FLT_SOLARIZE');
    miRGBChannels.Caption := lpGet('MI_FLT_RGB')+'...';
    miHueSaturation.Caption := lpGet('MI_FLT_HS')+'...';
    miExposure.Caption := lpGet('MI_FLT_EXPOSURE')+'...';
    miFormulae.Caption := lpGet('MI_FLT_FORMULAE')+'...';
    miAverage.Caption := lpGet('MI_FLT_AVERAGE');
    miSoftBlur.Caption := lpGet('MI_FLT_BLUR_SOFT');
    miBlurMore.Caption := lpGet('MI_FLT_BLUR_MORE');
    miCustomBlur.Caption := lpGet('MI_FLT_BLUR_CUSTOM')+'...';
    miSharpen.Caption := lpGet('MI_FLT_SHARPEN');
    miUnsharpMask.Caption := lpGet('MI_FLT_UNSHARP_MASK')+'...';
    miRemoveMatte.Caption := lpGet('MI_FLT_REMOVE_MATTE')+'...';
    miOpacity.Caption := lpGet('MI_FLT_OPACITY')+'...';
    miPaintContour.Caption := lpGet('MI_FLT_PAINT_CONTOUR');
    miDropShadow.Caption := lpGet('MI_FLT_DROP_SHADOW')+'...';
    miGlow.Caption := lpGet('MI_FLT_GLOW')+'...';
    miBevel.Caption := lpGet('MI_FLT_BEVEL')+'...';

    miLayers.Caption := lpGet('MI_LAYERS');
    miLayerNew.Caption := lpGet('MI_LAYERS_NEW');
    miLayerDupl.Caption := lpGet('MI_LAYERS_DUPLICATE');
    miLayerDelete.Caption := lpGet('MI_LAYERS_DELETE');
    miLayerProp.Caption := lpGet('MI_LAYERS_PROP')+'...';
    miMergeSelected.Caption := lpGet('MI_LAYERS_MERGE_SELECTED');
    miMergeVisible.Caption := lpGet('MI_LAYERS_MERGE_VISIBLE');
    miFlattenImage.Caption := lpGet('MI_LAYERS_FLATTEN');
    miLayerFromSel.Caption := lpGet('MI_LAYERS_FROM_SEL');

    miIcon.Caption := lpGet('MI_ICON');
    miPageNew.Caption := lpGet('MI_ICON_PAGE_NEW')+'...';
    miPageDelete.Caption := lpGet('MI_ICON_PAGE_DELETE');
    miPageProp.Caption := lpGet('MI_ICON_PAGE_PROP')+'...';
    miPageImport.Caption := lpGet('MI_ICON_PAGE_IMPORT')+'...';
    miPageExport.Caption := lpGet('MI_ICON_PAGE_EXPORT')+'...';
    miPageExportAll.Caption := lpGet('MI_ICON_PAGE_EXPORT_ALL')+'...';
    miUniformRate.Caption := lpGet('MI_ICON_UNIFORM_RATE');
    miCreateWinIcon.Caption := lpGet('MI_ICON_CREATE_WIN')+'...';
    miCreateMacIcon.Caption := lpGet('MI_ICON_CREATE_MAC')+'...';
    miTest.Caption := lpGet('MI_ICON_TEST')+'...';

    miLibrary.Caption := lpGet('MI_LIB');
    miResAdd.Caption := lpGet('MI_LIB_ADD')+'...';
    miResRemove.Caption := lpGet('MI_LIB_REMOVE');
    miResReplace.Caption := lpGet('MI_LIB_REPLACE')+'...';
    miResProp.Caption := lpGet('MI_LIB_PROP')+'...';
    miExtractEdit.Caption := lpGet('MI_LIB_EXTRACT_EDIT');
    miExtractSave.Caption := lpGet('MI_LIB_EXTRACT_SAVE')+'...';

    miSettings.Caption := lpGet('MI_SET');
    miPreferences.Caption := lpGet('MI_SET_PREFERENCES')+'...';
    s := lpGet('MI_SET_LANGUAGE');
    if s = 'Language' then miLanguage.Caption := s+'...' else
      miLanguage.Caption := s+' (Language)...';

    miHelp.Caption := lpGet('MI_HELP');
    for i := 0 to Length(miContents) - 1 do with miContents[i] do
      mi.Caption := lpGet('MI_HELP_CONTENTS') + ' (' + Language + ')...';
    miHomepage.Caption := lpGet('MI_HELP_HOMEPAGE');
    miSupport.Caption := lpGet('MI_HELP_SUPPORT');
    miDonate.Caption := lpGet('MI_HELP_DONATE') + sDonateService;
    miAbout.Caption := lpGet('MI_HELP_ABOUT')+'...';

    fltAll := lpGet('FF_ALL') + ' (*.*)|*.*';
    fltGraphic := Format('%s (*.gfie;*.gfi)|*.gfie;*.gfi|' +
      '%s (*.ico)|*.ico|%s (*.cur)|*.cur|%s (*.ani)|*.ani|%s (*.icns)|*.icns|' +
      '%s (*.png)|*.png|%s (*.xpm)|*.xpm|%s (*.bmp)|*.bmp|' +
      '%s (*.jpg;*.jpeg;*.jpe)|*.jpg;*.jpeg;*.jpe|' +
      '%s (*.gif)|*.gif|%s (*.jp2;*.j2k;*.jpf;*.jpx)|*.jp2;*.j2k;*.jpf;*.jpx|' +
      {'%s (*.tga)|*.tga|'+}'%s (*.pcx)|*.pcx',

      [lpGet('FF_GFIE'), lpGet('FF_ICO'), lpGet('FF_CUR'), lpGet('FF_ANI'), lpGet('FF_ICNS'),
       lpGet('FF_PNG'), lpGet('FF_XPM'), lpGet('FF_BMP'), lpGet('FF_JPEG'),
       lpGet('FF_GIF'), lpGet('FF_JPEG_2000'), {lpGet('FF_TGA'),} lpGet('FF_PCX')]);
    fltLibraryOpen := Format('%s|%s|%s (*.res)|*.res',
      [lpGet('FF_EXEC'), sExecExt, lpGet('FF_RES')]);
    fltLibrarySave := Format('%s (*.icl;*.dll)|*.icl;*.dll|%s (*.res)|*.res',
      [lpGet('FF_ICL'), lpGet('FF_RES')]);

    sdGraphic.Filter := fltAll + '|' + fltGraphic;
    sdLibrary.Filter := fltAll + '|' + fltLibrarySave;
    od.Filter := fltAll + '|' + fltGraphic + '|' + fltLibraryOpen;

    od.Title := lpGet('MI_FILE_OPEN');
    sdGraphic.Title := lpGet('MI_FILE_SAVE');
    sdLibrary.Title := lpGet('MI_FILE_SAVE');

    // TODO: auto-invalidate the accordion control when Caption changes
    accLayers.Caption := lpGet('MI_VIEW_LAYERS');
    accLayers.Invalidate;
    accColorPicker.Caption := lpGet('MI_VIEW_COLOR_PICKER');
    accColorPicker.Invalidate;
  end;

  // frmMetadata
  with frmMetadata do
  begin
    Caption := lpGet('MI_FILE_METADATA');
    
    gbSummary.Caption := Format(lpGet('MD_TYPE'), ['GFIE/ANI']);
    lTitle.Caption := lpGet('MD_TITLE')+':';
    lAuthor.Caption := lpGet('MD_AUTHOR')+':';
    lCopyright.Caption := lpGet('MD_COPYRIGHT')+':';
    lComments.Caption := lpGet('MD_COMMENTS')+':';

    gbGIF.Caption := Format(lpGet('MD_TYPE'), ['GIF']);
    alLoopCount.Caption := lpGet('MD_LOOP_COUNT')+':';

    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmOpacity
  with frmOpacity do
  begin
    Caption := lpGet('MI_FLT_OPACITY');
    alOpacity.Caption := lpGet('LABEL_OPACITY')+':';
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmPreferences
  with frmPreferences do
  begin
    Caption := lpGet('MI_SET_PREFERENCES');

    tsMisc.Caption := lpGet('PREF_MISC');
    gbImageMax.Caption := lpGet('PREF_IMAGE_MAX');
    alMaxWidth.Caption := lpGet('LABEL_WIDTH')+':';
    alMaxHeight.Caption := lpGet('LABEL_HEIGHT')+':';
    gbUsePNG.Caption := lpGet('PREF_PNG_ICONS');
    cbUsePNG.Caption := lpGet('PREF_PNG_LIMIT');

    tsEnvironment.Caption := lpGet('PREF_ENVIRONMENT');
    gbColors.Caption := lpGet('PREF_COLORS');
    lTransparentHatch.Caption := lpGet('PREF_TRANSPARENT_HATCH')+':';
    lGrid.Caption := lpGet('MI_VIEW_GRID')+':';
    lGrid2.Caption := lpGet('PREF_GRID2')+':';
    bResetColors.Caption := lpGet('B_RESET');
    lDVM.Caption := lpGet('PREF_DVM')+':';
    SetComboItems(cbDVM, lpGet('PREF_DVM_ITEMS'));
    lMWA.Caption := lpGet('PREF_MWA')+':';
    SetComboItems(cbMWA, lpGet('PREF_MWA_ITEMS'));
    cbSaveToolSettings.Caption := lpGet('PREF_SAVE_TOOL_SETTINGS');

    tsInstall.Caption := lpGet('PREF_INSTALL');
    gbFileAssoc.Caption := lpGet('PREF_FILE_ASSOC');
    lAdminMode.Caption := lpGet('PREF_ADMIN');
    
    bReset.Caption := lpGet('B_RESET');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmPrint
  with frmPrint do
  begin
    Caption := lpGet('MI_FILE_PRINT');
    bPrinterSetup.Caption := lpGet('B_PRINTER_SETUP')+'...';
    alCopies.Caption := lpGet('PRINT_COPIES')+':';
    alZoom.Caption := lpGet('PRINT_ZOOM')+':';
    lCaption.Caption := lpGet('PRINT_CAPTION')+':';
    rgPages.Caption := lpGet('PRINT_PAGES');
    rgPages.Items.Text := lpGet('PRINT_PAGES_BUTTONS');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmRemoveMatte
  with frmRemoveMatte do
  begin
    Caption := lpGet('MI_FLT_REMOVE_MATTE');
    lMatteColor.Caption := lpGet('LABEL_MATTE_COLOR')+':';
    bWhiteMatte.Caption := lpGet('LABEL_WHITE_MATTE');
    bBlackMatte.Caption := lpGet('LABEL_BLACK_MATTE');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmResProp
  with frmResProp do
  begin
    Caption := lpGet('MI_LIB_PROP');
    lName.Caption := lpGet('RP_NAME')+':';
    lLanguage.Caption := lpGet('RP_LANGUAGE')+':';
    cbLanguage.Items[0] := '('+lpGet('RP_LANG_CUSTOM')+')';
    cbLanguage.Items[1] := '('+lpGet('RP_LANG_NEUTRAL')+')';
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmRGBChannels
  with frmRGBChannels do
  begin
    Caption := lpGet('MI_FLT_RGB');
    lRed.Caption := lpGet('LABEL_RED')+':';
    lGreen.Caption := lpGet('LABEL_GREEN')+':';
    lBlue.Caption := lpGet('LABEL_BLUE')+':';
    bReset.Caption := lpGet('B_RESET');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmSaveOptions
  with frmSaveOptions do
  begin
    alQuality.Caption := lpGet('SO_QUALITY')+':';
    cbLossless.Caption := lpGet('SO_LOSSLESS');
    bPreview.Caption := lpGet('B_PREVIEW');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmShadow
  with frmShadow do
  begin
    Caption := lpGet('MI_FLT_DROP_SHADOW');
    alDistance.Caption := lpGet('LABEL_DISTANCE')+':';
    alAngle.Caption := lpGet('LABEL_ANGLE_DEGREES')+':';
    alBlur.Caption := lpGet('LABEL_BLUR')+':';
    lColor.Caption := lpGet('LABEL_COLOR')+':';
    alIntensity.Caption := lpGet('LABEL_INTENSITY')+':';
    cbToric.Caption := lpGet('LABEL_TORIC');
    cbPreview.Caption := lpGet('B_PREVIEW');
    bReset.Caption := lpGet('B_RESET');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // StartupFrame
  with TStartupScreenTab(frmMain.GetTabByClass(TStartupScreenTab)) do
  begin
    Caption := lpGet('MI_VIEW_STARTUP_SCREEN');
    Frame.lTitle.Caption := lpGet('ST_WELCOME');
    Frame.lSubtitle.Caption := lpGet('ST_CHOOSE_ACTION')+':';
    Frame.imHelp.Hint := lpGet('HINT_STARTUP_HELP');
    Frame.bRecentFiles.Caption := lpGet('MI_FILE_RECENT_FILES');
    Frame.bRecentFiles.Hint := lpGet('ST_RECENT_INFO');
    Frame.cbShow.Caption := lpGet('ST_SHOW');
  end;

  // frmTest
  with frmTest do
  begin
    Caption := lpGet('MI_ICON_TEST');
    gb.Caption := lpGet('LABEL_MOVE_OVER_IMAGE');
    sbClear.Hint := lpGet('B_CLEAR');
    sbBgrLoad.Hint := lpGet('HINT_TEST_BGR_LOAD')+'...';
    sbBgrDefault.Hint := lpGet('HINT_TEST_BGR_DEFAULT');
    bClose.Caption := lpGet('B_CLOSE');
  end;

  // frmText
  with frmText do
  begin
    Caption := lpGet('CAPTION_INSERT_TEXT');
    alSize.Caption := lpGet('LABEL_SIZE')+':';
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');

    cbFace.Hint := lpGet('HINT_TEXT_FACE');
    sbBold.Hint := lpGet('HINT_TEXT_BOLD');
    sbItalic.Hint := lpGet('HINT_TEXT_ITALIC');
    sbUnderline.Hint := lpGet('HINT_TEXT_UNDERLINE');
  end;

  // frmToolbar
  with frmMain.frmToolbar do
  begin
    Caption := lpGet('MI_VIEW_TOOLBAR');
    for dt in TDrawTool do if dt <> dtNone then
      sb[dt].Hint := Format('%s (%s)', [ToolName[dt],
        ToolShortcut[Ord(dt) + 1]]);
  end;

  // frmToolSet
  with frmMain.frmToolSet do
  begin
    Caption := lpGet('MI_VIEW_TOOL_BEHAVIOR');

    sbAntiAlias.Hint := lpGet('LABEL_ANTIALIAS');
    cbPattern.Hint := lpGet('TB_PATTERN');

    aiBrushSize.Hint := lpGet('TB_BRUSH_SIZE');
    neBrushSize.Hint := lpGet('TB_BRUSH_SIZE');
    cbBrushShape.Hint := lpGet('TB_BRUSH_SHAPE');

    aiLineWidth.Hint := lpGet('TB_LINE_WIDTH');
    neLineWidth.Hint := lpGet('TB_LINE_WIDTH');

    aiTolerance.Hint := lpGet('TB_TOLERANCE');
    neTolerance.Hint := lpGet('TB_TOLERANCE');

    sbContiguous.Hint := lpGet('TB_CONTIGUOUS');
    sbSampleAllLayers.Hint := lpGet('TB_SAMPLE_ALL_LAYERS');

    sbFramed.Hint := lpGet('TB_SHAPE_FRAMED');
    sbFilled.Hint := lpGet('TB_SHAPE_FILLED');

    sbEyedropperBack.Hint := lpGet('TB_EYEDROPPER_BACK');

    SetComboItems(cbRetouchMode, lpGet('TB_RETOUCH_ITEMS'));
    cbRetouchMode.Hint := lpGet('TB_RETOUCH_MODE');

    aiEraserAlpha.Hint := lpGet('TB_ERASER_STRENGTH');
    neEraserAlpha.Hint := lpGet('TB_ERASER_STRENGTH');

    sbLinear.Hint := lpGet('TB_G_LINEAR');
    sbRadial.Hint := lpGet('TB_G_RADIAL');
    sbConical.Hint := lpGet('TB_G_CONICAL');
    sbSpiral.Hint := lpGet('TB_G_SPIRAL');
    sbRepNone.Hint := lpGet('TB_REP_NONE');
    sbRepSym.Hint := lpGet('TB_REP_SYM');
    sbRepAsym.Hint := lpGet('TB_REP_ASYM');
    sbColor.Hint := lpGet('TB_MODE_COLOR');
    sbTransparency.Hint := lpGet('TB_MODE_TRANSPARENCY');
  end;

  // frmTransform
  with frmTransform do
  begin
    Caption := lpGet('MI_EDIT_SEL_TRANSFORM');
    gbPosition.Caption := lpGet('LABEL_POSITION');
    gbSize.Caption := lpGet('LABEL_SIZE');
    alWidth.Caption := lpGet('LABEL_WIDTH')+':';
    alHeight.Caption := lpGet('LABEL_HEIGHT')+':';
    SetComboItems(cbUnits, lpGet('XF_UNITS_ITEMS'));
    alAngle.Caption := lpGet('LABEL_ANGLE_DEGREES')+':';
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;

  // frmUnsharpMask
  with frmUnsharpMask do
  begin
    Caption := lpGet('MI_FLT_UNSHARP_MASK');
    alAmount.Caption := lpGet('LABEL_AMOUNT')+':';
    alRadius.Caption := lpGet('LABEL_RADIUS')+':';
    alThreshold.Caption := lpGet('LABEL_THRESHOLD')+':';
    cbToric.Caption := lpGet('LABEL_TORIC');
    cbPreview.Caption := lpGet('B_PREVIEW');
    bReset.Caption := lpGet('B_RESET');
    bOK.Caption := lpGet('B_OK');
    bCancel.Caption := lpGet('B_CANCEL');
  end;
end;

function QueryOverwrite;
begin
  Result := (MessageDlg(Format(lpGet('MSG_OVERWRITE'),
    [SysToUTF8(FileName)]), mtConfirmation, [mbYes, mbNo], 0) = mrYes);
end;

function QuerySaveChanges;
begin
  Result := MessageDlg(Format(lpGet('MSG_SAVE_CHANGES'),
    [SysToUTF8(FileName)]), mtConfirmation, [mbYes, mbNo, mbCancel], 0);
end;

end.
