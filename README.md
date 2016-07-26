# Click v2.4
Simple MATLAB script to automate all components of Clack Whisker Tracker

Uses version 1.1.0d of Whisk (https://openwiki.janelia.org/wiki/display/MyersLab/Whisker+Tracking+Downloads), Python 2.7, and  Matlab 2013a *(The "LoadMeasurements" matlab function included with Whisk only seems to work in matlab 2013a and perhaps older.)

WhiskerTracking should be installed on the Desktop for convenience but not neccessary and movies to be analyzed can exist in any directory as long as the path can be added to the analysis computer.

The user can select any directory and "click" will batch process all tif files within that directory and all it's subdirectories. Movies within the datadir folder are first processed using the parallel batch trace processor provided with the Whisker Tracker.
Then all data files are analyzed, matrix files created for each movie with individual and average whisker figures which are then output to the source datadir folder. In order to recieve precise analysis and minimal tracking issues, the expected number of whiskers per a folder to be analyzed is needed as an argument. This way "click" can process each directory with it's respective whisker information.

If there exists a gap in the data from the whisker tracker being unable to identify whiskers, figures will be created indicating an error per the respective movie and the gap will be replaced with NaN. Also included is a function called "redo" which you can run after filling in the gaps in data via the Whisker Tracker GUI to remake the figures and data with the updated whisker information.

Also included is the "rdir" function written by Thomas Vanaret and Gus Brown, which allows click and redo to process all appropriate files in all subdirectories within the starting directory.
