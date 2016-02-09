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
unit dlgToolbar;

interface

uses
  LclIntf, LclType,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, ieShared, Layers, ComCtrls;

type

  { TToolbarFrame }

  TToolbarFrame = class(TFrame)
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FrameMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sbClick(Sender: TObject);
  private
    FDrawTool: TDrawTool;

    procedure SetDrawTool(const Value: TDrawTool);
  public
    sb: array[TDrawTool] of TSpeedButton;
    PrevTool: TDrawTool;

    constructor Create(AOwner: TComponent); override;
    property DrawTool: TDrawTool read FDrawTool write SetDrawTool;
  end;

implementation

uses dlgDoc, Main, dlgText, dlgToolSet;

{$R *.lfm}

const
  tbButtonSize = 34;
  tbGap = 6;

procedure TToolbarFrame.SetDrawTool(const Value: TDrawTool);
var
  i: integer;
  ts: TTabSheet;
  
begin
  if FDrawTool <> Value then
  begin
    // Cease drawing
    for i := 0 to frmMain.pc.PageCount - 1 do
    begin
      ts := frmMain.pc.Pages[i];
      if (ts is TDocumentTab) and (TDocumentTab(ts).Frame is TGraphicFrame) then
        TGraphicFrame(TDocumentTab(ts).Frame).ma := iemaNone;
    end; // for i

    // check the button
    sb[Value].Down := True;
    // save previous tool
    PrevTool := FDrawTool;
    // write the value
    FDrawTool := Value;

    frmMain.frmToolSet.UpdateLayout(DrawTool);

    if DrawTool <> dtText then frmText.Visible := False;

    for i := 0 to frmMain.pc.PageCount - 1 do
    begin
      ts := frmMain.pc.Pages[i];
      if (ts is TDocumentTab) and (TDocumentTab(ts).Frame is TGraphicFrame) then
      with TGraphicFrame(TDocumentTab(ts).Frame) do
      begin
        if DrawTool = dtTransform then
        with Doc.Pages[ImageIndex].Layers do
          if (SelState = stSelecting) and (SelectedCount <> 0) then
        begin
          cuCreateFloating('UNDO_CREATE_FLOATING');
          CreateFloatingSelection;
        end;

        // redraw if needed
        if ts = frmMain.pc.ActivePage then RedrawPaintBox;
      end; // with frm
    end; // for i
  end;
end;

constructor TToolbarFrame.Create(AOwner: TComponent);
var
  sbTop: integer;
  dt: TDrawTool;

begin
  inherited;

  // create the speedbuttons
  // Last TDrawTool is dtNone, do not create a button for it !!!
  for dt in TDrawTool do
  if dt <> dtNone then
  begin
    sb[dt] := TSpeedButton.Create(Self);

    with sb[dt] do
    begin
      Parent := Self;

      sbTop := tbGap + Ord(dt) div 2 * tbButtonSize;
      if dt >= dtCrop then inc(sbTop, 3*tbGap);
      if dt >= dtRect then inc(sbTop, 3*tbGap);
      SetBounds(tbGap + Ord(dt) mod 2 * tbButtonSize, sbTop,
        tbButtonSize, tbButtonSize);

      GroupIndex := 1;
      Down := dt = dtSelRect;
      Flat := True;
      GetToolGlyph(Glyph, dt);
      // the Hint property will be set by LangPack.lpApplyToUI
      ShowHint := True;
      Tag := Ord(dt);

      OnClick := sbClick;
      OnMouseMove := ControlMouseMove;
    end;
  end;

  FDrawTool := dtSelRect;
  PrevTool := DrawTool;
end;

procedure TToolbarFrame.ControlMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  frmMain.SetStatus(TControl(Sender).Hint);
end;

procedure TToolbarFrame.FrameMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  frmMain.SetStatus('');
end;

procedure TToolbarFrame.sbClick(Sender: TObject);
begin
  DrawTool := TDrawTool(TComponent(Sender).Tag);
end;

end.

