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
unit dlgLib;

interface

uses
  LclIntf, LclType,
  SysUtils, Variants, Classes, Graphics, Controls, Forms, FileUtil,
  Dialogs, ExtCtrls, Buttons, Menus, ResList, LangPack,
  BitmapEx, bmExUtils, Filters, DocClass, ieShared, ShellEx, StrUtils,
  gfListBox, gfMath, Math, dlgExeFormat, dlgDebug, types;

type
  TDlgResItem = class(TPersistent)
  private
    FDoc: TIconDoc;
  public
    IsIcon: boolean;
    Name: string;
    Language: word;
    Selected: boolean;

    property Doc: TIconDoc read FDoc;

    constructor Create;
    destructor Destroy; override;
  end;

  { TLibraryFrame }

  TLibraryFrame = class(TDocumentFrame)
    odIcon: TOpenDialog;
    pToolbar: TPanel;
    sbAdd: TSpeedButton;
    sbRemove: TSpeedButton;
    sbReplace: TSpeedButton;
    sbProperties: TSpeedButton;
    sbExtractEdit: TSpeedButton;
    Bevel1: TBevel;
    sbExtractSave: TSpeedButton;
    sbSave: TSpeedButton;
    Bevel2: TBevel;
    lb: TgfListBox;
    procedure sbPropertiesClick(Sender: TObject);
    procedure sbRemoveClick(Sender: TObject);
    procedure lbKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbAddClick(Sender: TObject);
    procedure sbReplaceClick(Sender: TObject);
    procedure sbExtractEditClick(Sender: TObject);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sbExtractSaveClick(Sender: TObject);
    procedure sbSaveClick(Sender: TObject);
    procedure lbResize(Sender: TObject);
    procedure lbGetCount(Sender: TObject; var Value: Integer);
    procedure lbItemGetSelected(Sender: TObject; Index: Integer;
      var Value: Boolean);
    procedure lbItemSetSelected(Sender: TObject; Index: Integer;
      Value: Boolean);
    procedure lbListDblClick(Sender: TObject);
    procedure lbItemPaint(Sender: TObject; ACanvas: TCanvas; Index: Integer;
      ItemRect: TRect);
  private
    FFileName: string;
    FModified: boolean;
    
    procedure SetFileName(const Value: string);
    procedure SetModified(Value: boolean);
  public
    // Icon and cursor resources
    rlIcon: TList; // list of TDlgResItem
    // Other resources
    rlOther: TResList;

    // This is in fact much like a property
    FileType: TResFileType;

    procedure DocFrameCreate; override;
    destructor Destroy; override;
    function DocFrameCanClose: boolean; override;
	
    procedure ApplyLanguagePack;
    procedure UpdateCaption;

    function rlIconIndexOf(AIsIcon: boolean;
      const AName: string; ALanguage: integer): integer;
    // select only one resource
    function SelectOneResource: integer;

    procedure DoClear;
    function DoLoad: boolean;
    // dsoSilent is an invalid option here
    function DoSave(const fn: string; ft: TResFileType;
      Options: TDocumentSaveOptions): boolean;

    procedure DoAdd;
    procedure DoRemove;
    procedure DoReplace;
    procedure DoProperties;
    procedure DoExtractEdit;
    procedure DoExtractSave;

    property FileName: string read FFileName write SetFileName;
    property Modified: boolean read FModified write SetModified;
  end;

implementation

uses Main, dlgDoc, dlgResProp, ICO, dlgStartupFrame;

{$R *.lfm}

// TDlgResItem

constructor TDlgResItem.Create;
begin
  inherited;

  FDoc := TIconDoc.Create;
  Selected := False;
end;

destructor TDlgResItem.Destroy;
begin
  FDoc.Free;

  inherited;
end;

// TLibraryFrame

procedure TLibraryFrame.SetFileName;
begin
  FFileName := Value;
  UpdateCaption;
end;

procedure TLibraryFrame.SetModified;
begin
  FModified := Value;
  UpdateCaption;
end;

procedure TLibraryFrame.DocFrameCreate;
begin
  rlIcon := TList.Create;
  rlOther := TResList.Create;

  // load glyphs
  GetMiscGlyph(sbSave.Glyph, mgSave);
  GetMiscGlyph(sbAdd.Glyph, mgPlus);
  GetMiscGlyph(sbRemove.Glyph, mgMinus);
  GetMiscGlyph(sbReplace.Glyph, mgReplace);
  GetMiscGlyph(sbProperties.Glyph, mgProperties);
  GetMiscGlyph(sbExtractEdit.Glyph, mgExtractEdit);
  GetMiscGlyph(sbExtractSave.Glyph, mgExtractSave);

  FFileName := '';
  FModified := False;

  UpdateCaption;
  Resize;
  ApplyLanguagePack;

  frmMain.TabVisible[TStartupScreenTab] := False;
end;

destructor TLibraryFrame.Destroy;
var
  i: integer;
  
begin
  // avoid repainting
  lb.Visible := False;

  for i := 0 to rlIcon.Count - 1 do TDlgResItem(rlIcon[i]).Free;
  rlIcon.Free;
  rlOther.Free;
  
  inherited;
end;

procedure TLibraryFrame.ApplyLanguagePack;
begin
  sbSave.Hint := lpGet('MI_FILE_SAVE');
  sbAdd.Hint := lpGet('MI_LIB_ADD')+'...';
  sbRemove.Hint := lpGet('MI_LIB_REMOVE');
  sbReplace.Hint := lpGet('MI_LIB_REPLACE')+'...';
  sbProperties.Hint := lpGet('MI_LIB_PROP')+'...';
  sbExtractEdit.Hint := lpGet('MI_LIB_EXTRACT_EDIT');
  sbExtractSave.Hint := lpGet('MI_LIB_EXTRACT_SAVE')+'...';

  odIcon.Filter := Format('%s (*.ico)|*.ico|%s (*.cur)|*.cur',
    [lpGet('FF_ICO'), lpGet('FF_CUR')]);
end;

procedure TLibraryFrame.UpdateCaption;
var
  s: string;

begin
  if FileName = '' then
    s := lpGet('UNTITLED')
  else
    s := SysToUTF8(ExtractFileName(FileName));
  if Modified then s := s + '*';

  SetTabCaption(s);
end;

function TLibraryFrame.rlIconIndexOf;
begin
  for Result := 0 to rlIcon.Count - 1 do
  with TDlgResItem(rlIcon[Result]) do
    if (IsIcon = AIsIcon) and (Name = AName) and (Language = ALanguage) then
  Exit;

  Result := -1;
end;

function TLibraryFrame.SelectOneResource;
begin
  lb.ItemIndex := Max(0, lb.ItemIndex);
  Result := lb.ItemIndex;
end;

procedure TLibraryFrame.DoClear;
var
  i: integer;
  
begin
  for i := 0 to rlIcon.Count - 1 do TDlgResItem(rlIcon[i]).Free;
  rlIcon.Clear;
  rlOther.Clear;
end;

function TLibraryFrame.DoLoad;
var
  i: integer;
  rl: TResList;
  e: TResEntry;
  dri: TDlgResItem;

begin
  Screen.Cursor := crHourglass;
  try
    rl := TResList.Create;
    try
      FileType := rl.LoadFromFile(FileName);
      Result := FileType <> rftNone;
      if not Result then Exit;

      DoClear;

      // process resources
      for i := 0 to rl.EntryCount - 1 do
      begin
        e := rl[i];
        
        if (e._Type = resIconType[True, ritGroup]) or
          (e._Type = resIconType[False, ritGroup]) then
        // icon/cursor resource
        begin
          dri := TDlgResItem.Create;

          dri.IsIcon := (e._Type = resIconType[True, ritGroup]);
          dri.Name := e.Name;
          dri.Language := e.Language;

          if rl.GetIcon(dri.IsIcon, dri.Name, dri.Language, dri.Doc) then
            rlIcon.Add(dri) else dri.Free;
        end else

        if (e._Type <> resIconType[True, ritPage]) and
          (e._Type <> resIconType[False, ritPage]) then
        // no icon/cursor resource
        rlOther.NewEntry.Assign(e);
      end; // for i

      lb.ClientArea.Invalidate;
      Modified := False;
    finally
      rl.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TLibraryFrame.DoSave;
var
  i: integer;
  IsIcon: boolean;
  rl: TResList;
  s: TMemoryStream;
  dri: TDlgResItem;
  SaveOK: boolean;
  ExeFormatSave: TExeFormat;

begin
  Result := False;

  if ft = rftExe then
  begin
    ExeFormatSave := exeDetectFormat(fn);
    case ExeFormatSave of
      exeNone: begin
        // show a dialog for ICL format: 32-bit or 16-bit?
        frmExeFormat.rg.ItemIndex := 0;
        frmExeFormat.ShowModal;
        case frmExeFormat.rg.ItemIndex of
          0: ExeFormatSave := exePE;
          else ExeFormatSave := exeNE;
        end;
      end;

      // Warn: saving to NE format is destructive (overwrites file contents)
      exeNE: if MessageDlg(lpGet('MSG_CONFIRM_DESTROY_EXE'), mtConfirmation,
        [mbYes, mbNo], 0) <> mrYes then Exit;
    end; // case exe format
  end else
    ExeFormatSave := exeNone;

  try
    Screen.Cursor := crHourglass;
    try
      rl := TResList.Create;
      try
        // write icon/cursor resources
        s := TMemoryStream.Create;
        try
          for i := 0 to rlIcon.Count - 1 do
          begin
            dri := TDlgResItem(rlIcon[i]);

            s.Clear;
            IsIcon := dri.IsIcon;
            icoSaveToStream(dri.Doc, s, not IsIcon, Pref_PNGLimit);
            s.Position := 0;
            rl.SetIconFromStream(IsIcon, dri.Name, dri.Language, s);
          end;
        finally
          s.Free;
        end;

        // write other resources
        rl.Append(rlOther);

        SaveOK := rl.SaveToFile(fn, ft, ExeFormatSave);
      finally
        rl.Free;
      end;
    finally
      Screen.Cursor := crDefault;
    end;

    if not SaveOK then
    begin
      ShowMessage(lpGet('MSG_ERROR_WRITE_RES')+LineEnding);
      Exit;
    end;

    Modified := False;
    if not (dsoSaveACopy in Options) then
    begin
      FileName := fn;
      FileType := ft;
    end;

    // success
    Result := True;
  except
  end;
end;

procedure TLibraryFrame.DoAdd;
var
  i: integer;
  IsIcon: boolean;
  fn: string;
  dri: TDlgResItem;

begin
  odIcon.Options := odIcon.Options + [ofAllowMultiSelect];
  if odIcon.Execute then
  begin
    // deselect all other items
    lb.ItemIndex := -1;
    
    IsIcon := odIcon.FilterIndex = 1;
    for i := 0 to odIcon.Files.Count - 1 do
    begin
      fn := UTF8ToSys(odIcon.Files[i]);
      
      dri := TDlgResItem.Create;
      dri.IsIcon := IsIcon;
      dri.Name := resValidName(ExtractOnlyFileName(fn));
      dri.Language := 0;
      dri.Selected := True;
      icoLoadFromFile(dri.Doc, fn);

      // modify name if not unique
      while rlIconIndexOf(dri.IsIcon, dri.Name, dri.Language) >= 0 do
        dri.Name := dri.Name + '_';

      rlIcon.Add(dri)
    end; // for i

    // changed
    lb.ClientArea.Repaint;
    lb.ScrollTo(lb.Count - 1);
    Modified := True;
  end;
end;

procedure TLibraryFrame.DoRemove;
var
  i: integer;

begin
  if lb.SelectedCount = 0 then ShowMessage(lpGet('MSG_SELECT_ITEMS')) else
  if MessageDlg(lpGet('MSG_CONFIRM_REMOVE'), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    for i := lb.Count - 1 downto 0 do if lb.Selected[i] then
    begin
      TDlgResItem(rlIcon[i]).Free;
      rlIcon.Delete(i);
    end;

    // changed
    lb.ClientArea.Invalidate;
    Modified := True;
  end;
end;

procedure TLibraryFrame.DoReplace;
var
  i: integer;

begin        
  if lb.SelectedCount = 0 then ShowMessage(lpGet('MSG_SELECT_ITEMS')) else
  begin
    odIcon.Options := odIcon.Options - [ofAllowMultiSelect];
    if odIcon.Execute then
    begin
      for i := 0 to lb.Count - 1 do if lb.Selected[i] then
        icoLoadFromFile(TDlgResItem(rlIcon[i]).Doc, UTF8ToSys(odIcon.FileName));

      // changed
      lb.ClientArea.Invalidate;
      Modified := True;
    end; // odIcon.Execute
  end; // selected
end;

procedure TLibraryFrame.DoProperties;
var
  i, ii: integer;
  dri: TDlgResItem;
  NewName: string;
  NewLanguage: word;

begin
  ii := SelectOneResource;
  if ii < 0 then
  begin
    ShowMessage(lpGet('MSG_SELECT_ITEMS'));
    Exit;
  end;

  dri := TDlgResItem(rlIcon[ii]);

  with frmResProp do
  begin
    eName.Text := dri.Name;
    neLanguage.Value := dri.Language;

    if ShowModal <> mrOk then Exit;

    // load settings from form
    NewName := resValidName(eName.Text);
    NewLanguage := Round(neLanguage.Value);
  end;

  i := rlIconIndexOf(dri.IsIcon, NewName, NewLanguage);

  // nothing changed?
  if i = ii then Exit;
  // already exists?
  if i >= 0 then
  begin
    ShowMessage(Format(lpGet('MSG_RES_EXIST'), [NewName, NewLanguage]));
    Exit;
  end;

  // change resource
  dri.Name := NewName;
  dri.Language := NewLanguage;

  // changed
  lb.ClientArea.Invalidate;
  Modified := True;
end;

procedure TLibraryFrame.DoExtractEdit;
var
  i: integer;

begin
  if lb.SelectedCount = 0 then ShowMessage(lpGet('MSG_SELECT_ITEMS')) else
  for i := 0 to lb.Count - 1 do if lb.Selected[i] then
  with TGraphicFrame(frmMain.NewDocument(TGraphicFrame)) do
  begin
    Doc.Assign(TDlgResItem(rlIcon[i]).Doc);

    PageCountChanged;
    PageSizeChanged;
  end;
end;

procedure TLibraryFrame.DoExtractSave;
var
  i, fnIndex: integer;
  dir, fn, Ext: string;

begin
  if lb.SelectedCount = 0 then ShowMessage(lpGet('MSG_SELECT_ITEMS')) else
  begin
    dir := BrowseForFolder(lpGet('HINT_RES_FOLDER')+':', '');
    if DirectoryExists(dir) then // extract all selected resources
    begin
      Screen.Cursor := crHourGlass;
      try
        dir := IncludeTrailingPathDelimiter(dir);

        for i := 0 to lb.Count - 1 do if lb.Selected[i] then
        with TDlgResItem(rlIcon[i]) do
        begin
          Ext := IfThen(IsIcon, '.ico', '.cur');

          // gen. unique file name
          fnIndex := 1; fn := dir + Name;
          while FileExists(fn + Ext) do
          begin
            inc(fnIndex);
            fn := dir + Name + ' (' + IntToStr(fnIndex) + ')';
          end;

          icoSaveToFile(Doc, fn + Ext, not IsIcon, Pref_PNGLimit);
        end; // for i

        OpenDocument(SysToUTF8(dir));
      finally
        Screen.Cursor := crDefault;
      end;
    end; // if directory exists
  end; // SelCount <> 0
end;

procedure TLibraryFrame.sbPropertiesClick(Sender: TObject);
begin
  DoProperties;
end;

procedure TLibraryFrame.sbRemoveClick(Sender: TObject);
begin
  DoRemove;
end;

procedure TLibraryFrame.lbKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then DoRemove;
end;

procedure TLibraryFrame.sbAddClick(Sender: TObject);
begin
  DoAdd;
end;

procedure TLibraryFrame.sbReplaceClick(Sender: TObject);
begin
  DoReplace;
end;

function TLibraryFrame.DocFrameCanClose: boolean;
begin
  Result := True;

  if Modified then
  case QuerySaveChanges(FileName) of
    IDYES: Result := DoSave(FileName, FileType, []);
    IDCANCEL: Result := False;
  end;
end;

procedure TLibraryFrame.sbExtractEditClick(Sender: TObject);
begin
  DoExtractEdit;
end;

procedure TLibraryFrame.ControlMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  frmMain.SetStatus((Sender as TControl).Hint);
end;

procedure TLibraryFrame.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  frmMain.SetStatus('');
end;

procedure TLibraryFrame.sbExtractSaveClick(Sender: TObject);
begin
  DoExtractSave;
end;

procedure TLibraryFrame.sbSaveClick(Sender: TObject);
begin
  frmMain.DoSave;
end;

procedure TLibraryFrame.lbResize(Sender: TObject);
begin
  lb.Columns := lb.ClientArea.Height div lb.ItemHeight;
end;

procedure TLibraryFrame.lbGetCount(Sender: TObject; var Value: Integer);
begin
  Value := rlIcon.Count;
end;

procedure TLibraryFrame.lbItemGetSelected(Sender: TObject; Index: Integer;
  var Value: Boolean);
begin
  Value := TDlgResItem(rlIcon[Index]).Selected;
end;

procedure TLibraryFrame.lbItemSetSelected(Sender: TObject; Index: Integer;
  Value: Boolean);
begin
  TDlgResItem(rlIcon[Index]).Selected := Value;
end;

procedure TLibraryFrame.lbListDblClick(Sender: TObject);
begin
  DoExtractEdit;
end;

procedure TLibraryFrame.lbItemPaint(Sender: TObject; ACanvas: TCanvas;
  Index: Integer; ItemRect: TRect);
const
  MaxLength = 14;

var
  yText, h: integer;
  s: string;
  dri: TDlgResItem;
  bmItem, bmThumb: TBitmap32;
  r: TRect;

begin
  dri := TDlgResItem(rlIcon[Index]);
  bmItem := TBitmap32.Create;
  try
    bmItem.Resize(ItemRect.Width, ItemRect.Height);
    bmItem.FillColor(TColor32(lb.Color) or cl32Opaque);

    // background
    if lb.Selected[Index] then
    begin
      r := bmItem.ClientRect.Inflate(-8, -8);
      bmItem.Rectangle(r, IfThen(lb.ClientArea.Focused, $30a03030, $10000000), True, 0);
      fltBoxBlur(bmItem, nil, 9, False, False, False);
      bmItem.Gradient(cl32Transparent, $20000000,
        Point(0, 0), Point(0, bmItem.Height),
        r, gkLinear, grNone);
    end;

    // draw text
    bmItem.Font.Name := 'Tahoma';
    bmItem.Font.Size := 8;
    h := bmItem.TextExtent('Mg').Y;
    yText := bmItem.Height - 8 - 2*h;
    // resource name
    s := dri.Name;
    if Length(s) > MaxLength then s := Copy(s, 1, MaxLength) + '...';
    bmItem.TextOut((bmItem.Width - bmItem.TextExtent(s).X) div 2, yText, s, cl32Black, True);
    // language id
    s := IntToStr(dri.Language);
    bmItem.TextOut((bmItem.Width - bmItem.TextExtent(s).X) div 2, yText + h, s, cl32Gray, True);

    // draw thumbnail
    bmThumb := TBitmap32.Create;
    try
      dri.Doc.GetThumbnail(48, bmThumb, False);
      bmItem.Draw((bmItem.Width - bmThumb.Width) div 2, (yText - bmThumb.Height) div 2, bmThumb);
    finally
      bmThumb.Free;
    end;

    bmItem.DrawToCanvas(ACanvas, ItemRect.Left, ItemRect.Top, Pref_Hatch);
  finally
    bmItem.Free;
  end;
end;

end.

