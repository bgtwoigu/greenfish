(*
	Greenfish Controls - Double-buffered paint box
	Copyright © 2013 Balázs Szalkai
	This file is released under the zlib license:

	This software is provided 'as-is', without any express or implied
	warranty. In no event will the authors be held liable for any damages
	arising from the use of this software.

	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:

	   1. The origin of this software must not be misrepresented; you must not
	   claim that you wrote the original software. If you use this software
	   in a product, an acknowledgment in the product documentation would be
	   appreciated but is not required.

	   2. Altered source versions must be plainly marked as such, and must not be
	   misrepresented as being the original software.

	   3. This notice may not be removed or altered from any source
	   distribution.
*)
unit DoubleBufPB;

interface

uses
  {$IFNDEF LCL} Windows, Messages,
  {$ELSE} LclIntf, LMessages, LclType, LResources, {$ENDIF}
  SysUtils, Classes, Controls, ExtCtrls, Forms;

type
  TDoubleBufPB = class(TCustomControl)
  private
    FOnPaint: TNotifyEvent;
    FOnSetFocus, FOnKillFocus: TNotifyEvent;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: integer); override;
{$IFNDEF LCL}
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
    procedure WMSetFocus(var Message: TMessage); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TMessage); message WM_KILLFOCUS;
{$ELSE}
    procedure WMGetDlgCode(var Message: TLMNoParams); message LM_GETDLGCODE;
    procedure WMSetFocus(var Message: TLMSetFocus); message LM_SETFOCUS;
    procedure WMKillFocus(var Message: TLMKillFocus); message LM_KILLFOCUS;
{$ENDIF}
  public
    property Canvas;
    constructor Create(AOwner: TComponent); override;
  published
    property OnClick;
    property OnDblClick;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnMouseWheel;
//    property OnMouseEnter;
//    property OnMouseLeave;
    property OnResize;
    
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnSetFocus: TNotifyEvent read FOnSetFocus write FOnSetFocus;
    property OnKillFocus: TNotifyEvent read FOnKillFocus write FOnKillFocus;

    property Anchors;
    property Align;
    property Hint;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
  end;

procedure Register;

implementation

procedure TDoubleBufPB.Paint;
begin
  if Assigned(FOnPaint) then FOnPaint(Self);
end;

procedure TDoubleBufPB.MouseDown;
begin
  inherited;
  if CanFocus then SetFocus;
end;

procedure TDoubleBufPB.WMGetDlgCode;
begin
  Message.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

procedure TDoubleBufPB.WMSetFocus;
begin
  inherited;
  if Assigned(FOnSetFocus) then FOnSetFocus(Self);
end;

procedure TDoubleBufPB.WMKillFocus;
begin
  inherited;
  if Assigned(FOnKillFocus) then FOnKillFocus(Self);
end;

constructor TDoubleBufPB.Create(AOwner: TComponent);
begin
  inherited;

  DoubleBuffered := True;
  FOnPaint := nil;
{$IFDEF LCL}
  ControlStyle := ControlStyle + [csCaptureMouse];
  CaptureMouseButtons := CaptureMouseButtons + [mbLeft, mbRight, mbMiddle];
{$ENDIF}
end;

procedure Register;
begin
  RegisterComponents('Greenfish', [TDoubleBufPB]);
end;

{$IFDEF LCL}
initialization
  {$I DoubleBufPB.lrs}
{$ENDIF}
end.
