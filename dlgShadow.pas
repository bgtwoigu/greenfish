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
unit dlgShadow;

interface

uses
  LclIntf, LclType,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, AdjustControl, NumberEdit, dlgDoc, Layers,
  DocClass, BitmapEx, Filters, ieShared, FilterDialog, dlgDebug;

type
  TfrmShadow = class(TFilterDialog)
    neDistance: TNumberEdit;
    neIntensity: TNumberEdit;
    alDistance: TAdjustLabel;
    alIntensity: TAdjustLabel;
    lColor: TLabel;
    sColor: TShape;
    alAngle: TAdjustLabel;
    neAngle: TNumberEdit;
    bOK: TButton;
    bCancel: TButton;
    bReset: TButton;
    alBlur: TAdjustLabel;
    neBlur: TNumberEdit;
    cbPreview: TCheckBox;
    cbToric: TCheckBox;
    procedure bResetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ObjectChange(Sender: TObject);
    procedure sColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure cbPreviewClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
  public
    procedure FillInfo; override;
    procedure DoFilter(bm: TBitmap32; Mask: TBitmap1); override;
    procedure PreviewChanged;
  end;

var
  frmShadow: TfrmShadow;

implementation

{$R *.lfm}

procedure TfrmShadow.DoFilter;
var
  q: double;
  
begin
  q := neAngle.Value * pi / 180;
  fltShadow(bm, Mask, Round(neDistance.Value * Cos(q)),
    Round(neDistance.Value * Sin(q)), neBlur.Value,
    sColor.Brush.Color, Round(neIntensity.Value * 2.55), cbToric.Checked);
end;

procedure TfrmShadow.FillInfo;
begin
  inherited;
  UndoText := 'MI_FLT_DROP_SHADOW';
  NeedsApplyTransform := True;
end;

procedure TfrmShadow.PreviewChanged;
begin
  if cbPreview.Checked then InvokeEffect;
end;

procedure TfrmShadow.bResetClick(Sender: TObject);
begin
  inc(frmUpdating);
    neDistance.Value := 3;
    neAngle.Value := 45;
    neBlur.Value := 1.5;
    sColor.Brush.Color := clBlack;
    neIntensity.Value := 30;
  dec(frmUpdating);

  PreviewChanged;
end;

procedure TfrmShadow.FormShow(Sender: TObject);
begin
  inc(frmUpdating);
    cbPreview.Checked := Pref_FilterPreview;
  dec(frmUpdating);

  PreviewChanged;
end;

procedure TfrmShadow.ObjectChange(Sender: TObject);
begin
  if frmUpdating = 0 then PreviewChanged;
end;

procedure TfrmShadow.sColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Value: TColor;
  
begin
  Value := GFIEPickColor(sColor.Brush.Color);
  if Value <> sColor.Brush.Color then
  begin
    sColor.Brush.Color := Value;
    PreviewChanged;
  end;
end;

procedure TfrmShadow.FormCreate(Sender: TObject);
begin
  bReset.Click;
  if VerboseMode then Log('TfrmShadow created');
end;

procedure TfrmShadow.cbPreviewClick(Sender: TObject);
begin
  if (frmUpdating <> 0) or (frmDoc = nil) then Exit;
  if cbPreview.Checked then PreviewChanged else
  begin
    ls.Assign(frmDoc.lsSrc);
    frmDoc.RedrawPaintBox;
  end;
end;

procedure TfrmShadow.FormHide(Sender: TObject);
begin
  Pref_FilterPreview := cbPreview.Checked;
end;

end.
