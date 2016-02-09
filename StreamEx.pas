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
unit StreamEx;

interface

uses
  LclIntf, LclType, SysUtils, Classes, Math;

// Buffered stream I/O
const
  DefaultStreamIOBuf = 4096;
  sEndOfStreamError = 'Error: read beyond end of stream';

type
  TBufferedReader = class
  public
    Stream: TStream;
    Buffer: array of byte;
    BytesRead, Position: integer;

    constructor Create(s: TStream); virtual;
    procedure SetBufferSize(i: integer);
    // p can be nil (=skipping Count bytes)
    procedure Read(p: Pointer; Count: integer);
  end;

  TBufferedWriter = class
  public
    Stream: TStream;
    Buffer: array of byte;
    Position: integer;

    constructor Create(s: TStream); virtual;
    destructor Destroy; override;

    procedure SetBufferSize(i: integer);
    procedure Write(p: Pointer; Count: integer);
    procedure Flush;
  end;

function ReadPascalString(s: TStream): string;
procedure WritePascalString(s: TStream; const Text: string);

implementation

function ReadPascalString(s: TStream): string;
var
  Len: byte;

begin
  s.ReadBuffer(Len, SizeOf(Len));
  SetLength(Result, Len);
  s.ReadBuffer(Result[1], Len);
end;

procedure WritePascalString(s: TStream; const Text: string);
var
  Len: byte;

begin
  Len := Min(255, Length(Text));
  s.WriteBuffer(Len, SizeOf(Len));
  s.WriteBuffer(Text[1], Len);
end;

// TBufferedReader

constructor TBufferedReader.Create;
begin
  Stream := s;
  SetBufferSize(DefaultStreamIOBuf);
  Position := 0;
  BytesRead := 0;
end;

procedure TBufferedReader.SetBufferSize;
begin
  SetLength(Buffer, i);
end;

procedure TBufferedReader.Read;
var
  i: integer;

begin
  while Count > 0 do
  begin
    // read new block if needed
    if Position >= BytesRead then
    begin
      Position := 0;
      BytesRead := Stream.Read(Buffer[0], Length(Buffer));
      // can read no more bytes?
      if BytesRead = 0 then raise Exception.Create(sEndOfStreamError);
    end;

    // copy block
    i := Min(Count, BytesRead - Position);
    if Assigned(p) then Move(Buffer[Position], p^, i);

    // iterate
    inc(Position, i);
    if Assigned(p) then inc(PByte(p), i);
    dec(Count, i);
  end;
end;

// TBufferedWriter

constructor TBufferedWriter.Create;
begin
  Stream := s;
  SetBufferSize(DefaultStreamIOBuf);
  Position := 0;
end;

destructor TBufferedWriter.Destroy;
begin
  if Assigned(Stream) then Flush;

  inherited;
end;

procedure TBufferedWriter.SetBufferSize;
begin
  SetLength(Buffer, i);
end;

procedure TBufferedWriter.Write;
begin
  if Count > Length(Buffer) then Stream.WriteBuffer(p^, Count) else
  begin
    if Count > Length(Buffer) - Position then Flush;
    Move(p^, Buffer[Position], Count);
    inc(Position, Count);
  end;
end;

procedure TBufferedWriter.Flush;
begin
  Stream.WriteBuffer(Buffer[0], Position);
  Position := 0;
end;

end.
