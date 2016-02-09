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
unit Jpeg2000;

interface

uses
  LclIntf, LclType, CIntf, SysUtils, Classes, Graphics, BitmapEx;

// TODO: check if other JPEG types exist
const
  FCC_JFIF = $4649464a;
  FCC_Exif = $66697845;

function jp2Detect(Data: Pointer; Size: integer): boolean;
function jp2LoadFromStream(bm: TBitmap32; s: TStream): boolean;
// Quality is the Peak Signal to Noise Ratio. If Quality=0, then
// image is saved as lossless JPEG 2000
procedure jp2SaveToStream(bm: TBitmap32; s: TStream; Quality: single);

function jpegDetect(Data: Pointer; Size: integer): boolean;
function jpegLoadFromStream(bm: TBitmap32; s: TStream): boolean;
procedure jpegSaveToStream(bm: TBitmap32; s: TStream; Quality: integer);

implementation

function jp2Detect;
begin
  Result := (Size >= 8) and
    (PInteger(Data)^ = $0c000000) and (PIntegerArray(Data)[1] = $2020506a);
end;

function jp2LoadFromStream;
var
  TotalSize, w, h: integer;
  Data: array of byte;
  jp2bm: Pointer;

begin
  Result := False;
  try
    // TODO: maybe we shouldn't load the whole stream to memory...
    TotalSize := s.Size - s.Position;
    SetLength(Data, TotalSize);
    s.ReadBuffer(Data[0], TotalSize);

    // try to convert
    if not jp2Load(jp2bm, w, h, @Data[0], TotalSize) then Exit;
    try
      bm.Resize(w, h);
      Move(jp2bm^, bm.Data^, w*h*4);
    finally
      jp2Free(jp2bm);
    end;

    // success
    Result := True;
  except
  end;
end;

procedure jp2SaveToStream;
var
  p: Pointer;
  DataSize: integer;

begin
  if jp2Save(bm.Data, bm.Width, bm.Height, Quality, p, DataSize) then
  try
    s.WriteBuffer(p^, DataSize);
  finally
    jp2Free(p);
  end;
end;

function jpegDetect;
begin
  Result := (Size >= 4) and (PInteger(Data)^ and $00ffffff = $00ffd8ff);
end;

function jpegLoadFromStream;
var
  objBitmap: TBitmap;
  objJPEG: TJPEGImage;

begin
  Result := False;
  try
    objBitmap := TBitmap.Create;
    try
      objJPEG := TJPEGImage.Create;
      try
        objJPEG.LoadFromStream(s);
        objBitmap.Assign(objJPEG);
      finally
        objJPEG.Free;
      end;

      bm.Assign(objBitmap);
    finally
      objBitmap.Free;
    end;

    // success
    Result := True;
  except
  end;
end;

procedure jpegSaveToStream;
var
  objBitmap: TBitmap;

begin
  // save on a white background
  objBitmap := TBitmap.Create;
  try
    bm.ToBitmap(objBitmap, clWhite);

    with TJPEGImage.Create do
    try
      CompressionQuality := Quality;
      Assign(objBitmap);
      SaveToStream(s);
    finally
      Free;
    end; // try JPEG
  finally
    objBitmap.Free;
  end;
end;

end.

