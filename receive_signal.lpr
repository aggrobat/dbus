program receive_signal;

uses sysutils, dbus;

var
  err                      : DBusError;
  conn                     : PDBusConnection;
  msg                      : PDBusMessage;
  args                     : DBusMessageIter;
  msgValue                 : PChar;
  name                     : PChar;

begin

  // initialise the error value
  dbus_error_init(@err);

  // connect to the DBUS system bus and check for errors
  conn := dbus_bus_get(DBUS_BUS_SESSION, @err);
  if dbus_error_is_set(@err) <> 0 then begin
    writeln('Connection Error :', err.message);
    dbus_error_free(@err);
  end;
  if conn = nil then exit;
  name := 'beliebigerName';
  // dbus_bus_request_name(conn, name, DBUS_NAME_FLAG_DO_NOT_QUEUE, @err);


  // receive signals from interface "com.example.greeting"
  dbus_bus_add_match(conn, 'type=''signal'',interface=''com.example.greeting''', @err);
  dbus_connection_flush(conn);
  if dbus_error_is_set(@err) <> 0 then begin
    writeln('Match error: ', err.message);
    exit;
  end;

  writeln('In a second Terminal window enter the command:');
  writeln('  dbus-send --session --type=signal / com.example.greeting.GreetingSignal string:"hello"');
  writeln;

  // loop listening for signals being emmitted
  while true do begin

    // non blocking read of the next available message
    dbus_connection_read_write(conn, 0);
    msg := dbus_connection_pop_message(conn);

    // loop again if we haven't read a message
    if msg = nil then begin
      sleep(1000);
      continue;
    end;

    // check if the message is a signal from the correct interface and with the correct name
    if dbus_message_is_signal(msg, 'com.example.greeting', 'GreetingSignal') <> 0 then begin

      // read the message
      if dbus_message_iter_init(msg, @args) = 0 then
        writeln('No message text')
      else
      if dbus_message_iter_get_arg_type(@args) <> DBUS_TYPE_STRING then
        writeln('Message is not a string: ' + chr(dbus_message_iter_get_arg_type(@args)))
      else begin
        dbus_message_iter_get_basic(@args, @msgValue);
        writeln('Received: ' + msgValue);
      end;

      // free the message
      dbus_message_unref(msg);

    end;

  end;

  // finish using the connection
  dbus_connection_unref(conn);

end.
