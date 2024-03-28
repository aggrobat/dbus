import subprocess

# Define the command and its arguments
command = "dbus-send"
msg = "Hello, beautiful world!"
arguments = ["--session", "--type=signal", "/", "com.example.greeting.GreetingSignal", "string:" + msg]

# Execute the command with arguments. command is in brackets because it is a list. Why is it not just a string? Becasue
# the command is a list of strings, where the first element is the command and the rest are arguments.
subprocess.run([command] + arguments)