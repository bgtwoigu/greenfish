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
unit dlgPreferences;

interface

uses
  {$IFDEF WINDOWS} DdeServer, FileAssoc, {$ENDIF} LclIntf, LclType,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ieShared,
  LangPack, ComCtrls, NumberEdit, Math, AdjustControl;

type

  { TfrmPreferences }

  TfrmPreferences = class(TForm)
    bOK: TButton;
    bCancel: TButton;
    bReset: TButton;
    cbJpeg2000: TCheckBox;
    pc: TPageControl;
    tsEnvironment: TTabSheet;
    tsInstall: TTabSheet;
    gbColors: TGroupBox;
    sHatch1: TShape;
    sHatch2: TShape;
    bResetColors: TButton;
    lDVM: TLabel;
    cbDVM: TComboBox;
    gbFileAssoc: TGroupBox;
    cbICO: TCheckBox;
    cbCUR: TCheckBox;
    cbPNG: TCheckBox;
    cbXPM: TCheckBox;
    cbJPEG: TCheckBox;
    cbBMP: TCheckBox;
    tsMisc: TTabSheet;
    gbUsePNG: TGroupBox;
    cbUsePNG: TCheckBox;
    nePNGLimit: TNumberEdit;
    lTransparentHatch: TLabel;
    sGrid2: TShape;
    sGrid1: TShape;
    lGrid: TLabel;
    sGrid2_1: TShape;
    sGrid2_2: TShape;
    lGrid2: TLabel;
    cbANI: TCheckBox;
    cbSaveToolSettings: TCheckBox;
    cbMWA: TComboBox;
    lMWA: TLabel;
    cbGIF: TCheckBox;
    gbImageMax: TGroupBox;
    alMaxWidth: TAdjustLabel;
    neMaxWidth: TNumberEdit;
    alMaxHeight: TAdjustLabel;
    neMaxHeight: TNumberEdit;
    cbPCX: TCheckBox;
    cbGFIE: TCheckBox;
    lAdminMode: TLabel;
    cbICL: TCheckBox;
    cbICNS: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure ShapeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure bResetClick(Sender: TObject);
    procedure bResetColorsClick(Sender: TObject);
    procedure nePNGLimitChange(Sender: TObject);
  private
    { Private declarations }
  public
    // update the controls with the current Pref_... values
    procedure UpdateForm;
    // write info from controls to Pref_... vars
    procedure UpdateData;
  end;

var
  frmPreferences: TfrmPreferences;

{$IFDEF WINDOWS}
// Remove all associations
procedure UnAssociateAll;
{$ENDIF}

implementation

uses Main, dlgColor;

{$R *.lfm}

{$IFDEF WINDOWS}
function IsAssociated(const Ext: string): boolean;
var
  r: TFileAssoc;

begin
  Result := GetFileAssoc(Ext, r) and
    (Pos(AnsiUpperCase(ParamStr(0)), AnsiUpperCase(r.cmdOpen)) <> 0);
end;

procedure SetAssociation(const Ext: string; SelfIcon, Value: boolean);
var
  r: TFileAssoc;

begin
  if IsAssociated(Ext) <> Value then
  if Value then
  begin
    // fill in TFileAssoc.fields
    r.TypeId := Application.Title + Ext + 'file';
    r.TypeDesc := r.TypeId;
    if SelfIcon then r.DefaultIcon := '%1' else
      r.DefaultIcon := ParamStr(0) + ',0';
    r.cmdOpen := ParamStr(0);

    r.ddeUse := True;
    r.ddeMacro := '[Open("%1")]';
    r.ddeServerName := sDDEServerName;
    r.ddeTopic := sDDETopic;

    // register
    SetFileAssoc(Ext, r);
  end else
    UndoFileAssoc(Ext);
end;

procedure UnAssociateAll;
begin
  try
    SetAssociation('.gfie', False, False);
    SetAssociation('.gfi', False, False);
    SetAssociation('.ico', True, False);
    SetAssociation('.cur', True, False);
    SetAssociation('.ani', True, False);
    SetAssociation('.icns', False, False);
    SetAssociation('.png', False, False);
    SetAssociation('.xpm', False, False);
    SetAssociation('.bmp', False, False);
    SetAssociation('.jpg', False, False);
    SetAssociation('.jpeg', False, False);
    SetAssociation('.jpe', False, False);
    SetAssociation('.gif', False, False);
    SetAssociation('.jp2', False, False);
    SetAssociation('.j2k', False, False);
    SetAssociation('.jpf', False, False);
    SetAssociation('.jpx', False, False);
    //SetAssociation('.tga', False, False);
    SetAssociation('.pcx', False, False);
    SetAssociation('.icl', False, False);
  except
    ShowMessage('Error removing file associations.'); // Do not localize
  end;
end;
{$ENDIF} // ifdef windows

procedure TfrmPreferences.UpdateForm;
begin
  neMaxWidth.Value := Pref_MaxWidth;
  neMaxHeight.Value := Pref_MaxHeight;
  nePNGLimit.Value := Min(256, Pref_PNGLimit);
  cbUsePNG.Checked := Pref_PNGLimit <= 256;

  sHatch1.Brush.Color := Pref_Hatch.Color[0];
  sHatch2.Brush.Color := Pref_Hatch.Color[1];
  sGrid1.Brush.Color := Pref_clGrid[0];
  sGrid2.Brush.Color := Pref_clGrid[1];
  sGrid2_1.Brush.Color := Pref_clGrid2[0];
  sGrid2_2.Brush.Color := Pref_clGrid2[1];
  cbDVM.ItemIndex := Pref_DialogViewMode;
  cbMWA.ItemIndex := Ord(Pref_MWA);
  cbSaveToolSettings.Checked := Pref_SaveToolSettings;

{$IFDEF WINDOWS}
  // load associations
  cbGFIE.Checked := IsAssociated('.gfie') and IsAssociated('.gfi');
  cbICO.Checked := IsAssociated('.ico');
  cbCUR.Checked := IsAssociated('.cur');
  cbANI.Checked := IsAssociated('.ani');
  cbICNS.Checked := IsAssociated('.icns');
  cbPNG.Checked := IsAssociated('.png');
  cbXPM.Checked := IsAssociated('.xpm');
  cbBMP.Checked := IsAssociated('.bmp');
  cbJPEG.Checked := IsAssociated('.jpg') and IsAssociated('.jpeg') and
    IsAssociated('.jpe');
  cbGIF.Checked := IsAssociated('.gif');
  cbJpeg2000.Checked := IsAssociated('.jp2') and IsAssociated('.j2k') and
    IsAssociated('.jpf') and IsAssociated('.jpx');
  //cbTGA.Checked := IsAssociated('.tga');
  cbPCX.Checked := IsAssociated('.pcx');
  cbICL.Checked := IsAssociated('.icl');
{$ENDIF}
end;

procedure TfrmPreferences.UpdateData;
var
  i, j: integer;
  Changed_Hatch: boolean;

begin
  // update variables
  Pref_MaxWidth := Round(neMaxWidth.Value);
  Pref_MaxHeight := Round(neMaxHeight.Value);
  Pref_PNGLimit := IfThen(cbUsePNG.Checked, Round(nePNGLimit.Value), MaxInt);

  i := sHatch1.Brush.Color; j := sHatch2.Brush.Color;
  with Pref_Hatch do
  begin
    Changed_Hatch := (Color[0] <> i) or (Color[1] <> j);
    Color[0] := i; Color[1] := j;
  end;
  Pref_clGrid[0] := sGrid1.Brush.Color;
  Pref_clGrid[1] := sGrid2.Brush.Color;
  Pref_clGrid2[0] := sGrid2_1.Brush.Color;
  Pref_clGrid2[1] := sGrid2_2.Brush.Color;

  Pref_DialogViewMode := cbDVM.ItemIndex;
  Byte(Pref_MWA) := cbMWA.ItemIndex;
  Pref_SaveToolSettings := cbSaveToolSettings.Checked;

{$IFDEF WINDOWS}
  // save associations
  try
    SetAssociation('.gfie', False, cbGFIE.Checked);
    SetAssociation('.gfi', False, cbGFIE.Checked);
    SetAssociation('.ico', True, cbICO.Checked);
    SetAssociation('.cur', True, cbCUR.Checked);
    SetAssociation('.ani', True, cbANI.Checked);
    SetAssociation('.icns', False, cbICNS.Checked);
    SetAssociation('.png', False, cbPNG.Checked);
    SetAssociation('.xpm', False, cbXPM.Checked);
    SetAssociation('.bmp', False, cbBMP.Checked);
    SetAssociation('.jpg', False, cbJPEG.Checked);
    SetAssociation('.jpeg', False, cbJPEG.Checked);
    SetAssociation('.jpe', False, cbJPEG.Checked);
    SetAssociation('.gif', False, cbGIF.Checked);
    SetAssociation('.jp2', False, cbJpeg2000.Checked);
    SetAssociation('.j2k', False, cbJpeg2000.Checked);
    SetAssociation('.jpf', False, cbJpeg2000.Checked);
    SetAssociation('.jpx', False, cbJpeg2000.Checked);
    //SetAssociation('.tga', False, cbTGA.Checked);
    SetAssociation('.pcx', False, cbPCX.Checked);
    SetAssociation('.icl', False, cbICL.Checked);
  except
    ShowMessage(lpGet('MSG_ERROR_ASSOC'));
  end;
{$ENDIF}

  // "OnChange" events

  // repaint child form, if hatch color/PNG limit has changed
  if Assigned(frmMain.frmGraphicActive) then frmMain.frmGraphicActive.Invalidate;

  // repaint other controls which display the hatch
  if Changed_Hatch then
  with frmMain.frmColor do
  begin
    pbForeColor.Invalidate;
    pbBackColor.Invalidate;
    sbAlpha.Invalidate;
  end;
end;

procedure TfrmPreferences.ShapeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  with Sender as TShape do Brush.Color := GFIEPickColor(Brush.Color);
end;

procedure TfrmPreferences.FormCreate(Sender: TObject);
begin
{$IFNDEF WINDOWS}
  tsInstall.TabVisible := False;
{$ENDIF}
end;

procedure TfrmPreferences.bResetClick(Sender: TObject);
begin
  neMaxWidth.Value := Default_Pref_MaxWidth;
  neMaxHeight.Value := Default_Pref_MaxHeight;
  cbUsePNG.Checked := True;
  nePNGLimit.Value := 256;
  bResetColors.Click;
  cbDVM.ItemIndex := 3;
  cbSaveToolSettings.Checked := True;
end;

procedure TfrmPreferences.bResetColorsClick(Sender: TObject);
begin
  sHatch1.Brush.Color := clWhite;
  sHatch2.Brush.Color := clSilver;
  sGrid1.Brush.Color := clGray;
  sGrid2.Brush.Color := clSilver;
  sGrid2_1.Brush.Color := clMaroon;
  sGrid2_2.Brush.Color := clRed;
end;

procedure TfrmPreferences.nePNGLimitChange(Sender: TObject);
begin
  cbUsePNG.Checked := True;
end;

end.

