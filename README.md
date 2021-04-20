# RasPi-Pico-Build-Loader
Windows Bat script to load the uf2 file onto the Pico.
## Requirements
- An existing and functional Pico dev environment.
- stdio enabled for usb in your CMakeLists.txt file.
## How to use
1. Create a new task in Task Scheduler named "LoadFileOntoPico" that runs load.bat.
This task should be setup so that it can only be run manually (i.e. no schedule).
2. Download and install putty from putty.org. 
3. Add the following to your CMakeLists.txt file:
See the file example file provided with in this repo. It was pulled from a working project.
```make
add_custom_command(TARGET your_projects_target
    # Run after all other rules within the target have been executed
    POST_BUILD
    COMMAND pre-load
    COMMENT "Loading uf2 file onto PICO..."
    VERBATIM
)
```
4. Copy "pre-load.bat" and "load.bat" to your build folder.
5. Update the paths in "load.bat" to match your system. The path to putty.exe and the .uf2 file you want to load must be updated for this to work on your system.
6. Update the COM-port number in "load.bat" to match the COM port that shows up when you plug in your Pico.
7. Update the drive letter at the end of the line to whatever drive letter your Pico shows up as: (drive "i:" in my case)
```bat
copy "P:\Documents\RasPi Pico\i2c slave testing\build\i2c_slave_test.uf2" i:
```
8. Click the build button (or run make directly) and wait. A command prompt window should pop up, and right before it exits, you should see "1 file copied successfully" (or something very similar). If this doesn't show up, something when awry. 

## How it works
Within the Pico-SDK there's a secret BAUD that will reset the Pico and boot it into the uf2 loader. By default it's 1200 baud. As long as you haven't messed with this special sauce, it should work without any modifications to your code.

The lines added to CMakeLists.txt tells Make to run "COMMAND pre-load" each time the project is built. "pre-load.bat" then runs the task "LoadFileOntoPico" using the Task Schedule command line. The task runs load.bat. 

The intermediary step of using Task Scheduler, instead of just running load.bat directly, is required to keep Make from stalling. This would happen because Make monitors sub-processes that are started by any part of the make preocess in order to ensure that each step completes before starting another. 

But because this script starts putty to monitor serial traffic at the end of load.bat, Make would wait for putty to exit before, itself, exiting. But, using Task Scheduler means that load.bat is started as a sub-process of svchost.exe, which Make can't/doesn't monitor. "pre-load.bat" finishes and Make continues happily along without stalling. And your uf2 file gets copied to your Pico.

load.bat peforms the following:
1. Kill any instances of putty.exe to ensure that the serial port will be available (your should also make sure you don't have another program using the COM port for your Pico).
2. Start putty with options set for the Pico's com port and 1200 baud.
3. Kill putty again. When putty connects at 1200baud, the Pico resets and putty shows an error. This step kills putty just so the user doesn't have to click the error window. 
4. Copy the uf2 file to the drive that the Pico shows up as.
5. Start putty to connect to the Pico to display serial output.

The "TIMEOUT" lines in "load.bat" are there to give each step time to complete. The whole process takes about 10 seconds to load the uf2 onto the Pico, but it could be faster if you tune the TIMEOUTs in your configuration. 
You can remove the last START if you don't want putty starting back up after loading the file.

## TODO:
If you're interested in a version that has an easier setup, submit an issue with the label "Better Setup Process". If there's enough interest, I'll figure out an easy UI for setting it up.
