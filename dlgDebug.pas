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
unit dlgDebug;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

const
  EnableDebug = True;

type

  { TfrmDebug }

  TfrmDebug = class(TForm)
    m: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public

  end; 

var
  frmDebug: TfrmDebug;
  VerboseMode: boolean = False;

procedure Log(const s: string = ''); overload;
procedure Log(const i: integer); overload;
procedure Log(const Fmt: string; const Args: array of const); overload;

implementation

{$R *.lfm}

procedure Log(const s: string);
begin
  if not EnableDebug then Exit;
  frmDebug.m.Lines.Add(s);
  frmDebug.Visible := True;
end;

procedure Log(const i: integer);
begin
  Log(IntToStr(i));
end;

procedure Log(const Fmt: string; const Args: array of const);
begin
  Log(Format(Fmt, Args));
end;

{ TfrmDebug }

procedure TfrmDebug.FormCreate(Sender: TObject);
begin
  if VerboseMode then Log('TfrmDebug created');
end;

end.

