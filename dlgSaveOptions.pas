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
unit dlgSaveOptions;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  NumberEdit, AdjustControl, dlgDoc, Layers, DocClass, Jpeg2000, BitmapEx,
  LangPack, Math;

const
  SupportedFileTypes = [iftJPEG, iftJpeg2000];

type

  { TfrmSaveOptions }

  TfrmSaveOptions = class(TForm)
    alQuality: TAdjustLabel;
    bCancel: TButton;
    bOK: TButton;
    bPreview: TButton;
    cbLossless: TCheckBox;
    lFileSize: TLabel;
    neQuality: TNumberEdit;
    procedure bPreviewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    // In which file type we want to save
    // Must be set before calling Execute
    FileType: TImageFileType;
    // This will store the bitmap we want to save
    bmToSave: TBitmap32;

    // see TFilterDialog
    frmDoc: TGraphicFrame;
    ls: TLayers;
  public
    function Execute(_frmDoc: TGraphicFrame; _FileType: TImageFileType): boolean;
  end; 

var
  frmSaveOptions: TfrmSaveOptions;

implementation

{$R *.lfm}

procedure TfrmSaveOptions.bPreviewClick(Sender: TObject);
var
  st: TStream;
  bmLoaded: TBitmap32;

begin
  if frmDoc = nil then Exit;

  // save and reopen image in the specified format
  bmLoaded := TBitmap32.Create;
  try
    st := TMemoryStream.Create;
    try
      Screen.Cursor := crHourGlass;
      try
        case FileType of
          iftJpeg2000: begin
            jp2SaveToStream(bmToSave, st, IfThen(cbLossless.Checked, 0, neQuality.Value));
            st.Position := 0;
            jp2LoadFromStream(bmLoaded, st);
          end;

          iftJpeg: begin
            jpegSaveToStream(bmToSave, st, Round(neQuality.Value));
            st.Position := 0;
            jpegLoadFromStream(bmLoaded, st);
          end;
        end;
      finally
        Screen.Cursor := crDefault;
      end;

      lFileSize.Caption := lpGet('LABEL_FILE_SIZE')+': '+IntToStr(st.Size div 1024)+'K';
    finally
      st.Free;
    end;

    ls.Assign(bmLoaded);
    ls[0].Name := lpGet('B_PREVIEW');
  finally
    bmLoaded.Free;
  end;

  frmDoc.RedrawPaintBox;
end;

procedure TfrmSaveOptions.FormCreate(Sender: TObject);
begin
  bmToSave := TBitmap32.Create;
end;

procedure TfrmSaveOptions.FormDestroy(Sender: TObject);
begin
  bmToSave.Free;
end;

function TfrmSaveOptions.Execute(_frmDoc: TGraphicFrame; _FileType: TImageFileType): boolean;
var
  mr: TModalResult;

begin
  FileType := _FileType;
  if not (FileType in SupportedFileTypes) then Exit(True);

  // prepare form
  Caption := lpGet('SO_TITLE')+' ('+iftDefaultExt[FileType]+')';
  neQuality.Value := IfThen(FileType = iftJpeg2000, 60, 75);
  cbLossless.Enabled := (FileType = iftJpeg2000);
  cbLossless.Checked := False;
  lFileSize.Caption := '';

  frmDoc := _frmDoc;
  bPreview.Visible := Assigned(frmDoc);

  if Assigned(frmDoc) then
  begin
    ls := frmDoc.Doc.Pages[frmDoc.ImageIndex].Layers;

    // save image
    frmDoc.lsSave.Assign(ls);
    try
      // create flattened image
      bmToSave.Assign(ls);

      // create preview
      //bPreview.Click;
      mr := ShowModal;
    finally
      // restore image
      ls.Assign(frmDoc.lsSave);
      frmDoc.RedrawPaintBox;
    end;

    // free the resources
    bmToSave.Resize(0, 0);
    frmDoc.lsSave.Clear;
  end else
  begin
    ls := nil;
    mr := ShowModal;
  end;

  Result := (mr = mrOk);
end;

end.

