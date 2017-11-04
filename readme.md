# mmase-159065_annotated-lecture-slides

Code from mathematica.stackexchange question:  [https://mathematica.stackexchange.com/questions/159065/automatic-edx-pdf-handout-creator](https://mathematica.stackexchange.com/questions/159065/automatic-edx-pdf-handout-creator)

**Of course, forks and pull requests are welcome!**

So far I've just made the original post's code run on my machine.

Hopefully I've made it easy for someone else to set everything up on their
machine.

Note that the code initially (and currently) took ~1300 seconds to run on my
machine (Win10 i7 8Gb ram, running MMA version 11.2).  About 1200 seconds of
that was importing video files.  It took about 400 seconds to import the
framerate and 700 seconds to import the video frames.

## Progress

Here's what I've done so far:

* Started by pasting OP's code
* Made it easy to specify input and output files/directories
* Added displays of timing after each of OP's code chunks
* Note that the code currently runs in ~1300 seconds on my machine
  * ~1200 seconds is reading the videos
    * ~400 seconds getting the framerate (this seems strange...)
	* ~700 seconds importing video frames

