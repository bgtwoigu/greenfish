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
unit dlgUnsharpMask;

interface

uses
  LclIntf, LclType,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, NumberEdit, AdjustControl, dlgDoc, DocClass, BitmapEx,
  Filters, ieShared, Layers, FilterDialog, dlgDebug;

type       
  TfrmUnsharpMask = class(TFilterDialog)
    alAmount: TAdjustLabel;
    neAmount: TNumberEdit;
    alRadius: TAdjustLabel;
    neRadius: TNumberEdit;
    alThreshold: TAdjustLabel;
    neThreshold: TNumberEdit;
    bOK: TButton;
    bCancel: TButton;
    bReset: TButton;
    cbPreview: TCheckBox;
    cbToric: TCheckBox;
    procedure bResetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ObjectChange(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure cbPreviewClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure FillInfo; override;
    procedure DoFilter(bm: TBitmap32; Mask: TBitmap1); override;
    procedure PreviewChanged;
  end;

var
  frmUnsharpMask: TfrmUnsharpMask;

implementation

{$R *.lfm}

procedure TfrmUnsharpMask.FillInfo;
begin
  inherited;
  UndoText := 'MI_FLT_UNSHARP_MASK';
  NeedsApplyTransform := True;
end;

procedure TfrmUnsharpMask.DoFilter(bm: TBitmap32; Mask: TBitmap1);
begin
  fltUnsharpMask(bm, Mask, Round(neAmount.Value * 2.56), neRadius.Value,
    Round(neThreshold.Value), cbToric.Checked);
end;

procedure TfrmUnsharpMask.PreviewChanged;
begin
  if cbPreview.Checked then InvokeEffect;
end;

procedure TfrmUnsharpMask.bResetClick(Sender: TObject);
begin
  inc(frmUpdating);
    neAmount.Value := 100;
    neRadius.Value := 0.7;
    neThreshold.Value := 0;
  dec(frmUpdating);

  PreviewChanged;
end;

procedure TfrmUnsharpMask.FormCreate(Sender: TObject);
begin
  bReset.Click;
  if VerboseMode then Log('TfrmUnsharpMask created');
end;

procedure TfrmUnsharpMask.FormShow(Sender: TObject);
begin
  inc(frmUpdating);
    cbPreview.Checked := Pref_FilterPreview;
  dec(frmUpdating);

  PreviewChanged;
end;

procedure TfrmUnsharpMask.ObjectChange(Sender: TObject);
begin
  if frmUpdating = 0 then PreviewChanged;
end;

procedure TfrmUnsharpMask.FormHide(Sender: TObject);
begin
  Pref_FilterPreview := cbPreview.Checked;
end;

procedure TfrmUnsharpMask.cbPreviewClick(Sender: TObject);
begin
  if (frmUpdating <> 0) or (frmDoc = nil) then Exit;
  if cbPreview.Checked then PreviewChanged else
  begin
    ls.Assign(frmDoc.lsSrc);
    frmDoc.RedrawPaintBox;
  end;
end;

end.
