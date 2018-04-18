# Photo Dupe Finder
Greg Kennedy 2012

Got dupes?  I did.  And various photo-manip tools had added their own EXIF headers over the years, but left the original data unchanged.  So I wrote a tool (mainly shelling out to `jpegtran`) to find them.

**There are much better photo duplicate finders out there - including some that use visual similarity - but this worked for me.**

Identifies duplicate photos by image data:
* strips EXIF info and converts to optimize + progressive
* before performing MD5 on image data

## Requires "jpegtran" application from libjpeg project
Mac users: http://www.phpied.com/installing-jpegtran-mac-unix-linux/
