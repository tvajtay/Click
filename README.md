# Click v1.1
Simple MATLAB script to automate all components of Clack Whisker Tracker

Uses version 1.1.0d of Clack Whisker Tracker and Matlab 2013

WhiskerTracking should be installed on the Desktop

Movies within the datadir folder are first processed using the parallel batch trace processor provided with the Whisker Tracker.
Then all data files are analyzed, matrix files created for each movie with individual and average whisker figures which are then outputted to the original datadir folder. Make sure the LoadMeasurements script and dependencies are in WhiskerTracking directory and not residing in lower directories.

If there exists a gap in the data from the whisker tracker losing track, figures will be created indicating an error per the respective movie. Also included is a function called "redo" which you can run after filling in the gaps in data via the Whisker Tracker GUI to remake the figures without re-running the Clack Whisker Tracker.

*You can now specify any datadir path to be analyzed. 
