# How to run it?

	java -Xmx1G -Xss32m -jar rascal.jar

(This will start a console). If you have a Rascal source module File.rsc with this function:

	public void main(list[str] args)

You can run it from the comman line by typing:

	java -Xmx1G -Xss32m -jar rascal.jar File.rsc arg1 arg2 …

# Where to get it?

The most recent release of Rascal Shell is to be found at: http://www.rascal-mpl.org/Rascal/Commandline

# How to make it yourself?

- check out the rascal-shell project
- find the RascalShell class and select 'Run As Java Program'
- edit the run configuration to use more stack and heap space: -Xss32m -Xmx1000m
- select the rascal-shell project and choose "Export ..." from the context menu
- select Java->Runnable jar, this starts a wizard
- select your newly made run configuration from the top dropdown box
- type an export destination, like ``/Users/jurgenv/Desktop/rascal-0.4.20.jar``
- select "Package required libraries into generated jar"
- press "Finish"
- an error dialog pops up; read the messages and ignore all "class file compiled with compiler warnings", but review the other messages
- when satisfied, press "Ok", which brings you back to the main wizard.
- now press "Cancel", and the jar will still be where you exported it to
- test it
- deploy
