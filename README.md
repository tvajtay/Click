# Click v1.0
Simple MATLAB script to automate all components of Clack Whisker Tracker

Uses version 1.1.0d of Clack Whisker Tracker and Matlab 2013

WhiskerTracking should be installed on the Desktop

Movies placed in a data folder are first processed using the parallel batch trace processor provided with the Whisker Tracker.
Then all data files are analyzed, and matrix files created for each movie with individual and average whisker figures.

If there exists a gap in the data from the whisker tracker losing track, figures will be created indicating an error per the respective movie. Also included is a function called "redo" which you can run after filling in the gaps in data via the Whisker Tracker GUI to remake the figures without the running the Clack Whisker Tracker.
