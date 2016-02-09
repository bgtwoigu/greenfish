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
unit DocClass;

interface

uses
  SysUtils, Classes, Graphics, BitmapEx, bmExUtils, Layers,
  Math, PixelFormats, BlendModes;

type
  TDocPage = class(TPersistent)
  public
    Layers: TLayers;
    HotSpot: TPoint;
    FrameRate: integer; // in millisecs (if animated)

    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Src: TPersistent); override;
  end;

  TImageFileType = (iftNone, iftGfie, iftIco, iftCur, iftAni, iftIcns,
    iftPng, iftXpm, iftBmp, iftJpeg, iftGif, iftJpeg2000, iftPcx);

const
  iftDefaultExt: array[TImageFileType] of string =
    ('', '.gfie', '.ico', '.cur', '.ani', '.icns',
      '.png', '.xpm', '.bmp', '.jpg', '.gif', '.jp2', '.pcx');

type
  TieDataLoss = (dlMultiPage, dlLayers, dlSize256, dlTransparency, dlColorDepth,
    dlIcns);
  TieDataLosses = set of TieDataLoss;

  TIconDocMetadata = record
    Title, Author, Copyright, Comments: string; // Ani
    LoopCount: integer; // Gif
  end;

const
  mdDefault: TIconDocMetadata =
    (Title: ''; Author: ''; Copyright: ''; Comments: '';
     LoopCount: 0);

type
  TIconDoc = class(TPersistent)
  private
    FPages: TList; // of TDocPage
    
    function GetPage(Index: integer): TDocPage;
    procedure SetPage(Index: integer; const Value: TDocPage);
  public
    Metadata: TIconDocMetadata;

    constructor Create; virtual;
    destructor Destroy; override;
    procedure Assign(Src: TPersistent); override;
    procedure Append(Src: TIconDoc);
    procedure Clear;

    function PageCount: integer;
    function NewPage: TDocPage;
    function InsertPage(Index: integer): TDocPage;
    procedure DeletePage(Index: integer);
    procedure MovePage(Src, Dest: integer);

    procedure GetThumbnail(Size: integer; bm: TBitmap32; Antialias: boolean);

    // MaxWidth and MaxHeight are ignored if reading ICO, CUR or ANI file
    function LoadFromStream(s: TStream;
      MaxWidth, MaxHeight: integer;
      const DefaultLayerName: string): TImageFileType;
    procedure SaveToStream(s: TStream; FileType: TImageFileType;
      PNGLimit: integer; const xpmID: string; Quality: single; Lossless: boolean;
      out DataLoss: TieDataLosses);

    function LoadFromFile(const fn: string;
      MaxWidth, MaxHeight: integer;
      const DefaultLayerName: string): TImageFileType;
    procedure SaveToFile(const fn: string; FileType: TImageFileType;
      PNGLimit: integer; const xpmID: string; Quality: single; Lossless: boolean;
      out DataLoss: TieDataLosses);

    // WARNING: avoid SetPage when possible (when using it, the old page won't be freed)
    property Pages[Index: integer]: TDocPage read GetPage write SetPage; default;
  end;

// Detects file type from stream contents
function DetectImageFileType(s: TStream): TImageFileType;
// Detects file type from extension of filename
function DetectImageFileTypeFromName(const fn: string): TImageFileType;
function PNGCompressIcon(w, h, Limit: integer): boolean;

implementation

uses
  GFIEFormat, ICO, ANI, ICNS, PNG, XPM, BMP, GIF, Jpeg2000, PCX;

function DetectImageFileType;
const
  MAX_HEADER_SIZE = 100;

var
  oldPos, HeaderSize: integer;
  Header: array[0..MAX_HEADER_SIZE-1] of byte;

begin
  Result := iftNone;
  try
    oldPos := s.Position;
    HeaderSize := s.Read(Header, MAX_HEADER_SIZE);
    s.Position := oldPos;

    if gfieDetect(@Header, HeaderSize) then Result := iftGfie else
    if icoDetect(@Header, HeaderSize, False) then Result := iftIco else
    if icoDetect(@Header, HeaderSize, True) then Result := iftCur else
    if aniDetect(@Header, HeaderSize) then Result := iftAni else
    if icnsDetect(@Header, HeaderSize) then Result := iftIcns else
    if pngDetect(@Header, HeaderSize) then Result := iftPng else
    if xpmDetect(@Header, HeaderSize) then Result := iftXpm else
    if bmpDetect(@Header, HeaderSize) then Result := iftBmp else
    if jpegDetect(@Header, HeaderSize) then Result := iftJpeg else
    if gifDetect(@Header, HeaderSize) then Result := iftGif else
    if jp2Detect(@Header, HeaderSize) then Result := iftJpeg2000 else
    if pcxDetect(@Header, HeaderSize) then Result := iftPcx;
  except
  end;
end;

function DetectImageFileTypeFromName;
var
  Ext: string;

begin
  Ext := UpperCase(ExtractFileExt(fn));

  if (Ext = '.GFIE') or (Ext = '.GFI') then Result := iftGfie else

  if Ext = '.ICO' then Result := iftIco else
  if Ext = '.CUR' then Result := iftCur else
  if Ext = '.ANI' then Result := iftAni else
  if Ext = '.ICNS' then Result := iftIcns else

  if Ext = '.PNG' then Result := iftPng else
  if Ext = '.XPM' then Result := iftXpm else
  if Ext = '.BMP' then Result := iftBmp else
  if (Ext = '.JPG') or (Ext = '.JPEG') or (Ext = '.JPE') then Result := iftJpeg else
  if Ext = '.GIF' then Result := iftGif else
  if (Ext = '.JP2') or (Ext = '.J2K') or (Ext = '.JPF') or (Ext = '.JPX') then
    Result := iftJpeg2000 else
  if Ext = '.PCX' then Result := iftPcx else

    Result := iftNone;
end;

function PNGCompressIcon;
begin
  Result := (w >= Limit) or (h >= Limit);
end;

// TDocPage

constructor TDocPage.Create;
begin
  inherited;

  Layers := TLayers.Create;
  HotSpot := Point(0, 0);
  FrameRate := 0;
end;

destructor TDocPage.Destroy;
begin
  Layers.Free;

  inherited;
end;

procedure TDocPage.Assign;
var
  x: TDocPage;

begin
  if Src is TDocPage then
  begin
    x := Src as TDocPage;

    Layers.Assign(x.Layers);
    HotSpot := x.HotSpot;
    FrameRate := x.FrameRate;
  end else
    inherited;
end;

// TIconDoc

function TIconDoc.GetPage;
begin
  Result := FPages[Index];
end;

procedure TIconDoc.SetPage;
begin
  FPages[Index] := Value;
end;

constructor TIconDoc.Create;
begin
  inherited;

  FPages := TList.Create;
  Clear;
end;

destructor TIconDoc.Destroy;
begin
  Clear;
  FPages.Free;

  inherited;
end;

procedure TIconDoc.Assign;
var
  i: integer;
  x: TIconDoc;

begin
  if Src is TIconDoc then
  begin
    x := Src as TIconDoc;

    // copy all pages
    Clear;
    for i := 0 to x.PageCount - 1 do NewPage.Assign(x.Pages[i]);

    // copy metadata
    Metadata := x.Metadata;
  end else
    inherited;
end;

procedure TIconDoc.Append;
var
  i: integer;

begin
  for i := 0 to Src.PageCount - 1 do
    NewPage.Assign(Src.Pages[i]);
end;

procedure TIconDoc.Clear;
var
  i: integer;
  
begin
  for i := 0 to PageCount - 1 do Pages[i].Free;
  FPages.Clear;
  Metadata := mdDefault;
end;

function TIconDoc.PageCount;
begin
  Result := FPages.Count;
end;

function TIconDoc.NewPage;
begin
  Result := InsertPage(PageCount);
end;

function TIconDoc.InsertPage;
begin
  Result := TDocPage.Create;
  FPages.Insert(Index, Result);
end;

procedure TIconDoc.DeletePage;
begin
  Pages[Index].Free;
  FPages.Delete(Index);
end;

procedure TIconDoc.MovePage;
begin
  FPages.Move(Src, Dest);
end;

procedure TIconDoc.GetThumbnail;
var
  i: integer;
  b1, b2: boolean;
  pgBest, pg: TDocPage;
  bmTemp: TBitmap32;
  
begin
  // No pages?
  if PageCount = 0 then
  begin
    bm.Resize(Size, Size);
    bm.FillColor(cl32Transparent);
    Exit;
  end;

  // We have to find the smallest page, which is larger or equal to Size
  // If there is no such page, we have to find the greatest page
  pgBest := Pages[0];
  for i := 1 to PageCount - 1 do
  begin
    pg := Pages[i];
    b1 := pg.Layers.Width >= Size;
    b2 := pg.Layers.Width > pgBest.Layers.Width;

    if (b1 and (not b2 or (pgBest.Layers.Width < Size))) or
      (not b1 and b2) then pgBest := pg;
  end;

  bmTemp := TBitmap32.Create;
  try
    bmTemp.Assign(pgBest.Layers);
    bm.CreateThumbnail(bmTemp, Size, Antialias);
  finally
    bmTemp.Free;
  end;
end;

function TIconDoc.LoadFromStream;
var
  i, j: integer;
  Page: TDocPage;
  bm: TBitmap32;
  FileType: TImageFileType;

begin
  Result := iftNone;
  try
    FileType := DetectImageFileType(s);
    if FileType = iftNone then Exit;

    case FileType of
      iftGfie: if not gfieLoadFromStream(Self, s, MaxWidth, MaxHeight) then Exit;

      iftIco, iftCur: if not icoLoadFromStream(Self, s) then Exit;
      iftAni: if not aniLoadFromStream(Self, s) then Exit;
      iftIcns: if not icnsLoadFromStream(Self, s) then Exit;

      // single-page image files
      iftPng, iftXpm, iftBmp, iftJpeg, iftJpeg2000, iftPcx: begin
        Clear;
        Page := NewPage;

        bm := TBitmap32.Create;
        try
          case FileType of
            iftPng: if not pngLoadFromStream(bm, s) then Exit;
            iftXpm: if not xpmLoadFromStream(bm, Page.HotSpot, s) then Exit;
            iftBmp: if not bmpLoadFromStream(bm, s) then Exit;
            iftJpeg: if not jpegLoadFromStream(bm, s) then Exit;
            iftJpeg2000: if not jp2LoadFromStream(bm, s) then Exit;
            iftPcx: if not pcxLoadFromStream(bm, s) then Exit;
          end; // case ft, if single-page

          bm.Resize(Min(bm.Width, MaxWidth), Min(bm.Height, MaxHeight));
          Page.Layers.Assign(bm);
        finally
          bm.Free;
        end;
      end; // case single-page

      iftGif: if not gifLoadFromStream(Self, s, MaxWidth, MaxHeight) then Exit;
    end; // case FileType

    if FileType <> iftGfie then
    // rename layers
    for i := 0 to PageCount - 1 do
    for j := 0 to Pages[i].Layers.LayerCount - 1 do
      Pages[i].Layers[j].Name := DefaultLayerName;

    // success
    Result := FileType;
  except
  end;
end;

procedure TIconDoc.SaveToStream;
var
  i: integer;
  ColorLoss, Transparent: boolean;
  pt: TPoint;
  bm, bmFirst: TBitmap32;
  DroppedPages: TicnsDroppedPages;

begin
  // Determine which parts of data will be lost to inform the user
  DataLoss := [];

  for i := 0 to PageCount - 1 do with Pages[i].Layers do
  begin
    if (FileType in [iftIco, iftCur, iftAni]) and
      ((Width > 256) or (Height > 256)) then
    DataLoss += [dlSize256];

    if (FileType <> iftGfie) and not ( (LayerCount = 1) and
      Layers[0].Visible and (Layers[0].Opacity = $ff) and
      (Layers[0].BlendMode = bmNormal) ) then
    DataLoss += [dlLayers];
  end;

  // one-page file formats
  if FileType in [iftPng, iftXpm, iftBmp, iftJpeg, iftJpeg2000, iftPcx] then
  begin
    if PageCount <> 1 then DataLoss += [dlMultiPage];

    bmFirst := TBitmap32.Create;
    if PageCount > 0 then
      bmFirst.Assign(Pages[0].Layers);
  end else
    bmFirst := nil;

  try // for bmFirst
    if (FileType in [iftJpeg, iftPcx]) and bmFirst.HasTransparency then
      DataLoss += [dlTransparency];

    ColorLoss := False;
    case FileType of
      iftXpm: ColorLoss := (GetPixelFormat32(bmFirst, nil, nil, nil, nil) = pf32_32bit);

      iftGif: begin
        bm := TBitmap32.Create;
        try
          for i := 0 to PageCount - 1 do
          begin
            bm.Assign(Pages[i].Layers);
            if not gifGet256Colors(bm, nil, Transparent) then
            begin
              ColorLoss := True;
              Break;
            end;
          end; // for i
        finally
          bm.Free;
        end;
      end;
    end;
    if ColorLoss then DataLoss += [dlColorDepth];

    case FileType of
      iftNone: begin end;

      iftGfie: gfieSaveToStream(Self, s);

      iftIco, iftCur: icoSaveToStream(Self, s, FileType = iftCur, PNGLimit);
      iftAni: aniSaveToStream(Self, s, PNGLimit);

      iftIcns: begin
        icnsSaveToStream(Self, s, DroppedPages);
        if Length(DroppedPages) > 0 then DataLoss += [dlIcns];
      end;

      iftPng: pngSaveToStream(bmFirst, s, PNG_COMPRESSION_HIGH);
      iftXpm: begin
        if PageCount > 0 then pt := Pages[0].HotSpot else pt := Point(0, 0);
        xpmSaveToStream(bmFirst, xpmID, pt, s);
      end;
      iftBmp: bmpSaveToStream(bmFirst, s);
      iftJpeg: jpegSaveToStream(bmFirst, s, Round(Quality));
      iftGif: gifSaveToStream(Self, s);
      iftJpeg2000: jp2SaveToStream(bmFirst, s, IfThen(Lossless, 0, Quality));
      iftPcx: pcxSaveToStream(bmFirst, s);
    end; // case FileType
  finally
    if Assigned(bmFirst) then bmFirst.Free;
  end;
end;

function TIconDoc.LoadFromFile;
var
  s: TStream;

begin
  Result := iftNone;
  try
    s := TFileStream.Create(fn, fmOpenRead);
    try
      Result := LoadFromStream(s, MaxWidth, MaxHeight, DefaultLayerName);
    finally
      s.Free;
    end;
  except
  end;
end;

procedure TIconDoc.SaveToFile;
var
  s: TStream;

begin
  s := TFileStream.Create(fn, fmCreate);
  try
    SaveToStream(s, FileType, PNGLimit, xpmID, Quality, Lossless, DataLoss);
  finally
    s.Free;
  end;
end;

end.

