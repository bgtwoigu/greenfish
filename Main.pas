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
unit Main;

interface

uses
  LclIntf, LclType, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  FileUtil, Dialogs, Menus, ExtCtrls, ComCtrls, StdCtrls, DocClass, ieShared,
  dlgDoc, dlgLib, ImageTransform, ShellEx, Math, LangPack, Layers, UndoObject,
  dlgToolbar, dlgLayers, dlgColor, dlgToolSet, DoubleBufPB, Accordion, bmExUtils,
  NumberEdit, dlgDebug, dlgCreateMacIcon, IniFiles, ResList;

const
  nRecentFiles = 16;

type
  TmiContents = record
    mi: TMenuItem;
    Language, FileName: string;
  end;

  TTabSheetClass = class of TTabSheet;

  { TfrmMain }

  TfrmMain = class(TForm)
    accLayers: TAccordion;
    accColorPicker: TAccordion;
    Bevel1: TBevel;
    Bevel2: TBevel;
    frmColor: TColorFrame;
    frmLayers: TLayersFrame;
    miSaveACopy: TMenuItem;
    miPanelRight: TMenuItem;
    miPanelLeft: TMenuItem;
    N28: TMenuItem;
    miPageExportAll: TMenuItem;
    pc: TPageControl;
    pbStatusBar: TDoubleBufPB;
    frmToolbar: TToolbarFrame;
    mm: TMainMenu;
    miFile: TMenuItem;
    miNewGraphic: TMenuItem;
    miExit: TMenuItem;
    miIcon: TMenuItem;
    miPageNew: TMenuItem;
    miPageDelete: TMenuItem;
    miPageProp: TMenuItem;
    miEdit: TMenuItem;
    miUndo: TMenuItem;
    miRedo: TMenuItem;
    N3: TMenuItem;
    miCut: TMenuItem;
    miCopy: TMenuItem;
    miPaste: TMenuItem;
    miDelete: TMenuItem;
    N4: TMenuItem;
    miSelectAll: TMenuItem;
    miDeselectAll: TMenuItem;
    miInvertSelection: TMenuItem;
    miOpen: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    miPrint: TMenuItem;
    N5: TMenuItem;
    miCreateWinIcon: TMenuItem;
    miCreateMacIcon: TMenuItem;
    N6: TMenuItem;
    N2: TMenuItem;
    miTest: TMenuItem;
    miSaveSelection: TMenuItem;
    miLoadSelection: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    miRecentFiles: TMenuItem;
    miClose: TMenuItem;
    N10: TMenuItem;
    miFilters: TMenuItem;
    miGrayscale: TMenuItem;
    miInvert: TMenuItem;
    miRGBChannels: TMenuItem;
    miHueSaturation: TMenuItem;
    miExposure: TMenuItem;
    miAverage: TMenuItem;
    miSoftBlur: TMenuItem;
    miBlurMore: TMenuItem;
    miCustomBlur: TMenuItem;
    miPaintContour: TMenuItem;
    miDropShadow: TMenuItem;
    N12: TMenuItem;
    pLeft: TPanel;
    pRight: TPanel;
    N11: TMenuItem;
    miRemoveMatte: TMenuItem;
    N13: TMenuItem;
    miView: TMenuItem;
    miZoomIn: TMenuItem;
    miZoomOut: TMenuItem;
    mi100Percent: TMenuItem;
    miFitWindow: TMenuItem;
    N14: TMenuItem;
    miGrid: TMenuItem;
    N15: TMenuItem;
    miHelp: TMenuItem;
    miAbout: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    miXformSel: TMenuItem;
    miSolarize: TMenuItem;
    miPasteAsPage: TMenuItem;
    miOpacity: TMenuItem;
    od: TOpenDialog;
    sdGraphic: TSaveDialog;
    miClearList: TMenuItem;
    N19: TMenuItem;
    miRevert: TMenuItem;
    N9: TMenuItem;
    N16: TMenuItem;
    miHomepage: TMenuItem;
    miUnsharpMask: TMenuItem;
    miSharpen: TMenuItem;
    N20: TMenuItem;
    miGlow: TMenuItem;
    miCloseAll: TMenuItem;
    miBevel: TMenuItem;
    miSaveAll: TMenuItem;
    miTransform: TMenuItem;
    N21: TMenuItem;
    miFlipHoriz: TMenuItem;
    miFlipVert: TMenuItem;
    miRotate90Left: TMenuItem;
    miRotate90Right: TMenuItem;
    miRotate180: TMenuItem;
    miStartupScreen: TMenuItem;
    miDonate: TMenuItem;
    miCenterLines: TMenuItem;
    miBatchConvert: TMenuItem;
    miUniformRate: TMenuItem;
    miCropTransparency: TMenuItem;
    miPageImport: TMenuItem;
    miPageExport: TMenuItem;
    miMetadata: TMenuItem;
    N22: TMenuItem;
    sdLibrary: TSaveDialog;
    miNewLibrary: TMenuItem;
    miLibrary: TMenuItem;
    miResAdd: TMenuItem;
    miResRemove: TMenuItem;
    miResReplace: TMenuItem;
    miResProp: TMenuItem;
    miExtractEdit: TMenuItem;
    miExtractSave: TMenuItem;
    N23: TMenuItem;
    N24: TMenuItem;
    N25: TMenuItem;
    miViewPages: TMenuItem;
    miFormulae: TMenuItem;
    miLayers: TMenuItem;
    miLayerNew: TMenuItem;
    miLayerDupl: TMenuItem;
    miLayerDelete: TMenuItem;
    miLayerProp: TMenuItem;
    N26: TMenuItem;
    miMergeSelected: TMenuItem;
    miMergeVisible: TMenuItem;
    miFlattenImage: TMenuItem;
    N27: TMenuItem;
    miLayerFromSel: TMenuItem;
    miCellGrid: TMenuItem;
    miSettings: TMenuItem;
    miPreferences: TMenuItem;
    miLanguage: TMenuItem;
    miSupport: TMenuItem;
    miPasteAsDoc: TMenuItem;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of string);
    procedure FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure miNewGraphicClick(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure miEditClick(Sender: TObject);
    procedure miPageExportAllClick(Sender: TObject);
    procedure miPanelLeftClick(Sender: TObject);
    procedure miPanelRightClick(Sender: TObject);
    procedure miSaveACopyClick(Sender: TObject);
    procedure miUndoRedoClick(Sender: TObject);
    procedure miPageNewClick(Sender: TObject);
    procedure miPageDeleteClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure miViewClick(Sender: TObject);
    procedure miFitWindowClick(Sender: TObject);
    procedure miGridClick(Sender: TObject);
    procedure miSelectAllClick(Sender: TObject);
    procedure miDeselectAllClick(Sender: TObject);
    procedure miInvertSelectionClick(Sender: TObject);
    procedure miCutClick(Sender: TObject);
    procedure miCopyClick(Sender: TObject);
    procedure miPasteClick(Sender: TObject);
    procedure miDeleteClick(Sender: TObject);
    procedure miLoadSelectionClick(Sender: TObject);
    procedure miSaveSelectionClick(Sender: TObject);
    procedure miXformSelClick(Sender: TObject);
    procedure miIconClick(Sender: TObject);
    procedure miPasteAsPageClick(Sender: TObject);
    procedure miFlipRotateClick(Sender: TObject);
    procedure miGrayscaleClick(Sender: TObject);
    procedure miInvertClick(Sender: TObject);
    procedure miSolarizeClick(Sender: TObject);
    procedure miRGBChannelsClick(Sender: TObject);
    procedure miHueSaturationClick(Sender: TObject);
    procedure miExposureClick(Sender: TObject);
    procedure miAverageClick(Sender: TObject);
    procedure miFiltersClick(Sender: TObject);
    procedure miBlurMoreClick(Sender: TObject);
    procedure miCustomBlurClick(Sender: TObject);
    procedure miSoftBlurClick(Sender: TObject);
    procedure miRemoveMatteClick(Sender: TObject);
    procedure miPaintContourClick(Sender: TObject);
    procedure miDropShadowClick(Sender: TObject);
    procedure miOpacityClick(Sender: TObject);
    procedure miPagePropClick(Sender: TObject);
    procedure miCreateWinIconClick(Sender: TObject);
    procedure miCreateMacIconClick(Sender: TObject);
    procedure miTestClick(Sender: TObject);
    procedure miZoomInClick(Sender: TObject);
    procedure miZoomOutClick(Sender: TObject);
    procedure mi100PercentClick(Sender: TObject);
    procedure miFileClick(Sender: TObject);
    procedure miOpenClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure miCloseClick(Sender: TObject);
    procedure miSaveAsClick(Sender: TObject);
    procedure miClearListClick(Sender: TObject);
    procedure miPrintClick(Sender: TObject);
    procedure miRevertClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure miContentsClick(Sender: TObject);
    procedure miHomepageClick(Sender: TObject);
    procedure miUnsharpMaskClick(Sender: TObject);
    procedure miSharpenClick(Sender: TObject);
    procedure miPreferencesClick(Sender: TObject);
    procedure miGlowClick(Sender: TObject);
    procedure miCloseAllClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure miBevelClick(Sender: TObject);
    procedure miSaveAllClick(Sender: TObject);
    procedure DialogFolderChange(Sender: TObject);
    procedure miStartupScreenClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure miDonateClick(Sender: TObject);
    procedure miCenterLinesClick(Sender: TObject);
    procedure miBatchConvertClick(Sender: TObject);
    procedure miLanguageClick(Sender: TObject);
    procedure miUniformRateClick(Sender: TObject);
    procedure miCropTransparencyClick(Sender: TObject);
    procedure miPageImportClick(Sender: TObject);
    procedure miPageExportClick(Sender: TObject);
    procedure miMetadataClick(Sender: TObject);
    procedure pbStatusBarPaint(Sender: TObject);
    procedure pcMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure pcMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure pcPageChanged(Sender: TObject);
    procedure pLeftMouseEnter(Sender: TObject);
    procedure sdGraphicCanClose(Sender: TObject; var CanClose: boolean);
    procedure sdLibraryCanClose(Sender: TObject; var CanClose: boolean);
    procedure miNewLibraryClick(Sender: TObject);
    procedure miLibraryClick(Sender: TObject);
    procedure miResAddClick(Sender: TObject);
    procedure miResRemoveClick(Sender: TObject);
    procedure miResReplaceClick(Sender: TObject);
    procedure miResPropClick(Sender: TObject);
    procedure miExtractEditClick(Sender: TObject);
    procedure miExtractSaveClick(Sender: TObject);
    procedure miViewPagesClick(Sender: TObject);
    procedure miFormulaeClick(Sender: TObject);
    procedure miLayersClick(Sender: TObject);
    procedure miLayerPropClick(Sender: TObject);
    procedure miLayerNewClick(Sender: TObject);
    procedure miLayerDuplClick(Sender: TObject);
    procedure miLayerDeleteClick(Sender: TObject);
    procedure miMergeLayersClick(Sender: TObject);
    procedure miLayerFromSelClick(Sender: TObject);
    procedure miCellGridClick(Sender: TObject);
    procedure miSupportClick(Sender: TObject);
    procedure miPasteAsDocClick(Sender: TObject);
  private
    function GetTabVisible(TabClass: TTabSheetClass): boolean;
    procedure SetTabVisible(TabClass: TTabSheetClass; Value: boolean);
  public
    StatusBarText: string;
    rf: array[0..nRecentFiles - 1] of string;
    miRecentFile: array[0..nRecentFiles - 1] of TMenuItem;
    // Installed Help languages
    miContents: array of TmiContents;

    // Number of open documents and other tabs in total
    // pc.PageCount does not refresh often enough, so we need to count
    // the tabs ourselves
    NumberOfTabs: integer;

    // We create this component at runtime
    // (Frames in Lazarus designer do not always reflect changes)
    frmToolSet: TToolSetFrame;

    procedure SetStatus(Value: string);

    function frmDocActive: TDocumentFrame;
    function frmGraphicActive: TGraphicFrame;
    function frmLibraryActive: TLibraryFrame;

    function AddTab(tab: TTabSheet; ShowTab: boolean): TTabSheet;
    function NewDocument(c: TDocumentFrameClass): TDocumentFrame;
    function DoCloseTab(const ts: TTabSheet): boolean;
    function DoCloseAll: boolean;
    // Useful for e.g. getting the startup screen
    function GetTabByClass(TabClass: TTabSheetClass): TTabSheet;

    function DoOpen(const fn: string): TDocumentFrame;
    function sdGraphicExec(var fn: string; var ft: TImageFileType): boolean;
    function sdLibraryExec(var fn: string; var ft: TResFileType): boolean;
    procedure DoSave;
    function DoSaveGraphicAs(frm: TGraphicFrame; SaveACopy: boolean): boolean;
    function DoSaveLibraryAs(frm: TLibraryFrame; SaveACopy: boolean): boolean;
    procedure PasteAsNewDocument;

    // Recent files
    procedure rfUpdateMenu;
    procedure rfLoad;
    procedure rfSave;
    procedure rfAdd(const _FileName: string);
    procedure rfClear;

    procedure miRecentFileClick(Sender: TObject);

    property TabVisible[TabClass: TTabSheetClass]: boolean
      read GetTabVisible write SetTabVisible;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  dlgDocPage, dlgTransform,
  dlgBlur, dlgExposure, dlgRGBChannels, dlgHueSaturation,
  dlgShadow, dlgMatte, dlgOpacity, dlgCreateIcon, dlgTest, dlgPrint,
  dlgUnsharpMask, dlgPreferences, dlgGlow, dlgBevel, dlgStartupFrame,
  dlgBatchConvert, dlgLanguage, dlgMetadata, dlgFormulae,
  dlgCellGrid;

{$R *.lfm}

procedure TfrmMain.SetStatus(Value: string);
var
  ls: TLayers;

begin
  // Add a warning, if needed
  if (Value <> '') and (frmGraphicActive <> nil) then
  begin
    ls := frmGraphicActive.Doc.Pages[frmGraphicActive.ImageIndex].Layers;
    if ls.LayerCount = 0 then
      Value += ' [' + lpGet('MSG_NO_LAYERS') + '!]'
    else
    if ls.SelectedCount = 0 then
      Value += ' [' + lpGet('MSG_NO_LAYERS_SELECTED') + '!]';
  end;

  if StatusBarText <> Value then
  begin
    StatusBarText := Value;
    pbStatusBar.Repaint;
  end;
end;

function TfrmMain.frmDocActive: TDocumentFrame;
var
  ts: TTabSheet;

begin
  ts := pc.ActivePage;
  if not (ts is TDocumentTab) then
    Exit(nil);
  Exit(TDocumentTab(ts).Frame);
end;

function TfrmMain.frmGraphicActive: TGraphicFrame;
var
  frm: TDocumentFrame;

begin
  frm := frmDocActive;
  if not (frm is TGraphicFrame) then
    Result := nil
  else
    Result := TGraphicFrame(frm);
end;

function TfrmMain.frmLibraryActive: TLibraryFrame;
var
  frm: TDocumentFrame;

begin
  frm := frmDocActive;
  if not (frm is TLibraryFrame) then
    Result := nil
  else
    Result := TLibraryFrame(frm);
end;

function TfrmMain.AddTab(tab: TTabSheet; ShowTab: boolean): TTabSheet;
begin
  tab.PageControl := pc;
  tab.TabVisible := ShowTab;
  if ShowTab then
  begin
    Inc(NumberOfTabs);
    pc.Visible := True;
    pc.ActivePage := tab;
  end;
  Result := tab;
end;

function TfrmMain.NewDocument(c: TDocumentFrameClass): TDocumentFrame;
var
  tab: TDocumentTab;

begin
  tab := TDocumentTab(AddTab(TDocumentTab.CreateTab(Self, c), True));
  Result := tab.Frame;
end;

function TfrmMain.DoCloseTab(const ts: TTabSheet): boolean;
begin
  if (ts = nil) or (ts.TabVisible = False) then
    Exit(True);
  if (ts is TDocumentTab) and (TDocumentTab(ts).Frame <> nil) then
    Result := TDocumentTab(ts).Frame.DocFrameCanClose
  else
    Result := True;

  // close
  if Result then
  begin
    // free the tab sheet for good, if it contained a document
    if ts is TDocumentTab then
      Application.ReleaseComponent(ts)
    else
      ts.TabVisible := False;

    Dec(NumberOfTabs);
    pc.Visible := NumberOfTabs <> 0;
  end;
end;

function TfrmMain.DoCloseAll: boolean;
var
  i: integer;
  ts: array of TTabSheet;

begin
  Result := True;
  SetLength(ts, pc.PageCount);
  for i := 0 to Length(ts) - 1 do
    ts[i] := pc.Pages[i];
  for i := 0 to Length(ts) - 1 do
    if not DoCloseTab(ts[i]) then
    begin
      Result := False;
      Break;
    end;
end;

function TfrmMain.GetTabByClass(TabClass: TTabSheetClass): TTabSheet;
var
  i: integer;

begin
  for i := 0 to pc.PageCount - 1 do
    if pc.Pages[i] is TabClass then
      Exit(pc.Pages[i]);
  Result := nil;
end;

function TfrmMain.DoOpen(const fn: string): TDocumentFrame;
var
  LoadOK: boolean;
  s: TStream;
  ift: TImageFileType;
  rft: TResFileType;
  Ext: string;

begin
  Result := nil;

  if not FileExists(fn) then
  begin
    ShowMessage(Format(lpGet('MSG_NOT_EXIST'), [SysToUTF8(fn)]));
    Exit;
  end;

  ift := iftNone;
  rft := rftNone;
  try
    s := TFileStream.Create(fn, fmOpenRead);
    try
      ift := DetectImageFileType(s);
      rft := DetectResFileType(s);
    finally
      s.Free;
    end;
  except
  end;

  if (ift = iftNone) and (rft = rftNone) then
  begin
    ShowMessage(Format(lpGet('MSG_UNKNOWN_FILE_TYPE'), [SysToUTF8(fn)]));
    Exit;
  end;

  // Graphic file?
  if ift <> iftNone then
  begin
    Result := NewDocument(TGraphicFrame);
    with TGraphicFrame(Result) do
    begin
      FileName := fn;
      LoadOK := DoLoad;
    end;
  end else
  // Library file
  begin
    Result := NewDocument(TLibraryFrame);
    with TLibraryFrame(Result) do
    begin
      FileName := fn;
      LoadOK := DoLoad;
    end;
  end;

  if not LoadOK then
    // cannot load file
  begin
    if ift <> iftNone then Ext := iftDefaultExt[ift] else Ext := rftDefaultExt[rft];
    ShowMessage(Format(lpGet('MSG_INVALID_FILE_FORMAT'),
      [SysToUTF8(fn), Ext]));
    DoCloseTab(Result.Tab);
    Result := nil;
  end
  else
    // file was successfully loaded
    rfAdd(fn);
end;

function TfrmMain.sdGraphicExec(var fn: string; var ft: TImageFileType): boolean;
begin
  // Filter: set according to FileType
  // File name: if extension meets format, then it is omitted
  if (ft <> iftNone) and (UpperCase(ChangeFileExt(fn, iftDefaultExt[ft])) =
    UpperCase(fn)) then
    fn := ChangeFileExt(fn, '');

  sdGraphic.FileName := SysToUTF8(fn);
  sdGraphic.FilterIndex := 1 + Ord(ft);

  Result := sdExecuteWithCanClose(sdGraphic);
  if Result then
  begin
    // File type: detected from file name, then from selected filter
    // File name: default extension is appended, if none was specified
    fn := UTF8ToSys(sdGraphic.FileName);
    ft := DetectImageFileTypeFromName(fn);

    if ft = iftNone then
    begin
      ft := TImageFileType(sdGraphic.FilterIndex - 1);
      fn := SetDefaultExt(fn, iftDefaultExt[ft]);
    end;
  end;
end;

function TfrmMain.sdLibraryExec(var fn: string; var ft: TResFileType): boolean;
begin
  // Filter: set according to FileType
  // File name: if extension meets format, then it is omitted
  if (ft <> rftNone) and (UpperCase(ChangeFileExt(fn, rftDefaultExt[ft])) =
    UpperCase(fn)) then
    fn := ChangeFileExt(fn, '');

  sdLibrary.FileName := SysToUTF8(fn);
  sdLibrary.FilterIndex := 1 + Ord(ft);

  Result := sdExecuteWithCanClose(sdLibrary);
  if Result then
  begin
    // File type: detected from file name, then from selected filter
    // File name: default extension is appended, if none was specified
    fn := UTF8ToSys(sdLibrary.FileName);
    ft := DetectResFileTypeFromName(fn);

    if ft = rftNone then
    begin
      ft := TResFileType(sdLibrary.FilterIndex - 1);
      fn := SetDefaultExt(fn, rftDefaultExt[ft]);
    end;
  end;
end;

procedure TfrmMain.DoSave;
var
  frm: TDocumentFrame;

begin
  frm := frmDocActive;

  if frm is TGraphicFrame then
    with TGraphicFrame(frm) do
    begin
      if FileName = '' then
        DoSaveGraphicAs(TGraphicFrame(frm), False)
      else
        DoSave(FileName, FileType, []);
    end
  else
  if frm is TLibraryFrame then
    with TLibraryFrame(frm) do
    begin
      if FileName = '' then
        DoSaveLibraryAs(TLibraryFrame(frm), False)
      else
        DoSave(FileName, FileType, []);
    end;
end;

function TfrmMain.DoSaveGraphicAs(frm: TGraphicFrame; SaveACopy: boolean): boolean;
var
  fn: string;
  ft: TImageFileType;
  dso: TDocumentSaveOptions;

begin
  Result := False;

  if frm = nil then
    Exit;

  fn := frm.FileName;
  ft := frm.FileType;
  if not sdGraphicExec(fn, ft) then
    Exit;

  if ft = iftNone then
    ShowMessage(Format(lpGet('MSG_UNKNOWN_FILE_TYPE'), [SysToUTF8(fn)]))
  else
  begin
    if SaveACopy then dso := [dsoSaveACopy] else dso := [];
    if not frm.DoSave(fn, ft, dso) then
      Exit;

    // success
    Result := True;
    if not SaveACopy then rfAdd(frm.FileName);
  end; // known format
end;

function TfrmMain.DoSaveLibraryAs(frm: TLibraryFrame; SaveACopy: boolean): boolean;
var
  fn: string;
  ft: TResFileType;
  dso: TDocumentSaveOptions;

begin
  Result := False;

  if frm = nil then
    Exit;

  fn := frm.FileName;
  ft := frm.FileType;
  if not sdLibraryExec(fn, ft) then
    Exit;

  if ft = rftNone then
    ShowMessage(Format(lpGet('MSG_UNKNOWN_FILE_TYPE'), [SysToUTF8(fn)]))
  else
  begin
    if SaveACopy then dso := [dsoSaveACopy] else dso := [];
    if not frm.DoSave(fn, ft, dso) then
      Exit;

    // success
    Result := True;
    if not SaveACopy then rfAdd(frm.FileName);
  end; // known format
end;

procedure TfrmMain.PasteAsNewDocument;
var
  f: TGraphicFrame;

begin
  if not IconEditorCanPaste then
    Exit;
  f := TGraphicFrame(NewDocument(TGraphicFrame));
  f.DoEditPaste(True);
  f.pgDelete(0);
end;

procedure TfrmMain.rfUpdateMenu;
var
  i: integer;

begin
  // Update menu items
  for i := 0 to nRecentFiles - 1 do
    with miRecentFile[i] do
    begin
      Visible := rf[i] <> '';
      if Visible then
        Caption := Format('%d %s', [i + 1, SysToUTF8(rf[i])]);
    end;
end;

procedure TfrmMain.rfLoad;
var
  i: integer;
  ini: TIniFile;

begin
  if not FileExists(Config_RecentFiles) then
    rfClear
  else
  begin
    ini := TIniFile.Create(Config_RecentFiles);
    try
      for i := 0 to nRecentFiles - 1 do
        rf[i] := ini.ReadString('File'+IntToStr(i), 'Name', '');
    finally
      ini.Free;
    end;

    // invalidate
    rfUpdateMenu;
  end;
end;

procedure TfrmMain.rfSave;
var
  i: integer;
  ini: TIniFile;

begin
  ini := TIniFile.Create(Config_RecentFiles);
  try
    for i := 0 to nRecentFiles - 1 do
      ini.WriteString('File'+IntToStr(i), 'Name', rf[i]);
  finally
    ini.Free;
  end;
end;

procedure TfrmMain.rfAdd(const _FileName: string);
var
  i, m: integer;

begin
  // if the file already exists, move it to the top
  m := nRecentFiles - 1;
  for i := 0 to nRecentFiles - 1 do
    if rf[i] = _FileName then
    begin
      m := i;
      Break;
    end;

  // shift files
  // we cannot use Move! (because of managed strings)
  for i := m downto 1 do
    rf[i] := rf[i - 1];

  // insert record
  rf[0]  := _FileName;

  // invalidate
  rfUpdateMenu;
end;

procedure TfrmMain.rfClear;
var
  i: integer;

begin
  // clear all records
  for i := 0 to nRecentFiles - 1 do
    rf[i] := '';

  // invalidate
  rfUpdateMenu;
end;

procedure TfrmMain.miRecentFileClick(Sender: TObject);
begin
  DoOpen(rf[(Sender as TMenuItem).Tag]);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
const
  Padding = 2;

var
  i, j: integer;
  sr: TSearchRecs;
  fn: string;

begin
{$IFDEF CPU32}
  Caption := Caption + ' 32-bit';
{$ENDIF}
{$IFDEF CPU64}
  Caption := Caption + ' 64-bit';
{$ENDIF}

  // create some components
  frmToolSet := TToolSetFrame.Create(Self);
  frmToolSet.Parent := pLeft;
  frmToolSet.Align := alClient;

  SetBounds(Padding, Padding, Screen.Width - Padding * 2, Screen.Height -
    50 - Padding * 2);
  WindowState := wsMaximized;
  frmColor.pc.ActivePage := frmColor.tsHSBMap;

  // create recent file menu items
  for i := nRecentFiles - 1 downto 0 do
  begin
    miRecentFile[i] := TMenuItem.Create(Self);

    with miRecentFile[i] do
    begin
      Tag := i;
      OnClick := miRecentFileClick;
    end;

    miRecentFiles.Insert(0, miRecentFile[i]);
  end;

  // create Help Contents menu items
  FindAll(HelpDir + '*.*', faDirectory, sr);
  for i := 0 to Length(sr) - 1 do
  begin
    if (sr[i].Name = '.') or (sr[i].Name = '..') then
      Continue;
    fn := HelpDir + sr[i].Name + '\index.html';
    if not FileExists(fn) then
      Continue;

    j := Length(miContents);
    SetLength(miContents, j + 1);
    with miContents[j] do
    begin
      Language := sr[i].Name;
      FileName := fn;

      mi := TMenuItem.Create(Self);
      mi.Tag := j;
      if UpperCase(Language) = 'ENGLISH' then
        mi.ShortCut := VK_F1;
      mi.OnClick := miContentsClick;

      miHelp.Insert(0, mi);
    end;
  end;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  CanClose := DoCloseAll;
end;

procedure TfrmMain.FormDropFiles(Sender: TObject; const FileNames: array of string);
var
  i: integer;
begin
  for i := 0 to Length(FileNames) - 1 do
    DoOpen(UTF8ToSys(FileNames[i]));
end;

procedure TfrmMain.FormKeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
var
  NoShift: boolean;
  gf: TGraphicFrame;
  dt: TDrawTool;

begin
  // let controls capture keys
  if ActiveControl is TCustomEdit then
    Exit;

  NoShift := (Shift * [ssAlt, ssCtrl, ssShift] = []);
  gf := frmGraphicActive;

  // not drawing?
  if (gf = nil) or (gf.ma = iemaNone) then
  begin
    if NoShift then
    begin
      if Key < 256 then
      begin
        // tool shortcut?
        dt := KeyToDrawTool(char(Key));
        if dt <> dtNone then frmToolbar.DrawTool := dt;
      end; // simple char

      if gf <> nil then
        case Key of
          Ord('1')..Ord('9'): gf.Zoom := Key - Ord('0');
          Ord('0'): gf.Zoom := 10;
          VK_ADD: gf.sbZoomInClick(nil);
          VK_SUBTRACT: gf.sbZoomOutClick(nil);
          VK_MULTIPLY: gf.Zoom := 1;
          VK_DIVIDE: gf.zoomFitWindow;
          VK_ESCAPE: gf.DoDeselectAll;
        end; // if gf <> nil
    end; // if NoShift
  end; // not drawing

  // update cursor
  if gf <> nil then gf.pbUpdateCursor;
end;

procedure TfrmMain.FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
var
  gf: TGraphicFrame;

begin
  gf := frmGraphicActive;
  if gf <> nil then
    gf.pbUpdateCursor;
end;

procedure TfrmMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
begin
  SetStatus('');
end;

procedure TfrmMain.miNewGraphicClick(Sender: TObject);
var
  st: TdpSettings;
  frm: TGraphicFrame;

begin
  st.Caption := lpGet('MI_FILE_NEW_GRAPHIC');
  st.showColors := False;
  st.showCreateFrom := False;
  st.showWhenResizing := False;
  st.Width := 48;
  st.Height := 48;
  st.FrameRate := 0;

  if frmDocPage.Execute(st) then
  begin
    frm := TGraphicFrame(NewDocument(TGraphicFrame));

    with frm.Doc.Pages[0] do
    begin
      Layers.Resize(st.Width, st.Height);
      FrameRate := st.FrameRate;
    end;

    frm.PageSizeChanged;
  end;
end;

procedure TfrmMain.FormDblClick(Sender: TObject);
begin
  TabVisible[TStartupScreenTab] := True;
end;

procedure TfrmMain.miEditClick(Sender: TObject);
var
  frm: TGraphicFrame;
  ls: TLayers;

begin
  frm := frmGraphicActive;
  if Assigned(frm) then
    ls := frm.Doc.Pages[frm.ImageIndex].Layers
  else
    ls := nil;

  miUndo.Enabled := Assigned(frm) and frm.CanUndo;
  if miUndo.Enabled then
    miUndo.Caption :=
      lpGet('MI_EDIT_UNDO') + ': ' + lpGet(TUndoObject(frm.UndoStack[0]).Caption)
  else
    miUndo.Caption := lpGet('MI_EDIT_CANT_UNDO');

  miRedo.Enabled := Assigned(frm) and frm.CanRedo;
  if miRedo.Enabled then
    miRedo.Caption :=
      lpGet('MI_EDIT_REDO') + ': ' + lpGet(TUndoObject(frm.RedoStack[0]).Caption)
  else
    miRedo.Caption := lpGet('MI_EDIT_CANT_REDO');

  miCut.Enabled := Assigned(frm) and (ls.SelState <> stNone);
  miCopy.Enabled := miCut.Enabled;
  miPaste.Enabled := IconEditorCanPaste;
  miPasteAsPage.Enabled := Assigned(frm) and IconEditorCanPaste;
  miPasteAsDoc.Enabled := IconEditorCanPaste;
  miDelete.Enabled := miCut.Enabled;

  miSelectAll.Enabled := Assigned(frm);
  miDeselectAll.Enabled := Assigned(frm) and (ls.SelState <> stNone);

  miInvertSelection.Enabled := Assigned(frm) and (ls.SelState = stSelecting);
  miLoadSelection.Enabled := Assigned(frm);
  miSaveSelection.Enabled := miInvertSelection.Enabled;

  miCropTransparency.Enabled := Assigned(frm);
  miTransform.Enabled := Assigned(frm);
  miXformSel.Enabled := Assigned(frm) and (ls.SelState <> stNone);
end;

procedure TfrmMain.miPageExportAllClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoPageExport(True);
end;

procedure TfrmMain.miPanelLeftClick(Sender: TObject);
begin
  pLeft.Visible := not pLeft.Visible;
end;

procedure TfrmMain.miPanelRightClick(Sender: TObject);
begin
  pRight.Visible := not pRight.Visible;
end;

procedure TfrmMain.miSaveACopyClick(Sender: TObject);
var
  frm: TDocumentFrame;

begin
  frm := frmDocActive;

  if frm is TGraphicFrame then
    DoSaveGraphicAs(TGraphicFrame(frm), True)
  else
  if frm is TLibraryFrame then
    DoSaveLibraryAs(TLibraryFrame(frm), True);
end;

procedure TfrmMain.miUndoRedoClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.PerformUndoRedo(boolean((Sender as TMenuItem).Tag));
end;

procedure TfrmMain.miPageNewClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoPageNew;
end;

procedure TfrmMain.miPageDeleteClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoPageDelete;
end;

procedure TfrmMain.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.miViewClick(Sender: TObject);
var
  frm: TGraphicFrame;

begin
  frm := frmGraphicActive;

  miZoomIn.Enabled := Assigned(frm);
  miZoomOut.Enabled := Assigned(frm);
  mi100percent.Enabled := Assigned(frm);
  miFitWindow.Enabled := Assigned(frm);
  miGrid.Enabled := Assigned(frm);
  miCellGrid.Enabled := Assigned(frm);
  miCenterLines.Enabled := Assigned(frm);
  miViewPages.Enabled := Assigned(frm);

  if Assigned(frm) then
  begin
    miFitWindow.Checked := frm.sbZoomFit.Down;
    miGrid.Checked := frm.sbGrid.Down;
    miCellGrid.Checked := frm.cg.Enabled;
    miCenterLines.Checked := frm.sbCenterLines.Down;
    miViewPages.Checked := frm.pPages.Visible;
  end;

  miPanelLeft.Checked := pLeft.Visible;
  miPanelRight.Checked := pRight.Visible;
  miStartupScreen.Checked := TabVisible[TStartupScreenTab];
end;

procedure TfrmMain.miViewPagesClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoTogglePages;
end;

procedure TfrmMain.miFitWindowClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    ToggleSpeedButton(frmGraphicActive.sbZoomFit);
end;

procedure TfrmMain.miGridClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    ToggleSpeedButton(frmGraphicActive.sbGrid);
end;

procedure TfrmMain.miSelectAllClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoSelectAll;
end;

procedure TfrmMain.miDeselectAllClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoDeselectAll;
end;

procedure TfrmMain.miInvertSelectionClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoInvertSelection;
end;

procedure TfrmMain.miCutClick(Sender: TObject);
begin
  miCopy.Click;
  miDelete.Click;
end;

procedure TfrmMain.miCopyClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoEditCopy;
end;

procedure TfrmMain.miPasteClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoEditPaste(False)
  else
    PasteAsNewDocument;
end;

procedure TfrmMain.miDeleteClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoEditDelete;
end;

procedure TfrmMain.miLoadSelectionClick(Sender: TObject);
begin
  if (frmGraphicActive <> nil) and od.Execute then
    frmGraphicActive.DoLoadSelection(UTF8ToSys(od.FileName));
end;

procedure TfrmMain.miSaveSelectionClick(Sender: TObject);
var
  frm: TGraphicFrame;
  fn: string;
  ft: TImageFileType;

begin
  frm := frmGraphicActive;
  if frm = nil then Exit;

  fn := '';
  ft := iftPng;
  if not sdGraphicExec(fn, ft) then
    Exit;

  if ft = iftNone then
    ShowMessage(Format(lpGet('MSG_UNKNOWN_FILE_TYPE'), [SysToUTF8(fn)]))
  else
    frm.DoSaveSelection(fn, ft);
end;

procedure TfrmMain.miXformSelClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmTransform.Execute(frmGraphicActive);
end;

procedure TfrmMain.miIconClick(Sender: TObject);
var
  frm: TGraphicFrame;

begin
  frm := frmGraphicActive;

  miPageNew.Enabled := Assigned(frm);
  miPageDelete.Enabled := Assigned(frm) and (frm.Doc.PageCount > 1);
  miPageProp.Enabled := Assigned(frm);
  miPageImport.Enabled := Assigned(frm);
  miPageExport.Enabled := Assigned(frm);
  miPageExportAll.Enabled := Assigned(frm);
  miUniformRate.Enabled := Assigned(frm) and (frm.Doc.PageCount > 1);
  miCreateWinIcon.Enabled := Assigned(frm);
  miCreateMacIcon.Enabled := Assigned(frm);
  miTest.Enabled := Assigned(frm);
end;

procedure TfrmMain.miPasteAsPageClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoEditPaste(True);
end;

procedure TfrmMain.miFlipRotateClick(Sender: TObject);
begin
  if (frmGraphicActive <> nil) then
    frmGraphicActive.DoFlipRotate(TSimpleFlipRotate((Sender as TComponent).Tag));
end;

procedure TfrmMain.miFormulaeClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmFormulae.Execute(frmGraphicActive);
end;

procedure TfrmMain.miGrayscaleClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    with frmGraphicActive do
      UseFilter(DoFilter_Grayscale, False, 'MI_FLT_GRAYSCALE');
end;

procedure TfrmMain.miInvertClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    with frmGraphicActive do
      UseFilter(DoFilter_Invert, False, 'MI_FLT_INVERT');
end;

procedure TfrmMain.miSolarizeClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    with frmGraphicActive do
      UseFilter(DoFilter_Solarize, False, 'MI_FLT_SOLARIZE');
end;

procedure TfrmMain.miRGBChannelsClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmRGBChannels.Execute(frmGraphicActive);
end;

procedure TfrmMain.miHueSaturationClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmHueSaturation.Execute(frmGraphicActive);
end;

procedure TfrmMain.miExposureClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmExposure.Execute(frmGraphicActive);
end;

procedure TfrmMain.miAverageClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    with frmGraphicActive do
      UseFilter(DoFilter_Average, False, 'MI_FLT_AVERAGE');
end;

procedure TfrmMain.miFiltersClick(Sender: TObject);
var
  b: boolean;

begin
  b := frmGraphicActive <> nil;

  miGrayscale.Enabled := b;
  miInvert.Enabled := b;
  miSolarize.Enabled := b;
  miRGBChannels.Enabled := b;
  miHueSaturation.Enabled := b;
  miExposure.Enabled := b;
  miFormulae.Enabled := b;

  miAverage.Enabled := b;
  miSoftBlur.Enabled := b;
  miBlurMore.Enabled := b;
  miCustomBlur.Enabled := b;

  miSharpen.Enabled := b;
  miUnsharpMask.Enabled := b;

  miRemoveMatte.Enabled := b;
  miOpacity.Enabled := b;

  miPaintContour.Enabled := b;
  miDropShadow.Enabled := b;
  miGlow.Enabled := b;
  miBevel.Enabled := b;
end;

procedure TfrmMain.miBlurMoreClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    with frmGraphicActive do
      UseFilter(DoFilter_BlurMore, True, 'MI_FLT_BLUR_MORE');
end;

procedure TfrmMain.miCustomBlurClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmBlur.Execute(frmGraphicActive);
end;

procedure TfrmMain.miSoftBlurClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    with frmGraphicActive do
      UseFilter(DoFilter_SoftBlur, True, 'MI_FLT_BLUR_SOFT');
end;

procedure TfrmMain.miRemoveMatteClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmRemoveMatte.Execute(frmGraphicActive);
end;

procedure TfrmMain.miPaintContourClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    with frmGraphicActive do
      UseFilter(DoFilter_PaintContour, True, 'MI_FLT_PAINT_CONTOUR');
end;

procedure TfrmMain.miDropShadowClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmShadow.Execute(frmGraphicActive);
end;

procedure TfrmMain.miOpacityClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmOpacity.Execute(frmGraphicActive);
end;

procedure TfrmMain.miPagePropClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoPageProp;
end;

procedure TfrmMain.miCreateWinIconClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmCreateIcon.Execute(frmGraphicActive);
end;

procedure TfrmMain.miCreateMacIconClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmCreateMacIcon.Execute(frmGraphicActive);
end;

procedure TfrmMain.miTestClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmTest.Execute(frmGraphicActive);
end;

procedure TfrmMain.miZoomInClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.sbZoomIn.Click;
end;

procedure TfrmMain.miZoomOutClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.sbZoomOut.Click;
end;

procedure TfrmMain.mi100PercentClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.sbZoom1.Click;
end;

procedure TfrmMain.miFileClick(Sender: TObject);
var
  frm: TDocumentFrame;

begin
  frm := frmDocActive;

  miClose.Enabled := Assigned(frm);
  miCloseAll.Enabled := Assigned(frm);
  miSave.Enabled := Assigned(frm);
  miSaveAs.Enabled := Assigned(frm);
  miSaveACopy.Enabled := Assigned(frm);
  miSaveAll.Enabled := Assigned(frm);
  miRevert.Enabled := Assigned(frm);
  miMetadata.Enabled := frm is TGraphicFrame;
  miPrint.Enabled := frm is TGraphicFrame;
end;

procedure TfrmMain.miOpenClick(Sender: TObject);
var
  i: integer;

begin
  if od.Execute then
    for i := 0 to od.Files.Count - 1 do
      DoOpen(UTF8ToSys(od.Files[i]));
end;

procedure TfrmMain.miSaveClick(Sender: TObject);
begin
  DoSave;
end;

procedure TfrmMain.miCloseClick(Sender: TObject);
begin
  DoCloseTab(pc.ActivePage);
end;

procedure TfrmMain.miSaveAsClick(Sender: TObject);
var
  frm: TDocumentFrame;

begin
  frm := frmDocActive;

  if frm is TGraphicFrame then
    DoSaveGraphicAs(TGraphicFrame(frm), False)
  else
  if frm is TLibraryFrame then
    DoSaveLibraryAs(TLibraryFrame(frm), False);
end;

procedure TfrmMain.miClearListClick(Sender: TObject);
begin
  rfClear;
end;

procedure TfrmMain.miPrintClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmPrint.Execute(frmGraphicActive);
end;

procedure TfrmMain.miRevertClick(Sender: TObject);
var
  frm: TDocumentFrame;

begin
  frm := frmDocActive;

  if frm is TGraphicFrame then
    with TGraphicFrame(frm) do
    begin
      if (FileName <> '') and (MessageDlg(Format(lpGet('MSG_CONFIRM_REVERT'),
        [FileName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
        DoLoad;
    end
  else
  if frm is TLibraryFrame then
    with TLibraryFrame(frm) do
    begin
      if (FileName <> '') and (MessageDlg(Format(lpGet('MSG_CONFIRM_REVERT'),
        [FileName]), mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
        DoLoad;
    end;
end;

procedure TfrmMain.miAboutClick(Sender: TObject);
begin
  OpenDocument(SysToUTF8(AppDir + 'readme.html'));
end;

procedure TfrmMain.miContentsClick(Sender: TObject);
begin
  OpenDocument(SysToUTF8(miContents[(Sender as TComponent).Tag].FileName));
end;

procedure TfrmMain.miHomepageClick(Sender: TObject);
begin
  OpenURL(sGreenfishHomepage);
end;

procedure TfrmMain.miUnsharpMaskClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmUnsharpMask.Execute(frmGraphicActive);
end;

procedure TfrmMain.miSharpenClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    with frmGraphicActive do
      UseFilter(DoFilter_Sharpen, True, 'MI_FLT_SHARPEN');
end;

procedure TfrmMain.miPreferencesClick(Sender: TObject);
begin
  frmPreferences.UpdateForm;
  if frmPreferences.ShowModal = mrOk then
    frmPreferences.UpdateData;
end;

procedure TfrmMain.miGlowClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGlow.Execute(frmGraphicActive);
end;

procedure TfrmMain.miCloseAllClick(Sender: TObject);
begin
  DoCloseAll;
end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  i: integer;
  s: string;

begin
  if VerboseMode then Log('Showing TfrmMain...');
  pc.Visible := False;

  // create special tabs
  if VerboseMode then Log('Creating Startup screen');
  AddTab(TStartupScreenTab.Create(Self), Pref_ShowStartupScreen);
  if VerboseMode then Log('Startup screen created');

  try
    // load language pack
    lpLoad(LanguageDir + Pref_LanguagePack);
    if VerboseMode then Log('Language pack loaded');
    lpApplyToUI;
    if VerboseMode then Log('Language pack applied');
    // load recent file list from config
    rfLoad;
    if VerboseMode then Log('Recent files loaded');
    // load window positions
    wndPosLoad;
    if VerboseMode then Log('Window positions loaded');
  except
  end;
  if VerboseMode then Log('Finished loading attempts');

  // check parameter list
  for i := 1 to ParamCount do
  begin
    s := ParamStr(i);
    if (s <> '') and not (s[1] in ['-', '/']) then
      DoOpen(s);
  end;

  if VerboseMode then Log('TfrmMain shown');
end;

procedure TfrmMain.miBevelClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmBevel.Execute(frmGraphicActive);
end;

procedure TfrmMain.miSaveAllClick(Sender: TObject);
var
  i: integer;
  frm: TDocumentFrame;

begin
  for i := 0 to pc.PageCount - 1 do
  begin
    if not (pc.Pages[i] is TDocumentTab) then
      Continue;

    frm := TDocumentTab(pc.Pages[i]).Frame;

    if frm is TGraphicFrame then
      with TGraphicFrame(frm) do
      begin
        if FileName <> '' then
        begin
          if not DoSave(FileName, FileType, []) then
            Break;
        end
        else
        if not DoSaveGraphicAs(TGraphicFrame(frm), False) then
          Break;
      end
    else
    if frm is TLibraryFrame then
      with TLibraryFrame(frm) do
      begin
        if FileName <> '' then
        begin
          if not DoSave(FileName, FileType, []) then
            Break;
        end
        else
        if not DoSaveLibraryAs(TLibraryFrame(frm), False) then
          Break;
      end;
  end;
end;

procedure TfrmMain.DialogFolderChange(Sender: TObject);
begin
  // We cannot do it at OnShow(), because the listview does not exist then
  DlgSetViewMode((Sender as TOpenDialog).Handle, dvm[Pref_DialogViewMode]);
end;

procedure TfrmMain.miStartupScreenClick(Sender: TObject);
begin
  TabVisible[TStartupScreenTab] := not TabVisible[TStartupScreenTab];
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    // save recent file list to Config
    rfSave;
    // save window positions: we cannot do it in ICONEDIT.DPR,
    // because this must be done when windows are not yet destroyed
    wndPosSave;
  except
  end;
end;

procedure TfrmMain.miDonateClick(Sender: TObject);
begin
  OpenURL(sGreenfishDonate);
end;

procedure TfrmMain.miCenterLinesClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    ToggleSpeedButton(frmGraphicActive.sbCenterLines);
end;

procedure TfrmMain.miBatchConvertClick(Sender: TObject);
begin
  frmBatchConvert.ShowModal;
end;

procedure TfrmMain.miLanguageClick(Sender: TObject);
begin
  frmLanguage.Execute;
end;

procedure TfrmMain.miUniformRateClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    with frmGraphicActive do
      DoUniformFrameRate(Doc.Pages[ImageIndex].FrameRate);
end;

procedure TfrmMain.miCropTransparencyClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoCropTransparency(True);
end;

procedure TfrmMain.miPageImportClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoPageImport;
end;

procedure TfrmMain.miPageExportClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoPageExport(False);
end;

procedure TfrmMain.miMetadataClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmMetadata.Execute(frmGraphicActive);
end;

// A panel instead of a paintbox was too slow
procedure TfrmMain.pbStatusBarPaint(Sender: TObject);
var
  h: integer;
  c: TCanvas;

begin
  c := pbStatusBar.Canvas;

  c.Brush.Color := clForm;
  c.FillRect(c.ClipRect);
  c.Font.Assign(Font);
  h := c.TextHeight(StatusBarText);
  c.TextOut(4, (pbStatusBar.Height - h) div 2, StatusBarText);
end;

procedure TfrmMain.pcMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
var
  TabIndex: integer;

begin
  TabIndex := Proper_TabIndexAtClientPos(pc, Point(X, Y));

  case Button of
    mbLeft: if frmDocActive <> nil then
        frmDocActive.DocFrameActivate;
    mbMiddle: if (TabIndex >= 0) and (TabIndex < pc.PageCount) then
      DoCloseTab(pc.Pages[TabIndex]);
  end;
end;

procedure TfrmMain.pcMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
var
  TabIndex: integer;
  ts: TTabSheet;
  frm: TDocumentFrame;
  fn: string;

begin
  fn := '';

  TabIndex := Proper_TabIndexAtClientPos(pc, Point(X, Y));
  if (TabIndex >= 0) and (TabIndex < pc.PageCount) then
  begin
    ts := pc.Pages[TabIndex];
    if ts is TDocumentTab then
    begin
      frm := TDocumentTab(ts).Frame;
      if frm is TGraphicFrame then
        fn := TGraphicFrame(frm).FileName
      else
      if frm is TLibraryFrame then
        fn := TLibraryFrame(frm).FileName;
    end;
  end;

  SetStatus(SysToUTF8(fn));
end;

procedure TfrmMain.pcPageChanged(Sender: TObject);
begin
  // active document changed
  if frmGraphicActive <> nil then
    frmGraphicActive.RedrawPaintBox;
  frmLayers.lb.ClientArea.Invalidate;
end;

procedure TfrmMain.pLeftMouseEnter(Sender: TObject);
begin
  frmToolSet.Visible := True;
end;

procedure TfrmMain.sdGraphicCanClose(Sender: TObject; var CanClose: boolean);
var
  fn: string;

begin
  fn := SetDefaultExt(UTF8ToSys(sdGraphic.FileName),
    iftDefaultExt[TImageFileType(sdGraphic.FilterIndex - 1)]);
  CanClose := not FileExists(fn) or QueryOverwrite(fn);
end;

procedure TfrmMain.sdLibraryCanClose(Sender: TObject; var CanClose: boolean);
var
  fn: string;

begin
  fn := SetDefaultExt(UTF8ToSys(sdLibrary.FileName),
    rftDefaultExt[TResFileType(sdLibrary.FilterIndex - 1)]);
  CanClose := not FileExists(fn) or QueryOverwrite(fn);
end;

procedure TfrmMain.miNewLibraryClick(Sender: TObject);
begin
  NewDocument(TLibraryFrame);
end;

procedure TfrmMain.miLibraryClick(Sender: TObject);
var
  frm: TLibraryFrame;
  rSelected: boolean;

begin
  frm := frmLibraryActive;
  rSelected := Assigned(frm) and (frm.lb.SelectedCount <> 0);

  miResAdd.Enabled := Assigned(frm);
  miResRemove.Enabled := rSelected;
  miResReplace.Enabled := rSelected;
  miResProp.Enabled := rSelected;
  miExtractEdit.Enabled := rSelected;
  miExtractSave.Enabled := rSelected;
end;

procedure TfrmMain.miResAddClick(Sender: TObject);
begin
  if frmLibraryActive <> nil then
    frmLibraryActive.DoAdd;
end;

procedure TfrmMain.miResRemoveClick(Sender: TObject);
begin
  if frmLibraryActive <> nil then
    frmLibraryActive.DoRemove;
end;

procedure TfrmMain.miResReplaceClick(Sender: TObject);
begin
  if frmLibraryActive <> nil then
    frmLibraryActive.DoReplace;
end;

procedure TfrmMain.miResPropClick(Sender: TObject);
begin
  if frmLibraryActive <> nil then
    frmLibraryActive.DoProperties;
end;

procedure TfrmMain.miExtractEditClick(Sender: TObject);
begin
  if frmLibraryActive <> nil then
    frmLibraryActive.DoExtractEdit;
end;

procedure TfrmMain.miExtractSaveClick(Sender: TObject);
begin
  if frmLibraryActive <> nil then
    frmLibraryActive.DoExtractSave;
end;

procedure TfrmMain.miLayersClick(Sender: TObject);
var
  frm: TGraphicFrame;
  ls: TLayers;

begin
  frm := frmGraphicActive;
  if Assigned(frm) then
    ls := frm.Doc.Pages[frm.ImageIndex].Layers;

  miLayerNew.Enabled := Assigned(frm);
  miLayerDupl.Enabled := Assigned(frm) and (ls.SelectedCount > 0);
  miLayerDelete.Enabled := Assigned(frm) and (ls.SelectedCount > 0);
  miLayerProp.Enabled := Assigned(frm) and (ls.SelectedCount = 1);
  miMergeSelected.Enabled := Assigned(frm) and (ls.SelectedCount > 0);
  miMergeVisible.Enabled := Assigned(frm) and (ls.VisibleCount > 0);
  miFlattenImage.Enabled := Assigned(frm) and (ls.LayerCount > 0);
  miLayerFromSel.Enabled := Assigned(frm) and (ls.SelState <> stNone);
end;

procedure TfrmMain.miLayerPropClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoLayerProp;
end;

procedure TfrmMain.miLayerNewClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoLayerNew;
end;

procedure TfrmMain.miLayerDuplClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoLayerDupl;
end;

procedure TfrmMain.miLayerDeleteClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoLayerDelete;
end;

procedure TfrmMain.miMergeLayersClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoLayerMerge(TLayerSubset((Sender as TComponent).Tag));
end;

procedure TfrmMain.miLayerFromSelClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmGraphicActive.DoLayerFromSel;
end;

procedure TfrmMain.miCellGridClick(Sender: TObject);
begin
  if frmGraphicActive <> nil then
    frmCellGrid.Execute(frmGraphicActive);
end;

procedure TfrmMain.miSupportClick(Sender: TObject);
begin
  OpenURL(sGreenfishSupport);
end;

procedure TfrmMain.miPasteAsDocClick(Sender: TObject);
begin
  PasteAsNewDocument;
end;

function TfrmMain.GetTabVisible(TabClass: TTabSheetClass): boolean;
begin
  Result := GetTabByClass(TabClass).TabVisible;
end;

procedure TfrmMain.SetTabVisible(TabClass: TTabSheetClass; Value: boolean);
var
  tab: TTabSheet;

begin
  tab := GetTabByClass(TabClass);
  if tab.TabVisible <> Value then
  begin
    tab.TabVisible := Value;
    if Value then
    begin
      Inc(NumberOfTabs);
      pc.ActivePage := tab;
    end
    else
      Dec(NumberOfTabs);
    pc.Visible := NumberOfTabs <> 0;
  end;
end;

end.

