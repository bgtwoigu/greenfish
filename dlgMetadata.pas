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
unit dlgMetadata;

interface

uses
  LclIntf, LclType,
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, dlgDoc, NumberEdit, AdjustControl;

type
  TfrmMetadata = class(TForm)
    gbSummary: TGroupBox;
    lTitle: TLabel;
    lAuthor: TLabel;
    lCopyright: TLabel;
    lComments: TLabel;
    eTitle: TEdit;
    eAuthor: TEdit;
    eCopyright: TEdit;
    mComments: TMemo;
    bOK: TButton;
    bCancel: TButton;
    gbGIF: TGroupBox;
    alLoopCount: TAdjustLabel;
    neLoopCount: TNumberEdit;
  private
    { Private declarations }
  public
    procedure Execute(frmDoc: TGraphicFrame);
  end;

var
  frmMetadata: TfrmMetadata;

implementation

{$R *.lfm}

procedure TfrmMetadata.Execute;
begin
  with frmDoc.Doc.Metadata do
  begin
    eTitle.Text := Title;
    eAuthor.Text := Author;
    eCopyright.Text := Copyright;
    mComments.Text := Comments;
    neLoopCount.Value := LoopCount;

    if ShowModal = mrOk then
    begin
      Title := eTitle.Text;
      Author := eAuthor.Text;
      Copyright := eCopyright.Text;
      Comments := mComments.Text;
      LoopCount := Round(neLoopCount.Value);

      frmDoc.Modified := True;
    end;
  end;
end;

end.
