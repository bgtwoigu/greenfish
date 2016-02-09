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
unit dlgOpacity;

interface

uses
  LclIntf, LclType,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdjustControl, NumberEdit,
  Layers, DocClass, BitmapEx, Filters, FilterDialog;

type
  TfrmOpacity = class(TFilterDialog)
    bOK: TButton;
    bCancel: TButton;
    neOpacity: TNumberEdit;
    alOpacity: TAdjustLabel;
    procedure neOpacityChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    procedure FillInfo; override;
    procedure DoFilter(bm: TBitmap32; Mask: TBitmap1); override;
  end;

var
  frmOpacity: TfrmOpacity;

implementation

{$R *.lfm}

procedure TfrmOpacity.FillInfo;
begin
  inherited;
  UndoText := 'MI_FLT_OPACITY';
end;

procedure TfrmOpacity.DoFilter;
begin
  fltOpacity(bm, Mask, Round(neOpacity.Value * 2.56));
end;

procedure TfrmOpacity.neOpacityChange(Sender: TObject);
begin
  InvokeEffect;
end;

procedure TfrmOpacity.FormShow(Sender: TObject);
begin
  InvokeEffect;
end;

end.
