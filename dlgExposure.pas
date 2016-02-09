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
unit dlgExposure;

interface

uses
  LclIntf, LclType,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, NumberEdit, DocClass, BitmapEx,
  Filters, FilterDialog;

type
  TfrmExposure = class(TFilterDialog)
    lGamma: TLabel;
    tbGamma: TTrackBar;
    neGamma: TNumberEdit;
    lBrightness: TLabel;
    tbBrightness: TTrackBar;
    neBrightness: TNumberEdit;
    bOK: TButton;
    bCancel: TButton;
    bReset: TButton;
    procedure FormCreate(Sender: TObject);
    procedure neGammaChange(Sender: TObject);
    procedure tbGammaChange(Sender: TObject);
    procedure neBrightnessChange(Sender: TObject);
    procedure tbBrightnessChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bResetClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure FillInfo; override;
    procedure DoFilter(bm: TBitmap32; Mask: TBitmap1); override;
  end;

var
  frmExposure: TfrmExposure;

implementation

{$R *.lfm}

procedure TfrmExposure.FillInfo;
begin
  inherited;
  UndoText := 'MI_FLT_EXPOSURE';
end;

procedure TfrmExposure.DoFilter;
begin
  fltExposure(bm, Mask, bm.ClientRect, neGamma.Value, neBrightness.Value);
end;

procedure TfrmExposure.FormCreate(Sender: TObject);
begin
  frmUpdating := 0;
end;

procedure TfrmExposure.neGammaChange(Sender: TObject);
begin
  if frmUpdating = 0 then
  begin
    inc(frmUpdating);
      tbGamma.Position := Round(Ln(neGamma.Value) / Ln(10) * tbGamma.Max);
    dec(frmUpdating);

    InvokeEffect;
  end;
end;

procedure TfrmExposure.tbGammaChange(Sender: TObject);
begin
  if frmUpdating = 0 then
  begin
    inc(frmUpdating);
      neGamma.Value := Exp(Ln(10) * tbGamma.Position / tbGamma.Max);
    dec(frmUpdating);

    InvokeEffect;
  end;
end;

procedure TfrmExposure.neBrightnessChange(Sender: TObject);
begin
  if frmUpdating = 0 then
  begin
    inc(frmUpdating);
      tbBrightness.Position := Round(neBrightness.Value * tbBrightness.Max);
    dec(frmUpdating);

    InvokeEffect;
  end;
end;

procedure TfrmExposure.tbBrightnessChange(Sender: TObject);
begin
  if frmUpdating = 0 then
  begin
    inc(frmUpdating);
      neBrightness.Value := tbBrightness.Position / tbBrightness.Max;
    dec(frmUpdating);

    InvokeEffect;
  end;
end;

procedure TfrmExposure.FormShow(Sender: TObject);
begin
  InvokeEffect;
end;

procedure TfrmExposure.bResetClick(Sender: TObject);
begin
  tbGamma.Position := 0;
  tbBrightness.Position := 0;
end;

end.

