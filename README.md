# ruby_phrases_changer
This tool allows to you to quick and comfortable changing of phrase in every files in indicated directory (recursively).

This feature provides most comfortable manner to make many changes in many
files in directory. 

It passes recursively by indicated directory and
will ask you step by step if you are sure to change phrase to another phrase
(for instance <? to <?php) in indicated file in indicated place.
If you wish to make all changes at once there is such option of course.
In comparison to phrase changes options in many IDE
you do not be afraid that something will be changed even if you dont wish
unwanted change in some places.
All changes you made you will see in console.
At the end of the process the log file will be generate in logs directory.
The name of the log corresponds to the phrase you are changing.

To use it just set: 
PATH_TO_DIRECTORY, 
WHAT_I_WANT_TO_CHANGE, 
WHAT_I_WANT_TO_RECEIVE
in configuration section in file phrases_changer.rb
and run:
$ ruby phrases_changer.rb

The logic of script have been tested on linux-arch, ruby 2.5.1 version.
Colors of console messages have been tested on zsh (Z Shell).
