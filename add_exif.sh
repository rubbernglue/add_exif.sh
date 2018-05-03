#!/bin/bash

################################################################
#
# Fixa / Adda:
# 
# Posibility to type time (hour:minute) without colons...
#
################################################################

declare DIR=$(dirname "$LIST" | sed s/\'//g)


rm -f "$HOME"/tmp/add_exif/.* 2>/dev/null

REM1=`file "$HOME"/tmp/add_exif/.remove`
REM2=`file "$HOME"/tmp/add_exif/.remove.list`
if [ "$REM1" = 0 -o "$REM2" = 0 ]
  then dialog --title "Remove old file!" --msgbox "I was unable to remove:
$REM1
$REM2" 0 0 ; exit 0
fi

which dialog || 'echo "Package: Dialog not found!"; exit 1'
which exiv2 || 'echo "Package: exiv2 not found!"; exit 1'
#DELDATE=`date +%s`

if [ ! -e $HOME/tmp/add_exif ]
  then dialog --title "About add_exif.sh" --msgbox "
First startup!

Config-dir will be: "$HOME"/.add_exif.config

Please use this script at your own risk, I am not responsible for your data.
This script will create small scripts for each of your images which must be supported by your version of exiv2.

Programs needed in order to run this is:
dialog
exiv2
md5sum (optional, and should be found in /usr/bin )

And of course permission to write in your home directory - it will create the paths:
$HOME/tmp/add_exif and $HOME/.add_exif.config for temporary settings during runtime.

Lenses can be added to $HOME/.add_exi.config/lenses using this format:
M42?AUTO CHINON 1:2.8 f=35mm!35
Where \"?\" and \"!\" is delimiters between mount, lens and focal length.

Best mentioning is that this script does NOT yet work well with filenamed including spaces, I have yet to fix that.

Any questions? Please contact me at johan.g.lindgren@gmail.com
" 25 50

fi

mkdir -p $HOME/.add_exif.config
mkdir -p $HOME/tmp/add_exif
if [ "$?" != 0 ]
  then echo "Attention, problem with 
permissions on $HOME/tmp/add_exif
exiting."
       exit 0
fi


DATE () {

#For removing exif#
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]
 then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
#	echo "removing DATE tag in $X"
       sed --in-place '/Exif.Photo.Date/d' "$X"
     done
else



for D in $(cat $HOME/tmp/add_exif/.list)
do
FULLNAME=$(basename "$D")
FILENAME="${FULLNAME%.*}"
#DEKLARERAD DIR=$(dirname $D | sed s/\'//g)

if [ -e "$HOME"/tmp/add_exif/.datetime ]
   then #echo "Date, same as last? [`cat $HOME/tmp/add_exif/.exiftimehistory`]"
        DATE=`cat $HOME/tmp/add_exif/.datetime | awk '{print $1}'`
        TIME=`cat $HOME/tmp/add_exif/.datetime | awk '{print $2}'`
   else DATE=2016:01:01
        TIME=00:00
fi

DATETIME=$(dialog --title "Date" --inputbox "File: $FILENAME" 0 0 "$DATE $TIME" --output-fd 1)
echo "$DATETIME" > $HOME/tmp/add_exif/.datetime

if [ -e $HOME/tmp/add_exif/.datetime ]
   then #echo "Date, same as last? [`cat $HOME/tmp/add_exif/.exiftimehistory`]"
        DATE=`cat $HOME/tmp/add_exif/.datetime | awk '{print $1}'`
        TIME=`cat $HOME/tmp/add_exif/.datetime | awk '{print $2}'`
fi
	sed --in-place '/Exif.Photo.Date/d' "$DIR"/script.$FILENAME.out
        echo "exiv2 -M\"del Exif.Photo.DateTimeOriginal\"             $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
        echo "exiv2 -M\"set Exif.Photo.DateTimeOriginal $DATE $TIME\" $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
#       echo 'DateTime' >> $HOME/tmp/add_exif/added
#       echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"

done
rm -r $HOME/tmp/add_exif/.datetime
fi
}

DATEOLD () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ] 
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
#	echo "removing DATE tag in $X"
       sed --in-place '/Exif.Photo.Date/d' "$X"
     done
else
for D in $(cat $HOME/tmp/add_exif/.list);
do
FULLNAME=$(basename "$D")
FILENAME="${FULLNAME%.*}"
#DEKLARERAD DIR=$(dirname $D | sed s/\'//g)
	 echo ""
	 echo "------------------------[ $FILENAME ]---------------------"
	 if [ -e $HOME/tmp/add_exif/.exiftimehistory ]
	   then echo "Date, same as last? [`cat $HOME/tmp/.exiftimehistory`]"
	   else echo "Date, ex 2012:12:31"
         fi
         read OUT1
	 if [ -z "$OUT1" ]
	   then OUT1=`cat $HOME/tmp/add_exif/.exiftimehistory 2>/dev/null`
	 fi
	 echo "$OUT1" > $HOME/tmp/add_exif/.exiftimehistory

         echo "Time, ex 13:24"
         read OUT2
         echo "exiv2 -M\"del Exif.Photo.DateTimeOriginal\"             $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
         echo "exiv2 -M\"set Exif.Photo.DateTimeOriginal $OUT1 $OUT2\" $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
	 echo 'DateTime' >> $HOME/tmp/add_exif/added
#	 echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
done
rm -r $HOME/tmp/add_exif/.exiftimehistory
fi
}

DEVEL () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
#	echo "removing DEV tag in $X"
       sed --in-place '/Home\ developed\ using/d' "$X"
       sed --in-place '/Developed\ using/d' "$X"
     done
else while true;
	do
	DEV=$(dialog --title "Which development process?"  --menu "Options:" 25 40 80 \
	"Agfa" "" \
	"Adox" "" \
	"BKA" "" \
	"Compard" "" \
	"Bergger" "" \
	"Foma" "" \
	"Fuji" "" \
	"Kodak" "" \
	"Ilford" "" \
	"Rollei" "" \
	"Moersch" "" \
	"Spur" "" \
	"Tetenal" "" \
	"Homemade developers" "" \
	"Other Developer" "" \
	"Professional Processing" "" --output-fd 1)
	
	case "$DEV" in
	Agfa)dialog --title "Adox"  --menu "Options:" 25 40 80 \
	        ".." "" \
	        "Agfa Rodinal" "" \
		"Agfa Rodinal Special" "" 2>$HOME/tmp/add_exif/.dev;;
	Adox)dialog --title "Adox"  --menu "Options:" 25 40 80 \
	        ".." "" \
	        "Adox Adonal/Rodinal" "" \
		"Adox Atomal 49" "" \
		"Adox FX-39" "" \
		"Adox APH-09" "" \
	        "Adox Silvermax" "" \
	        "Adox Adotech III" "" 2>$HOME/tmp/add_exif/.dev;;
	BKA)dialog --title "BKA"  --menu "Options:" 25 40 80 \
	        ".." "" \
	        "BKA ACU-1" "aka. Acufine" \
	        "BKA Ethol" "" \
	        "BKA Diafine" "" 2>$HOME/tmp/add_exif/.dev;;
	Compard)dialog --title "Compard"  --menu "Options:" 25 40 80 \
		".." "" \
		"Compard r09" "" \
		"Compard r09 Studio" "" \
		"Compard D512" "" \
		"Compard Digibase" "c-41" 2>$HOME/tmp/add_exif/.dev;;
	Bergger)dialog --title "Bergger"  --menu "Options:" 25 40 80 \
	        ".." "" \
	        "Bergger P.M.K." "" \
	        "Bergger BerSpeed" "" 2>$HOME/tmp/add_exif/.dev;;
	Foma)dialog --title "Foma"  --menu "Options:" 25 40 80 \
	        ".." "" \
		"Fomadon r09" "" \
		"Foma Universal" "" \
		"Foma Retro Special" "" \
		"Fomadon Excel W27" "" \
		"Fomadon Excel 37" "" \
	        "Foma Fomadon LQR" \
		"Foma Fomadon LQN" "" 2>$HOME/tmp/add_exif/.dev;;
	Fuji)dialog --title "Fuji" --menu "Options:" 25 40 80 \
		".." "" \
		"Fuji X-Press" "c-41" \
		"Fuji Hunt Chrome" "e-6" 2>$HOME/tmp/add_exif/.dev;;
	Kodak)dialog --title "Kodak"  --menu "Options:" 25 40 80 \
	        ".." "" \
	        "Kodak T-MAX" "" \
	        "Kodak XTOL" "" \
	        "Kodak D-76" "" \
		"Kodak HC-110" "" \
		"Kodak D-11" "" \
	        "Kodak D-19" "" \
	        "Kodak DK-50" "" 2>$HOME/tmp/add_exif/.dev;;
	Ilford)dialog --title "Ilford"  --menu "Options:" 25 40 80 \
	        ".." "" \
	        "Ilford Ilfotec DD-X" "" \
	        "Ilford Ilfotec LC29" "" \
		"Ilford Ilfotec HC" "" \
		"Ilford Ilfosol 3" "" \
	        "Ilford Microphen" "" \
	        "Ilford ID-11" "" \
		"Ilford Perceptol" "" \
		"Ilford PQ Universal" "" 2>$HOME/tmp/add_exif/.dev;;
	Rollei)dialog --title "Rollei"  --menu "Options:" 25 40 80 \
	        ".." "" \
		"Rollei Supergrain" "" \
		"Rollei RPX-D" "" \
		"Rollei RLS" "" \
		"Rollei RLC" "" \
		"Rollei Acurol" "" \
		"Rollei ATP-DC/AB" "" \
	        "Rollei Colorchem" "c-41" 2>$HOME/tmp/add_exif/.dev;;
	Moersch)dialog --title "Moersch"  --menu "Options:" 25 40 80 \
	        ".." "" \
	        "Moersch Finol" "" \
	        "Moersch Tanol" "" \
		"Moersch Tanol Speed" "" \
		"Moersch Eco" "" \
	        "Moerch SE 1 Sepia Positive" "" 2>$HOME/tmp/add_exif/.dev;;
	Spur)dialog --title "Spur"  --menu "Options:" 25 40 80 \
	        ".." "" \
	        "Spur SD 2525" "" \
		"Spur Ultraspeed Vario" "" \
		"Spur Modular UR" "" \
		"Spur HRX" "" \
		"Spur SLD Professional" "" \
		"Spur Acurol-N" "" 2>$HOME/tmp/add_exif/.dev;;
	Tetenal)dialog --title "Tetenal" --menu "Options:" 25 40 80 \
		".." "" \
		"Tetenal Neofin Blue" "" \
		"Tetenal Paranol S" "" \
		"Tetenal Ultrafin T-Plus" "" \
		"Tetenal Ultrafin" "" \
		"Tetenal Colortec" "c-41/e-6" 2>$HOME/tmp/add_exif/.dev;;
	"Homemade developers")dialog --title "Homemade developers"  --menu "Options:" 25 40 80 \
	        ".." "" \
	        "Caffenol C-L" "" \
	        "Caffenol C-M" "" \
		"Caffenol C-M RS" "" \
	        "Caffenol C-H" "" \
		"Caffenol C-H RS" "" \
	        "Beernol" "" \
	        "Winenol" "" 2>$HOME/tmp/add_exif/.dev;;
	'Other Developer')dialog --title "Type your choice of developer properly" --inputbox "(type BACK to go back)

Type ex. Adox Adonal" 12 50 2> $HOME/tmp/add_exif/.dev;;
'Professional Processing')echo "Professional Processing" > $HOME/tmp/add_exif/.dev;;
	esac

	DEV=`cat $HOME/tmp/add_exif/.dev`

	case "$DEV" in
	".."|back|Back|BACK);;
	*)break;;
	esac

	done

	for P in $(cat $HOME/tmp/add_exif/.list);
	  do
	   FULLNAME=$(basename "$P")
	   FILENAME="${FULLNAME%.*}"
#DEKLARERAD	   DIR=$(dirname $P | sed s/\'//g)
	   if [ "$DEV" != "Professional Processing" ]
	     then sed --in-place '/eveloped using/d' "$DIR"/script.$FILENAME.out
	          echo "exiv2 -M\"add Exif.Photo.UserComment Home developed using $DEV\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
	     else echo "exiv2 -M\"add Exif.Photo.UserComment Developed using $DEV\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
	   fi
	   echo 'developed' >> $HOME/tmp/add_exif/added
#	   echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
	 done
fi
}

PROGRAM () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
#	echo "removing PROGRAM tag in $X"
       sed --in-place '/Photo.ExposureProgram/d' "$X"
     done
else

PROGRAMHIST="A"
BEENHERE="no"

while true;
do
 for X in $(cat $HOME/tmp/add_exif/.list);
 do
  FULLNAME=$(basename "$X")
  FILENAME="${FULLNAME%.*}"
#DEKLARERAD  DIR=$(dirname "$X" | sed s/\'//g)
  if [ "$BEENHERE" = "no" ]
	   then PROGRAMHIST=$(dialog --title "Shutter mode" --default-item "$PROGRAMHIST" --menu "File: $FILENAME" 0 0 0 \
	"P" "Program" \
	"S" "Shutter Priority" \
	"A" "Aperture Priority" \
	"M" "Manual" \
	"x" "skip/unknown" --output-fd 1)
         if [ `cat $HOME/tmp/add_exif/.list|wc -l` -gt 1 ]
	 	then dialog --title "Repeat for all?" --yesno "All images with same shutter-setting?" 7 45 --output-fd 1
		     REPEAT=$?
		else REPEAT=0
	 fi
         BEENHERE="yes"
	   else if [ "$REPEAT" != "0" -a "$BEENHERE" = "yes" ]
		  then PROGRAMHIST=$(dialog --title "Shutter mode" --default-item "$PROGRAMHIST" --menu "File: $FILENAME" 0 0 0 \
	"P" "Program" \
	"S" "Shutter Priority" \
	"A" "Aperture Priority" \
	"M" "Manual" \
	"x" "skip/unknown" --output-fd 1)
		fi
  fi	   
  if [ "$PROGRAMHIST" != "x" ]
   then case "$PROGRAMHIST" in
	P)MODE=5;;
	S)MODE=4;;
	A)MODE=3;;
	M)MODE=1;;
	esac
	sed --in-place '/Photo.ExposureProgram/d' "$DIR"/script.$FILENAME.out
	echo "exiv2 -M\"del Exif.Photo.ExposureProgram\"       $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
        echo "exiv2 -M\"set Exif.Photo.ExposureProgram "$MODE"\" $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
  fi
 done; break
done
fi
}

PROGRAMOLD () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ] 
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
#	echo "removing PROGRAM tag in $X"
       sed --in-place '/Photo.ExposureProgram/d' "$X"
     done
else
clear
for X in $(cat $HOME/tmp/add_exif/.list);
do
 FULLNAME=$(basename "$X")
 FILENAME="${FULLNAME%.*}"
#DEKLARERAD DIR=$(dirname $X | sed s/\'//g)
	 echo ""
    	 echo "------------------------[ $FILENAME ]---------------------"

         if [ -e $HOME/tmp/add_exif/.exifprogramhistory ]
           then echo "Program mode, P,A,S or M (or X to skip), `cat $HOME/tmp/add_exif/.exifprogramhistory`? [`cat $HOME/tmp/add_exif/.exifprogramhistory`]"
           else echo "Program mode, P,A,S or M (or X to skip)"
         fi
         read OUT
         if [ -z "$OUT" ]
           then OUT=`cat $HOME/tmp/add_exif/.exifprogramhistory 2>/dev/null`
         fi
         echo "$OUT" > $HOME/tmp/add_exif/.exifprogramhistory

	 echo 
         case $OUT in
           P)MODE=5;;
           A)MODE=3;;
           S)MODE=4;;
           M)MODE=1;;
	   X)MODE=unknown;;
         esac
	 if [ "$MODE" != unknown ]
	   then sed --in-place '/Exif.Photo.ExposureProgram/d' "$DIR"/script.$FILENAME.out
	        echo "exiv2 -M\"del Exif.Photo.ExposureProgram\"       $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
                echo "exiv2 -M\"set Exif.Photo.ExposureProgram $MODE\" $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
		echo 'ExposureProgram' >> $HOME/tmp/add_exif/added
#		echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
	 fi
done
rm $HOME/tmp/add_exif/.exifprogramhistory
fi
}

APERTURE () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ] 
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
#	echo "removing APERTURE tag in $X"
       sed --in-place '/Exif.Photo.FNumber/d' "$X"
     done
else
clear
for X in $(cat $HOME/tmp/add_exif/.list);
do
  FULLNAME=$(basename "$X")
  FILENAME="${FULLNAME%.*}"
#DEKLARERAD  DIR=$(dirname $X | sed s/\'//g)
	 echo ""
	 echo "------------------------[ $FILENAME ]---------------------"
    	 echo "Aperture, ex 5.6 (type X to skip)"
    	 read OUT

	 if [ "$OUT" = "X" ]
	   then echo "skipping..."
	   else sed --in-place '/Exif.Photo.FNumber/d' "$DIR"/script.$FILENAME.out
	        echo "exiv2 -M\"del Exif.Photo.FNumber\" modify 		     $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
    	   case "$OUT" in
     	  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|18|20|22|32|45|64|90|128|135|180|256|360|512)
	      sed --in-place '/Exif.Photo.FNumber/d' "$DIR"/script.$FILENAME.out
     	      echo "exiv2 -M\"add Exif.Photo.FNumber Rational $OUT/1\" modify  $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out ;;
     	  0.95|1.1|1.2|1.4|1.5|1.6|1.7|1.8|1.9|2.2|2.5|2.6|2.8|3.2|3.5|4.5|5.6|7.1)
	      sed --in-place '/Exif.Photo.FNumber/d' "$DIR"/script.$FILENAME.out
	      OUT=`echo "$OUT"|sed 's/\.//g'`
     	      echo "exiv2 -M\"add Exif.Photo.FNumber Rational $OUT/10\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out ;;
       	  0,95|1,1|1,2|1,4|1,5|1,6|1,7|1,8|1,9|2,2|2,5|2,6|2,8|3,2|3,5|4,5|5,6|7,1)
	      sed --in-place '/Exif.Photo.FNumber/d' "$DIR"/script.$FILENAME.out
	      OUT=`echo "$OUT"|sed 's/\,//g'`
       	      echo "exiv2 -M\"add Exif.Photo.FNumber Rational $OUT/10\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out ;;
	      *)echo "As that number was not in the existing list (for script to adjust)
you will have to type it again, but like this:
f/3.2 is written: 32/10 but f/20 (without decimal) is written 20/1
Whatever you write will be accepted and sent to script-file, without any corrections.

(OR type X to skip!)"
	      read OUT
	      if [ "$OUT" != "X" ]
	      then sed --in-place '/Exif.Photo.FNumber/d' "$DIR"/script.$FILENAME.out
	      	   echo "exiv2 -M\"add Exif.Photo.FNumber Rational $OUT\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
	      fi ;;
    	 esac
	 fi
	 echo 'FNumber' >> $HOME/tmp/add_exif/added
#	 echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
done
fi
}

SPEED () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ] 
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
#	echo "removing SPEED tag in $X"
       sed --in-place '/Exif.Photo.ExposureTime/d' "$X"
     done
else
clear
for X in $(cat $HOME/tmp/add_exif/.list);
do
  FULLNAME=$(basename "$X")
  FILENAME="${FULLNAME%.*}"
#DEKLARERAD  DIR=$(dirname $X | se\'//g)




if [ -e "$HOME"/tmp/add_exif/.speed ]
	then SP=`cat $HOME/tmp/add_exif/.speed|awk '{print $1}'`
	else SP="1/"
fi

OUT=$(dialog --title "Shutterspeed" --inputbox "Example:
- 1/125 exposure is simply written 1/125
- 10 second exposure is written 10/1
- Type X do skip this file.

$FILENAME
" 0 0 "$SP" --output-fd 1) 

echo "$OUT" > "$HOME"/tmp/add_exif/.speed

#	 echo ""
#	 echo "------------------------[ $FILENAME ]---------------------"
#        echo "Speed, ex 4/1 (4sek) or 1/125 (type X to skip)"
#    	 read OUT
	 if [ "$OUT" = "X" ]
	   then echo "skipping..."
	   else sed --in-place '/Exif.Photo.ExposureTime/d' "$DIR"/script.$FILENAME.out
	        echo "exiv2 -M\"del Exif.Photo.ExposureTime Rational\" modify      $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
    	        echo "exiv2 -M\"add Exif.Photo.ExposureTime Rational $OUT\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
	        echo 'ExposureTime' >> $HOME/tmp/add_exif/added
#                echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
	 fi
done
fi
}
 
LENS () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ] 
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
#	echo "removing LENS tag in $X"
       sed --in-place '/Exif.Photo.FocalLength/d' "$X"
     done
else
clear
for X in $(cat $HOME/tmp/add_exif/.list);
do
  FULLNAME=$(basename "$X")
  FILENAME="${FULLNAME%.*}"
#DEKLARERAD  DIR=$(dirname $X | sed s/\'//g)
	 echo ""
	 echo "------------------------[ $FILENAME ]---------------------"
#         echo "Lens/Optics/Focal length, type ex: 55 (type X to skip)"


	 if [ -e $HOME/tmp/add_exif/.exiflenshistory ]
           then echo "Lens, ex: 55 or same as last, `cat $HOME/tmp/add_exif/.exiflenshistory` or unknown = X? [`cat $HOME/tmp/add_exif/.exiflenshistory`]"
           else echo "Lens, ex: 55 or unknown = X?"
         fi
         read OUT
         if [ -z "$OUT" ]
           then OUT=`cat $HOME/tmp/add_exif/.exiflenshistory 2>/dev/null`
         fi
         echo "$OUT" > $HOME/tmp/add_exif/.exiflenshistory


#         read OUT
	  case "$OUT" in
		X|x);;
		*) sed --in-place '/Exif.Photo.FocalLength/d' "$DIR"/script.$FILENAME.out
		   echo "exiv2 -M\"del Exif.Photo.FocalLength Rational\" modify        $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
           	   echo "exiv2 -M\"set Exif.Photo.FocalLength Rational $OUT/1\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
#	   	   echo 'FocalLength' >> $HOME/tmp/add_exif/added
#           	   echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE";;
	  esac
done
fi
}

ADDLENS () {

while true; do

LENSMODEL=""
MAKER=""
pkg=""
pkglist=""
LENSUSED=""
MAKERVALUE=""
F1=""
F2=""
F3=""
LM1=""
LM2=""
LM3=""

if [`cat $HOME/tmp/add_exif/.list|wc -l` -gt 1 ]
	then dialog --title "Lens and focal length" --yesno "All files selected? (or none)" 0 0
		case $? in
			0) MARKING=on ;;
			1) MARKING=off;;
		esac
	else MARKING=0
fi

#list files
for pkg in $(cat $HOME/tmp/add_exif/.list)
        do
#	   echo pkg "$pkg"
#	   echo "$DIR"
#	   file "$DIR"/script.`echo $pkg|sed 's/\./ /g'|awk '{print $1}'`.out
	   a123=$(echo "$DIR"/script.`echo "$pkg"|sed 's/\./ /g'|awk '{print $1}'`.out)
#	   echo "$LENGTH"
#	   read
#	   exit 0
#	   OPT='~'
#	   echo $a123
#	   read  
	   if [ -e "$a123" ]
	   	then OPT=$(grep 'set Exif.Photo.FocalLengt' "$a123"|sed 's/\// /g'|awk '{print $5}')
#		     echo $OPT
#		     read
#		     exit 0
		     if [ $OPT -le 10000 ]
		       then echo "Nice leingth!"
		       else OPT='~'
		     fi
	   	else OPT='~'
	   fi
	   pkglist="$pkglist $pkg "$OPT" "$MARKING" "
done

if [ `ls "$DIR"/script.*|wc -l` -ge 1 ]
  then AMOUNT=$(grep Exif.Photo.LensModel "$DIR"/script.*|wc -l)
       EXTRA="$AMOUNT of these chosen files allready has LENSMODEL data."
fi

choise=$(/usr/bin/dialog --checklist "LENSMODEL:

Chose one or more files for EACH lens

$EXTRA

This Menu will return!
" 0 0 0 $pkglist --output-fd 1)

if [ -z $choise ]
 then break
fi
		
choise=`echo $choise | tr " " "\n"`
echo "$choise" > $HOME/tmp/add_exif/.lenslist

lenslist=""
 for pkg in $(cat $HOME/.add_exif.config/lenses)
        do pkglist="$pkglist $pkg ~ "
done



MAKERVALUE=""
MAKERMODEL=""
MAKER=""
if [ -e "$HOME"/.add_exif.config/lenses ];
	then LENSLIST="$HOME/.add_exif.config/lenses"
		MAKER=""
		for pkg in $(grep "$MAKERVALUE" "$LENSLIST" | cut -d'?' -f1|sort|uniq)
			do MAKER="$MAKER $pkg -"
		done

		MAKERMODEL=$(cut -d'?' -f2 "$LENSLIST")

		#List all makers (first field in lenses-file)
		MAKERVALUE=$(/usr/bin/dialog --stdout --title "Choose mount" --menu "Lens MOUNT:" 0 0 0 $MAKER --output-fd 1)
		
		if [ -n "$MAKERVALUE" ];
		  then F1=`grep "$MAKERVALUE" "$LENSLIST" | cut -d'?' -f2 | sed 's/ /_/g'`
#		       echo MAKERMODEL 1: "$MAKERMODEL"
#		       read bah
		       pkglist=""
		       for pkg in $(echo "$F1"| cut -d'!' -f1)
		          do pkglist="$pkglist $pkg -"
		       done
		       echo "F1"
		       echo pkglist 2: "$pkglist"
#		       read bah

		       #list all lenses within that maker
		       LENSUSED=$(/usr/bin/dialog --stdout --menu "Chose lens" 0 0 0 `echo $pkglist` --output-fd 1)
		fi
		

#
# Lägg till option för att backa i menyn!
#
# Lägg till option för "other" vilket blir i praktiken samma som "cancel"
#


	else dialog --title "mah" --msgbox "some text here..." 0 0
fi



if [ -z "$LENSUSED" ]; then

	LM1=$(dialog --title "LENS MOUNT" --inputbox "Write your lens MOUNT:

    ### CREATING A LENS TO THE LIBRARY! 1/3 ###

This is NOT a tag, but used to catagorize for you to easier find the lens again.

NIKON (as in Nikon mount)
or
LUBITEL (as in camera with unreplacable lenses)
" 0 0 --output-fd 1) || break

if [ -n "$LM1" ]
	then LM2=$(dialog --title "Type your lens." --inputbox "Write your lens model as following to look proper:

    ### CREATING A LENS TO THE LIBRARY! 2/3 ###

Micro-NIKKOR 200mm 1:4
or
NIKKOR AF-S DX 18-140mm 1:3.5-5.6 G ED VR

" 0 0 --output-fd 1) || break

	if [ -n "$LM1" -a -n "$LM2" ];
		then LM3=$(dialog --title "focal length" --inputbox "Type the focal length:

    ### CREATING A LENS TO THE LIBRARY! 3/3 ###

75
or
75mm

" 0 0 --output-fd 1) || break
	#Remove any 'mm' in the name as somebody might do it wrong...
	LM3=`echo "$LM3" | sed 's/mm//g'`
	fi
fi




fi

if [ -n "$LM1" -a -n "$LM2" ]
	then echo "$LM1"?"$LM2"!"$LM3" >> "$HOME"/.add_exif.config/lenses
#	     break #för att hoppa ur och välja nya gluggen ur nygenererad glugg-lista
		LENSUSED="$LM2"
		
fi

                if [ -z "$LENSUSED" ]
                   then echo "NO!"
			#echo $LENSUSED
                   else echo "YES!" #; LENSUSED=NOLENS

		for LIST in `cat $HOME/tmp/add_exif/.lenslist`; do
		FULLNAME=$(basename "$LIST")
		FILENAME="${FULLNAME%.*}"
#DEKLARERAD		DIR=$(dirname "$LIST" | sed s/\'//g)
		#Remove old data:

		   sed --in-place '/Exif.Photo.LensModel/d' "$DIR"/script.$FILENAME.out 2>/dev/null
		#Add new data:
		   LENSUSED1=`echo $LENSUSED|sed 's/_/ /g'`
                   sed --in-place '/Exif.Photo.LensModel/d' "$DIR"/script.$FILENAME.out
		   echo "exiv2 -M\"set Exif.Photo.LensModel $LENSUSED1\" modify        $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out

		if [ -z "$LM3" ]
			then F2=$(echo "$LENSUSED" | sed 's/_/ /g') # | cut -d'!' -f2 | sed -e 's/mm//g' -e 's/MM//g')
			     F3=$(grep "$F2" $HOME/.add_exif.config/lenses |cut -d'!' -f2 | sed -e 's/mm//g' -e 's/MM//g' )
			else F3="$LM3"
		fi

#if lens is not a zoom, then add the focal length to exif aswell.
#		FOCAL=$(grep "$LENSUSED" $LENSLIST | cut -d'_' -f3) 
#
#Checking if F3 is actually something equivalent to a focal lenth (a number) which most likely is lower than 10000.

		if [ -n "$F3" -a "$F3" -lt 10000 2>/dev/null ]
                   then sed --in-place '/Exif.Photo.FocalLength/d' "$DIR"/script.$FILENAME.out #2>/dev/null
		   	echo "exiv2 -M\"set Exif.Photo.FocalLength Rational $F3/1\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
		   else	echo "FocalLength `echo $F3` NOT added to exif!
- Probably there was no value in the Lenses configuration-file."
		   	read bah
		fi


done #;break
fi #

#if [ -n "$exit" -a $exit = exit ] 
#  then break
#fi

done #; break
#fi
}


LENSMODEL () {

#####
##
## Add info to this tag:
## Exif.Photo.LensModel   Ascii   19   14.0-24.0 mm f/2.8
##					Tessar 1:3.5 f=75mm
#####

# remove old tag if remove action was used to start script.
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
	then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
	       sed --in-place '/Exif.Photo.LensModel/d' "$X"
	     done
	else ADDLENS

#Loop to return to menu after being done with the first lens.

	if [ `cat $HOME/tmp/add_exif/.list|wc -l` != `cat $HOME/tmp/add_exif/.lenslist|wc -l` ]
		then dialog --title "Lenses" --defaultno --yesno "Add more lenses?" 0 0
		if [ $? = 0 ]
		   then ADDLENS
		   else break
		fi 
	fi
fi
}


GPSDATA () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
       sed --in-place '/Exif.GPSInfo/d' "$X"
       sed --in-place '/GPS\ Data:/d' "$X"
       sed --in-place '/GPS\ End./d' "$X"
     done
else

rm -rf /$HOME/tmp/add_exif/.gps

###pkglist=""
###for pkg in $(cat $HOME/tmp/add_exif/.list)
###        do pkglist="$pkglist $pkg ~ off "
###done

#echo "1: $FILENAME" >> /tmp/add_exif/BAAH		

#echo $pkglist
#while choise=`/usr/bin/dialog --stdout --title "Chose one file at a time for GPS data" --menu "Items:" 0 0 0 $pkglist`; do

#Loop to return to menu after being done with the first coordinate.
while true; do


pkglist=""
for pkg in $(cat $HOME/tmp/add_exif/.list); do
	FULLNAME=$(basename "$pkg")
	FILENAME="${FULLNAME%.*}"
	if [ `grep 'GPSInfo' "$DIR"/script.$FILENAME.out|wc -l` -ge 1 ]
		then OPT='GPS'
		else OPT='~'
	fi
	pkglist="$pkglist $pkg $OPT off "
done




choise=$(/usr/bin/dialog --checklist "GPSDATA:

Chose one or more files FOR EACH coordinates

This Menu will return!

!!! Any existing gps data will be removed !!!" 0 0 0 $pkglist --output-fd 1) || break

#case $? in
# 0);;
# 1)break ;;
#esac

#echo $choise > /$HOME/tmp/add_exif/.gpslist

#FULLNAME=$(basename "$choise")
#FILENAME="${FULLNAME%.*}"
#DIR=$(dirname "$choise" | sed s/\'//g)

dialog --title "List of files" --inputbox "Write your GPS tag using the following format:
$choise

N 64 32 5.3, E 12 24 3.6
Must be, degrees, minutes AND seconds!

GPS format converter can be found on:
http://www.gpscoordinates.eu/convert-gps-coordinates.php" 0 0 " " 2>$HOME/tmp/add_exif/.gps


# sed removed empty spaces in the beginning of the gps-string:
OUT=`cat $HOME/tmp/add_exif/.gps | sed -e 's/^[ \t]*//'`

if [ -z "$OUT" ]
  then echo "NO..." ; OUT=NOGPS
  else echo "YES!";
  case "$OUT" in
	N*|S*|W*|E*)
                        GPS1=`echo "$OUT" | awk '{print $1}'`
                        GPS2=`echo "$OUT" | awk '{print $2}'`
                        if [ "$GPS2" = `echo "$GPS2" | sed 's/\.//g'` ]
                          then BY1=1
                          else BY1=10
                        fi

                        GPS3=`echo "$OUT" | awk '{print $3}'`
                        if [ "$GPS3" = `echo "$GPS3" | sed 's/\.//g'` ]
                          then BY2=1
                          else BY2=10
                        fi

                        GPS4=`echo "$OUT" | awk '{print $4}' | sed 's/,//g'`
                        if [ "$GPS4" = `echo "$GPS4" | sed 's/\.//g'` ]
                          then BY3=1
                          else BY3=10
                               GPS4=`echo $GPS4 | sed 's/\.//g'`
                        fi

                        GPS5=`echo "$OUT" | awk '{print $5}'`

                        GPS6=`echo "$OUT" | awk '{print $6}'`
                        if [ "$GPS6" = `echo "$GPS6" | sed 's/\.//g'` ]
                          then BY4=1
                          else BY4=10
                        fi

                        GPS7=`echo "$OUT" | awk '{print $7}'`
                        if [ "$GPS7" = `echo "$GPS7" | sed 's/\.//g'` ]
                          then BY5=1
                          else BY5=10
                        fi

                        GPS8=`echo "$OUT" | awk '{print $8}'`
                        if [ "$GPS8" = `echo "$GPS8" | sed 's/\.//g'` ]
                          then BY6=1
                          else BY6=10
                               GPS8=`echo $GPS8 | sed 's/\.//g'`
                        fi
		#echo "Check..."		
		#read bah1
		echo "before $choise"
		choise=$(echo $choise | tr " " "\n")
		echo "$choise" > $HOME/tmp/add_exif/.gpslist
		for LIST in `cat $HOME/tmp/add_exif/.gpslist`; do
		FULLNAME=$(basename "$LIST")
		FILENAME="${FULLNAME%.*}"
#DEKLARERAD		DIR=$(dirname "$LIST" | sed s/\'//g)
		       sed --in-place '/Exif.GPSInfo/d' "$DIR"/script.$FILENAME.out
		       sed --in-place '/GPS\ Data:/d' "$DIR"/script.$FILENAME.out
		       sed --in-place '/GPS\ End./d' "$DIR"/script.$FILENAME.out
                   echo " 
# GPS Data:"  >> "$DIR"/script.$FILENAME.out
		   sed --in-place '/Exif.GPSInfo/d' "$X"
		   sed --in-place '/GPS\ Data:/d' "$X"
		   sed --in-place '/GPS\ End./d' "$X"
                   echo "exiv2 -M\"del Exif.GPSInfo.GPSLatitudeRef\" modify        $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
                   echo "exiv2 -M\"add Exif.GPSInfo.GPSLatitudeRef $GPS1\" modify        $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out

                   echo "exiv2 -M\"del Exif.GPSInfo.GPSLongitudeRef\" modify     $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
                   echo "exiv2 -M\"add Exif.GPSInfo.GPSLongitudeRef $GPS5\" modify     $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
                   echo "exiv2 -M\"set Exif.GPSInfo.GPSLatitude $GPS2/$BY1 $GPS3/$BY2 $GPS4/$BY3\" modify     $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
                   echo "exiv2 -M\"set Exif.GPSInfo.GPSLongitude $GPS6/$BY4 $GPS7/$BY5 $GPS8/$BY6\" modify     $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
		   echo "# GPS End.
   "  >> "$DIR"/script.$FILENAME.out
		done;;
	*)dialog --title "Error" --msgbox 'The formating on that coordinate was WRONG, please start over.' 0 0 ;;
  esac
fi



dialog --title "Coordinates" --defaultno --yesno "Add more coordinates?" 0 0
if [ $? = 1 ]
 then break
 else echo "om igen..." 
fi

#End of menu-loop:
done

if [ $? = 2 ]
  then exit 0
fi 
#rm /$HOME/tmp/add_exif/.gps
#done
fi
}

ISO () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
       sed --in-place '/pulled\ to/d' "$X"
       sed --in-place '/pushed\ to/d' "$X"
       sed --in-place '/Exif.Photo.ISOSpeedRatings/d' "$X"
     done
else
 dialog --title "One ISO-setting for all?" --defaultno --yesno "Is this about more than one ISO?" 7 45

 if [ $? = 1 ]
 then echo ""
     echo "------------------------[ ALL FILES ]---------------------"
     echo "ISO -FOR ALL- (if no ISO, set n here)"
     echo ""
     echo "Pushed or pulled? ex. N or no ---"
     read PUSH
     case "$PUSH" in
       n|N|Nej|No|NO|no) echo "Write the films actual ISO (or n to skip this)"
          read OUT
          ;;
       *) echo 'From: (ex: 100)'
          read PUSH1
          echo 'to: (ex: 200)'
          read PUSH2
          if [ "$PUSH1" -gt "$PUSH2" ]
            then sed --in-place '/pulled/d' "$DIR"/script.$FILENAME.out
	    	 echo "exiv2 -M\"add Exif.Photo.UserComment $PUSH1 pulled to $PUSH2\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
            else sed --in-place '/pushed/d' "$DIR"/script.$FILENAME.out
	         echo "exiv2 -M\"add Exif.Photo.UserComment $PUSH1 pushed to $PUSH2\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
          fi
          echo 'Push' >> $HOME/tmp/add_exif/added
          OUT="$PUSH2"
          ;;
     esac

     if [ "$OUT" != "n" ];
       then
           for X in $(cat $HOME/tmp/add_exif/.list);
           do
           FULLNAME=$(basename "$X")
           FILENAME="${FULLNAME%.*}"
#DEKLARERAD           DIR=$(dirname $X | sed s/\'//g)
	   sed --in-place '/Exif.Photo.ISOSpeedRatings/d' "$DIR"/script.$FILENAME.out
           echo "exiv2 -M\"del Exif.Photo.ISOSpeedRatings\"      $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
           echo "exiv2 -M\"set Exif.Photo.ISOSpeedRatings $OUT\" $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
           echo 'ISOSpeedRatings' >> $HOME/tmp/add_exif/added
           echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
           done
     fi


 else echo "-----------------------[ SEVERAL ISOs ]-------------------"
     for X in $(cat $HOME/tmp/add_exif/.list);
      do
       FULLNAME=$(basename "$X")
       FILENAME="${FULLNAME%.*}"
#DEKLARERAD       DIR=$(dirname $X | sed s/\'//g)
         echo ""
         echo "------------------------[ $FILENAME ]---------------------"
         echo ""
     echo "Pushed or pulled? ex. N or no ---"
     read PUSH
     case "$PUSH" in
       n|N|Nej|No|NO|no) echo "Set ISO or [Enter] to use same as last: `cat $HOME/tmp/add_exif/.exifisohistory`"
          read OUT
	  if [ -z $OUT ]
            then OUT=`cat $HOME/tmp/add_exif/.exifisohistory`
          fi
          ;;
       *) echo 'From: (ex: 100)'
          read OUT
          echo 'to: (ex: 200)'
          read PUSH2
          if [ "$OUT" -gt "$PUSH2" ]
            then sed --in-place '/pulled/d' "$DIR"/script.$FILENAME.out
	         echo "exiv2 -M\"add Exif.Photo.UserComment $OUT pulled to $PUSH2\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
            else sed --in-place '/pushed/d' "$DIR"/script.$FILENAME.out
	         echo "exiv2 -M\"add Exif.Photo.UserComment $OUT pushed to $PUSH2\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
          fi
	  echo "$OUT" > $HOME/tmp/add_exif/.exifisohistory
          OUT="$PUSH2"
          ;;
     esac
         sed --in-place '/Exif.Photo.ISOSpeedRatings/d' "$DIR"/script.$FILENAME.out
	 echo "exiv2 -M\"del Exif.Photo.ISOSpeedRatings\"      $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
         echo "exiv2 -M\"set Exif.Photo.ISOSpeedRatings $OUT\" $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
         echo 'ISOSpeedRatings' >> $HOME/tmp/add_exif/added
#         echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
      done
 rm $HOME/tmp/.exifisohistory
 fi
fi
}

PHOTOGRAPHER () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
       sed --in-place '/Exif.Image.Artist/d' "$X"
       sed --in-place '/Exif.Image.Copyright/d' "$X"
     done
else
 if [ -e $HOME/.add_exif.config/mail ]
  then MAIL=`cat $HOME/.add_exif.config/mail`
  else MAIL="Your mailaddress here"
 fi

 MAIL=$(dialog --title "Photographer tag" --inputbox "This mail will be added to the images ARTIST and COPYRIGHT tags" 12 40 "$MAIL" --output-fd 1)

 echo $MAIL > $HOME/.add_exif.config/mail

 for X in $(cat $HOME/tmp/add_exif/.list);
 do
  FULLNAME=$(basename "$X")
  FILENAME="${FULLNAME%.*}"
#DEKLARERAD  DIR=$(dirname $X | sed s/\'//g)
  sed --in-place '/Exif.Image.Artist/d' "$DIR"/script.$FILENAME.out
  echo "exiv2 -M\"del Exif.Image.Artist\" 		 $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
  echo "exiv2 -M\"set Exif.Image.Artist $MAIL\"           $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
  sed --in-place '/Exif.Exif.Image.Copyright/d' "$DIR"/script.$FILENAME.out
  echo "exiv2 -M\"set Exif.Image.Copyright $MAIL\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
  echo 'Artist'    >> $HOME/tmp/add_exif/added
  echo 'Copyright' >> $HOME/tmp/add_exif/added
#  echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
 done
fi
}

SOFTWARE () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
       sed --in-place '/Exif.Image.Software/d' "$X"
       sed --in-place '/Scanned\ with:/d' "$X"
     done
else
 clear
#for X in $(cat $HOME/tmp/add_exif/.list);
#do
	 echo ""
	 echo "------------------[ Scanner and software ]------------"
         echo "Software/scanner [Gimp 2.8 and Nikon Coolscan V ED]"
	 echo "(1) Gimp 2.8 and Nikon Coolscan V ED"
	 echo "(2) Gimp 2.8 and Epson V500 flatbed"
	 echo "(3) Gimp 2.8 and Epson (other)"
	 echo "(4) Gimp 2.8 and Nikon Coolscan 8000 ED"
	 echo "(5) Vuescan no scanner"
	 echo "(6) TWAIN no scanner"
	 echo "(7) Gimp 2.8 and Canon CanoScan 9000F"
	 echo "(8) Gimp 2.8 and Epson Perfection V700"
	 echo "(9) Other [write what you used]"
	 echo "(10) None"
	 read OUT
	 if [ -z "$OUT" ]
	   then echo "Skipping..."
           else case "$OUT" in
		   1)SOFTWARE="Gimp 2.8"
		     SCANNER="Nikon Coolscan V ED";;
		   2)SOFTWARE="Gimp 2.8"
		     SCANNER="Epson Perfection V500 Photo";;
		   3)echo "Which model?"
	             echo "(1) V700"
	             echo "(2) V750"
		     echo "(3) 1240u"
	             echo "(4) Other"
	             read SCANNER
	             case "$SCANNER" in
	               1)SCANNER="Epson Perfection V700 Photo";;
	               2)SCANNER="Epson Perfection V750 Pro";;
		       3)SCANNER="Epson Perfection 1240u";;
	               4)echo "Write Epson model, Tag will say: 'Epson $SCANMOD'"
		         read SCANMOD
		         SCANNER="Epson $SCANMOD"
			 SOFTWARE="Vuescan";;
		     esac
		     SOFTWARE="Gimp 2.8";;
                   4)SOFTWARE="Gimp 2.8"
		     SCANNER="Nikon Coolscan 8000 ED";;
		   5)SOFTWARE="Vuescan"
		     SCANNER="n";;
		   6)SOFTWARE="Twain"
		     SCANNER="n";;
		   7)SOFTWARE="Gimp 2.8"
		     SCANNER="Canon CanoScan 9000F";;
		   8)SOFTWARE="Gimp 2.8"
		     SCANNER="Epson Perfection V700";;
		   9)echo "Scanner manufacturer:"
                     read MANUFACT
		     echo "Write model:"
		     read SCANMOD
		     SCANNER="$MANUFACT $SCANMOD"
		     echo 'With which software?'
		     read SOFTWARE
		     if [ -z "$SOFTWARE" ]
		       then SOFTWARE="n"
		     fi;;
		   10)SOFTWARE="n"
		     SCANNER="n";;
		 esac
	 fi

         if [ -z $OUT ]
           then OUT="Vuescan"
         fi

 for X in $(cat $HOME/tmp/add_exif/.list);
 do
  FULLNAME=$(basename "$X")
  FILENAME="${FULLNAME%.*}"
#DEKLARERAD  DIR=$(dirname $X | sed s/\'//g)
         sed --in-place '/Exif.Image.Software/d' "$DIR"/script.$FILENAME.out
	 echo "exiv2 -M\"del Exif.Image.Software\" modify                                  $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
         if [ "$SOFTWARE" != "n" ];
	   then sed --in-place '/Exif.Image.Software/d' "$DIR"/script.$FILENAME.out
	        echo "exiv2 -M\"set Exif.Image.Software $SOFTWARE\" modify                 $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
#                echo 'Image.Software' >> $HOME/tmp/add_exif/added
	 fi
	 if [ "$SCANNER" != "n" ];
	   then sed --in-place '/Scanned/d' "$DIR"/script.$FILENAME.out
	        echo "exiv2 -M\"add Exif.Photo.UserComment Scanned with: $SCANNER\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
#	        echo 'Scanned' >> $HOME/tmp/add_exif/added
	 fi
 done
# echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
fi
}

CAMERA () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
       sed --in-place '/Exif.Image.Model/d' "$X"
       sed --in-place '/Exif.Image.Make/d' "$X"
     done
else
 clear
	 echo ""
	 echo "-----------------[ Make and model of Camera ]--------"
         echo "Camera manufacturer, ex Nikon"
         read OUT

         case "$OUT" in
        pentax|Pentax|PENTAX)
             echo "Pentax Model? ex LX"
             read TYPE
	     OUT="Asahi Pentax";;
        nikon|Nikon|NIKON)
             echo "Nikon Model? ex FA"
             read TYPE
	     OUT="Nikon";;
	 toyo|Toyo|TOYO)
	     TOYO=$(dialog --title "Which TYPE of toyo?" --menu "Types:" 0 0 0 "Field" "" "View" "" --output-fd 1)
	     TOYO2=$(dialog --title "TOYO $TOYO" --inputbox "Which model,
 ex 45AII, 810G" 0 0 " " --output-fd 1)
	     TYPE="$TOYO $TOYO2"
	     OUT="TOYO";;
  zenza|bronica|zensa|Zenza|Zensa|Bronica|ZENZA|ZENSA|BRONICA)
             echo "Bronica Model? ex EC-TL"
	     read TYPE
	     OUT="Zenza Bronica";;
        canon|Canon|CANON)
             echo "Canon Model? ex A-1"
             read TYPE
	     OUT="Canon";;
        recesky|Recesky|RECESKY)
	     OUT="Recesky"
             TYPE="DC67 TLR";;
        rolleicord|Rolleicord|ROLLEICORD)
# 	dialog --title "Kentmere"  --menu "Options:" 20 40 60 \
#	"Kentmere 100" "" \
#	"Kentmere 400" "" \
             echo "Rolleicord Model? Rolleicord IV K3D"
             read TYPE
	     OUT="Rolleicord IV K3D";;
	Edixa|edixa)
	     echo "Which (Wirgin) Edixa model? (ex: Mat Reflex)

This will be written
Make: Wirgin
Model: Edixa XXXXX
"
	     read TYPEOF
	     OUT="Wirgin"
	     TYPE="Edixa $TYPEOF";;
        *)   echo "Type Camera model, if any (not the brand here)"
             read TYPE
	     ;;
#	fi;;
         esac
####
 for X in $(cat $HOME/tmp/add_exif/.list);
 do
  FULLNAME=$(basename "$X")
  FILENAME="${FULLNAME%.*}"
#DEKLARERAD  DIR=$(dirname $X | sed s/\'//g)   
  echo "$DIR/$FILENAME"
  echo sed --in-place '/Exif.Image.Model/d' "$DIR"/script.$FILENAME.out
  echo sed --in-place '/Exif.Image.Make/d' "$DIR"/script.$FILENAME.out
  echo "exiv2 -M\"del Exif.Image.Model\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
  echo "exiv2 -M\"del Exif.Image.Make\" modify  $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
  if [ -z "$TYPE" ]
    then : #echo "exiv2 -M\"add Exif.Image.Make $OUT\" modify               $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
    else sed --in-place '/Exif.Image.Model/d' "$DIR"/script.$FILENAME.out
         echo "exiv2 -M\"add Exif.Image.Model $TYPE\" modify             $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
#         echo 'Image.Model' >> $HOME/tmp/add_exif/added
	 sed --in-place '/Exif.Image.Make/d' "$DIR"/script.$FILENAME.out
         echo "exiv2 -M\"add Exif.Image.Make $OUT\" modify               $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
#         echo 'Image.Make' >> $HOME/tmp/add_exif/added
  fi
#  echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
 done
####

#done
fi
}

ROLLNR () {

	########## EXPLANATION ############
	#				
	#  I use this funktion in order to
	#  keep track of my rolls, and which
	#  roll that should be crossed which
	#  which exif-data. So if I start a 
	#  new roll, I will give that roll 
	#  a number - this is that number.
	#
	###################################

if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
       sed --in-place '/Roll-id/d' "$X"
     done
else
#ROLL=`dialog --title "One or several?" --defaultno --yesno "Is this about more than one roll or sheet?" 7 45`
 dialog --title "One or several?" --defaultno --yesno "Is this about more than one roll or sheet?" 7 45

 if [ $? = 1 ]
  if [ `echo $FILENAME|awk 'print $1'` -le 99999 ]
    then NUMBER=`echo $FILENAME|awk 'print $1'`
  fi
  then echo ""
     echo "-------------------[ ONE ROLL $NUMBER ]-----------------"
     echo ""
     echo "Type roll-id number:"
     read ROLL

  if [ -z "$ROLL" ];
   then echo "No roll-id?? ok, skipping this one."; read ANS 
   else
      for X in $(cat $HOME/tmp/add_exif/.list);
      do
        FULLNAME=$(basename "$X")
        FILENAME="${FULLNAME%.*}"
#DEKLARERAD        DIR=$(dirname $X | sed s/\'//g)
        sed --in-place '/Roll-id/d' "$DIR"/script.$FILENAME.out
	echo "exiv2 -M\"add Exif.Photo.UserComment Roll-id $ROLL\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out

        echo 'roll-id' >> $HOME/tmp/add_exif/added
#        echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
      done
   fi
  else echo "-----------------------[ SEVERAL ROLLS ]------------------"
     for X in $(cat $HOME/tmp/add_exif/.list);
      do
       FULLNAME=$(basename "$X")
       FILENAME="${FULLNAME%.*}"
#DEKLARERAD       DIR=$(dirname $X | sed s/\'//g)
         echo ""
         echo "------------------------[ $FILENAME ]---------------------"

         if [ -e $HOME/tmp/add_exif/.exifrollhistory ]
           then echo "Type roll-nr or if same as last, `cat $HOME/tmp/add_exif/.exifrollhistory` or none = X? [`cat $HOME/tmp/add_exif/.exifrollhistory`]"
           else echo "Type roll-nr or X = dont know"
         fi
         read ROLL
         if [ -z "$ROLL" ]
           then ROLL=`cat $HOME/tmp/add_exif/.exifrollhistory 2>/dev/null`
         fi
         echo "$ROLL" > $HOME/tmp/add_exif/.exifrollhistory
 	 sed --in-place '/Roll-id/d' "$DIR"/script.$FILENAME.out
         echo "exiv2 -M\"add Exif.Photo.UserComment Roll-id $ROLL\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
         echo 'roll-id' >> $HOME/tmp/add_exif/added
#         echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
      done
  rm $HOME/tmp/add_exif/.exifrollhistory
 fi
fi
}


COMMENT () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
       sed --in-place '/COMMENT:/,/COMMENT./d' "$DIR"/"$X"
     done
else

rm -rf /$HOME/tmp/add_exif/.comment

########

while true; do

pkglist=""
for pkg in $(cat $HOME/tmp/add_exif/.list); do
	FULLNAME=$(basename "$pkg")
	FILENAME="${FULLNAME%.*}"
	if [ `grep 'COMMENT:' "$DIR"/script.$FILENAME.out|wc -l` -ge 1 ]
		then OPT='C'
		else OPT='~'
	fi
	pkglist="$pkglist $pkg $OPT off "
done

choise=$(/usr/bin/dialog --checklist "COMMENT:

Chose one or more files FOR EACH comment

C = Comment present.
~ = Comment NOT present.

!!! Any existing comments will be removed !!!" 0 0 0 $pkglist --output-fd 1) || break

dialog --title "List of files" --inputbox "Write your Comment with up to 90 chars.
$choise

To make sure comments are added using this script please DONT use quotations, they are likely to break the scrip!!" 0 0 " " 2>$HOME/tmp/add_exif/.comment

# sed removed empty spaces in the beginning of the comment-string:
OUT=`cat $HOME/tmp/add_exif/.comment | sed -e 's/^[ \t]*//'`

if [ -z "$OUT" ]
  then echo "NO..." ; OUT=NOCOMMENT
  else echo "YES!";
		choise=$(echo $choise | tr " " "\n")
		echo "$choise" > $HOME/tmp/add_exif/.commentlist
		for LIST in `cat $HOME/tmp/add_exif/.commentlist`; do
		FULLNAME=$(basename "$LIST")
		FILENAME="${FULLNAME%.*}"
#DEKLARERAD		DIR=$(dirname "$LIST" | sed s/\'//g)
		       sed --in-place '/COMMENT:/,/COMMENT./d' "$DIR"/script.$FILENAME.out
                   echo " 
# COMMENT:"  >> "$DIR"/script.$FILENAME.out
		   echo "exiv2 -M\"add Exif.Photo.UserComment $OUT\" modify $DIR/$FILENAME*.???" >>"$DIR"/script.$FILENAME.out
		   echo "# COMMENT.
   "  >> "$DIR"/script.$FILENAME.out
		done
fi

dialog --title "Comments" --defaultno --yesno "Add more comments?" 0 0
	if [ $? = 1 ]
	 then break
	 else echo "om igen..." 
	fi

done

	if [ $? = 2 ]
	  then exit 0
	fi 
fi
}

FILM () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
then MD5SUM="/usr/bin/md5sum"
     for X in `cat $HOME/tmp/add_exif/.remove.list`; do
	if [ -x $MD5SUM ]
	  then BEFORE=`$MD5SUM "$X"`
	     sed --in-place '/Film:/d' "$X"
	     AFTER=`"$MD5SUM" "$X"`
		if [ "$BEFORE" = "$AFTER" ]
		  then dialog --title "Tag not removed" --msgbox "The script-file either does not contain this tag at all, or does not use the sign 'Film:' which I was looking for." 10 40
		fi
	     sed --in-place '/Film:/d' "$X"
	fi
     done
else
 dialog --title "Which film?"  --menu "Options:" 20 40 60 \
	"Kodak" "" \
	"Ilford" "" \
	"Fujifilm" "" \
	"Kentmere" "" \
	"Lomography" "" \
	"Rollei" "" \
	"CineStill" "" \
	"FOMA" "" \
	"Bergger" "" \
	"Ferrania" "" \
	"Agfa-Gevaert" "" \
	"AgfaPhoto" "" \
	"ORWO" "" \
	"Efke" "" \
	"Arista EDU Ultra" "" \
	"Shanghai GP3" "" \
	"Holga" "" \
	"DM Paradies 200" "" \
	"Noname" "" \
	"Polaroid (format)" "" \
	"Others" "" \
        "X" "Don't know" \
2> $HOME/tmp/add_exif/.film
OUT=`cat $HOME/tmp/add_exif/.film | sed 's/\%//g'`

#echo "bah1"

 case "$OUT" in
 'Kodak')dialog --title "Kodak"  --menu "Options:" 20 40 60 \
	"Kodak Ektar" "" \
        "Kodak Tmax" "" \
        "Kodak TriX" "" \
        "Kodak Portra" "" \
	"Kodak BW400CN" "" \
	"Kodak Portra 160" "" \
	"Kodak Portra 160NC" "" \
	"Kodak Portra 160VC" "" \
	"Kodak Portra 400" "" \
	"Kodak Portra 800" "" \
	"Kodak E100" "" \
	"Kodak E100VC" "" \
	"Kodak E100VS" "" \
	"Kodak UltraMax" "" \
        "Kodak Gold" "" \
        "Kodak ColorPlus" "" \
        "Kodak Elitechrome" "" \
	"Kodak Verichrome" "" \
	"Kodak Kodachrome" "" \
        "Kodak Ektachrome" "" \
	"Kodak Ektachrome (very old)" "" \
	"Kodak Motion Picture Vision3 250D" "" \
	"Kodak Motion Picture Vision3 500T" "" \
	"Kodak Tri-X Pan (very old)" "" \
	"Kodak Ektar (very old)" "" \
	"Kodak High Speed Infrared film" "" \
	"Kodak Plus-X Pan" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Ilford')dialog --title "Ilford"  --menu "Options:" 20 40 60 \
	"Ilford PanF" "" \
	"Ilford Pan" "" \
        "Ilford FP4" "" \
        "Ilford HP5+" "" \
        "Ilford Delta" "" \
        "Ilford XP2" "" \
        "Ilford SFX" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Kentmere')dialog --title "Kentmere"  --menu "Options:" 20 40 60 \
	"Kentmere 100" "" \
	"Kentmere 400" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Fujifilm')dialog --title "Fuji"  --menu "Options:" 20 40 60 \
	"Fujifilm 160 NS" "" \
	"Fujifilm Superia" "" \
        "Fujifilm Superia X-Tra" "" \
        "Fujifilm Pro 400H" "" \
        "Fujifilm Astia" "" \
	"Fujifilm C200" "" \
        "Fujifilm Reala" "" \
        "Fujifilm Neopan" "" \
        "Fujifilm Neopan 100 Acros" "" \
        "Fujichrome Velvia" "" \
        "Fujichrome 64T" "" \
        "Fujichrome Provia" "" \
	"Fujichrome Provia 400X" "" \
	"Fujichrome Provia 100" "" \
	"Fujichrome Provia 100F" "" \
	"Fujichrome Provia 50" "" \
2> $HOME/tmp/add_exif/.film ;;
 'FOMA')dialog --title "Fomapan"  --menu "Options:" 20 40 60 \
        "FOMA Fomapan Classic" "" \
        "FOMA Fomapan Creative" "" \
        "FOMA Fomapan Action" "" \
        "FOMA Fomapan R" "" \
2> $HOME/tmp/add_exif/.film ;;
 'AgfaPhoto')dialog --title "AgfaPhoto"  --menu "Options:" 20 40 60 \
	"AgfaPhoto Vista Plus" "" \
        "AgfaPhoto CT Precisa" "" \
        "AgfaPhoto APX (old)" "" \
        "AgfaPhoto APX (new)" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Agfa-Gevaert')dialog --title "Agfa"  --menu "Options:" 20 40 60 \
        "Agfa-Gevaert Scala 200x" "" \
	"Agfa-Gevaert Copex Rapid" "" \
	"Agfa-Gevaert Isopan" "" \
	"Agfa-Gevaert Agfapan" "" \
	"Agfa-Gevaert AgfaPan Vario XL" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Bergger')dialog --title "Bergger" --menu "Options:" 20 40 60 \
	"Bergger BRF-200" "" \
	"Bergger BRF-400" "" \
	"Bergger BRF400 Plus" "" \
	"Bergger Pancro 400" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Adox')dialog --title "Ferrania"  --menu "Options:" 20 40 60 \
        "Adox CHS 100 II" "" \
        "Adox CMS 20 II" "" \
        "Adox Silvermax" "" \
	"Adox Color Implosion!" "" \
	"Adox R17" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Ferrania')dialog --title "Ferrania"  --menu "Options:" 20 40 60 \
	"Ferrania P30" "" \
	"Ferrania Solaris" "" \
	"Ferrania ScotchChrome" "" \
2> $HOME/tmp/add_exif/.film ;;
 'CineStill')dialog --title "CineStill"  --menu "Options:" 20 40 60 \
        "CineStill 50 Daylight Xpro" "" \
        "CineStill 800 Tungsten Xpro" "" \
        "CineStill bwXX" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Lomography')dialog --title "Lomography"  --menu "Options:" 20 40 60 \
        "Lomography Earl Grey B&W" "" \
	"Lomography Lobster Redscale" "" \
	"Lomography Redscale XR 50-200" "" \
	"Lomography Color Negative" "" \
        "Lomography XPro" "" \
	"Lomography XPro Slide" "" \
	"Lomography Color Tiger" "" \
	"Lomography Peacock" "" \
        "Lomography LomoChrome Purple XR 100-400" "" \
	"Lomography LomoChrome Turquoise XR 100-400" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Rollei')dialog --title "Rollei"  --menu "Options:" 20 40 60 \
        "Rollei Infrared" "" \
        "Rollei Superpan" "" \
        "Rollei RPX" "" \
        "Rollei Retro 80s" "" \
        "Rollei Retro 400s" "" \
        "Rollei ATO 2.1" "" \
        "Rollei ATP 1.1" "" \
        "Rollei Orto" "" \
	"Rollei Crossbird" "" \
	"Rollei Redbird" "" \
	"Rollei Nightbird" "" \
        "Rollei CR 200" "" \
        "Rollei CN 200" "" \
	"Rollei Vario Chrome" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Efke')dialog --title "Efke"  --menu "Options:" 20 40 60 \
	"Efke IR 820" "" \
        "Efke R 100" "" \
	"Efke KB 100" "" \
	"Efke KB 50" "" \
	"Efke KB 25" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Orwo')dialog --title "ORWO"  --menu "Options:" 20 40 60 \
	"ORWO NP15" "" \
	"ORWO NP20" "" \
	"ORWO NP22" "" \
	"ORWO NP27" "" \
	"ORWO NP30" "" \
	"ORWO N 74 Plus" "" \
	"ORWO Pan" "" \
	"ORWO UN 54" "" \
	"ORWO Color NC3" "" \
	"ORWO Color NC16" "" \
	"ORWO PC7" "" 19
	"ORWO Color NC16" "" \
	"ORWO Color QRS 100" "" \
	"ORWOChrom UT18 " "" \
	"ORWOChrom UT21 " "" \
2> $HOME/tmp/add_exif/.film ;;
 'Polaroid (format)')dialog --title "Polaroid" --menu "Options:" 20 40 60 \
 	"Polaroid 600" "" \
	"Fujifilm FP-3000B" "" \
	"Fujifilm FP-100C" "" \
	"Fujifilm FP-100" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Others')dialog --title "Which strange (old?) film have you found?"  --menu "Options:" 20 40 60 \
	"Konica Centuria" "" \
	"ExtraFilm.com" "" \
	"Kosmo Foto Mono" "" \
	"Lucky SHD" "" \
	"JCH Street Pan" "" \
	"CFP Double-X B&W" "" \
	"Rera Pan" "" \
	"Rera Chrome" "" \
2> $HOME/tmp/add_exif/.film ;;
 esac
 OUT=`cat $HOME/tmp/add_exif/.film | sed 's/\%//g'`

 if [ -z $OUT ]
  then echo "No film was chosen"
  else for X in $(cat $HOME/tmp/add_exif/.list);
       do
  	FULLNAME=$(basename "$X")
  	FILENAME="${FULLNAME%.*}"
#DEKLARERAD  	DIR=$(dirname $X | sed s/\'//g)

          if [ "$OUT" != "X" ]
            then #echo "exiv2 -M\"del Exif.Photo.UserComment\" modify      $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
                 sed --in-place '/Film:/d' "$DIR"/script.$FILENAME.out
		 echo "exiv2 -M\"add Exif.Photo.UserComment Film: $OUT\" modify $DIR/$FILENAME*.???" >> "$DIR"/script.$FILENAME.out
#                echo 'Film' >> $HOME/tmp/add_exif/added
#                echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
          fi
	done
 fi
fi
}

RUNGPS () {
TOP='Adding images to $HOME/tmp/add_exif/.list'
TIF=$(ls -l *.tif | wc -l)

	if [ $TIF = 0 ]
	 then CMD='/bin/ls *.jpg'
	 else CMD='/bin/ls *.tif'
	fi

	   dialog --title "$TOP" --inputbox "You are in `pwd` Type command to add files to $HOME/tmp/add_exif/.list" 0 0 "$CMD > $HOME/tmp/add_exif/.list" 2>$HOME/tmp/add_exif/.command
	   if [ $? = 1 ]
	     then echo "Pressed 'Cancel'"
		  exit 0
	   fi
	   sh $HOME/tmp/add_exif/.command
GPSDATA
}

RUNREMOVE () {

	###########################################
	# This option exists to easely
	# remove specific lines of data
	# from script-files using "sed --in-place."
	# I have had problems with this, so please
	# make a copy of your script-files before
	# you run this.
	###########################################

ls script.* > $HOME/tmp/add_exif/.remove.alternatives

#REMOVE=`cat $HOME/tmp/add_exif/.remove.list`



REMOVE=""
for pkg in $(cat $HOME/tmp/add_exif/.remove.alternatives)
        do REMOVE="$REMOVE $pkg ~ on "
done

choise=$(/usr/bin/dialog --checklist "Chose in which scriptfiles you wish to remove some data." 0 0 0 $REMOVE  --output-fd 1)

echo "running magic.."
echo $choise | tr " " "\n" > "$HOME"/tmp/add_exif/.remove.list

dialog --title "listing scriptfiles:" --yesno "Does this look ok?

`echo $choise`

`cat $HOME/tmp/add_exif/.dialogout`" 15 55
if [ $? = 1 ]
  then exit 0
  else dialog --separate-output --checklist "Choose what to remove:" 20 35 60 \
        DATE " " off \
        APERTURE " " off \
        SPEED " " off \
        LENS " " off \
        ISO " " off \
        FILM " " off \
	DEVEL " " off \
	ROLLNR " " off \
        PHOTOGRAPHER " " off \
        CAMERA " " off \
        PROGRAM " " off \
        SOFTWARE " " off \
	COMMENT " " off \
	GPSDATA " " off \
2>> "$HOME"/tmp/add_exif/.dialogout





#for Y in $(cat "$HOME"/tmp/add_exif/.dialogout); do
#echo "### AAAAAAAAAAAAAAAAAAAAAAAAAAA 1 ###"
  for DLG in $(cat "$HOME"/tmp/add_exif/.dialogout); do
    "$DLG"
  done; #rm "$HOME"/tmp/add_exif/.remove.list

#done; rm -rf "$HOME"/tmp/add_exif/.remove.list >/dev/null

fi





rm -rf "$HOME"/tmp/add_exif/.remove.* >/dev/null
}

RUN () {
	rm -rf "$HOME"/tmp/add_exif/.remove 2>/dev/null
TOP='Adding images to $HOME/tmp/add_exif/.list'
TIF=$(ls -l *.tif | wc -l)

	   if [ "$TIF" = 0 ]
	    then CMD='/bin/ls *.jpg'
	    else CMD='/bin/ls *.tif'
	   fi
	   dialog --title "$TOP" --inputbox "You are in `pwd` Type command to add files to $HOME/tmp/add_exif/.list" 0 0 "$CMD > $HOME/tmp/add_exif/.list" 2>$HOME/tmp/add_exif/.command
	   if [ "$?" = 1 ]
	     then echo "Pressed 'Cancel'"
		  exit 0
	   fi
	   sh "$HOME"/tmp/add_exif/.command

	   dialog --title "Execute for..." --yesno "Does this look ok?

`cat "$HOME"/tmp/add_exif/.list`" 25 40
           if [ $? = 1 ]
	     then exit 0 
	   fi

   	   rm -rf "$HOME"/tmp/add_exif/.dialogout 
           dialog --separate-output --checklist "Choose exifdata:" 0 0 0 \
        DATE " " on \
        PROGRAM " " on \
        APERTURE " " on \
        SPEED " " on \
        LENS " " off \
	LENSMODEL " " on \
        ISO " " on \
        FILM " " on \
	DEVEL " " on \
	ROLLNR " " on \
        CAMERA " " on \
        SOFTWARE " " on \
        PHOTOGRAPHER " " on \
	COMMENT " " on \
	GPSDATA " " off \
2> "$HOME"/tmp/add_exif/.dialogout

for Y in $(cat "$HOME"/tmp/add_exif/.list); do
  exiv2 -dx "$Y"
  for DLG in $(cat "$HOME"/tmp/add_exif/.dialogout); do
    $DLG #; clear
  done

  echo ""


FINAL () {

### while ###
while true;
do
### start ###
for X in $(cat $HOME/tmp/add_exif/.list);
 do FULLNAME=$(basename "$X")
    FILENAME="${FULLNAME%.*}"
#DEKLARERAD    DIR=$(dirname $X | sed s/\'//g)
done
FIN=$(dialog --title "Finally running generated exif-scripts..." --menu "Running the generated files

If you prefer to run these later, you can simply
restart this script and unchecking the dialogboxes
in mainmenu, or simply executing them manually:

sh script.FOOBAR.out
" 0 0 0 "1" "Execute ALL generated script-files in dir" "0" "Menu-list for each script" --output-fd 1)

case $FIN in
0) for pkg in $(ls $DIR/script.*)
    do pkglist="$pkglist $pkg ~ "; done

   echo $pkglist
   while choise=`/usr/bin/dialog --stdout --menu "Items:" 0 45 0 $pkglist`; do
   if [ $? = 1 ]
     then break
   fi

# clean file prior to exifiation
   dialog --title "Remove existing exif in files" --yesno "Clean files before execute script?" 7 40 
   if [ $? = 0 ]
     then clear
          EXIVDEL=$(exiv2 delete `echo $choise | sed 's/script\.//g;s/\.out/\.\*/g'`)
          if [ $? != 0 ]
	    then echo "$?

$EXIVDEL

hit Enter to continue."
	    else echo "Done! Now, hit Enter to continue."
	  fi
          read MEH
     else echo "no cleaning..."
   fi

##### exify:#####	
#   clear
   echo $choise
   sh $choise
#   read BAH

   done;;
#################
1)		dialog --title "Clean _ALL_ image in files" --yesno "Clean (remove exif) files before execute script/s?" 7 40
		if [ $? = 0 ]
		  then for choise in $(ls "$DIR"/script.*); do
			   exiv2 delete `echo "$choise" | sed 's/script\.//g;s/\.out/\.\*/g'`
		       done
		fi
		  clear
		  dialog --title "Execute the following..." --yesno "`ls $DIR/script.*`" 20 45
		if [ $? = 0 ]
		then
		  for B in $(ls $DIR/script.*);
		    do echo "Running $B"
		       sh "$B"
		    done
		  rm $HOME/tmp/add_exif/.list.first 2>/dev/null
		fi
	exit 0;; #utan denna exit startar den om scriptet??
*)exit 0;;      #dialog --title "WTF" --msgbox "How did you end up here??!" 20 20
esac
### while ###
done
### stop ####
}
FINAL $X
done
exit 0
}


case $1 in
 -h|--help|--h)HELP ; exit 0;;
# -gps|-GPS|gps|GPS);;
 -remove|-r)touch $HOME/tmp/add_exif/.remove && rm -rf "$HOME"/tmp/add_exif/.dialogout && RUNREMOVE;;
 *)RUN;;
esac

#echo "running RUN $1"
#RUN $1



#aperture, speed, date, time, program, lens, + iso, photographer, software, camera, film
#filnamnsproblem, om fil med samma namn, men olika extension ska ha samma data.



