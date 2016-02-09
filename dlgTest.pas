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
unit dlgTest;

interface

uses
  LclIntf, LclType,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DoubleBufPB, dlgDoc, DocClass, ExtCtrls,
  bmExUtils, BitmapEx, Buttons, ieShared, Math, FileUtil, Layers, dlgDebug;

type
  TfrmTest = class(TForm)
    gb: TGroupBox;
    pb: TDoubleBufPB;
    tmCursor: TTimer;
    tmAni: TTimer;
    pTop: TPanel;
    sbClear: TSpeedButton;
    sbBgrLoad: TSpeedButton;
    sbBgrDefault: TSpeedButton;
    bClose: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure pbPaint(Sender: TObject);
    procedure pbMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pbMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmCursorTimer(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure tmAniTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure sbClearClick(Sender: TObject);
    procedure sbBgrLoadClick(Sender: TObject);
    procedure sbBgrDefaultClick(Sender: TObject);
  private
    { Private declarations }
  public
    bmBgr, bmSketch: TBitmap;
    pPrev, pCursor: TPoint;
    Drawing: boolean;

    Doc: TIconDoc;
    FrameEnd: TArrayOfInteger;
    ImageIndex, LoopCount: integer;
    timeAniStart: Int64;

    procedure ClearSketch;
    procedure LoadBackground;
    procedure Execute(frmDoc: TGraphicFrame);
  end;

var
  frmTest: TfrmTest;

implementation

uses Main;

{$R *.lfm}

procedure TfrmTest.ClearSketch;
begin
  bmSketch.PixelFormat := pf24bit;
  bmSketch.Width := pb.Width;
  bmSketch.Height := pb.Height;
  bmSketch.Canvas.StretchDraw(Rect(0, 0, bmSketch.Width, bmSketch.Height), bmBgr);

  pb.Repaint;
end;

procedure TfrmTest.LoadBackground;
var
  Success: boolean;
  doc: TIconDoc;
  bx: TBitmap32;

begin
  Success := FileExists(Pref_TestBackground);
  if Success then
  begin
    doc := TIconDoc.Create;
    try
      Success := (doc.LoadFromFile(Pref_TestBackground,
        Pref_MaxWidth, Pref_MaxHeight, '') <> iftNone);
      if Success then
      begin
        bx := TBitmap32.Create;
        try
          bx.Assign(doc.Pages[0].Layers);
          bx.ToBitmap(bmBgr, clWhite);
        finally
          bx.Free;
        end;
      end;
    finally
      doc.Free;
    end;
  end;

  if not Success then
  begin
    bmBgr.PixelFormat := pf24bit;
    bmBgr.Width := 4;
    bmBgr.Height := 1;

    with bmBgr.Canvas do
    begin
      Pixels[0, 0] := clBlack;
      Pixels[1, 0] := clGray;
      Pixels[2, 0] := clSilver;
      Pixels[3, 0] := clWhite;
    end;
  end;
end;

procedure TfrmTest.Execute;
var
  i, t: integer;

begin
  Doc.Assign(frmDoc.Doc);
  for i := 0 to Doc.PageCount - 1 do Doc.Pages[i].Layers.Merge(lssAll);
  
  LoopCount := 0;
  SetLength(FrameEnd, Doc.PageCount);
  t := 0;
  for i := 0 to Doc.PageCount - 1 do with Doc.Pages[i] do
  begin
    if FrameRate <> 0 then LoopCount :=
      IfThen(Doc.Metadata.LoopCount = 0, MaxInt, Doc.Metadata.LoopCount);

    // calculate time constraints of the frame
    inc(t, FrameRate);
    FrameEnd[i] := t;
  end;

  if LoopCount <> 0 then
  begin
    ImageIndex := 0;
    timeAniStart := Int64(GetTickCount64);
  end else
    ImageIndex := frmDoc.ImageIndex;

  ClearSketch;
  pCursor := Point(10, 10);
  Mouse.CursorPos := pb.ClientToScreen(pCursor);
  tmCursor.Enabled := True;
  tmAni.Enabled := LoopCount <> 0;

  ShowModal;
end;

procedure TfrmTest.FormCreate(Sender: TObject);
begin
  // load tool button glyphs
  GetMiscGlyph(sbClear.Glyph, mgDelete);
  GetMiscGlyph(sbBgrLoad.Glyph, mgOpen);
  GetMiscGlyph(sbBgrDefault.Glyph, mgBgrDefault);

  bmBgr := TBitmap.Create;
  bmSketch := TBitmap.Create;
  Doc := TIconDoc.Create;

  pb.Cursor := crNone;
  Drawing := False;

  LoadBackground;

  if VerboseMode then Log('TfrmTest created');
end;

procedure TfrmTest.FormDestroy(Sender: TObject);
begin
  bmBgr.Free;
  bmSketch.Free;
  Doc.Free;
end;

procedure TfrmTest.pbPaint(Sender: TObject);
var
  bmTemp: TBitmap;

begin
  bmTemp := TBitmap.Create;
  try
    //bmTemp.Assign(bmSketch); WORKAROUND this does not work with Lazarus :D
    bmTemp.Width := bmSketch.Width;
    bmTemp.Height := bmSketch.Height;
    bmTemp.PixelFormat := pf24bit;
    bmTemp.Canvas.Draw(0, 0, bmSketch);

    with Doc.Pages[ImageIndex] do
    if Layers.LayerCount >= 1 then
      Layers[0].Image.DrawTo24(bmTemp, pCursor.X - HotSpot.X, pCursor.Y - HotSpot.Y);
    pb.Canvas.Draw(0, 0, bmTemp);
  finally
    bmTemp.Free;
  end;
end;

procedure TfrmTest.pbMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if Drawing then
  with bmSketch.Canvas do
  begin
    Pen.Color := clRed;
    MoveTo(pPrev.X, pPrev.Y);
    pPrev := Point(X, Y);
    LineTo(pPrev.X, pPrev.Y);
  end;

  if (X <> pCursor.X) or (Y <> pCursor.Y) then pCursor := Point(X, Y);

  pb.Repaint;
end;

procedure TfrmTest.pbMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    Drawing := True;
    pPrev := Point(X, Y);
  end;
end;

procedure TfrmTest.pbMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Drawing := False;
end;

procedure TfrmTest.tmCursorTimer(Sender: TObject);
var
  p: TPoint;
  
begin
  p := pb.ScreenToClient(Mouse.CursorPos);
  if (p.X <> pCursor.X) or (p.Y <> pCursor.Y) then
  begin
    pCursor := p;
    pb.Repaint;
  end;
end;

procedure TfrmTest.FormHide(Sender: TObject);
begin
  tmCursor.Enabled := False;
  tmAni.Enabled := False;
end;

procedure TfrmTest.tmAniTimer(Sender: TObject);
var
  AniTicks: Int64;
  
begin
  // the number of msecs elapsed from the beginning of the animation
  AniTicks := Int64(GetTickCount64) - timeAniStart;

  if AniTicks >= FrameEnd[ImageIndex] then
  // next frame
  begin
    while AniTicks >= FrameEnd[ImageIndex] do
    begin
      inc(ImageIndex);
      if ImageIndex >= Doc.PageCount then
      begin
        // loop
        ImageIndex := 0;
        timeAniStart := Int64(GetTickCount64);

        dec(LoopCount);
        if LoopCount = 0 then tmAni.Enabled := False;
        
        Break;
      end;
    end; // while a new frame is needed

    // draw the new frame
    pb.Repaint;
  end;
end;

procedure TfrmTest.FormResize(Sender: TObject);
begin
  ClearSketch;
end;

procedure TfrmTest.sbClearClick(Sender: TObject);
begin
  ClearSketch;
end;

procedure TfrmTest.sbBgrLoadClick(Sender: TObject);
begin
  if frmMain.od.Execute then
  begin
    Pref_TestBackground := UTF8ToSys(frmMain.od.FileName);
    LoadBackground;
    ClearSketch;
  end;
end;

procedure TfrmTest.sbBgrDefaultClick(Sender: TObject);
begin
  Pref_TestBackground := '';
  LoadBackground;
  ClearSketch;
end;

end.
