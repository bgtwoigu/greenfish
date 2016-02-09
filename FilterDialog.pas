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
unit FilterDialog;

{$mode delphi}

interface

uses
  Classes, SysUtils, Dialogs, Forms, Controls, dlgDoc, Layers, BitmapEx;

type
  TFilterDialog = class(TForm)
  public
    // 0 = the form is currently not being updated
    // >0 = ui events should be discarded
    frmUpdating: integer;
    // The current document
    frmDoc: TGraphicFrame;
    // Stores frmDoc.Doc.Pages[frmDoc.ImageIndex].Layers
    ls: TLayers;

    // Information
    // What undo text should be displayed
    UndoText: string; // default: ''
    // Whether the dialog needs a floating selection whose size
    // is equal to that of SelRect
    NeedsApplyTransform: boolean; // default: false

    // Can set values for UndoText and NeedsApplyTransform
    procedure FillInfo; virtual;
    // Override this to provide custom filter behavior
    procedure DoFilter(bm: TBitmap32; Mask: TBitmap1); virtual; abstract;
    // Apply the filter on the layers
    procedure InvokeEffect;
    // Show the filter dialog
    procedure Execute(_frmDoc: TGraphicFrame);

    constructor Create(AOwner: TComponent); override;
  end;

implementation

// TFilterDialog

procedure TFilterDialog.FillInfo;
begin
  UndoText := '';
  NeedsApplyTransform := False;
end;

procedure TFilterDialog.InvokeEffect;
begin
  if frmDoc <> nil then
  begin
    ls.Assign(frmDoc.lsSrc);
    frmDoc.DoFilter(DoFilter);
  end;
end;

procedure TFilterDialog.Execute(_frmDoc: TGraphicFrame);
var
  mr: TModalResult;

begin
  frmDoc := _frmDoc;
  with frmDoc do
    ls := Doc.Pages[ImageIndex].Layers;

  // save image
  frmDoc.lsSave.Assign(ls);
  try
    // create source for filter
    with frmDoc.lsSrc do
    begin
      Assign(ls);
      if (SelState = stFloating) and NeedsApplyTransform then
        ApplySelectionTransform;
    end;

    mr := ShowModal;
    // restore
    ls.Assign(frmDoc.lsSave);

    with frmDoc do
      if mr = mrOk then
      begin
        Modified := True;
        cuFilter(UndoText);
        InvokeEffect;
      end else
        RedrawPaintBox;
  except
    // restore image
    ls.Assign(frmDoc.lsSave);
  end;

  // free the resources
  frmDoc.lsSave.Clear;
  frmDoc.lsSrc.Clear;
end;

constructor TFilterDialog.Create;
begin
  inherited;

  frmUpdating := 0;
  FillInfo;
end;

end.

