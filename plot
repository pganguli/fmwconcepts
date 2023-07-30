#!/bin/bash
#
# Developed by Fred Weinhaus 12/28/2013 .......... revised 2/10/2018
#
# ------------------------------------------------------------------------------
# 
# Licensing:
# 
# Copyright © Fred Weinhaus
# 
# My scripts are available free of charge for non-commercial use, ONLY.
# 
# For use of my scripts in commercial (for-profit) environments or 
# non-free applications, please contact me (Fred Weinhaus) for 
# licensing arrangements. My email address is fmw at alink dot net.
# 
# If you: 1) redistribute, 2) incorporate any of these scripts into other 
# free applications or 3) reprogram them in another scripting language, 
# then you must contact me for permission, especially if the result might 
# be used in a commercial or for-profit environment.
# 
# My scripts are also subject, in a subordinate manner, to the ImageMagick 
# license, which can be found at: http://www.imagemagick.org/script/license.php
# 
# ------------------------------------------------------------------------------
# 
####
#
# USAGE: plot [-r row] [-c col] [-p process] [-m mode] [-f format] 
# [-n normalize] [-w width] [-h height] [-t ticspace] [-d density] 
# [-x xplotscale] [-y yplotscale] [-F font] [-e expansion ] [-l] 
# [-b brightness] [-g gridmode] [-P preprocess] [-s] infile [outfile]
# USAGE: plot [-help]
#
# OPTIONS:
#
# -r     row            row of image to plot; rows start at 0; default=0
# -c     col            column of image to plot; cols start at 0;
#                       script will use only one of -r or -c, namely, the last  
#                       one specified in the command line; default is -r 0
# -p     process        processing type; choices are graph (g) or histogram (h); 
#                       default=graph
# -m     mode           graph mode; choices are unfilled curve or filled curve; 
#                       default=unfilled
# -f     format         number of graphs; choices are 1 combined or 3 separate 
#                       graphs; default=1
# -n     normalize      y-axis plot normalization (only for format=3 with  
#                       either histogram or graph with yplotscale=minmax); 
#                       choices are global (g) or separate (s); default=global
# -w     width          width of plot; integer>=0 or "image"; a value of 0 is  
#                       the same as "image" (i.e. use the full length of  
#                       the row or column); otherwise resize to width supplied; 
#                       default=256
# -h     height         height of plot; integer>0; default=256
# -t     ticspace       tic/grid separation as a percent of plotscales; 
#                       0<integer<100; nominally 20 or 25; default=25
# -d     density        thickness (strokewidth) of drawn lines; default=1
# -x     xplotscale     max value shown on x axes; choices are integer>0 or 
#                       "image" (i.e. use the full length of the row or column); 
#                       default=image; not used for process=histogram
# -y     yplotscale     max value shown on y axes; choices are integer>0 or 
#                       "image" (2^depth-1; e.g. 255 for 8-bit image) or
#                       "minmax" (image channel minimum and maximum values);
#                       typical values are either 255 (i.e. 8-bit depth) or 
#                       100 (percent); default=image; not used for histogram
# -F     font           font name or path to font file and size to use, 
#                       e.g. "arial,9"; default=medium
# -e     expansion      histogram vertical expansion of the count data; 
#						float>=1; default=1
# -l                    log plot on y axis; process=histogram only
# -b     brightness     background grayscale brightness; 0<=integer<=100; 
#                       0 is black and 100 is white; default=100
# -g     gridmode       mode for grid; choices are front, back, none; 
#                       default=front
# -P     preprocess     preprocess the image to single channel; choices are 
#                       red, green, blue, grayscale or global; 
#                       default is no preprocessing
# -s                    show text list of data to terminal
# outfile             	if not specified, outfile will be named from the 
#                       infile name with _graph.gif appended
#
###
#
# NAME: PLOT 
# 
# PURPOSE: To generates a profile of an image row or column or an image histogram. 
# 
# DESCRIPTION: PROFILE generates an output image which is composed of the 
# separate profiles from each channel of the input image for a given row 
# or column. Alternately the output will the histogram of each channel of 
# the image. If the image is CMYK, then it must be converted to RGB or sRGB 
# prior to running the script.
# 
# 
# OPTIONS: 
# 
# -r row ... ROW is the row of image to plot. Rows start at 0. The default=0.
# 
# -c col ... COL is the column of image to plot. Rows start at 0. The default=0.
# 
# Note, the script will use only one of -r or -c, whichever is the last one  
# specified in the command line. The default is to use -r 0.
#
# -p process ... PROCESS is the processing type. Choices are: graph (g) or 
# histogram (h). When mode=graph, the xplotscale and yplotscale are user 
# specified. When mode=histogram, xplotscale=255 (8-bit data number of bins) 
# and yplotscale is the largest count from all bins. The default=graph.
#
# -m mode ... MODE of graph/histogram. The choices are unfilled (u) or 
# filled (f). Unfilled is simple curve. Filled is curve colored to x-axis. 
# The default=unfilled.
# 
# -f format ... FORMAT is the number of graphs. The choices are: 1 (for one 
# combined plot) or 3 (for three separate stacked plots). When format=3, the 3 
# graphs will be trimmed and padded before stacking. Therefore, the width will 
# be a litte smaller than specified and the height will be little smaller than 
# 3x the specified height. The default=1.
#
# -n normalize ... NORMALIZE is the y-axis plot normalization. This is only   
# useable when format=3 combined with either histogram or with graph plus 
# yplotscale=minmax. The choices are global (g) or separate (s). The
# default=global. Global means to use the maximum count or maximum and minimum 
# graylevel from r,g,b channels for normalizing the y-axis of each plot.  
# Separate means to use each channels maximum count or maximum and minimum 
# graylevel for normalizing its own y-axis in the corresponding plot. The 
# default=global.
# 
# -w width ... WIDTH of plot in pixels. Values are integer>=0 or "image". A 
# value of 0 is the same as "image" (i.e. use the full length of the row or 
# column); otherwise resize to width supplied. The default=256.
# 
# -h height ... HEIGHT of plot in pixels. Values are integer>0. The default=256.
# 
# -t ticspace ... TICSPACE is the tic/grid separation as a percent of the 
# plotscales. Values are 0<integer<100. Nominal values are either 20 or 25. 
# The default=25.
# 
# -d density ... DENSITY is the thickness (strokewidth) of drawn lines. Values 
# are either 1 or 2. The default=1.
#
# -x xplotscale ... XPLOTSCALE is the max value shown on x axes. Values are 
# integer>0 or "image" (i.e. use the full length of the row or column).  
# The default=image. Note this is only relevant to process=graph. For 
# histograms, this is 255 (8-bit image depth).
# 
# -y yplotscale ... YPLOTSCALE is the max value shown on y axes. The choices 
# are integer>0 or "image" (2^depth-1; e.g. 255 for 8-bit image) or "minmax" 
# (image channel minimum and maximum graylevel values). Typical values are 
# either 255 (i.e. 8-bit depth) or 100 (percent). The default=image. Note 
# this is only relevant to process=graph. For histograms, the max value comes 
# from the histogram counts.
# 
# -F font ... FONT name or path to font file and size to use. For example,
# "arial,9". The default=medium.
# 
# -e expansion ... EXPANSION is the histogram count expandion on the graph, 
# so that low counts can be amplified at the expense of saturating high 
# counts. Values are floats greater than or equal to one. The default=1.
# 
# -l .. use LOG base 10 plot on y (count) axis. Only for process=histogram
# 
# -b brightness ... BRIGHTNESS is the background grayscale brightness. Values 
# are 0<=integer<=100. 0 is black and 100 is white. The default=100.
# 
# -g gridmode ... GRIDMODE is the grid setting. The choices are: front (f), 
# back (b), none (n). The default=front.
# 
# -P preprocess ... PREPROCESS the image to convert to single . The choices 
# are red, green, blue, grayscale or global. The default is no preprocessing.
# 
# -s ... SHOW text list of data to terminal
# 
# REQUIREMENTS: Needs GNUPLOT (4.6). I cannot guarantee it will work on older 
# versions, but it may. Also libgd is needed by GNUPLOT for proper rendering 
# of fonts in PNG output. The GDFONTPATH environment variable should then be 
# set to your fonts location and that put in your PATH. The script may also 
# work without libgd by setting the font argument to a specific font and size 
# or to "". But that has not been tested.
#
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
#

# set default values
line="Row"
lineval=0
process="graph"			# graph or histogram
mode="unfilled"			# unfilled or filled curves; default=unfilled
format=1				# 1 (combined) or 3 (stacked) graphs
normalize="global"		# histogram count normalization for format=3; global or separate; default=global
width=256				# image means use appropriate image dimension; otherwise scale to size specified; default=image
height=256				# 256 matches bit depth; otherwise, if larger, it may stairstep; default=256
ticspace=25				# percent of plotscale; 20 or 25 or 50; default=25
density=1				# line thickness; 1 or 2; default=1
xplotscale="image"		# value (nominally 100 or 255) or image (appropriate dimension); default=image; process=graph only
yplotscale="image"		# value (nominally 100 or 255) or image (2^depth - 1) or minmax (actual range); default=image; process=graph only
font="medium"           # font or font path and size or medium or ""
expansion=1				# histogram count expansion factor
logplot="no"			# histogram log plot of counts
brightness=100			# background brightness for mode=filled and format=1; 0<=integer<=100
gridmode="front"		# display grid in front or behind data or none; front or back for mode=filled and format=1
preprocess=""			# preprocess to single channel; red, green, blue, grayscale, global
show="no"				# show data list at terminal

# set directory for temporary files
dir="."    # suggestions are dir="." or dir="/tmp"

# set up functions to report Usage and Usage with Description
PROGNAME=`type $0 | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname $PROGNAME`            # extract directory of program
PROGNAME=`basename $PROGNAME`          # base name of program
usage1() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^###/g;  /^#/!q;  s/^#//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}
usage2() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -e '1,/^####/d;  /^######/g;  /^#/!q;  s/^#*//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}

# function to report error messages
errMsg()
	{
	echo ""
	echo $1
	echo ""
	usage1
	exit 1
	}

# function to test for minus at start of value of second part of option 1 or 2
checkMinus()
	{
	test=`echo "$1" | grep -c '^-.*$'`   # returns 1 if match; 0 otherwise
    [ $test -eq 1 ] && errMsg "$errorMsg"
	}

# test for correct number of arguments and get values
if [ $# -eq 0 ]
	then
	# help information
   echo ""
   usage2
   exit 0
elif [ $# -gt 36 ]
	then
	errMsg "--- TOO MANY ARGUMENTS WERE PROVIDED ---"
else
	while [ $# -gt 0 ]
		do
			# get parameter values
			case "$1" in
		     -help)    # help information
					   echo ""
					   usage2
					   exit 0
					   ;;
				-r)    # get row
					   line="Row"
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID ROW SPECIFICATION ---"
					   checkMinus "$1"
					   lineval=`expr "$1" : '\([0-9]*\)'`
					   [ "$lineval" = "" ] && errMsg "--- ROW=$lineval MUST BE AN INTEGER ---"
					   ;;
				-c)    # get col
					   line="Col"
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID COL SPECIFICATION ---"
					   checkMinus "$1"
					   lineval=`expr "$1" : '\([0-9]*\)'`
					   [ "$lineval" = "" ] && errMsg "--- COL=$lineval MUST BE AN INTEGER ---"
					   ;;
				-p)    # get process
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID PROCESS SPECIFICATION ---"
					   checkMinus "$1"
					   process=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   case "$process" in
					   		graph|g) process="graph" ;;
					   		histogram|h) process="histogram" ;;
					   		*) errMsg "--- PROCESS=$process IS NOT A VALID CHOICE ---" ;;
					   esac
					   ;;
				-m)    # get mode
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID MODE SPECIFICATION ---"
					   checkMinus "$1"
					   mode=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   case "$mode" in
					   		unfilled|u) mode="unfilled" ;;
					   		filled|f) mode="filled" ;;
					   		*) errMsg "--- MODE=$mode IS NOT A VALID CHOICE ---" ;;
					   esac
					   ;;
				-f)    # get format
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID FORMAT SPECIFICATION ---"
					   checkMinus "$1"
					   format=`expr "$1" : '\([13]\)'`
					   [ "$format" = "" ] && errMsg "--- FORMAT=$format MUST BE AN INTEGER ---"
					   [ $format -ne 1 -a $format -ne 3 ] && errMsg "--- FORMAT=$format MUST BE EITHER 1 OR 3 ---"
					   ;;
				-n)    # get normalize
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID NORMALIZE SPECIFICATION ---"
					   checkMinus "$1"
					   normalize=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   case "$normalize" in
					   		global|g) normalize="global" ;;
					   		separate|s) normalize="separate" ;;
					   		*) errMsg "--- NORMALIZE=$normalize IS NOT A VALID CHOICE ---" ;;
					   esac
					   ;;
				-w)    # get width
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID WIDTH SPECIFICATION ---"
					   checkMinus "$1"
					   width=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   width1=`expr "$width" : '\([0-9]*\)'`
					   width2=`expr "$1" : 'image'`
					   [ "$width1" = "" -a "$width2" = "" ] && errMsg "--- WIDTH MUST BE AN INTEGER OR 'IMAGE' ---"
					   [ "$width1" != "" ] && width=$width1
					   [ "$width1" = "0" ] && width="image"
					   ;;
				-h)    # get height
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID HEIGHT SPECIFICATION ---"
					   checkMinus "$1"
					   height=`expr "$1" : '\([0-9]*\)'`
					   [ "$height" = "" ] && errMsg "--- HEIGHT=$height MUST BE AN INTEGER ---"
					   test=`echo "$height < 1" | bc`
					   [ $test -eq 1 ] && errMsg "--- HEIGHT=$height MUST BE A POSITIVE INTEGER ---"
					   ;;
				-t)    # get ticspace
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID TICSPACE SPECIFICATION ---"
					   checkMinus "$1"
					   ticspace=`expr "$1" : '\([0-9]*\)'`
					   [ "$ticspace" = "" ] && errMsg "--- TICSPACE=$ticspace MUST BE AN INTEGER ---"
					   test1=`echo "$ticspace <= 0" | bc`
					   test2=`echo "$ticspace >= 100" | bc`
					   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- TICSPACE=$ticspace MUST BE A POSITIVE INTEGER BETWEEN 1 AND 99 ---"
					   ;;
				-d)    # get density
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID DENSITY SPECIFICATION ---"
					   checkMinus "$1"
					   density=`expr "$1" : '\([12]\)'`
					   [ "$density" = "" ] && errMsg "--- DENSITY=$density MUST BE AN INTEGER ---"
					   [ $density -ne 1 -a $density -ne 2 ] && errMsg "--- DENSITY=$density MUST BE EITHER 1 OR 2 ---"
					   ;;
				-x)    # get xplotscale
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID XPLOTSCALE SPECIFICATION ---"
					   checkMinus "$1"
					   xplotscale=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   xplotscale1=`expr "$xplotscale" : '\([0-9]*\)'`
					   xplotscale2=`expr "$xplotscale" : '\([image]*\)'`
					   [ "$xplotscale1" = "" -a "$xplotscale2" != "image" ] && errMsg "--- XPLOTSCALE MUST BE AN INTEGER OR 'IMAGE' ---"
					   [ "$xplotscale1" != "" ] && xplotscale=$xplotscale1
					   [ "$xplotscale1" = "0" ] && xplotscale="image"
					   [ "$xplotscale2" = "image" ] && xplotscale="image"
					   ;;
				-y)    # get yplotscale
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID YPLOTSCALE SPECIFICATION ---"
					   checkMinus "$1"
					   yplotscale=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   yplotscale1=`expr "$yplotscale" : '\([0-9]*\)'`
					   yplotscale2=`expr "$yplotscale" : '\([image]*\)'`
					   yplotscale3=`expr "$yplotscale" : '\([minmax]*\)'`
					   [ "$yplotscale1" = "" -a "$yplotscale2" != "image" -a "$yplotscale3" != "minmax" ] && errMsg "--- YPLOTSCALE MUST BE AN INTEGER OR 'IMAGE' OR 'MINMAX' ---"
					   [ "$yplotscale1" != "" ] && yplotscale=$yplotscale1
					   [ "$yplotscale1" = "0" ] && yplotscale="image"
					   [ "$yplotscale2" = "image" ] && yplotscale="image"
					   [ "$yplotscale3" = "minmax" ] && yplotscale="minmax"
					   ;;
				-F)    # get font
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID FONT SPECIFICATION ---"
					   checkMinus "$1"
					   font="$1"
					   ;;
				-e)    # get expansion
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID EXPANSION SPECIFICATION ---"
					   checkMinus "$1"
					   expansion=`expr "$1" : '\([.0-9]*\)'`
					   [ "$expansion" = "" ] && errMsg "--- EXPANSION=$expansion MUST BE AN INTEGER ---"
					   test1=`echo "$expansion < 1" | bc`
					   [ $test1 -eq 1 ] && errMsg "--- EXPANSION=$expansion MUST BE A POSITIVE INTEGER GREATER THAN OR EQUAL TO 1 ---"
					   ;;
				-l)    # set log plot
					   logplot="yes" 
					   ;;
				-b)    # get brightness
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID BRIGHTNESS SPECIFICATION ---"
					   checkMinus "$1"
					   brightness=`expr "$1" : '\([0-9]*\)'`
					   [ "$brightness" = "" ] && errMsg "--- BRIGHTNESS=$brightness MUST BE AN INTEGER ---"
					   test1=`echo "$brightness < 0" | bc`
					   test2=`echo "$brightness > 100" | bc`
					   [ $test1 -eq 1 -o $test2 -eq 1 ] && errMsg "--- BRIGHTNESS=$brightness MUST BE A POSITIVE INTEGER BETWEEN 0 AND 100 ---"
					   ;;
				-g)    # get gridmode
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID GRIDMODE SPECIFICATION ---"
					   checkMinus "$1"
					   gridmode=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   case "$gridmode" in
					   		front|f) gridmode="front" ;;
					   		back|b) gridmode="back" ;;
					   		none|n) gridmode="none" ;;
					   		*) errMsg "--- GRIDMODE=$gridmode IS NOT A VALID CHOICE ---" ;;
					   esac
					   ;;
				-P)    # get preprocess
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID PREPROCESS SPECIFICATION ---"
					   checkMinus "$1"
					   preprocess=`echo "$1" | tr "[:upper:]" "[:lower:]"`
					   case "$preprocess" in
					   		red) ;;
					   		green) ;;
					   		blue) ;;
					   		grayscale|gray) preprocess="grayscale" ;;
					   		global) ;;
					   		*) errMsg "--- PREPROCESS=$preprocess IS NOT A VALID CHOICE ---" ;;
					   esac
					   ;;
				-s)    # set show
					   show="yes" 
					   ;;
				 -)    # STDIN and end of arguments
					   break
					   ;;
				-*)    # any other - argument
					   errMsg "--- UNKNOWN OPTION ---"
					   ;;
				*)     # end of arguments
					   break
					   ;;
			esac
			shift   # next option
	done
	#
	# get infile and outfile
	infile="$1"
	outfile="$2"
fi
#
# test that infile provided
[ "$infile" = "" ] && errMsg "NO INPUT FILE SPECIFIED"
# test that outfile provided
if [ "$outfile" = "" ]
	then
	# get infile name before suffix
	inname=`convert "$infile" -format "%t" info:`
	gg="_graph"
	outfile="$inname$gg.gif"
fi

# set up tmp files
tmpA1="$dir/plot_1_$$.mpc"
tmpA2="$dir/plot_1_$$.cache"
tmpR="$dir/plot_R_$$.png"
tmpG="$dir/plot_G_$$.png"
tmpB="$dir/plot_B_$$.png"
tmpO="$dir/plot_O_$$.png"
tmpT="$dir/plot_T_$$.txt"
tmpTR="$dir/plot_TR_$$.txt"
tmpTG="$dir/plot_TG_$$.txt"
tmpTB="$dir/plot_TB_$$.txt"
trap "rm -f $tmpA1 $tmpA2 $tmpR $tmpG $tmpB $tmpO $tmpT $tmpTR $tmpTG $tmpTB;" 0
trap "rm -f $tmpA1 $tmpA2 $tmpR $tmpG $tmpB $tmpO $tmpT $tmpTR $tmpTG $tmpTB; exit 1" 1 2 3 15
#trap "rm -f $tmpA1 $tmpA2 $tmpR $tmpG $tmpB $tmpO $tmpT $tmpTR $tmpTG $tmpTB; exit 1" ERR

# setup preprocessing
if [ "$preprocess" = "red" ]; then
	proc="-channel red -separate"
elif [ "$preprocess" = "green" ]; then
	proc="-channel green -separate"
elif [ "$preprocess" = "blue" ]; then
	proc="-channel blue -separate"
elif [ "$preprocess" = "grayscale" ]; then
	proc="-colorspace gray"
elif [ "$preprocess" = "global" ]; then
	proc="-separate -append"
fi

# read the input image into the temporary cached image and test if valid
convert -quiet "$infile" +repage -alpha off $proc "$tmpA1" ||
	errMsg "--- FILE $infile DOES NOT EXIST OR IS NOT AN ORDINARY FILE, NOT READABLE OR HAS ZERO size  ---"

# note: prior to IM 6.9.2.1 txt: values were 0-255 (raw) for depth 8 and percent for Q16, Q32
# but at and after 6.9.2.1 txt: values are raw for Q depth (as they were a long time ago)

# get im version
im_version=`convert -list configure | \
	sed '/^LIB_VERSION_NUMBER */!d; s//,/;  s/,/,0/g;  s/,0*\([0-9][0-9]\)/\1/g' | head -n 1`


if [ "$im_version" -ge "07000000" ]; then
	identifying="magick identify"
else
	identifying="identify"
fi

# limit use of normalize=separate for graph usage
[ "$normalize" = "separate" -a "$process" = "graph" -a "$yplotscale" != "minmax" ] && errMsg "--- NORMALIZE=SEPARATE ONLY VALID FOR YPLOTSCALE=MINMAX ---"


# get colorspace and image depth
data=`$identifying -verbose $tmpA1`
colorspace=`echo "$data" | sed -n 's/^.*Colorspace: \([^ ]*\).*$/\1/p'`
type=`echo "$data" | sed -n 's/^.*Type: \([^ ]*\).*$/\1/p'`
depth=`echo "$data" | sed -n 's/^.*Depth\: \(.*\)$/\1 \1/p' | tr -cs "0-9" " " | sed 's/[ ][ ]*/ /g' | cut -d\  -f1`
drange=`convert xc: -format "%[fx:2^$depth-1]" info:`
qrange=`convert xc: -format "%[fx:quantumrange]" info:`
colormode=$colorspace
if [ "$colorspace" = "CMYK" ]; then
	errMsg "--- IMAGES WITH COLORSPACE=CMYK CANNOT BE PROCESSED, PLEASE CONVERT TO sRGB ---"
elif [ "$colorspace" = "Gray" -o "$type" = "Grayscale" -o "$type" = "Bilevel" ]; then
	colormode="Gray"
else 
	colormode="RGB"
fi
#echo "colormode=$colormode; depth=$depth; drange=$drange; qrange=$qrange;"

# get image width and height
imgwidth=`$identifying -format %w $tmpA1`
imgheight=`$identifying -format %h $tmpA1`


# get size and offset and line of data depending upon row or column
if [ "$line" = "Row" ]
	then 
	size="${imgwidth}x1"
	offset="0+$lineval"
	imgsize=$imgwidth
	rot=""
elif [ "$line" = "Col" ]
	then 
	size="1x${imgheight}"
	offset="$lineval+0"
	imgsize=$imgheight
	rot="-rotate -90"
fi


# set up shrink and width
if [ "$width" = "image" ]; then
	shrink=""
	width=$imgsize
elif [ $width -eq $imgsize ]; then
	shrink=""
	width=$width
elif [ $width -gt 0 ]; then
	shrink="-resize ${width}x1!"
	width=$width
fi
widthm1=$((width-1))
#echo "width=$width; height=$height"

# set up xplotscale
[ "$xplotscale" = "image" ] && xplotscale=$((imgsize-1)) || xplotscale=$xplotscale
#echo "xplotscale=$xplotscale"


# set up xticspace
xticspace=`convert xc: -format "%[fx:($ticspace*$xplotscale/100)]" info:`

# set up font
[ "$font" != "medium" -a "$font" != "" ] && font="font \"$font\""


if [ "$process" = "graph" ]; then

	if [ "$yplotscale" = "image" ]; then
		ymax=$drange
		ymin=0
		yticspace=`convert xc: -format "%[fx:($ticspace*$ymax/100)]" info:`
		yplotscale=$ymax
		rymax=$ymax
		rymin=$ymin
		ryticspace=$yticspace
		ryplotscale=$yplotscale
		gymax=$ymax
		gymin=$ymin
		gyticspace=$yticspace
		gyplotscale=$yplotscale
		bymax=$ymax
		bymin=$ymin
		byticspace=$yticspace
		byplotscale=$yplotscale
		expansion=1

	elif [ "$yplotscale" = "minmax" -a "$normalize" = "separate" ]; then
		rymax=`convert $tmpA1[$size+$offset] -format "%[fx:round(maxima.r*(2^$depth-1))]" info:`
		rymin=`convert $tmpA1[$size+$offset] -format "%[fx:round(minima.r*(2^$depth-1))]" info:`
		ryticspace=`convert xc: -format "%[fx:($ticspace*($rymax-$rymin)/100)]" info:`
		ryplotscale=$rymax
		gymax=`convert $tmpA1[$size+$offset] -format "%[fx:round(maxima.g*(2^$depth-1))]" info:`
		gymin=`convert $tmpA1[$size+$offset] -format "%[fx:round(minima.g*(2^$depth-1))]" info:`
		gyticspace=`convert xc: -format "%[fx:($ticspace*($gymax-$gymin)/100)]" info:`
		gyplotscale=$gymax
		bymax=`convert $tmpA1[$size+$offset] -format "%[fx:round(maxima.b*(2^$depth-1))]" info:`
		bymin=`convert $tmpA1[$size+$offset] -format "%[fx:round(minima.b*(2^$depth-1))]" info:`
		byticspace=`convert xc: -format "%[fx:($ticspace*($bymax-$bymin)/100)]" info:`
		byplotscale=$bymax
		expansion=1

	elif [ "$yplotscale" = "minmax" -a "$normalize" = "global" ]; then
		ymax=`convert $tmpA1[$size+$offset] -format "%[fx:round(maxima*(2^$depth-1))]" info:`
		ymin=`convert $tmpA1[$size+$offset] -format "%[fx:round(minima*(2^$depth-1))]" info:`
		yticspace=`convert xc: -format "%[fx:($ticspace*($ymax-$ymin)/100)]" info:`
		yplotscale=$ymax
		rymax=$ymax
		rymin=$ymin
		ryticspace=$yticspace
		ryplotscale=$yplotscale
		gymax=$ymax
		gymin=$ymin
		gyticspace=$yticspace
		gyplotscale=$yplotscale
		bymax=$ymax
		bymin=$ymin
		byticspace=$yticspace
		byplotscale=$yplotscale
		expansion=1

	else
		ymax=$drange
		ymin=0
		yticspace=`convert xc: -format "%[fx:($ticspace*$yplotscale/100)]" info:`
		rymax=$ymax
		rymin=$ymin
		ryticspace=$yticspace
		ryplotscale=$yplotscale
		gymax=$ymax
		gymin=$ymin
		gyticspace=$yticspace
		gyplotscale=$yplotscale
		bymax=$ymax
		bymin=$ymin
		byticspace=$yticspace
		byplotscale=$yplotscale
		expansion=1
	fi
#echo "depth=$depth; ymax=$ymax; ymin=$ymin; yplotscale=$yplotscale; yticspace=$yticspace;"
#echo "depth=$depth; rymax=$rymax; rymin=$rymin; ryplotscale=$ryplotscale"
#echo "depth=$depth; gymax=$gymax; gymin=$gymin; gyplotscale=$gyplotscale"
#echo "depth=$depth; bymax=$bymax; bymin=$bymin; byplotscale=$byplotscale"


	if [ "$colormode" = "RGB" ]; then
		if [ "$im_version" -ge "06090201" ]; then
			# convert raw values to drange
			convert $tmpA1[$size+$offset] $rot $shrink txt:- |\
				tail -n +2 | sed 's/[ %]*//g' | \
				sed -n 's/^\(.*\),0:[(]\(.*\),\(.*\),\(.*\)[)][ ]*\#.*$/\1 \2 \3 \4/p' |\
				awk -v drange=$drange -v qrange=$qrange ' { print $1, int(drange*$2/qrange), int(drange*$3/qrange), int(drange*$4/qrange); } ' > $tmpT
		
		
		elif [ $depth -eq 8 ]; then
			convert $tmpA1[$size+$offset] $rot $shrink txt:- |\
				tail -n +2 | sed 's/[ %]*//g' | \
				sed -n 's/^\(.*\),0:[(]\(.*\),\(.*\),\(.*\)[)][ ]*\#.*$/\1 \2 \3 \4/p' > $tmpT
		else
			# convert percent values to drange
			convert $tmpA1[$size+$offset] $rot $shrink txt:- |\
				tail -n +2 | sed 's/[ %]*//g' | \
				sed -n 's/^\(.*\),0:[(]\(.*\),\(.*\),\(.*\)[)][ ]*\#.*$/\1 \2 \3 \4/p' |\
				awk -v drange=$drange ' { print $1, int(drange*$2/100), int(drange*$3/100), int(drange*$4/100); } ' > $tmpT
		fi
		
	else
		if [ "$im_version" -ge "06090201" ]; then
			# convert raw values to drange
			convert $tmpA1[$size+$offset] $rot $shrink txt:- |\
				tail -n +2 | sed 's/[ %]*//g' | sed -n 's/^\(.*\),0:[(]\([^,]*\),.*$/\1 \2/p' |\
				awk -v drange=$drange -v qrange=$qrange ' { print $1, int(drange*$2/qrange); } ' > $tmpT
				
		elif [ $depth -eq 8 ]; then
			convert $tmpA1[$size+$offset] $rot $shrink txt:- |\
				tail -n +2 | sed 's/[ %]*//g' | sed -n 's/^\(.*\),0:[(]\([^,]*\),.*$/\1 \2/p' > $tmpT
		else
			# convert percent values to drange
			convert $tmpA1[$size+$offset] $rot $shrink txt:- |\
				tail -n +2 | sed 's/[ %]*//g' | sed -n 's/^\(.*\),0:[(]\([^,]*\),.*$/\1 \2/p' |\
				awk -v drange=$drange ' { print $1, int(drange*$2/100); } ' > $tmpT
		fi
	fi

elif [ "$process" = "histogram" ]; then
	if [ "$colormode" = "RGB" ]; then
		convert $tmpA1 -depth 8 -define histogram:unique-colors=true -format "%c" histogram:info:- \
		| tr -cs '0-9\012' ' ' |\
		awk '
		# AWK to generate a histogram and max count
		{ rbin[int($2)] += $1; rmax = 0; gbin[int($3)] += $1; gmax = 0; bbin[int($4)] += $1; bmax = 0;} 
		{ for (i=0;i<256;i++) { rmax = rbin[i]>rmax?rbin[i]:rmax; 
			gmax = gbin[i]>gmax?gbin[i]:gmax; 
			bmax = bbin[i]>bmax?bbin[i]:bmax; } }
		END { for (i=0;i<256;i++) { rhist = rbin[i]+0; ghist = gbin[i]+0; bhist = bbin[i]+0; 
			print i, rhist, ghist, bhist, rmax, gmax, bmax } } ' > $tmpT

		rymin=0
		rymax=`cat $tmpT | head -n 1 | cut -d\  -f5`
		ryplotscale=$rymax
		ryticspace=`convert xc: -format "%[fx:($ticspace*$ryplotscale/100)]" info:`
		gymin=0
		gymax=`cat $tmpT | head -n 1 | cut -d\  -f6`
		gyplotscale=$gymax
		gyticspace=`convert xc: -format "%[fx:($ticspace*$gyplotscale/100)]" info:`
		bymin=0
		bymax=`cat $tmpT | head -n 1 | cut -d\  -f7`
		byplotscale=$bymax
		byticspace=`convert xc: -format "%[fx:($ticspace*$byplotscale/100)]" info:`
		ymin=0
		ymax=`convert xc: -format "%[fx:max(max($rymax,$gymax),$bymax)]" info:`
		yplotscale=$ymax
		yticspace=`convert xc: -format "%[fx:($ticspace*$yplotscale/100)]" info:`
		xplotscale=255
		xticspace=`convert xc: -format "%[fx:($ticspace*$xplotscale/100)]" info:`
		widthm1=255

	else
		convert $tmpA1 -depth 8 -define histogram:unique-colors=true -format "%c" histogram:info:- \
			| tr -cs '0-9\012' ' ' |\
			awk '
			# AWK to generate a histogram and max count
			{ bin[int($2)] += $1; max = 0; } 
			{ for (i=0;i<256;i++) max = bin[i]>max?bin[i]:max; } 
			END { for (i=0;i<256;i++) { hist = bin[i]+0; print i, hist, max } } ' > $tmpT

		ymin=0
		ymax=`cat $tmpT | head -n 1 | cut -d\  -f3`
		yplotscale=$ymax
		yticspace=`convert xc: -format "%[fx:($ticspace*$yplotscale/100)]" info:`
		xplotscale=255
		xticspace=`convert xc: -format "%[fx:($ticspace*$xplotscale/100)]" info:`
		widthm1=255
	fi 
#echo "depth=$depth; ymax=$ymax; ymin=$ymin; yplotscale=$yplotscale; yticspace=$yticspace;"
#echo "depth=$depth; rymax=$rymax; rymin=$rymin; ryplotscale=$ryplotscale"
#echo "depth=$depth; gymax=$gymax; gymin=$gymin; gyplotscale=$gyplotscale"
#echo "depth=$depth; bymax=$bymax; bymin=$bymin; byplotscale=$byplotscale"
fi


# set up for separate histogram normalization vs global histogram normalization (or anything else)
if [ "$process" = "histogram" -a "$colormode" = "RGB" -a "$normalize" = "separate" ]; then
	ryticspace=`convert xc: -format "%[fx:($ticspace*$ryplotscale/100)]" info:`
	gyticspace=`convert xc: -format "%[fx:($ticspace*$gyplotscale/100)]" info:`
	byticspace=`convert xc: -format "%[fx:($ticspace*$byplotscale/100)]" info:`
elif [ "$process" = "histogram" -a "$colormode" = "RGB" -a "$normalize" = "global" ]; then
	ryticspace=$yticspace
	gyticspace=$yticspace
	byticspace=$yticspace
	ryplotscale=$yplotscale
	gyplotscale=$yplotscale
	byplotscale=$yplotscale
	rymax=$ymax
	gymax=$ymax
	bymax=$ymax
fi
#echo "xticspace=$xticspace; yticspace=$yticspace;"


# list data to terminal
[ "$show" = "yes" ] && cat $tmpT

# set up mode
if [ "$mode" = "unfilled" ]; then
	curve="line"
elif [ "$mode" = "filled" ]; then
	curve="filledcurves below x1"
fi

# set up background color and box/grid/tic color
# find hex equivalent to gray color
graycolor="gray$brightness"
bgcolor=`convert xc:"$graycolor" -depth 8 txt: | tail -n 1 | sed -n 's/^.*[#]\([0-9,a-f,A-F]*\).*$/\#\1/p'`
if [ $brightness -le 60 ]; then
	bgtcolor="white"
else
	bgtcolor="black"
fi
			

# process data to generate output
if [ "$colormode" = "Gray" ]; then
	gnuplot << EOF
	# set terminal size and background color and medium font size
	set terminal png $font size $width,$height background rgb "$bgcolor"
	unset title
	# set border color to white (note each border is a number: 1,2,4,8; so to set them all, just add the numbers, which is 15)
	set border 15 linecolor rgb "$bgtcolor"
	# set tics color and tics print format
	set tics textcolor rgb "$bgtcolor"
	set format x "%4.0f"	
	set format y "%4.0f"	
	# set tics start and spacing
	set xtics 0, $xticspace, $xplotscale
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set ytics 0, log($yticspace), $yplotscale }
	else {
		set ytics 0, $yticspace, $yplotscale }	
	# set grid color and front/back/none mode
	if ( "$gridmode" eq "none" ) {
		set grid noxtics noytics }
	else {
		set grid $gridmode linecolor rgb "$bgtcolor" }
	# set x and y labels and output
	set xlabel 'input' textcolor rgb "$bgtcolor"
	set ylabel 'output' textcolor rgb "$bgtcolor"
	set output "$tmpO"
	unset key
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set logscale y
		set yrange [$ymin+1:$yplotscale] }
	else {
		set yrange [$ymin:$yplotscale] }
	plot "$tmpT" using (\$1*$xplotscale/$widthm1):((\$2*$expansion>$ymax)?$yplotscale:(\$2*$expansion*$yplotscale/$ymax)) with $curve linewidth $density linecolor rgb 'black'
	# EOF must not have any white space before it or does not work
EOF

convert $tmpO "$outfile"


elif [ $format -eq 1 -a "$colormode" = "RGB" -a "$mode" = "unfilled" ]; then
	gnuplot << EOF
	# set terminal size and background color and medium font size
	set terminal png $font size $width,$height background rgb "$bgcolor"
	unset title
	# set border color to white (note each border is a number: 1,2,4,8; so to set them all, just add the numbers, which is 15)
	set border 15 linecolor rgb "$bgtcolor"
	# set tics color and tics print format
	set tics textcolor rgb "$bgtcolor"
	set format x "%4.0f"	
	set format y "%4.0f"	
	# set tics start and spacing
	set xtics 0, $xticspace, $xplotscale
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set ytics 0, log($yticspace), $yplotscale }
	else {
		set ytics 0, $yticspace, $yplotscale }	
	# set grid color and front/back/none mode
	if ( "$gridmode" eq "none" ) {
		set grid noxtics noytics }
	else {
		set grid $gridmode linecolor rgb "$bgtcolor" }
	# set x and y labels and output
	set xlabel 'input' textcolor rgb "$bgtcolor"
	set ylabel 'output' textcolor rgb "$bgtcolor"
	set output "$tmpO"
	unset key
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set logscale y
		set yrange [$ymin+1:$yplotscale] }
	else {
		set yrange [$ymin:$yplotscale] }
	plot "$tmpT" using (\$1*$xplotscale/$widthm1):((\$2*$expansion>$ymax)?$yplotscale:(\$2*$expansion*$yplotscale/$ymax)) with line linewidth $density linecolor rgb 'red', \
		 "$tmpT" using (\$1*$xplotscale/$widthm1):((\$3*$expansion>$ymax)?$yplotscale:(\$3*$expansion*$yplotscale/$ymax)) with line linewidth $density linecolor rgb 'green', \
		 "$tmpT" using (\$1*$xplotscale/$widthm1):((\$4*$expansion>$ymax)?$yplotscale:(\$4*$expansion*$yplotscale/$ymax)) with line linewidth $density linecolor rgb 'blue'
	# EOF must not have any white space before it or does not work
EOF

convert $tmpO "$outfile"


elif [ $format -eq 1 -a "$colormode" = "RGB" -a "$mode" = "filled" ]; then
	# Plot Red
	gnuplot << EOF
	# set terminal size and background color and medium font size
	set terminal png transparent $font size $width,$height 
	unset title
	# set border color to white (note each border is a number: 1,2,4,8; so to set them all, just add the numbers, which is 15)
	set border 15 linecolor rgb "$bgtcolor"
	# set tics color and tics print format
	set tics textcolor rgb "$bgtcolor"
	set format x "%4.0f"	
	set format y "%4.0f"	
	# set tics start and spacing
	set xtics 0, $xticspace, $xplotscale
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set ytics 0, log($yticspace), $yplotscale }
	else {
		set ytics 0, $yticspace, $yplotscale }	
	# set grid color and front/back/none mode
	if ( "$gridmode" eq "none" ) {
		set grid noxtics noytics }
	else {
		set grid $gridmode linecolor rgb "$bgtcolor" }
	# set x and y labels and output
	set xlabel 'input' textcolor rgb "$bgtcolor"
	set ylabel 'output' textcolor rgb "$bgtcolor"
	set output "$tmpR"
	unset key
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set logscale y
		set yrange [$ymin+1:$yplotscale] }
	else {
		set yrange [$ymin:$yplotscale] }
	plot "$tmpT" using (\$1*$xplotscale/$widthm1):((\$2*$expansion>$ymax)?$yplotscale:(\$2*$expansion*$yplotscale/$ymax)) with filledcurves below x1 linecolor rgb 'red'
EOF


	# Plot Green
	gnuplot << EOF
	# set terminal size and background color and medium font size
	set terminal png transparent $font size $width,$height 
	unset title
	# set border color to white (note each border is a number: 1,2,4,8; so to set them all, just add the numbers, which is 15)
	set border 15 linecolor rgb "$bgtcolor"
	# set tics color and tics print format
	set tics textcolor rgb "$bgtcolor"
	set format x "%4.0f"	
	set format y "%4.0f"	
	# set tics start and spacing
	set xtics 0, $xticspace, $xplotscale
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set ytics 0, log($yticspace), $yplotscale }
	else {
		set ytics 0, $yticspace, $yplotscale }	
	# set grid color and front/back/none mode
	if ( "$gridmode" eq "none" ) {
		set grid noxtics noytics }
	else {
		set grid $gridmode linecolor rgb "$bgtcolor" }
	# set x and y labels and output
	set xlabel 'input' textcolor rgb "$bgtcolor"
	set ylabel 'output' textcolor rgb "$bgtcolor"
	set output "$tmpG"
	unset key
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set logscale y
		set yrange [$ymin+1:$yplotscale] }
	else {
		set yrange [$ymin:$yplotscale] }
	plot "$tmpT" using (\$1*$xplotscale/$widthm1):((\$3*$expansion>$ymax)?$yplotscale:(\$3*$expansion*$yplotscale/$ymax)) with filledcurves below x1 linewidth $density linecolor rgb 'green'
EOF


	# Plot Blue
	gnuplot << EOF
	# set terminal size and background color and medium font size
	set terminal png transparent $font size $width,$height
	unset title
	# set border color to white (note each border is a number: 1,2,4,8; so to set them all, just add the numbers, which is 15)
	set border 15 linecolor rgb "$bgtcolor"
	# set tics color and tics print format
	set tics textcolor rgb "$bgtcolor"
	set format x "%4.0f"	
	set format y "%4.0f"	
	# set tics start and spacing
	set xtics 0, $xticspace, $xplotscale
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set ytics 0, log($yticspace), $yplotscale }
	else {
		set ytics 0, $yticspace, $yplotscale }	
	# set grid color and front/back/none mode
	if ( "$gridmode" eq "none" ) {
		set grid noxtics noytics }
	else {
		set grid $gridmode linecolor rgb "$bgtcolor" }
	# set x and y labels and output
	set xlabel 'input' textcolor rgb "$bgtcolor"
	set ylabel 'output' textcolor rgb "$bgtcolor"
	set output "$tmpB"
	unset key
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set logscale y
		set yrange [$ymin+1:$yplotscale] }
	else {
		set yrange [$ymin:$yplotscale] }
	plot "$tmpT" using (\$1*$xplotscale/$widthm1):((\$4*$expansion>$ymax)?$yplotscale:(\$4*$expansion*$yplotscale/$ymax)) with filledcurves below x1 linewidth $density linecolor rgb 'blue'
EOF

	convert $tmpR $tmpG -compose plus -composite $tmpB -compose plus -composite -compose over -background "$bgcolor" -flatten "$outfile"


elif [ $format -eq 3 ]; then

	# Plot Red
	gnuplot << EOF
	# set terminal size and background color and medium font size
	set terminal png $font size $width,$height background rgb "$bgcolor"
	unset title
	# set border color to white (note each border is a number: 1,2,4,8; so to set them all, just add the numbers, which is 15)
	set border 15 linecolor rgb "$bgtcolor"
	# set tics color and tics print format
	set tics textcolor rgb "$bgtcolor"
	set format x "%4.0f"	
	set format y "%4.0f"	
	# set tics start and spacing
	set xtics 0, $xticspace, $xplotscale
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set ytics $rymin, log($ryticspace), $ryplotscale }
	else {
		set ytics $rymin, $ryticspace, $ryplotscale }
	# set grid color and front/back/none mode
	if ( "$gridmode" eq "none" ) {
		set grid noxtics noytics }
	else {
		set grid $gridmode linecolor rgb "$bgtcolor" }
	# set x and y labels and output
	set xlabel 'input' textcolor rgb "$bgtcolor"
	set ylabel 'output' textcolor rgb "$bgtcolor"
	set output "$tmpR"
	unset key
	if ( "$normalize" eq "global" && "$process" eq "histogram" && "$logplot" eq "yes" ) { 
		set logscale y
		set yrange [$ymin+1:$yplotscale] }
	else {
		if ( "$normalize" eq "global" ) { set yrange [$ymin:$yplotscale] } 
		else { set yrange [$rymin:$ryplotscale] } }
	plot "$tmpT" using (\$1*$xplotscale/$widthm1):((\$2*$expansion>$rymax)?$ryplotscale:(\$2*$expansion*$ryplotscale/$rymax)) with $curve linewidth $density linecolor rgb 'red'
EOF


	# Plot Green
	gnuplot << EOF
	# set terminal size and background color and medium font size
	set terminal png $font size $width,$height background rgb "$bgcolor"
	unset title
	# set border color to white (note each border is a number: 1,2,4,8; so to set them all, just add the numbers, which is 15)
	set border 15 linecolor rgb "$bgtcolor"
	# set tics color and x tics print format
	# set tics color and tics print format
	set format x "%4.0f"	
	set format y "%4.0f"	
	# set tics start and spacing
	set xtics 0, $xticspace, $xplotscale
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set ytics $gymin, log($gyticspace), $gyplotscale }
	else {
		set ytics $gymin, $gyticspace, $gyplotscale }
	# set grid color and front/back/none mode
	if ( "$gridmode" eq "none" ) {
		set grid noxtics noytics }
	else {
		set grid $gridmode linecolor rgb "$bgtcolor" }
	# set x and y labels and output
	set xlabel 'input' textcolor rgb "$bgtcolor"
	set ylabel 'output' textcolor rgb "$bgtcolor"
	set output "$tmpG"
	unset key
	if ( "$normalize" eq "global" && "$process" eq "histogram" && "$logplot" eq "yes" ) { 
		set logscale y
		set yrange [$ymin+1:$yplotscale] }
	else {
		if ( "$normalize" eq "global" ) { set yrange [$ymin:$yplotscale] } 
		else { set yrange [$gymin:$gyplotscale] } }
	plot "$tmpT" using (\$1*$xplotscale/$widthm1):((\$3*$expansion>$gymax)?$gyplotscale:(\$3*$expansion*$gyplotscale/$gymax)) with $curve linewidth $density linecolor rgb 'green'
EOF


	# Plot Blue
	gnuplot << EOF
	# set terminal size and background color and medium font size
	set terminal png $font size $width,$height background rgb "$bgcolor"
	unset title
	# set border color to white (note each border is a number: 1,2,4,8; so to set them all, just add the numbers, which is 15)
	set border 15 linecolor rgb "$bgtcolor"
	# set tics color and tics print format
	set tics textcolor rgb "$bgtcolor"
	set format x "%4.0f"	
	set format y "%4.0f"	
	# set tics start and spacing
	set xtics 0, $xticspace, $xplotscale
	if ( "$process" eq "histogram" && "$logplot" eq "yes" ) {
		set ytics $bymin, log($byticspace), $byplotscale }
	else {
		set ytics $bymin, $byticspace, $byplotscale }	
	# set grid color and front/back/none mode
	if ( "$gridmode" eq "none" ) {
		set grid noxtics noytics }
	else {
		set grid $gridmode linecolor rgb "$bgtcolor" }
	# set x and y labels and output
	set xlabel 'input' textcolor rgb "$bgtcolor"
	set ylabel 'output' textcolor rgb "$bgtcolor"
	set output "$tmpB"
	unset key
	if ( "$normalize" eq "global" && "$process" eq "histogram" && "$logplot" eq "yes" ) { 
		set logscale y
		set yrange [$ymin+1:$yplotscale] }
	else {
		if ( "$normalize" eq "global" ) { set yrange [$ymin:$yplotscale] } 
		else { set yrange [$bymin:$byplotscale] } }
	plot "$tmpT" using (\$1*$xplotscale/$widthm1):((\$4*$expansion>$bymax)?$byplotscale:(\$4*$expansion*$byplotscale/$bymax)) with $curve linewidth $density linecolor rgb 'blue'
EOF

	convert $tmpR $tmpG $tmpB -trim +repage -bordercolor white -border 4 -append "$outfile"


fi

exit 0

