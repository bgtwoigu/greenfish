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
unit dlgText;

interface

uses
  LclIntf, LclType,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdjustControl, NumberEdit, Buttons, Math, ExtCtrls, dlgDoc,
  ieShared, types;

type

  { TfrmText }

  TfrmText = class(TForm)
    mText: TMemo;
    pTop: TPanel;
    sbBold: TSpeedButton;
    sbItalic: TSpeedButton;
    sbUnderline: TSpeedButton;
    alSize: TAdjustLabel;
    cbFace: TComboBox;
    neSize: TNumberEdit;
    bOK: TButton;
    bCancel: TButton;
    procedure cbFaceDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure ControlChange(Sender: TObject);
    //procedure cbFaceDrawItem(Control: TWinControl; Index: Integer;
    //  Rect: TRect; State: TOwnerDrawState);
    procedure FormShow(Sender: TObject);
    procedure bCancelClick(Sender: TObject);
    procedure bOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure GetFont(f: TFont);
    procedure SetFont(f: TFont);
  end;

var
  frmText: TfrmText;

implementation

uses Main, dlgColor, dlgToolSet;

{$R *.lfm}

procedure TfrmText.GetFont(f: TFont);
begin
  f.Name := cbFace.Text;
  if Screen.Fonts.IndexOf(f.Name) < 0 then f.Name := Font.Name;
  f.Size := Round(neSize.Value);
  f.Style := [];
  if sbBold.Down then f.Style := f.Style + [fsBold];
  if sbItalic.Down then f.Style := f.Style + [fsItalic];
  if sbUnderline.Down then f.Style := f.Style + [fsUnderline];
end;

procedure TfrmText.SetFont(f: TFont);
begin
  cbFace.Text := f.Name;
  neSize.Value := f.Size;
  sbBold.Down := fsBold in f.Style;
  sbItalic.Down := fsItalic in f.Style;
  sbUnderline.Down := fsUnderline in f.Style;
end;

procedure TfrmText.ControlChange(Sender: TObject);
begin
  GetFont(mText.Font);
end;

procedure TfrmText.cbFaceDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
begin
  with cbFace.Canvas do
  begin
    Brush.Color := IfThen(odSelected in State, clHighlight, clWhite);
    FillRect(ARect);

    Font.Name := cbFace.Items[Index];
    Font.Size := 12;
    Brush.Style := bsClear;
    TextOut(ARect.Left + 1,
      (ARect.Top + ARect.Bottom - TextHeight(cbFace.Items[Index])) div 2,
      cbFace.Items[Index]);
    Brush.Style := bsSolid;
  end;
end;

procedure TfrmText.FormShow(Sender: TObject);
var
  s: string;

begin
  // we should always load fonts when showing the form
  // because new fonts may be installed meanwhile
  with cbFace do
  begin
    if ItemIndex >= 0 then s := Items[ItemIndex] else s := '';
    Items.Assign(Screen.Fonts);
    ItemIndex := Items.IndexOf(s);
    if ItemIndex < 0 then ItemIndex := Items.IndexOf('Arial');
  end;

  ControlChange(nil);
  ActiveControl := mText;
end;

procedure TfrmText.bCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmText.bOKClick(Sender: TObject);
var
  frm: TGraphicFrame;
  
begin
  frm := frmMain.frmGraphicActive;
  if frm <> nil then frm.DoInsertText(mText.Lines.Text, mText.Font,
    frmMain.frmColor.SelColor[0],
    frmMain.frmToolSet.ToolAntialias[dtText]);
  
  Close;
end;

end.
