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
unit dlgFormulae;

interface

uses
  LclIntf, LclType,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DocClass, BitmapEx, Filters, ieShared,
  Math, FilterDialog, dlgDebug;

type
  TfrmFormulae = class(TFilterDialog)
    lRed: TLabel;
    lGreen: TLabel;
    lBlue: TLabel;
    eRed: TEdit;
    eGreen: TEdit;
    eBlue: TEdit;
    cbPreview: TCheckBox;
    bOK: TButton;
    bCancel: TButton;
    bReset: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure cbPreviewClick(Sender: TObject);
    procedure bResetClick(Sender: TObject);
    procedure eChange(Sender: TObject);
  private
    { Private declarations }
  public
    procedure FillInfo; override;
    procedure DoFilter(bm: TBitmap32; Mask: TBitmap1); override;
    procedure PreviewChanged;
  end;

var
  frmFormulae: TfrmFormulae;

implementation

{$R *.lfm}

procedure TfrmFormulae.FillInfo;
begin
  inherited;
  UndoText := 'MI_FLT_FORMULAE';
end;

procedure TfrmFormulae.DoFilter;
begin
  fltChannelFormula(bm, Mask, eRed.Text, eGreen.Text, eBlue.Text);
end;

procedure TfrmFormulae.eChange(Sender: TObject);
var
  c: TColor;
  
begin
  if frmUpdating = 0 then PreviewChanged;

  // mark syntax errors
  c := IfThen(fltChannelFormula(nil, nil, eRed.Text, eGreen.Text, eBlue.Text),
    clWindow, $8080ff);
  eRed.Color := c;
  eGreen.Color := c;
  eBlue.Color := c;
end;

procedure TfrmFormulae.PreviewChanged;
begin
  if cbPreview.Checked then InvokeEffect;
end;

procedure TfrmFormulae.cbPreviewClick(Sender: TObject);
begin
  if (frmUpdating <> 0) or (frmDoc = nil) then Exit;
  if cbPreview.Checked then PreviewChanged else
  begin
    ls.Assign(frmDoc.lsSrc);
    frmDoc.RedrawPaintBox;
  end;
end;

procedure TfrmFormulae.bResetClick(Sender: TObject);
begin
  inc(frmUpdating);
    eRed.Text := 'r';
    eGreen.Text := 'g';
    eBlue.Text := 'b';
  dec(frmUpdating);

  PreviewChanged;
end;

procedure TfrmFormulae.FormCreate(Sender: TObject);
begin
  frmUpdating := 0;
  bReset.Click;
  if VerboseMode then Log('TfrmFormulae created');
end;

procedure TfrmFormulae.FormHide(Sender: TObject);
begin
  Pref_FilterPreview := cbPreview.Checked;
end;

procedure TfrmFormulae.FormShow(Sender: TObject);
begin
  inc(frmUpdating);
    cbPreview.Checked := Pref_FilterPreview;
  dec(frmUpdating);

  PreviewChanged;
end;

end.
