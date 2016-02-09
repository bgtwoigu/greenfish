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
unit UndoObject;

interface

uses
  LclIntf, LclType,
  SysUtils, Classes, Graphics, BitmapEx, bmExUtils, Layers, DocClass;

type
  TUndoObject = class(TPersistent)
  public
    Caption: string;

    procedure Perform(Doc: TIconDoc); virtual; abstract;
    // This will return a redo object if Self was an undo object
    // So calling Self.Perform and Inverted.Perform will result in no change
    function Invert(Doc: TIconDoc): TUndoObject; virtual; abstract;
  end;

  TDeletePageUndo = class(TUndoObject)
  protected
    FPageIndex: integer;
    PageData: TDocPage;
  public
    constructor Create(const ACaption: string; Doc: TIconDoc; PageIndex: integer);
    destructor Destroy; override;

    procedure Perform(Doc: TIconDoc); override;
    function Invert(Doc: TIconDoc): TUndoObject; override;
  end;

  TFrameRatesUndo = class(TUndoObject)
  protected
    a: TArrayOfInteger;
  public
    constructor Create(const ACaption: string; Doc: TIconDoc);

    procedure Perform(Doc: TIconDoc); override;
    function Invert(Doc: TIconDoc): TUndoObject; override;
  end;

  THotSpotUndo = class(TUndoObject)
  protected
    FPageIndex: integer;
    FHotSpot: TPoint;
  public
    constructor Create(const ACaption: string; Doc: TIconDoc; PageIndex: integer);

    procedure Perform(Doc: TIconDoc); override;
    function Invert(Doc: TIconDoc): TUndoObject; override;
  end;

  TLayerOrderUndo = class(TUndoObject)
  protected
    FDoc: TIconDoc;
    FPageIndex: integer;

    SelDepth: integer; // selection may be moved as well
  public
    Permutation: TArrayOfInteger;

    constructor Create(const ACaption: string; Doc: TIconDoc; PageIndex: integer);

    procedure Perform(Doc: TIconDoc); override;
    function Invert(Doc: TIconDoc): TUndoObject; override;
  end;

  TLayerPropUndo = class(TUndoObject)
  protected
    FPageIndex, FLayerIndex: integer;
    lp: TLayerProp;
  public
    constructor Create(const ACaption: string; Doc: TIconDoc;
      PageIndex, LayerIndex: integer);
    destructor Destroy; override;

    procedure Perform(Doc: TIconDoc); override;
    function Invert(Doc: TIconDoc): TUndoObject; override;
  end;

  TInsertPageUndo = class(TUndoObject)
  protected
    FPageIndex: integer;
  public
    constructor Create(const ACaption: string; PageIndex: integer);

    procedure Perform(Doc: TIconDoc); override;
    function Invert(Doc: TIconDoc): TUndoObject; override;
  end;

  TMovePageUndo = class(TUndoObject)
  protected
    FIndexFrom, FIndexTo: integer;
  public
    constructor Create(const ACaption: string; IndexFrom, IndexTo: integer);

    procedure Perform(Doc: TIconDoc); override;
    function Invert(Doc: TIconDoc): TUndoObject; override;
  end;

  // -- Can store a layer index and (optionally) layer data
  TLayerSave = class
  private
    FLayerSaved: boolean;
    FLayer: TLayer;

    procedure SetLayerSaved(const Value: boolean);
  public
    Index: integer;

    constructor Create;
    destructor Destroy; override;

    property LayerSaved: boolean read FLayerSaved write SetLayerSaved;
    property Layer: TLayer read FLayer;
  end;

  // This undo object encodes modifications
  // which were done to the layers and selection of a single page
  // and, optionally, to the frame rate

  // Call the LayerChanged/~Deleted/etc. functions
  // in the following order:
  // - changed
  // - inserted
  // - deleted
  // and specify changed/deleted/etc. layer indexes in descending order.

  // Call SelectionChanged if the selection state, Image or Mask was changed
  // Box, Angle and Depth are automatically saved and restored

  // Always create the undo object before operations, e.g. insertion and deletion

  TPageChangeUndo = class(TUndoObject)
  protected
    FDoc: TIconDoc;
    FPageIndex: integer;

    Layers: TList; // list of TLayerSave

    // selection info
    SelSaved: boolean; // whether State, Image and Mask should be used
    SelState: TSelState;
    SelImage: TBitmap32; // can be nil if no snapshot
    SelMask: TBitmap1; // can be nil if no snapshot
    SelBox: TRect; // always saved
    SelAngle: double; // always saved
    SelDepth: integer; // always saved

    // other info
    FrameRate: integer;

    function GetLayer(Index: integer): TLayerSave;
    function PageLayers: TLayers;
  public
    constructor Create(const ACaption: string; Doc: TIconDoc; PageIndex: integer);
    destructor Destroy; override;
    procedure Clear;

    procedure SelectionChanged;
    
    procedure LayerChanged(AIndex: integer);
    procedure LayerDeleted(AIndex: integer);
    procedure LayerInserted(AIndex: integer);

    procedure FrameRateChanged;

    procedure Perform(Doc: TIconDoc); override;
    function Invert(Doc: TIconDoc): TUndoObject; override;
  end;

  // Use this undo object when multiple pages are completely modified
  // e.g. when resizing multiple pages at once
  TMultiPageUndo = class(TUndoObject)
  protected
    // This icon document contains only the modified pages
    FDoc: TIconDoc;
    // Which pages should be overwritten by the pages of FDoc
    FPageIndex: TArrayOfInteger;
  public
    constructor Create(const ACaption: string; Doc: TIconDoc; PageIndex: TArrayOfInteger);
    destructor Destroy; override;

    procedure Perform(Doc: TIconDoc); override;
    function Invert(Doc: TIconDoc): TUndoObject; override;
  end;

implementation

// TDeletePageUndo

constructor TDeletePageUndo.Create;
begin
  inherited Create;

  Caption := ACaption;
  FPageIndex := PageIndex;
  PageData := TDocPage.Create;
  PageData.Assign(Doc.Pages[PageIndex]);
end;

destructor TDeletePageUndo.Destroy;
begin
  PageData.Free;

  inherited;
end;

procedure TDeletePageUndo.Perform;
begin
  Doc.InsertPage(FPageIndex).Assign(PageData);
end;

function TDeletePageUndo.Invert;
begin
  Result := TInsertPageUndo.Create(Caption, FPageIndex);
end;

// TLayerOrderUndo

constructor TLayerOrderUndo.Create;
var
  i: integer;

begin
  inherited Create;

  Caption := ACaption;
  FDoc := Doc;
  FPageIndex := PageIndex;

  with Doc.Pages[PageIndex].Layers do
  begin
    if SelState = stFloating then SelDepth := Selection.Depth;

    SetLength(Permutation, LayerCount);
    for i := 0 to Length(Permutation) - 1 do Permutation[i] := i;
  end;
end;

procedure TLayerOrderUndo.Perform;
var
  i: integer;
  tmp: array of TLayer;
  
begin
  with Doc.Pages[FPageIndex].Layers do
  begin
    SetLength(tmp, LayerCount);
    for i := 0 to LayerCount - 1 do tmp[i] := Layers[i];
    for i := 0 to LayerCount - 1 do Layers[Permutation[i]] := tmp[i];

    if SelState = stFloating then Selection.Depth := SelDepth;
  end;
end;

function TLayerOrderUndo.Invert;
var
  i: integer;
  lou: TLayerOrderUndo;
  
begin
  lou := TLayerOrderUndo.Create(Caption, FDoc, FPageIndex);
  // simply invert the permutation
  for i := 0 to Length(Permutation) - 1 do lou.Permutation[Permutation[i]] := i;

  Result := lou;
end;

// TFrameRatesUndo

constructor TFrameRatesUndo.Create;
var
  i: integer;

begin
  inherited Create;

  Caption := ACaption;

  SetLength(a, Doc.PageCount);
  for i := 0 to Doc.PageCount - 1 do a[i] := Doc.Pages[i].FrameRate;
end;

procedure TFrameRatesUndo.Perform;
var
  i: integer;

begin
  for i := 0 to Doc.PageCount - 1 do Doc.Pages[i].FrameRate := a[i];
end;

function TFrameRatesUndo.Invert;
begin
  Result := TFrameRatesUndo.Create(Caption, Doc);
end;

// THotSpotUndo

constructor THotSpotUndo.Create;
begin
  inherited Create;

  Caption := ACaption;
  FPageIndex := PageIndex;
  FHotSpot := Doc.Pages[PageIndex].HotSpot;
end;

procedure THotSpotUndo.Perform;
begin
  Doc.Pages[FPageIndex].HotSpot := FHotSpot;
end;

function THotSpotUndo.Invert;
begin
  Result := THotSpotUndo.Create(Caption, Doc, FPageIndex);
end;

// TLayerPropUndo

constructor TLayerPropUndo.Create;
begin
  inherited Create;

  Caption := ACaption;
  FPageIndex := PageIndex;
  FLayerIndex := LayerIndex;
  
  lp := TLayerProp.Create;
  lp.Read(Doc.Pages[PageIndex].Layers[LayerIndex]);
end;

destructor TLayerPropUndo.Destroy;
begin
  lp.Free;
  inherited;
end;

procedure TLayerPropUndo.Perform;
begin
  lp.Write(Doc.Pages[FPageIndex].Layers[FLayerIndex]);
end;

function TLayerPropUndo.Invert;
begin
  Result := TLayerPropUndo.Create(Caption, Doc, FPageIndex, FLayerIndex);
end;

// TInsertPageUndo

constructor TInsertPageUndo.Create;
begin
  inherited Create;

  Caption := ACaption;
  FPageIndex := PageIndex;
end;

procedure TInsertPageUndo.Perform;
begin
  Doc.DeletePage(FPageIndex);
end;

function TInsertPageUndo.Invert;
begin
  Result := TDeletePageUndo.Create(Caption, Doc, FPageIndex);
end;

// TMovePageUndo

constructor TMovePageUndo.Create;
begin
  inherited Create;

  Caption := ACaption;
  FIndexFrom := IndexFrom;
  FIndexTo := IndexTo;
end;

procedure TMovePageUndo.Perform;
begin
  Doc.MovePage(FIndexTo, FIndexFrom);
end;

function TMovePageUndo.Invert;
begin
  Result := TMovePageUndo.Create(Caption, FIndexTo, FIndexFrom);
end;

// TLayerSave

procedure TLayerSave.SetLayerSaved;
begin
  if FLayerSaved <> Value then
  begin
    FLayerSaved := Value;
    if Value then FLayer := TLayer.Create else FLayer.Free;
  end;
end;

constructor TLayerSave.Create;
begin
  Index := 0;

  FLayerSaved := False;
  FLayer := nil;
end;

destructor TLayerSave.Destroy;
begin
  if Assigned(FLayer) then FLayer.Free;

  inherited;
end;

// TPageChangeUndo

function TPageChangeUndo.GetLayer;
begin
  Result := Layers[Index];
end;

function TPageChangeUndo.PageLayers;
begin
  Result := FDoc.Pages[FPageIndex].Layers;
end;

constructor TPageChangeUndo.Create;
var
  i: integer;
  ls: TLayerSave;

begin
  inherited Create;

  Caption := ACaption;
  FDoc := Doc;
  FPageIndex := PageIndex;

  Layers := TList.Create;

  SelSaved := False;
  SelImage := nil;
  SelMask := nil;
  with PageLayers.Selection do
  begin
    SelBox := Box;
    SelAngle := Angle;
    SelDepth := Depth;
  end;

  FrameRate := -1;

  // default
  for i := 0 to PageLayers.LayerCount - 1 do
  begin
    ls := TLayerSave.Create;
    ls.Index := i;
    Layers.Add(ls);
  end;
end;

destructor TPageChangeUndo.Destroy;
begin
  Clear;
  Layers.Free;

  inherited;
end;

procedure TPageChangeUndo.Clear;
var
  i: integer;

begin
  for i := 0 to Layers.Count - 1 do GetLayer(i).Free;
  Layers.Clear;

  SelSaved := False;
  if Assigned(SelImage) then FreeAndNil(SelImage);
  if Assigned(SelMask) then FreeAndNil(SelMask);

  FrameRate := -1;
end;

procedure TPageChangeUndo.SelectionChanged;
begin
  if not SelSaved then
  begin
    SelSaved := True;
    SelState := PageLayers.SelState;

    if SelState = stFloating then
    begin
      if not Assigned(SelImage) then SelImage := TBitmap32.Create;
      SelImage.Assign(PageLayers.Selection.Image);
    end else
    if SelState = stSelecting then
    begin
      if not Assigned(SelMask) then SelMask := TBitmap1.Create;
      SelMask.Assign(PageLayers.Selection.Mask);
    end;
  end;
end;

procedure TPageChangeUndo.LayerChanged;
var
  i: integer;

begin
  for i := 0 to Layers.Count - 1 do with GetLayer(i) do
    if Index = AIndex then
  begin
    if not LayerSaved then
    begin
      LayerSaved := True;
      Layer.Assign(PageLayers[Index]);
    end;
    
    Break;
  end;
end;

procedure TPageChangeUndo.LayerDeleted;
var
  i, j: integer;

begin
  for i := 0 to Layers.Count - 1 do with GetLayer(i) do
    if Index = AIndex then
  begin
    if not LayerSaved then
    begin
      LayerSaved := True;
      Layer.Assign(PageLayers[Index]);

      // shift all following indexes
      for j := i + 1 to Layers.Count - 1 do dec(GetLayer(j).Index);
    end;

    Break;
  end;
end;

procedure TPageChangeUndo.LayerInserted;
var
  i: integer;

begin
  for i := 0 to Layers.Count - 1 do with GetLayer(i) do
    if Index >= AIndex then inc(Index);
end;

procedure TPageChangeUndo.FrameRateChanged;
begin
  FrameRate := FDoc.Pages[FPageIndex].FrameRate;
end;

procedure TPageChangeUndo.Perform;
var
  i: integer;
  lsOrig, ls: TLayers;
  l: TLayer;

begin
  lsOrig := Doc.Pages[FPageIndex].Layers;

  ls := TLayers.Create;
  try
    // perform on layers
    if Layers.Count = 0 then
      ls.Resize(lsOrig.Width, lsOrig.Height) else
    begin
      for i := 0 to Layers.Count - 1 do
      begin
        with GetLayer(i) do
          if LayerSaved then
            l := Layer else
            l := lsOrig[Index];

        ls.NewLayer.Assign(l);
      end; // for i in Layers

      // set correct dimension fields
      with ls.Layers[0].Image do ls.Resize(Width, Height);
    end;

    // perform on selection
    if SelSaved then
    begin
      ls.SelState := SelState;
      case SelState of
        stSelecting: ls.Selection.Mask.Assign(SelMask);
        stFloating: ls.Selection.Image.Assign(SelImage);
      end;
    end else
    begin
      ls.SelState := lsOrig.SelState;
      ls.Selection.Assign(lsOrig.Selection);
    end;

    with ls.Selection do
    begin
      Box := SelBox;
      Angle := SelAngle;
      Depth := SelDepth;
    end;

    // re-assign
    lsOrig.Assign(ls);
  finally
    ls.Free;
  end;

  // other fields
  if FrameRate >= 0 then Doc.Pages[FPageIndex].FrameRate := FrameRate;
end;

function TPageChangeUndo.Invert;
var
  i, j: integer;
  Found: boolean;
  lsOrig: TLayers;
  lu: TPageChangeUndo;
  lso: TLayerSave;

begin
  lu := TPageChangeUndo.Create(Caption, Doc, FPageIndex);

  lu.Clear;

  lsOrig := Doc.Pages[FPageIndex].Layers;
  for i := 0 to lsOrig.LayerCount - 1 do
  begin
    lso := TLayerSave.Create;

    // search
    Found := False;
    for j := 0 to Layers.Count - 1 do with GetLayer(j) do
      if (Index = i) and not LayerSaved then
    begin
      lso.Index := j;
      Found := True;
      Break;
    end;

    // save layer
    if not Found then
    begin
      lso.LayerSaved := True;
      lso.Layer.Assign(lsOrig[i]);
    end;

    lu.Layers.Add(lso);
  end;

  // selection
  if SelSaved then lu.SelectionChanged;

  // other
  if FrameRate >= 0 then lu.FrameRateChanged;

  Result := lu;
end;

// TMultiPageUndo

constructor TMultiPageUndo.Create;
var
  i: integer;

begin
  inherited Create;

  Caption := ACaption;
  FPageIndex := Copy(PageIndex);

  // save pages
  FDoc := TIconDoc.Create;
  for i := 0 to Length(FPageIndex) do
    FDoc.NewPage.Assign(Doc.Pages[FPageIndex[i]]);
end;

destructor TMultiPageUndo.Destroy;
begin
  FDoc.Free;
  inherited;
end;

procedure TMultiPageUndo.Perform;
var
  i: integer;

begin
  for i := 0 to Length(FPageIndex) - 1 do
    Doc.Pages[FPageIndex[i]].Assign(FDoc.Pages[i]);
end;

function TMultiPageUndo.Invert;
begin
  Result := TMultiPageUndo.Create(Caption, Doc, FPageIndex);
end;

end.

