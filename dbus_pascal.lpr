program dbus_pascal;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp,
  { you can add units after this. AG: I did, I added dbus}
  dbus, ctypes;

type

  { TDbusApp }

  TDbusApp = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ TDbusApp }

procedure TDbusApp.DoRun;

var
  ErrorMsg: String;
    err: DBusError;
  conn: PDBusConnection;
  ret: cint;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  { add your program here }


  { Initializes the error handling }
  dbus_error_init(@err);

  { Connection }
  conn := dbus_bus_get(DBUS_BUS_SESSION, @err);

  if dbus_error_is_set(@err) <> 0 then
  begin
    WriteLn('Connection Error: ' + err.message);
    dbus_error_free(@err);
  end;

  if conn = nil then Exit;

  { Request the name of the bus }
  ret := dbus_bus_request_name(conn, 'test.method.server', DBUS_NAME_FLAG_REPLACE_EXISTING, @err);

  if dbus_error_is_set(@err) <> 0 then
  begin
    WriteLn('Name Error: ' + err.message);
    dbus_error_free(@err);
  end;

  if ret <> DBUS_REQUEST_NAME_REPLY_PRIMARY_OWNER then Exit;

  // stop program loop
  Terminate;
end;

constructor TDbusApp.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TDbusApp.Destroy;
begin
  inherited Destroy;
end;

procedure TDbusApp.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
  writeln('My Help code');
end;

var
  Application: TDbusApp;
begin
  Application:=TDbusApp.Create(nil);
  Application.Title:='My Application';
  Application.Run;
  Application.Free;
end.

