#!/bin/bash

declare DIR=$(dirname "$LIST" | sed s/\'//g)


rm -f "$HOME"/tmp/add_exif/.* 2>/dev/null

REM1=`file "$HOME"/tmp/add_exif/.remove`
REM2=`file "$HOME"/tmp/add_exif/.remove.list`
if [ "$REM1" = 0 -o "$REM2" = 0 ]
  then dialog --title "Remove old file!" --msgbox "I was unable to remove:
$REM1
$REM2" 0 0 ; exit 0
fi

which dialog 2>&1 >/dev/null|| `echo "Package: Dialog not found!"; exit 1`
which exiv2 2>&1 >/dev/null|| `echo "Package: exiv2 not found!"; exit 1`
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
and all possible script binaries


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
        APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
        echo "exiv2 -M\"del Exif.Photo.DateTimeOriginal\"             $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
        echo "exiv2 -M\"set Exif.Photo.DateTimeOriginal $DATE $TIME\" $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
#       echo 'DateTime' >> $HOME/tmp/add_exif/added
#       echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"

	if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
	       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
		    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
	fi
done
rm -r $HOME/tmp/add_exif/.datetime
fi
}

#deprecated
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
         echo "exiv2 -M\"del Exif.Photo.DateTimeOriginal\"             $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
         echo "exiv2 -M\"set Exif.Photo.DateTimeOriginal $OUT1 $OUT2\" $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
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
                  APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
	          echo "exiv2 -M\"add Exif.Photo.UserComment Home developed using $DEV\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	     else echo "exiv2 -M\"add Exif.Photo.UserComment Developed using $DEV\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	   fi
	   echo 'developed' >> $HOME/tmp/add_exif/added

	if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
	       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
		    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
	fi
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

	if [ -z "$PROGRAMHIST" ]
	   then break
	fi

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
        APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
        if [ "$MODE" -ge 1 ]; then
		echo "exiv2 -M\"del Exif.Photo.ExposureProgram\"       $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	        echo "exiv2 -M\"set Exif.Photo.ExposureProgram "$MODE"\" $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	fi
	if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
	       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
		    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
	fi
  fi
 done; break
done
fi
}

#deprecated
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
                APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
	        echo "exiv2 -M\"del Exif.Photo.ExposureProgram\"       $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
                echo "exiv2 -M\"set Exif.Photo.ExposureProgram $MODE\" $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		echo 'ExposureProgram' >> $HOME/tmp/add_exif/added
#		echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
	 fi
done
rm $HOME/tmp/add_exif/.exifprogramhistory
fi
}

#deprecated
APERTUREOLD () {
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

         APPLYON=`cat "$HOME"/.add_exif.config/apply_on`

	 if [ "$OUT" = "X" ]
	   then echo "skipping..."
	   else sed --in-place '/Exif.Photo.FNumber/d' "$DIR"/script.$FILENAME.out
	        echo "exiv2 -M\"del Exif.Photo.FNumber\" modify 		     $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
    	   case "$OUT" in
     	  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|18|20|22|32|45|64|90|125|128|135|180|256|360|512)
	      sed --in-place '/Exif.Photo.FNumber/d' "$DIR"/script.$FILENAME.out
     	      echo "exiv2 -M\"add Exif.Photo.FNumber Rational $OUT/1\" modify  $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out ;;
     	  0.95|1.1|1.2|1.4|1.5|1.6|1.7|1.8|1.9|2.2|2.4|2.5|2.6|2.7|2.8|2.9|3.2|3.3|3.5|4.5|4.8|5.6|6.3|6.7|7.1|9.5)
	      sed --in-place '/Exif.Photo.FNumber/d' "$DIR"/script.$FILENAME.out
	      OUT=`echo "$OUT"|sed 's/\.//g'`
     	      echo "exiv2 -M\"add Exif.Photo.FNumber Rational $OUT/10\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out ;;
       	  0.95|1,1|1,2|1,4|1,5|1,6|1,7|1,8|1,9|2,2|2,4|2,5|2,6|2,7|2,8|2,9|3,2|3,3|3,5|4,5|4,8|5,6|6,3|6,7|7,1|9,5)
	      sed --in-place '/Exif.Photo.FNumber/d' "$DIR"/script.$FILENAME.out
	      OUT=`echo "$OUT"|sed 's/\,//g'`
       	      echo "exiv2 -M\"add Exif.Photo.FNumber Rational $OUT/10\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out ;;
	      *)echo "As that number was not in the existing list (for script to adjust)
you will have to type it again, but like this:
f/3.2 is written: 32/10 but f/20 (without decimal) is written 20/1
Whatever you write will be accepted and sent to script-file, without any corrections.

(OR type X to skip!)"
	      read OUT
	      if [ "$OUT" != "X" ]
	      then sed --in-place '/Exif.Photo.FNumber/d' "$DIR"/script.$FILENAME.out
	      	   echo "exiv2 -M\"add Exif.Photo.FNumber Rational $OUT\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	      fi ;;
    	 esac
	 fi
	if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
	       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
		    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
	fi
	 echo 'FNumber' >> $HOME/tmp/add_exif/added
#	 echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
done
fi
}


APERTURE () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ] 
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
       sed --in-place '/Exif.Photo.FNumber/d' "$X"
     done
else
clear

ALL=N
ASK=N

for X in $(cat $HOME/tmp/add_exif/.list);
do
  FULLNAME=$(basename "$X")
  FILENAME="${FULLNAME%.*}"
#DEKLARERAD DIR=$(dirname $X | se\'//g)

if [ -e "$HOME"/tmp/add_exif/.aperture ]
	then SP=`cat $HOME/tmp/add_exif/.aperture|awk '{print $1}'`
	else SP="f/"
fi

if [ $ALL = N ]
	then OUT=$(dialog --title "Aperture" --inputbox "Example:
- f/5.6
- Type X do skip this file.

$FILENAME
" 0 0 "$SP" --output-fd 1) 
	else OUT="$SP"
fi

#cat $HOME/tmp/add_exif/.list|wc -l
#read bah

if [ `cat $HOME/tmp/add_exif/.list|wc -l` -ge "1" ]
	then if [ $ALL = N -a $ASK = N ]
		then $(dialog --title "Aperture" --defaultno --yesno "Same setting for all?" 0 0 --output-fd 1)
			if [ $? = 0 ]
		  		then ALL=Y
		       		     ASK=Y
		  		else ASK=Y
			fi
	     fi
	else ALL=Y
fi

echo "$OUT" > "$HOME"/tmp/add_exif/.aperture

if [ `echo $OUT|grep "\."|wc -l` = 1 -o `echo $OUT|grep \,|wc -l` = 1 ]
	then OUT="`echo $OUT|cut -d\/ -f2|sed 's/\.//g ; s/,//g'`/10"
	else OUT="`echo $OUT|cut -d\/ -f2`/1"
fi
	 if [ "$OUT" = "X" -o "$OUT" = "X/1" ]
	   then echo "skipping..."
	   else sed --in-place '/Exif.Photo.FNumber/d' "$DIR"/script.$FILENAME.out
		APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
		echo "exiv2 -M\"del Exif.Photo.FNumber Rational $OUT\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		echo "exiv2 -M\"add Exif.Photo.FNumber Rational $OUT\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		fi
	 fi
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
- 1,5 second exposure is written 15/10
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
	   	APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
	        echo "exiv2 -M\"del Exif.Photo.ExposureTime Rational\" modify      $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
    	        echo "exiv2 -M\"add Exif.Photo.ExposureTime Rational $OUT\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	        echo 'ExposureTime' >> $HOME/tmp/add_exif/added
#                echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
		if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		fi
	 fi
done
fi
}
 
#to be deprecated...
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

	  case "$OUT" in
		X|x);;
		*) sed --in-place '/Exif.Photo.FocalLength/d' "$DIR"/script.$FILENAME.out
		   APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
		   echo "exiv2 -M\"del Exif.Photo.FocalLength Rational\" modify        $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
           	   echo "exiv2 -M\"set Exif.Photo.FocalLength Rational $OUT/1\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		fi;;
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

if [ `cat $HOME/tmp/add_exif/.list|wc -l` -gt "1" ]
	then dialog --title "Lens and focal length" --yesno "All files selected? (or none)" 0 0
		case $? in
			0) MARKING=on ;;
			1) MARKING=off;;
		esac
	else MARKING=on
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
         if [ "$AMOUNT" -eq `cat $HOME/tmp/add_exif/.list|wc -l` ]; then AMOUNT=ALL ; fi
         EXTRA="$AMOUNT of the files in dir has set LENSMODEL data."
fi

##########################
#exit 0
##########################

choise=$(/usr/bin/dialog --checklist "LENSMODEL:

Chose one or more files for EACH lens

!!! Make sure to MARK in the list, !!!
!!!   Otherwise nothing is added   !!!

$EXTRA

" 0 0 0 $pkglist --output-fd 1)

if [ -z "$choise" ]
 then break
fi

#Filtrera bort automatiskt skräp:
#choise=`echo $choise | tr " " "\n"`
#version 2: Ta även bort \ och " som kommer när det är specialtecken i filnamnet:
choise=$(echo $choise | tr " " "\n"| sed 's/\"//g; s/\\//g')

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
		for pkg in $(grep "$MAKERVALUE" "$LENSLIST" | cut -d'?' -f1|sort|uniq|sed 's/ /_/g')
			do MAKER="$MAKER $pkg -"
		done

		MAKERMODEL=$(cut -d'?' -f2 "$LENSLIST")

		#List all makers (first field in lenses-file)
		MAKERVALUE=$(/usr/bin/dialog --stdout --title "Choose mount" --menu "Lens MOUNT:" 0 0 0 $MAKER --output-fd 1)
		
		if [ -n "$MAKERVALUE" ];
		  then MAKERVALUE=`echo $MAKERVALUE|sed 's/_/ /g'`
		       F1=`grep "$MAKERVALUE" "$LENSLIST" | cut -d'?' -f2|sed 's/ /_/g'`
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


	else dialog --title "No config file" --msgbox "There is no ready config with lenses
So I create one!

Follow the instructions further to create a lens.
- Since lenses can be adapted between camera manufacturers, I hade this so that firstly
  you set a parent directory using the lens mounts name, and then comes the actual lens name
  And after the lens name comes a focallength spec. Since focal is not allways in the lens name.

Example: 
  Canon FD --> CANON LENS FD 24mm 1:2.8 --> 24mm" 0 0
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

		for LIST in $(cat $HOME/tmp/add_exif/.lenslist); do
		FULLNAME=$(basename "$LIST")
		FILENAME="${FULLNAME%.*}"
#DEKLARERAD		DIR=$(dirname "$LIST" | sed s/\'//g)
		#Remove old data:

		   sed --in-place '/Exif.Photo.LensModel/d' "$DIR"/script.$FILENAME.out 2>/dev/null
		#Add new data:
		   LENSUSED1=`echo $LENSUSED|sed 's/_/ /g'`
                   sed --in-place '/Exif.Photo.LensModel/d' "$DIR"/script.$FILENAME.out
		   APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
		   echo "exiv2 -M\"set Exif.Photo.LensModel $LENSUSED1\" modify        $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		fi

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
                        APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
		   	echo "exiv2 -M\"set Exif.Photo.FocalLength Rational $F3/1\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
			if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
			       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
				    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
			fi
		   else FOCALL=$(dialog --title "focal length" --inputbox "There is no focal length for that setting, so please type the focal...

$FILENAME

ex. 75 or 75mm or leave blank to skip.
" 0 0 "$FOCALL" --output-fd 1)
			if [ ! -z "$FOCALL" ]
			  then FOCALL=`echo $FOCALL|sed 's/mm//g'`
			       if [ "$FOCALL" -lt 10000 2>/dev/null ]
				 then sed --in-place '/Exif.Photo.FocalLength/d' "$DIR"/script.$FILENAME.out
				      echo "exiv2 -M\"set Exif.Photo.FocalLength Rational $FOCALL/1\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
				 else echo fail ; read
			       fi
		   	  else  if [ `grep Exif.Photo.FocalLength "$DIR"/script.$FILENAME.out|wc -l` -lt 1 ]
                           		then echo "FocalLength `echo $F3` NOT added to exif!"
				fi
		   		#sleep 1
			fi
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
		then dialog --title "Lenses" --yesno "Add lenses?" 0 0
		if [ $? = 0 ]
		   then ADDLENS
		   else break
		fi 
	fi
fi
}



FILM () {
# remove old tag if remove action was used to start script.
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
	then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
	       sed --in-place '/Film:/d' "$X"
#	       sed --in-place '/Developer:/d' "$X"
	     done
	else ADDFILM

#Loop to return to menu after being done with the first selected
fi
}



ADDFILM () {

FILE=""
OPT=""

while true; do
pkglist=""
pkg=""
MA=""
MO=""

#If there is only one file, then select it. Otherwise ask.
if [ `cat $HOME/tmp/add_exif/.list|wc -l` -gt "1" ]
	then dialog --title "Film" --yesno "All files selected? (or none)" 0 0
		case $? in
			0) MARKING=on ;;
			1) MARKING=off;;
		esac
	else MARKING=on
fi

#list files
for pkg in $(cat $HOME/tmp/add_exif/.list)
	do
FILE=$(echo "$DIR"/script.`echo "$pkg"|sed 's/\./ /g'|awk '{print $1}'`.out)
#echo $FILE
if [ -e "$FILE" ]
	then if [ `grep 'Exif.Photo.UserComment Film:' "$FILE"|wc -l` = "1" ]
	       then MA=`grep 'Exif.Photo.UserComment Film:' "$FILE"|sed 's/exiv2\ -M\"add\ Exif.Photo.UserComment\ Film://g'|cut -d'"' -f1|awk '{$1=$1};1'`
	       else MA="~"
	     fi
#	     if [ `grep 'Exif.Photo.UserComment Developer:' "$FILE"|wc -l` = "1" ]
#	       then MO=`grep 'Exif.Photo.UserComment Developer:' "$FILE"|sed 's/add//g'|sed 's/exiv2\ \-M\"\ Exif\.Photo\.UserComment\ Developer://g ; s/\"//g ; s/modify//g'|rev|awk '{print $2 " " $3}'|rev|awk '{$1=$1};1'`
#	       else MO="~"
#	     fi
	else echo "no existing script file in dir."
	     MA="~"
	     MO="~"
fi


if [ "$MA" = "~" -a "$MO" = "~" ]
	then OPT="~"
	else OPT=`echo $MA $MO|sed 's/\ /_/g'`
fi
pkglist="$pkglist $pkg "$OPT" "$MARKING" "
done

if [ `ls "$DIR"/script.*|wc -l` -ge 1 ]
  then AMOUNT=$(grep 'Exif.Photo.UserComment Film:' "$DIR"/script.*|wc -l)
	 if [ "$AMOUNT" -eq `cat $HOME/tmp/add_exif/.list|wc -l` ]; then AMOUNT=ALL ; fi
	 EXTRA="$AMOUNT of these chosen files allready has a Film set."
fi

rm -rf "$HOME"/tmp/add_exif/.choise

echo bah
CHOISE=$(/usr/bin/dialog --checklist "Film" 0 0 0 $pkglist --output-fd 1 )

if [ -z "$CHOISE" ]
	then break 0
fi

for B in $CHOISE
do echo "$B" 2>&1 >>"$HOME"/tmp/add_exif/.choise
done

#done

ADDFILM () {
MA='~'
MO='~'

if [ ! -e "$HOME"/.add_exif.config/film ]
	then SHOW='Ex. Ilford'
	else SHOW=`cat "$HOME"/.add_exif.config/film|cut -d'?' -f1|sort|uniq`
	     SHOW="Added allready:
$SHOW

Write one already existing
OR a new manufacturer"
fi

MA=$(dialog --title "Film maker" --inputbox "Write the film MANUFACTURER

$SHOW

" 0 0 --output-fd 1)

if [ ! -e "$HOME"/.add_exif.config/film ]
	then SHOW='Ex. HP5+ 400'
	else SHOW=`cat "$HOME"/.add_exif.config/film|grep "$MA"|cut -d'?' -f2`
	     SHOW="Added allready:
$SHOW"
fi

MO=$(dialog --title "Film model" --inputbox "Write the film TYPE

$SHOW

" 0 0 --output-fd 1)

if [ "$MO" != '~' -a "$MA" != '~' ]
	then echo "$MA?$MO" >> "$HOME"/.add_exif.config/film
	     echo "$MA?$MO" > $HOME/tmp/add_exif/film
fi

if [ "$MA" != '~' -a "$MO" = '~' ]
	then echo "$MA?" >> "$HOME"/.add_exif.config/film
	     echo "$MA" > $HOME/tmp/add_exif/film
fi
}

LISTFILMS () {
LIST="$HOME/.add_exif.config/film"
pkg=""
MAKER=""
MODEL=""
MO='~'
MA='~'
for pkg in $(cut -d'?' -f1 "$HOME"/.add_exif.config/film|sort|uniq)
	do MAKER="$MAKER $pkg -"
done
MA=$(/usr/bin/dialog --stdout --title "Manufacturer" --menu "Film MANUFACTURER:" 0 0 0 $MAKER --output-fd 1)

if [ ! -z "$MA" ]
  then pkg=""
	for pkg in $(grep "$MA" "$HOME"/.add_exif.config/film|cut -d'?' -f2|sort|sed 's/ /_/g')
		do MODEL="$MODEL $pkg -"
	done

	echo "/usr/bin/dialog --stdout --title Model --menu 'Film TYPE:' 0 0 0 $MODEL --output-fd 1"
#	read
	MO=$(/usr/bin/dialog --stdout --title "Model" --menu "Film TYPE:" 0 0 0 $MODEL --output-fd 1)
	if [ -z "$MO" ]
		then dialog --title "No film type" --yesno "Manufacturer selected but no type.
Add a new type to the library and add it to your files?" 0 0
		     case $? in
			0)return 1
                	  echo "$MA" > $HOME/tmp/add_exif/film 
			;;
			1)echo 'no...';;
		     esac
		else echo "$MA?$MO" > $HOME/tmp/add_exif/film
	fi
  else return 1 
fi

}

APPLY () {

MAKE=$(cut -d'?' -f1 $HOME/tmp/add_exif/film)
MODEL=$(cut -d'?' -f2 $HOME/tmp/add_exif/film)
APPLYON=`cat "$HOME"/.add_exif.config/apply_on`

dialog --title "Correct or not" --yesno "
Make: $MAKE
Type: $MODEL
" 0 0 --output-fd 1
ANS=$?

for X in $(cat $HOME/tmp/add_exif/.choise)
do FULLNAME=$(basename "$X")
   FILENAME="${FULLNAME%.*}"

MAKE=`echo $MAKE|sed 's/_/ /g'`
MODEL=`echo $MODEL|sed 's/_/ /g'`


case $ANS in
      0)if [ "${#MAKE}" -gt "2" -a "${#MODEL}" -gt "2" ]
		then sed --in-place '/Exif.Photo.UserComment\ Film:/d' "$DIR"/script.$FILENAME.out
		     MAKE=`echo $MAKE|sed 's/_/ /g'`
#		     echo "exiv2 -M\"set Exif.Image.Make $MAKE\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		     echo "exiv2 -M\"add Exif.Photo.UserComment Film: $MAKE $MODEL\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		     if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		     fi
		else echo "else (1)"
#		     ${#MAKE} is less than 2
#		     ${#MODEL} is less than 2" ; read BAH
	fi
	if [ "${#MAKE}" -gt "1" -a "${#MODEL}" -lt "2" ]
		then sed --in-place '/Exif.Photo.UserComment\ Film:/d' "$DIR"/script.$FILENAME.out
		     MODEL=`echo $MODEL|sed 's/_/ /g'`
		     echo "exiv2 -M\"set Exif.Image.Model $MAKE\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		     echo "exiv2 -M\"add Exif.Photo.UserComment Film: $MAKE\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		     if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		     fi
		else echo "else (2)"
#		     ${#MAKE} is more than 1
#		     ${#MODEL} is less than 2 " ; read BAH
	fi;;
 1) echo MEH
#    read BAH ;;
esac
done
}

if [ -e "$HOME"/.add_exif.config/film ] 
	then LISTFILMS || ADDFILM
	     APPLY
	else ADDFILM
	     APPLY
fi
done
}



DEVELOPMENT () {
# remove old tag if remove action was used to start script.
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
	then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
	       sed --in-place '/Developed:/d' "$X"
#	       sed --in-place '/Developer:/d' "$X"
	     done
	else ADDDEV

#Loop to return to menu after being done with the first selected
fi
}



ADDDEV () {

FILE=""
OPT=""

while true; do
pkglist=""
pkg=""
MA=""
MO=""

#If there is only one file, then select it. Otherwise ask.
if [ `cat $HOME/tmp/add_exif/.list|wc -l` -gt "1" ]
	then dialog --title "Developed" --yesno "All files selected? (or none)" 0 0
		case $? in
			0) MARKING=on ;;
			1) MARKING=off;;
		esac
	else MARKING=on
fi

#list files
for pkg in $(cat $HOME/tmp/add_exif/.list)
	do
FILE=$(echo "$DIR"/script.`echo "$pkg"|sed 's/\./ /g'|awk '{print $1}'`.out)
#echo $FILE
if [ -e "$FILE" ]
	then if [ `grep 'Exif.Photo.UserComment Developed:' "$FILE"|wc -l` = "1" ]
	       then MA=`grep 'Exif.Photo.UserComment Developed:' "$FILE"|sed 's/exiv2\ -M\"add\ Exif.Photo.UserComment\ Developed://g'|cut -d'"' -f1|awk '{$1=$1};1'`
	       else MA="~"
	     fi
#	     if [ `grep 'Exif.Photo.UserComment Developer:' "$FILE"|wc -l` = "1" ]
#	       then MO=`grep 'Exif.Photo.UserComment Developer:' "$FILE"|sed 's/add//g'|sed 's/exiv2\ \-M\"\ Exif\.Photo\.UserComment\ Developer://g ; s/\"//g ; s/modify//g'|rev|awk '{print $2 " " $3}'|rev|awk '{$1=$1};1'`
#	       else MO="~"
#	     fi
	else echo "no existing script file in dir."
	     MA="~"
	     MO="~"
fi


if [ "$MA" = "~" -a "$MO" = "~" ]
	then OPT="~"
	else OPT=`echo $MA $MO|sed 's/\ /_/g'`
fi
pkglist="$pkglist $pkg "$OPT" "$MARKING" "
done

if [ `ls "$DIR"/script.*|wc -l` -ge 1 ]
  then AMOUNT=$(grep 'Exif.Photo.UserComment Developed:' "$DIR"/script.*|wc -l)
	 if [ "$AMOUNT" -eq `cat $HOME/tmp/add_exif/.list|wc -l` ]; then AMOUNT=ALL ; fi
	 EXTRA="$AMOUNT of these chosen files allready has a chosen Development."
fi

rm -rf "$HOME"/tmp/add_exif/.choise

echo bah
CHOISE=$(/usr/bin/dialog --checklist "Development" 0 0 0 $pkglist --output-fd 1 )

if [ -z "$CHOISE" ]
	then break 0
fi

for B in $CHOISE
do echo "$B" 2>&1 >>"$HOME"/tmp/add_exif/.choise
done

#done

ADDDEV () {
MA='~'
MO='~'

if [ ! -e "$HOME"/.add_exif.config/dev ]
	then SHOW='Ex. Compard R09 One Shot'
	else SHOW=`cat "$HOME"/.add_exif.config/dev|cut -d'?' -f1|sort|uniq`
	     SHOW="Added allready:
$SHOW"
fi

MA=$(dialog --title "Dev maker" --inputbox "Write what dev you are using

$SHOW

" 0 0 --output-fd 1)

if [ ! -e "$HOME"/.add_exif.config/dev ]
	then SHOW='Ex. Continous agitation, 60 min'
	else SHOW=`cat "$HOME"/.add_exif.config/dev|grep "$MA"|cut -d'?' -f2`
	     SHOW="Added allready:
$SHOW"
fi

MO=$(dialog --title "Dev" --inputbox "Write your development technique

$SHOW

" 0 0 --output-fd 1)

if [ "$MO" != '~' -a "$MA" != '~' ]
	then echo "$MA?$MO" >> "$HOME"/.add_exif.config/dev
	     echo "$MA?$MO" > $HOME/tmp/add_exif/dev
fi

if [ "$MA" != '~' -a "$MO" = '~' ]
	then echo "$MA?" >> "$HOME"/.add_exif.config/dev
	     echo "$MA" > $HOME/tmp/add_exif/dev
fi
}

LISTDEVS () {
LIST="$HOME/.add_exif.config/dev"
pkg=""
MAKER=""
MODEL=""
MO='~'
MA='~'
for pkg in $(cut -d'?' -f1 "$HOME"/.add_exif.config/dev|sort|uniq|sed 's/ /_/g')
	do MAKER="$MAKER $pkg -"
done
MA=$(/usr/bin/dialog --stdout --title "DEV" --menu "Developed:" 0 0 0 $MAKER --output-fd 1)

#echo "\$MA = $MA"
#read

if [ ! -z "$MA" ]
  then pkg=""
  	MA=`echo $MA|sed 's/_/ /g'`
#	for pkg in $(grep "$MA" "$HOME"/.add_exif.config/dev|sed 's/_/ /g'|cut -d'?' -f2|sort|sed 's/ /_/g')
        for pkg in $(grep "$MA" "$HOME"/.add_exif.config/dev|cut -d'?' -f2 |sort|uniq|sed 's/ /_/g')
		do MODEL="$MODEL $pkg -"
	done

	echo "$MODEL"

	MO=$(/usr/bin/dialog --stdout --title "Technique" --menu "Developed:" 0 0 0 $MODEL --output-fd 1)
#       echo "/usr/bin/dialog --stdout --title Model --menu Developed: 0 0 0 $MODEL --output-fd 1"
# 	read
	if [ -z "$MO" ]
		then dialog --title "No dev technique" --yesno "Developer selected but no technique.
Add a new technique to the library and add it to your files?" 0 0
		     case $? in
			0)return 1;;
			1)echo 'no...'
                          echo "$MA?0" > $HOME/tmp/add_exif/dev
			;;
		     esac
		else echo "$MA?$MO" > $HOME/tmp/add_exif/dev
	fi
  else return 1 
fi

}

APPLY () {

MAKE=$(cut -d'?' -f1 $HOME/tmp/add_exif/dev)
MODEL=$(cut -d'?' -f2 $HOME/tmp/add_exif/dev)
APPLYON=`cat "$HOME"/.add_exif.config/apply_on`

dialog --title "Correct or not" --yesno "

Make: $MAKE
Type: $MODEL
" 10 60 --output-fd 1
ANS=$?

for X in $(cat $HOME/tmp/add_exif/.choise)
do FULLNAME=$(basename "$X")
   FILENAME="${FULLNAME%.*}"

case $ANS in
      0)if [ "${#MAKE}" -gt "2" -a "${#MODEL}" -gt "2" ]
		then sed --in-place '/Exif.Photo.UserComment\ Developed:/d' "$DIR"/script.$FILENAME.out
		     MAKE=`echo $MAKE|sed 's/_/ /g'`
                     MODEL=`echo $MODEL|sed 's/_/ /g'`
#		     echo "exiv2 -M\"set Exif.Image.Make $MAKE\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		     echo "exiv2 -M\"add Exif.Photo.UserComment Developed: $MAKE $MODEL\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		     if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		     fi
		else echo "else (1)"
#		     ${#MAKE} is less than 2
#		     ${#MODEL} is less than 2" ; read BAH
	fi
	if [ "${#MAKE}" -gt "1" -a "${#MODEL}" -lt "2" ]
		then sed --in-place '/Exif.Photo.UserComment\ Developed:/d' "$DIR"/script.$FILENAME.out
		     MODEL=`echo $MODEL|sed 's/_/ /g'`
#		     echo "exiv2 -M\"set Exif.Image.Model $MAKE\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		     echo "exiv2 -M\"add Exif.Photo.UserComment Developed: $MAKE\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		     if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		     fi
		else echo "else (2)"
#		     ${#MAKE} is more than 1
#		     ${#MODEL} is less than 2 " ; read BAH
	fi;;
 1) echo MEH
#    read BAH ;;
esac
done
}

if [ -e "$HOME"/.add_exif.config/dev ] 
	then LISTDEVS || ADDDEV
	     APPLY
	else ADDDEV
	     APPLY
fi
done
}









CAMERA () {

# remove old tag if remove action was used to start script.
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
	then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
	       sed --in-place '/Exif.Image.Make/d' "$X"
	       sed --in-place '/Exif.Image.Model/d' "$X"
	     done
	else ADDCAM

#Loop to return to menu after being done with the first selected
#files, if there are more than one file.
#	if [ `cat $HOME/tmp/add_exif/.list|wc -l` != `cat $HOME/tmp/add_exif/.camlist|wc -l` ]
#		then dialog --title "Cameras" --defaultno --yesno "Add more Cameras?" 0 0
#		if [ $? = 0 ]
#		   then ADDCAM
#		   else break
#		fi 
#	fi
fi
}



ADDCAM () {

FILE=""
OPT=""

while true; do
pkglist=""
pkg=""
MA=""
MO=""

#If there is only one file, then select it. Otherwise ask.
if [ `cat $HOME/tmp/add_exif/.list|wc -l` -gt "1" ]
	then dialog --title "Cam and model" --yesno "All files selected? (or none)" 0 0
		case $? in
			0) MARKING=on ;;
			1) MARKING=off;;
		esac
	else MARKING=on
fi

#list files
for pkg in $(cat $HOME/tmp/add_exif/.list)
	do
FILE=$(echo "$DIR"/script.`echo "$pkg"|sed 's/\./ /g'|awk '{print $1}'`.out)
#echo $FILE
if [ -e "$FILE" ]
	then if [ `grep 'Exif.Image.Make' "$FILE"|wc -l` = "1" ]
	       then MA=`grep 'Exif.Image.Make' "$FILE"|sed 's/add//g ; s/set//g'|sed 's/exiv2\ \-M\"\ Exif\.Image\.Make//g ; s/\"//g ; s/modify//g'|rev|awk '{print $2 " " $3}'|rev|awk '{$1=$1};1'`
	       else MA="~"
	     fi
	     if [ `grep 'Exif.Image.Model' "$FILE"|wc -l` = "1" ]
	       then MO=`grep 'Exif.Image.Model' "$FILE"|sed 's/add//g ; s/set//g'|sed 's/exiv2\ \-M\"\ Exif\.Image\.Model//g ; s/\"//g ; s/modify//g'|rev|awk '{print $2 " " $3}'|rev|awk '{$1=$1};1'`
	       else MO="~"
	     fi
	else echo "no existing script file in dir."
	     MA="~"
	     MO="~"
fi


if [ "$MA" = "~" -a "$MO" = "~" ]
	then OPT="~"
	else OPT=`echo $MA $MO|sed 's/\ /_/g'`
fi
pkglist="$pkglist $pkg "$OPT" "$MARKING" "
done

if [ `ls "$DIR"/script.*|wc -l` -ge 1 ]
  then AMOUNT=$(grep Exif.Image.Model "$DIR"/script.*|wc -l)
	 if [ "$AMOUNT" -eq `cat $HOME/tmp/add_exif/.list|wc -l` ]; then AMOUNT=ALL ; fi
	 EXTRA="$AMOUNT of these chosen files allready has a Camera set."
fi

rm -rf "$HOME"/tmp/add_exif/.choise

#echo bah
CHOISE=$(/usr/bin/dialog --checklist "CAM MODEL" 0 0 0 $pkglist --output-fd 1 )

if [ -z "$CHOISE" ]
	then break 0
fi

for B in $CHOISE
do echo "$B" 2>&1 >>"$HOME"/tmp/add_exif/.choise
done

#done

ADDCAMERA () {
MA='~'
MO='~'

if [ ! -e "$HOME"/.add_exif.config/cameras ]
	then SHOW='Ex. Nikon'
	else SHOW=`cat "$HOME"/.add_exif.config/cameras|cut -d'?' -f1|sort|uniq`
	     SHOW="Added allready:
$SHOW"
fi

MA=$(dialog --title "Camera maker" --inputbox "Write the camera MANUFACTURER

$SHOW

" 0 0 --output-fd 1)

MO=$(dialog --title "Camera model" --inputbox "Write the camera MODEL

EX. FM2a
" 0 0 --output-fd 1)

if [ "$MO" != '~' -a "$MA" != '~' ]
	then echo "$MA?$MO" >> "$HOME"/.add_exif.config/cameras
	     echo "$MA?$MO" > $HOME/tmp/add_exif/cam
fi

if [ "$MA" != '~' -a "$MO" = '~' ]
	then echo "$MA?" >> "$HOME"/.add_exif.config/cameras
	     echo "$MA" > $HOME/tmp/add_exif/cam
fi
}

LISTCAMERAS () {
CAMLIST="$HOME/.add_exif.config/cameras"
pkg=""
MAKER=""
MODEL=""
MO='~'
MA='~'
for pkg in $(cut -d'?' -f1 "$HOME"/.add_exif.config/cameras|sort|uniq|sed 's/ /_/g')
	do MAKER="$MAKER $pkg -"
done
MA=$(/usr/bin/dialog --stdout --title "Manufacturer" --menu "Camera MANUFACTURER:" 0 0 0 $MAKER --output-fd 1)
#echo $MA
#read bah
#exit 0

if [ ! -z "$MA" ]
  then pkg=""
	for pkg in $(grep "`echo $MA|sed 's/_/ /g'`" "$HOME"/.add_exif.config/cameras|cut -d'?' -f2|sort|sed 's/ /_/g')
		do MODEL="$MODEL $pkg -"
	done

	echo "/usr/bin/dialog --stdout --title Model --menu 'Camera MODEL:' 0 0 0 $MODEL --output-fd 1"
#	read
	MO=$(/usr/bin/dialog --stdout --title "Model" --menu "Camera MODEL:" 0 0 0 $MODEL --output-fd 1)
	if [ -z "$MO" ]
		then dialog --title "No camera model" --yesno "Manufacturer selected but no model.
Add a new model to the library and add it to your files?" 0 0
		     case $? in
		     	0)return 1;;
			1)echo 'no...';;
		     esac
		else echo "$MA?$MO" > $HOME/tmp/add_exif/cam
	fi
  else return 1 
fi

}

APPLY () {

MAKE=$(cut -d'?' -f1 $HOME/tmp/add_exif/cam)
MODEL=$(cut -d'?' -f2 $HOME/tmp/add_exif/cam)
APPLYON=`cat "$HOME"/.add_exif.config/apply_on`

dialog --title "Correct or not" --yesno "
Make:  $MAKE
Model: $MODEL
" 0 0 --output-fd 1
ANS=$?

for X in $(cat $HOME/tmp/add_exif/.choise)
do FULLNAME=$(basename "$X")
   FILENAME="${FULLNAME%.*}"

case $ANS in
      0)if [ "${#MAKE}" -gt "1" ]
		then sed --in-place '/Exif.Image.Make/d' "$DIR"/script.$FILENAME.out
		     MAKE=`echo $MAKE|sed 's/_/ /g'`
		     echo "exiv2 -M\"set Exif.Image.Make $MAKE\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		     if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		     fi
		else echo else ; read BAH
	fi
	if [ "${#MODEL}" -ge "1" -a "$MODEL" != " " ]
	        then sed --in-place '/Exif.Image.Model/d' "$DIR"/script.$FILENAME.out
		     MODEL=`echo $MODEL|sed 's/_/ /g'`
		     echo "exiv2 -M\"set Exif.Image.Model $MODEL\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		     if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		     fi
		else echo else ; read BAH
	fi;;
 1) echo MEH
#    read BAH ;;
esac
done
}

if [ -e "$HOME"/.add_exif.config/cameras ] 
	then LISTCAMERAS || ADDCAMERA
	     APPLY
	else ADDCAMERA
	     APPLY
fi
done
}


GPSDATA () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]  
then for X in `cat $HOME/tmp/add_exif/.remove.list`; do
       sed --in-place '/Exif.GPSInfo/d' "$X"
       sed --in-place '/GPS\ Data:/d' "$X"
       sed --in-place '/GPS\ End./d' "$X"
     done
fi

#bort med ev. gammnal fil.
rm -rf /$HOME/tmp/add_exif/.gps

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

#echo $choise
#echo "$choise"|wc -l
#read ANS

if [ ${#choise} -ge 3 ];
	then dialog --title "List of files" --inputbox "Write your GPS tag using one of these following formats:

Will apply on: $choise

N 64 32 5.3, E 12 24 3.6
60 10 11.5N 024 57 06.4E
48°51'29.60\"N 2°17'36.90\"E

Must be, degrees, minutes AND seconds!" 0 0 " " 2>$HOME/tmp/add_exif/.gps
#	else dialog --title "Error" --msgbox "No files selected"
fi

#format some coordinates to fit accoordingly:
sed -i s/\'/\ /g $HOME/tmp/add_exif/.gps ; sed -i 's/\"//g ; s/°/ /g' $HOME/tmp/add_exif/.gps


# sed removed empty spaces in the beginning of the gps-string:
OUT=`cat $HOME/tmp/add_exif/.gps | sed -e 's/^[ \t]*//'`

if [ -z "$OUT" ]
  then echo "NO..." ; OUT=NOGPS
  else echo "YES!";




###### 60 10 11.5N 024 57 06.4E ######
#### 48°51'29.60\"N 2°17'36.90\"E ####

if [[ "$OUT" =~ ^[0-9]{1,2}\ [0-9]{1,2}\ [0-9]{1,2}\.[0-9]{1,2}[N,S]\ [0-9]{1,3}\ [0-9]{1,2}\ [0-9]{1,2}\.[0-9]{1,2}[W,E]$ ]]
  then		 G1=`echo "$OUT"|awk '{print $1}'|awk '{print $0"/1"}'|sed 's/^0//'`
  		 if [ `echo "$OUT"|awk '{print $2}'` = "0" ]
		 	then G2=`echo "$OUT"|awk '{print $2}'|awk '{print $0"/1"}'`
		 	else G2=`echo "$OUT"|awk '{print $2}'|awk '{print $0"/1"}'|sed 's/^0//'`
		 fi
		 G3=`echo "$OUT"|awk '{print $3}'|sed 's/\.//g'|cut -c -3|awk '{print $0"/10"}'|sed 's/^0//'`
		 G4=`echo "$OUT"|awk '{print $4}'|awk '{print $0"/1"}'|sed 's/^0//'`
  		 if [ `echo "$OUT"|awk '{print $5}'` = "0" ]
		 	then G5=`echo "$OUT"|awk '{print $5}'|awk '{print $0"/1"}'`
		 	else G5=`echo "$OUT"|awk '{print $5}'|awk '{print $0"/1"}'|sed 's/^0//'`
		 fi
		 G6=`echo "$OUT"|awk '{print $6}'|sed 's/\.//g'|cut -c -3|awk '{print $0"/10"}'|sed 's/^0//'`
		GNS=`echo "$OUT"|awk '{print $3}'|rev|cut -c -1`
		GWE=`echo "$OUT"|awk '{print $6}'|rev|cut -c -1`

#echo "OUT $OUT"
#echo "G1=$G1 G2=$G2 G3=$G3"
#read
#exit 0

#		echo "before $choise"
		choise=$(echo $choise | tr " " "\n"|sed 's/\"//g; s/\\//g')
		echo "$choise" > $HOME/tmp/add_exif/.gpslist

		for LIST in `cat $HOME/tmp/add_exif/.gpslist`; do

		FULLNAME=$(basename "$LIST")
		FILENAME="${FULLNAME%.*}"
		       sed --in-place '/Exif.GPSInfo/d' "$DIR"/script.$FILENAME.out
		       sed --in-place '/GPS\ Data:/d' "$DIR"/script.$FILENAME.out
		       sed --in-place '/GPS\ End./d' "$DIR"/script.$FILENAME.out
#		   echo "$FILENAME ..."
		   echo 1
		   echo " 
# GPS Data:"  >> "$DIR"/script.$FILENAME.out
#		   sed --in-place '/Exif.GPSInfo/d' "$X"
#		   sed --in-place '/GPS\ Data:/d' "$X"
#		   sed --in-place '/GPS\ End./d' "$X"
		   APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
		   echo "exiv2 -M\"del Exif.GPSInfo.GPSLatitudeRef\" modify        $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		   echo "exiv2 -M\"add Exif.GPSInfo.GPSLatitudeRef $GNS\" modify        $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		   echo "exiv2 -M\"del Exif.GPSInfo.GPSLongitudeRef\" modify     $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		   echo "exiv2 -M\"add Exif.GPSInfo.GPSLongitudeRef $GWE\" modify     $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		   echo "exiv2 -M\"set Exif.GPSInfo.GPSLatitude $G1 $G2 $G3\" modify     $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		   echo "exiv2 -M\"set Exif.GPSInfo.GPSLongitude $G4 $G5 $G6\" modify     $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		   echo "# GPS End.
   "  >> "$DIR"/script.$FILENAME.out
   		   echo 3
		if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		fi
	      	done
  else echo "nope.."
 fi




###### N 64 32 5.3, E 12 24 3.6 #######

if [[ "$OUT" =~ ^[N,S]\ [0-9]{1,2}\ [0-9]{1,2}\ [0-9]{1,2}\.[0-9]{1,2}\,\ [W,E]\ [0-9]{1,2}\ [0-9]{1,2}\ [0-9]{1,2}\.[0-9]{1,2}$ ]]
  then	        GPS1=`echo "$OUT" | awk '{print $1}'`
		GPS2=`echo "$OUT" | awk '{print $2}'`
#		echo 4a
		if [ "$GPS2" = `echo "$GPS2" | sed 's/\.//g'` ]
		  then BY1=1
		  else BY1=10
		fi

		GPS3=`echo "$OUT" | awk '{print $3}'`
		if [ "$GPS3" = `echo "$GPS3" | sed 's/\.//g'` ]
		  then BY2=1
		  else BY2=10
		fi
#                echo 4b
		GPS4=`echo "$OUT" | awk '{print $4}' | sed 's/,//g'`
		if [ "$GPS4" = `echo "$GPS4" | sed 's/\.//g'` ]
		  then BY3=1
		  else BY3=10
		       GPS4=`echo $GPS4 | sed 's/\.//g'`
		fi
#                echo 4c
		GPS5=`echo "$OUT" | awk '{print $5}'`

		GPS6=`echo "$OUT" | awk '{print $6}'`
		if [ "$GPS6" = `echo "$GPS6" | sed 's/\.//g'` ]
		  then BY4=1
		  else BY4=10
		fi
#                echo 4d
		GPS7=`echo "$OUT" | awk '{print $7}'`
		if [ "$GPS7" = `echo "$GPS7" | sed 's/\.//g'` ]
		  then BY5=1
		  else BY5=10
		fi
#                echo 4e
		GPS8=`echo "$OUT" | awk '{print $8}'`
		if [ "$GPS8" = `echo "$GPS8" | sed 's/\.//g'` ]
		  then BY6=1
		  else BY6=10
		       GPS8=`echo $GPS8 | sed 's/\.//g'`
		fi
#	echo 5
#read bah
	choise=$(echo $choise | tr " " "\n"|sed 's/\"//g; s/\\//g')
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
#	   sed --in-place '/Exif.GPSInfo/d' "$X"
#	   sed --in-place '/GPS\ Data:/d' "$X"
#	   sed --in-place '/GPS\ End./d' "$X"
	   APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
	   echo "exiv2 -M\"del Exif.GPSInfo.GPSLatitudeRef\" modify        $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	   echo "exiv2 -M\"add Exif.GPSInfo.GPSLatitudeRef $GPS1\" modify        $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	   echo "exiv2 -M\"del Exif.GPSInfo.GPSLongitudeRef\" modify     $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	   echo "exiv2 -M\"add Exif.GPSInfo.GPSLongitudeRef $GPS5\" modify     $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	   echo "exiv2 -M\"set Exif.GPSInfo.GPSLatitude $GPS2/$BY1 $GPS3/$BY2 $GPS4/$BY3\" modify     $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	   echo "exiv2 -M\"set Exif.GPSInfo.GPSLongitude $GPS6/$BY4 $GPS7/$BY5 $GPS8/$BY6\" modify     $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
	   echo "# GPS End.
"  >> "$DIR"/script.$FILENAME.out
	if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
	       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
		    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
	fi
        echo 6
   done
  else echo "nope"
 fi

if [ `grep GPSLatitude "$DIR"/script.$FILENAME.out|wc -l` -lt 1 ]; then dialog --title "Error" --msgbox 'The formating on that coordinate was WRONG, please start over.' 0 0 ; fi
 

fi

#read BAH
#TODO
#- konvertera googles decimal-coordinater till "vanliga" finns info här:
#  https://gis.stackexchange.com/questions/62103/how-do-you-convert-to-degrees-and-minutes-from-8-9-digit-lat-lon-dms-code
#- If bara en bild, eller alla är taggade = nej, annars ja! (nu är det default = nej)

#dialog --title "Coordinates" --defaultyes --yesno "Add more coordinates?" 0 0
#if [ $? = 1 ]
# then break
# else echo "om igen..." 
#fi

#End of menu-loop:
done

if [ $? = 2 ]
  then exit 0
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

if [ `cat $HOME/tmp/add_exif/.list|wc -l` -gt 1 ]
	then dialog --title "One ISO-setting for all?" --defaultno --yesno "Is this about more than one ISO?" 0 0
	else echo "Just one file."
fi

# clear

 if [ $? = 1 ]
 then clear 
     echo ""
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
	  if [ $PUSH1 -eq $PUSH2 ]; then break ; fi
	  APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
          if [ "$PUSH1" -gt "$PUSH2" ]
            then sed --in-place '/pulled/d' "$DIR"/script.$FILENAME.out
	    	 echo "exiv2 -M\"add Exif.Photo.UserComment $PUSH1 pulled to $PUSH2\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
            else sed --in-place '/pushed/d' "$DIR"/script.$FILENAME.out
	         echo "exiv2 -M\"add Exif.Photo.UserComment $PUSH1 pushed to $PUSH2\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
          fi
	if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
	       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
		    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
	fi
#          echo 'Push' >> $HOME/tmp/add_exif/added
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
	   APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
           echo "exiv2 -M\"del Exif.Photo.ISOSpeedRatings\"      $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
           echo "exiv2 -M\"set Exif.Photo.ISOSpeedRatings $OUT\" $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
           echo 'ISOSpeedRatings' >> $HOME/tmp/add_exif/added
           echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
           done
     fi


 else clear
      echo "-----------------------[ SEVERAL ISOs ]-------------------"
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
       n|N|Nej|No|NO|no) echo "Set ISO or [Enter] to use same as last: `cat $HOME/tmp/add_exif/.exifisohistory 2>/dev/null`"
          read OUT
	  if [ -z $OUT ]
            then OUT=`cat $HOME/tmp/add_exif/.exifisohistory`
          fi
          ;;
       *) echo 'From: (ex: 100)'
          read OUT
          echo 'to: (ex: 200)'
          read PUSH2
	  APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
          if [ "$OUT" -gt "$PUSH2" ]
            then sed --in-place '/pulled/d' "$DIR"/script.$FILENAME.out
	         echo "exiv2 -M\"add Exif.Photo.UserComment $OUT pulled to $PUSH2\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
            else sed --in-place '/pushed/d' "$DIR"/script.$FILENAME.out
	         echo "exiv2 -M\"add Exif.Photo.UserComment $OUT pushed to $PUSH2\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
          fi
	  echo "$OUT" > $HOME/tmp/add_exif/.exifisohistory
          OUT="$PUSH2"
          ;;
     esac
         sed --in-place '/Exif.Photo.ISOSpeedRatings/d' "$DIR"/script.$FILENAME.out
	 APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
	 echo "exiv2 -M\"del Exif.Photo.ISOSpeedRatings\"      $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
         echo "exiv2 -M\"set Exif.Photo.ISOSpeedRatings $OUT\" $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
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
       sed --in-place '/Exif.Image.Artist/d ; /Exif.Image.Copyright/d' "$X"
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
  APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
  sed --in-place '/Exif.Image.Artist/d ; /Exif.Image.Copyright/d' "$DIR"/script.$FILENAME.out
  echo "exiv2 -M\"set Exif.Image.Artist $MAIL\"           $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
  echo "exiv2 -M\"del Exif.Image.Artist\" 		 $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
  echo "exiv2 -M\"set Exif.Image.Copyright $MAIL\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
  echo 'Artist'    >> $HOME/tmp/add_exif/added
  echo 'Copyright' >> $HOME/tmp/add_exif/added
	if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
	       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
		    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
	fi
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
GIMPVERSION=`gimp --version|awk '{print $6}' 2>/dev/null`

	 echo ""
	 echo "------------------[ Scanner and software ]------------"
         echo "Software/scanner [Gimp $GIMPVERSION and Nikon Coolscan V ED]"
	 echo "(1) Gimp $GIMPVERSION and Nikon Coolscan V ED"
	 echo "(2) Gimp $GIMPVERSION and Epson V500 flatbed"
	 echo "(3) Gimp $GIMPVERSION and Epson (other)"
	 echo "(4) Gimp $GIMPVERSION and Nikon Coolscan 8000 ED"
	 echo "(5) Vuescan no scanner"
	 echo "(6) DSLR"
	 echo "(7) DSLR, re-use: `cat $HOME/.add_exif.config/dslr 2>/dev/null||echo '(no older settings found)'`"
	 echo "(8) Gimp $GIMPVERSION and Canon CanoScan 9000F"
	 echo "(9) Gimp $GIMPVERSION and Epson Perfection V700"
	 echo "(10) Other [write what you used]"
	 echo "(11) None"
	 read OUT
	 if [ -z "$OUT" ]
	   then echo "Skipping..."
           else case "$OUT" in
		   1)SOFTWARE="Gimp $GIMPVERSION"
		     SCANNER="Nikon Coolscan V ED";;
		   2)SOFTWARE="Gimp $GIMPVERSION"
		     SCANNER="Epson Perfection V500 Photo";;
		   3)echo "Which model?"
	             echo "(1) V700"
	             echo "(2) V750"
		     echo "(3) 1240u"
		     echo "(4) 1240u"
		     echo "(5) 1240u"
	             echo "(6) Other"
	             read SCANNER
	             case "$SCANNER" in
	               1)SCANNER="Epson Perfection V700 Photo";;
	               2)SCANNER="Epson Perfection V750 Pro";;
		       3)SCANNER="Epson Perfection V800 Photo";;
		       4)SCANNER="Epson Perfection V850 Pro";;
		       5)SCANNER="Epson Perfection 1240u";;
	               6)echo "Write Epson model, Tag will say: 'Epson $SCANMOD'"
		         read SCANMOD
		         SCANNER="Epson $SCANMOD"
			 SOFTWARE="Vuescan";;
		     esac
		     SOFTWARE="Gimp $GIMPVERSION";;
                   4)SOFTWARE="Gimp $GIMPVERSION"
		     SCANNER="Nikon Coolscan 8000 ED";;
		   5)SOFTWARE="Vuescan"
		     SCANNER="n";;
		   6)echo "DSLR manufacturer: (Model in next step)"
                     read MANUFACT
		     echo "Write DSLR model:"
		     read SCANMOD
		     SCANNER="$MANUFACT $SCANMOD"
		     echo 'With which software?'
		     read SOFTWARE
		     #if [ -z "$SOFTWARE" ]
		     #fi
		     echo "$MANUFACT:$SCANMOD:$SOFTWARE" > $HOME/.add_exif.config/dslr ;;
                   7)if [ -e $HOME/.add_exif.config/dslr ];
		     then
                     	SOFTWARE=`cat $HOME/.add_exif.config/dslr|cut -d\: -f 3`
		     	SCANNER=`cat $HOME/.add_exif.config/dslr|cut -d\: -f 1,2|sed 's/\:/ /g'`
                     else echo "No pre-set camerasettings found, quitting this setting"
		          read
		     fi;;
		   8)SOFTWARE="Gimp $GIMPVERSION"
		     SCANNER="Canon CanoScan 9000F";;
		   9)SOFTWARE="Gimp $GIMPVERSION"
		     SCANNER="Epson Perfection V700";;
		   10)echo "Scanner manufacturer:"
                     read MANUFACT
		     echo "Write model:"
		     read SCANMOD
		     SCANNER="$MANUFACT $SCANMOD"
		     echo 'With which software?'
		     read SOFTWARE
		     if [ -z "$SOFTWARE" ]
		       then SOFTWARE="n"
		     fi;;
		   11)SOFTWARE="n"
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
	 APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
	 echo "exiv2 -M\"del Exif.Image.Software\" modify                                  $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
         if [ "$SOFTWARE" != "n" ];
	   then sed --in-place '/Exif.Image.Software/d' "$DIR"/script.$FILENAME.out
	        echo "exiv2 -M\"set Exif.Image.Software $SOFTWARE\" modify                 $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
#                echo 'Image.Software' >> $HOME/tmp/add_exif/added
	 fi
	 if [ "$SCANNER" != "n" ];
	   then sed --in-place '/Scanned/d' "$DIR"/script.$FILENAME.out
	        echo "exiv2 -M\"add Exif.Photo.UserComment Scanned with: $SCANNER\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
#	        echo 'Scanned' >> $HOME/tmp/add_exif/added
	 fi
	if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
	       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
		    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
	fi
 done
# echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
fi
}


#deprecated
CAMERAOLD () {
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
    zeiss-ikon|"zeiss ikon"|zeissikon|"Zeiss Ikon"|"ZEISS IKON"|ZEISSIKON|ZEISS-IKON|"Zeiss IKON")
    	     echo "Which Zeiss IKON?, ex. Super Ikonta"
	     read TYPE
	     OUT="Zeiss IKON AG";;
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
             holga|Holga|HOLGA)OUT=Holga
	     echo "Holga model? ex CFN"
             read TYPE
             case "$TYPE" in
               GCFN|gcfn|Gcfn)TYPE="120 GCFN";;
               CFN|cfn|Cfn)TYPE="120 CFN";;
               GFN|gfn|Gfn)TYPE="120 GFN";;
               WPC|wpc|Wpc)TYPE="WPC120";;
               120gtlr|gtlr|GTLR)TYPE="120GTLR";;
               tlr|120tlr|TLR)TYPE="120TLR";;
               120s|"120 S"|"120 s")TYPE="120S";;
               120n|"120 N"|"120 n")TYPE="120N";;
             esac;;
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
  APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
  echo "exiv2 -M\"del Exif.Image.Model\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
  echo "exiv2 -M\"del Exif.Image.Make\" modify  $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
  if [ -z "$TYPE" ]
    then : #echo "exiv2 -M\"add Exif.Image.Make $OUT\" modify               $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
    else sed --in-place '/Exif.Image.Model/d' "$DIR"/script.$FILENAME.out
         echo "exiv2 -M\"add Exif.Image.Model $TYPE\" modify             $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
#         echo 'Image.Model' >> $HOME/tmp/add_exif/added
	 sed --in-place '/Exif.Image.Make/d' "$DIR"/script.$FILENAME.out
         echo "exiv2 -M\"add Exif.Image.Make $OUT\" modify               $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
#         echo 'Image.Make' >> $HOME/tmp/add_exif/added
  fi
	if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
	       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
		    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
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

 clear
 ASK=N
 ROLL=N

 for X in $(cat $HOME/tmp/add_exif/.list);
 do
   FULLNAME=$(basename "$X")
   FILENAME="${FULLNAME%.*}"

if [ $ASK = N -a `cat $HOME/tmp/add_exif/.list|wc -l` -gt 1 ]
	then ASK=Y
	     ALL=$(dialog --title "All or individual?" --menu "All frames or Individual?" 0 0 0 "All frames with same ROLL-nr" "" "Individual Roll-nr" "" --output-fd 1)
fi

if [ "$ALL" = "Individual Roll-nr" -o "$ROLL" = "N" ]
	then if [ "$ROLL" = "N" ]; then ROLL=100 ; fi
if [ `echo $FULLNAME|cut -d'-' -f1|cut -d'_' -f1` -ge 0 ]
	then INPUT=`echo $FULLNAME|cut -d'-' -f1|cut -d'_' -f1`
	else INPUT=""
fi

	     ROLL=$(dialog --title "Rollnumber" --inputbox "Example:
This is only to keep track of which number in a
sequence a sheet or roll has.

          $FULLNAME ...
" 0 0 $INPUT --output-fd 1)
fi

if [ "$ROLL" = "N" ]
	then echo "skipping..."
	else sed --in-place '/Roll-id/d' "$DIR"/script.$FILENAME.out
		APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
		echo "exiv2 -M\"add Exif.Photo.UserComment Roll-id $ROLL\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
			then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		fi
	fi
done
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

!!! Make sure to MARK in the list, !!!
!!!   otherwise nothing is added   !!!

!!! Any existing comments will be removed !!!" 0 0 0 $pkglist --output-fd 1) || break

dialog --title "List of files" --inputbox "Write your Comment with up to 90 chars.
$choise

To make sure comments are added using this script please DONT use quotations, they are likely to break the scrip!!" 0 0 " " 2>$HOME/tmp/add_exif/.comment

# sed removed empty spaces in the beginning of the comment-string:
OUT=`cat $HOME/tmp/add_exif/.comment | sed -e 's/^[ \t]*//'`

if [ -z "$OUT" ]
  then echo "NO..." ; OUT=NOCOMMENT
  else echo "YES!";
  		#Filtrera bort " och \ när specialtecken finns i filnamnet:
		choise=$(echo $choise | tr " " "\n"|sed 's/\"//g; s/\\//g')
		echo "$choise" > $HOME/tmp/add_exif/.commentlist
		for LIST in `cat $HOME/tmp/add_exif/.commentlist`; do
		FULLNAME=$(basename "$LIST")
		FILENAME="${FULLNAME%.*}"
#DEKLARERAD		DIR=$(dirname "$LIST" | sed s/\'//g)
	if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
	       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
		    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
	fi
		       sed --in-place '/COMMENT:/,/COMMENT./d' "$DIR"/script.$FILENAME.out
		       APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
                   echo " 
# COMMENT:"  >> "$DIR"/script.$FILENAME.out
		   echo "exiv2 -M\"add Exif.Photo.UserComment $OUT\" modify $DIR/$FILENAME*.$APPLYON" >>"$DIR"/script.$FILENAME.out
		   echo "# COMMENT.
   "  >> "$DIR"/script.$FILENAME.out
		done
fi

#dialog --title "Comments" --defaultno --yesno "Add more comments?" 0 0
#	if [ $? = 1 ]
#	 then break
#	 else echo "om igen..." 
#	fi

done

	if [ $? = 2 ]
	  then exit 0
	fi 
fi
}

#deprecated
DISABLE_FOR () {
if [ -e "$HOME"/tmp/add_exif/.remove.list -a -e "$HOME"/tmp/add_exif/.remove ]
then MD5SUM="/usr/bin/md5sum"
	for X in `cat $HOME/tmp/add_exif/.remove.list`; do
		if [ -x $MD5SUM ]
			then BEFORE=`$MD5SUM "$X"`
			     sed --in-place '/case/d' "$X"
			     AFTER=`"$MD5SUM" "$X"`
			     if [ "$BEFORE" = "$AFTER" ]
				then dialog --title "Tag not removed" --msgbox "Tag not found in file." 10 40
			     fi
			     sed --in-place '/case/d' "$X"
			fi
	done
else
	if [ ! -e $HOME/.add_exif.config/disable_for ] ; then echo '*.NEF *.dng *.zip' > $HOME/.add_exif.config/disable_for ; fi
	dialog --title 'Which files to ignore?' --inputbox "Which file extensions should be ignored by these scripts?
	
NEF files (Nikon raw files) among other raw files have shown prone to corruption when manipulated by exiv2.
Test this out yourself before executing exiv2 on your raw files.

Should be writtes case-sensitive and separated only by spaces.

ie. *.NEF *.dng
" 0 0 "`cat $HOME/.add_exif.config/disable_for`" 2>$HOME/.add_exif.config/disable_for
	DISABLE=`cat $HOME/.add_exif.config/disable_for|sed 's/ /\|/g'`
	for X in $(cat $HOME/tmp/add_exif/.list);
	  do
	    FULLNAME=$(basename "$X")
	    FILENAME="${FULLNAME%.*}"
	      #DEKLARERAD  DIR=$(dirname $X | sed s/\'//g)
	        sed --in-place '/case/d' "$DIR"/script.$FILENAME.out
		sed -i "1icase \$1 in $DISABLE)exit 0 ;; esac" "$DIR"/script.$FILENAME.out
	done
fi
# sed -i "1icase $1 in *.NEF|*.pp3|*.out|*.bz2|*.xcf)exit 0 ;; esac" file
}

#deprecated
FILMOLD () {

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

FILMSETTING=$(dialog --title "Which film" --menu "Two ways..." 0 0 0 "List types of films" "" "Write type of film" "" --output-fd 1)
#read BAH
case $FILMSETTING in
	List*)FILMA;;
	Write*)FILMB;;
esac
fi
#read BAH
}


FILMA () {
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
	"EFKE" "" \
	"CHM" "" \
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
        "Kodak Tmax 100" "" \
        "Kodak Tmax 400" "" \
        "Kodak TriX 320" "" \
        "Kodak TriX 400" "" \
        "Kodak Portra 160" "" \
	"Kodak Portra 160NC" "" \
	"Kodak Portra 160VC" "" \
        "Kodak Portra 400" "" \
        "Kodak Portra 800" "" \
	"Kodak BW400CN" "" \
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
	"Ilford PanF 50" "" \
	"Ilford Pan 400" "" \
        "Ilford FP4 125" "" \
        "Ilford HP5+ 400" "" \
        "Ilford Delta 100" "" \
        "Ilford Delta 400" "" \
        "Ilford Delta 3200" "" \
        "Ilford XP2" "" \
        "Ilford SFX 200" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Kentmere')dialog --title "Kentmere"  --menu "Options:" 20 40 60 \
	"Kentmere 100" "" \
	"Kentmere 400" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Fujifilm')dialog --title "Fuji"  --menu "Options:" 20 40 60 \
	"Fujifilm 160 NS" "" \
	"Fujifilm Superia 200" "" \
	"Fujifilm Superia 400" "" \
	"Fujifilm Superia 800" "" \
	"Fujifilm Superia 1600" "" \
        "Fujifilm Superia X-Tra 400" "" \
        "Fujifilm Superia X-Tra 800" "" \
        "Fujifilm Pro 400H" "" \
        "Fujifilm Astia" "" \
	"Fujifilm C200" "" \
        "Fujifilm Reala" "" \
        "Fujifilm Neopan 100 Acros" "" \
        "Fujifilm Neopan SS" "" \
        "Fujifilm Neopan 400" "" \
        "Fujifilm Neopan 1600" "" \
        "Fujichrome Velvia 50 (RVP50)" "" \
        "Fujichrome Velvia 100 (RVP100)" "" \
        "Fujichrome Velvia 100F (RVP100F)" "" \
        "Fujichrome T64 (RTP-II)" "" \
        "Fujichrome Provia" "" \
	"Fujichrome Provia 400X" "" \
	"Fujichrome Provia 100F (RDPIII)" "" \
	"Fujichrome Provia 400F (RHPIII)" "" \
	"Fujichrome Provia 1600 (RSP)" "" \
2> $HOME/tmp/add_exif/.film ;;
 'FOMA')dialog --title "Fomapan"  --menu "Options:" 20 40 60 \
        "FOMA Fomapan Classic 100" "" \
        "FOMA Fomapan Creative 200" "" \
        "FOMA Fomapan Action 400" "" \
        "FOMA Retropan 320" "" \
        "FOMA Fomapan R 100" "" \
2> $HOME/tmp/add_exif/.film ;;
 'AgfaPhoto')dialog --title "AgfaPhoto"  --menu "Options:" 20 40 60 \
	"AgfaPhoto Vista Plus 200" "" \
	"AgfaPhoto Vista Plus 400" "" \
        "AgfaPhoto CT Precisa 100" "" \
        "AgfaPhoto APX 100 (old emulsion)" "" \
        "AgfaPhoto APX 400 (old emulsion)" "" \
        "AgfaPhoto APX 100 (new emulsion)" "" \
        "AgfaPhoto APX 400 (new emulsion)" "" \
2> $HOME/tmp/add_exif/.film ;;
 'Agfa-Gevaert')dialog --title "Agfa"  --menu "Options:" 20 40 60 \
        "Agfa-Gevaert Scala 200x" "" \
	"Agfa-Gevaert Copex Rapid" "" \
	"Agfa-Gevaert Isopan 125" "" \
	"Agfa-Gevaert Agfapan 100" "" \
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
        "Rollei RPX 100" "" \
        "Rollei RPX 400" "" \
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
 'CHM')dialog --title "CHM" --menu "Options:" 20 40 60 \
 	"CHM 100 Universal" "" \
 	"CHM 400 Universal" "" \
2> $HOME/tmp/add_exif/.film ;;
 'EFKE')dialog --title "Efke"  --menu "Options:" 20 40 60 \
	"Efke IR 820" "" \
        "Efke R 100" "" \
	"Efke KB 100" "" \
	"Efke KB 50" "" \
	"Efke KB 25" "" \
        "Efke R17" "" \
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
	"Arista EDU Ultra" "" \
	"Shanghai GP3" "" \
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
            then #echo "exiv2 -M\"del Exif.Photo.UserComment\" modify      $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
                 sed --in-place '/Film:/d' "$DIR"/script.$FILENAME.out
		 APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
		 echo "exiv2 -M\"add Exif.Photo.UserComment Film: $OUT\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		fi
#                echo 'Film' >> $HOME/tmp/add_exif/added
#                echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
          fi
	done
 fi
}



FILMB () {

#read BAH
if [ -e $HOME/.add_exif.config/lastfilm ];
	then LASTFILM=`cat $HOME/.add_exif.config/lastfilm`;
fi
#read NAH
dialog --title "Which film is this?"  --inputbox "Film input manually: 

Example:
Kodak Ektar 100

" 20 40 "$LASTFILM" 2>$HOME/tmp/add_exif/.film
cp $HOME/tmp/add_exif/.film $HOME/.add_exif.config/lastfilm
#read BAH
OUT=`cat $HOME/tmp/add_exif/.film | sed 's/\%//g'`

 if [ -z $OUT 2>/dev/null ]
  then echo "No film was chosen"
  else for X in $(cat $HOME/tmp/add_exif/.list);
       do
	FULLNAME=$(basename "$X")
	FILENAME="${FULLNAME%.*}"
#DEKLARERAD  	DIR=$(dirname $X | sed s/\'//g)

	  if [ "$OUT" != "X" ]
	    then #echo "exiv2 -M\"del Exif.Photo.UserComment\" modify      $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		 sed --in-place '/Film:/d' "$DIR"/script.$FILENAME.out
		 APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
		 echo "exiv2 -M\"add Exif.Photo.UserComment Film: $OUT\" modify $DIR/$FILENAME*.$APPLYON" >> "$DIR"/script.$FILENAME.out
		if [ `grep '#!/bin/bash' "$DIR"/script.$FILENAME.out|wc -l` -eq 0 ]
		       then sed --in-place '1 i shopt -s nullglob' "$DIR"/script.$FILENAME.out
			    sed --in-place '1 i \#\!\/bin\/bash' "$DIR"/script.$FILENAME.out
		fi
#                echo 'Film' >> $HOME/tmp/add_exif/added
#                echo "$DIR"/script.$FILENAME.out  >> $HOME/tmp/add_exif/.exiv_scripts."$DELDATE"
	  fi
	done
 fi
#ead BAH
}



HELP () {

 echo "
Start script in folder containing image-files which can be tagged with exif-data and are writable by exiv2.
The script is best used in a folder containing ie. one roll of scanned film which you have some data for.

You can read just how to add your data in the inputbox you are in, for example the syntax for GPS, DATE and more.
If you dont have the entire date for example, you may just set a year.

If you have started a function ie. 'DATE' or whatever, you can ofter use 'X' as input or 'Cancel' button to skip to the next.

Run script with -r to remove data from existing scripts easely. The menu will open up where you can choose specific files 
and just choose which data to clean.

Before running a script for the second time, or simply because you want to remove all/old exif in a file:
exiv2 -Pkyct filnamn

If you want to run all your scripts without adding any new data to your files; start the script in folder and when 
you reach the menu - do cancel, which will take you to the option of 'cleaning' and running the generated scriptfiles.

Each scriptfile can be run by:

sh script.filename.out


Any questions regarding functionality, bugs, whatever - please mail me on johan.g.lindgren@gmail.com"
}


# Start script with 'add_exif.sh RUNGPS' in order to only do GPS (fastmode.
RUNGPS () {
TOP='Selecting and listing images in your dir'
TIF=$(ls -l *.tif | wc -l)

	if [ $TIF = 0 ]
	 then CMD='/bin/ls *.jpg'
	 else CMD='/bin/ls *.tif'
	fi

	   dialog --title "$TOP" --inputbox "You are in `pwd` Type command to select files
Examples:

*.tif (default)
DSC_{0034..0048}.tif (adding all DSC_ -files between nr 0034 and 0048

" 0 0 "$CMD > $HOME/tmp/add_exif/.list" 2>$HOME/tmp/add_exif/.command
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
echo $choise | tr " " "\n"|sed 's/\"//g; s/\\//g' > "$HOME"/tmp/add_exif/.remove.list

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
	DEVELOPMENT " " off \
	ROLLNR " " off \
        PHOTOGRAPHER " " off \
        CAMERA " " off \
        PROGRAM " " off \
        SOFTWARE " " off \
	COMMENT " " off \
	GPSDATA " " off \
#	DISABLE_FOR " " off \
2>> "$HOME"/tmp/add_exif/.dialogout





#for Y in $(cat "$HOME"/tmp/add_exif/.dialogout); do
#echo "### AAAAAAAAAAAAAAAAAAAAAAAAAAA 1 ###"
  for DLG in $(cat "$HOME"/tmp/add_exif/.dialogout); do
    "$DLG" $DEBUG
  done; #rm "$HOME"/tmp/add_exif/.remove.list

#done; rm -rf "$HOME"/tmp/add_exif/.remove.list >/dev/null

fi


rm -rf "$HOME"/tmp/add_exif/.remove.* >/dev/null
}

RUN () {
	rm -rf "$HOME"/tmp/add_exif/.remove 2>/dev/null
#TOP='Selecting and listing images in your dir'
#TIF=$(ls -l *.tif | wc -l)

#	   if [ "$TIF" = 0 ]
#	    then CMD='/bin/ls *.jpg'
#	    else CMD='/bin/ls *.tif'
#	   fi
#	   dialog --title "$TOP" --inputbox "You are in `pwd` Type command to select files

#examples...

#*.tif (default)
#DSC_{0034..0048}.tif
#{0045_delta400.tif,0051_tmax100.jpg}

#" 0 0 "$CMD > $HOME/tmp/add_exif/.list" 2>$HOME/tmp/add_exif/.command
#	   if [ "$?" = 1 ]
#	     then echo "Pressed 'Cancel'"
#		  exit 0
#	   fi

#       then for X in $(ls *.tif); do file "$X" && LIST=`echo $LIST $X "~" on`; done

LIST=""
if [ `ls *.tif|wc -l` != 0 ]
       then for X in $(ls *.tif); do if [ -e "$X" ] ; then LIST=$(echo $LIST $X "~" on) ; fi ; done
       else for X in $(ls *.{jpg,JPG,TIF,tiff,TIFF,dng,DNG,pef,PEF,PNG,png,JP2,jp2,nef,NEF}); do if [ -e "$X" ] ; then LIST=`echo $LIST $X "~" on`; fi ; done
fi

if [ -z "$LIST" ]
	then dialog --title 'Problem' --msgbox "There are no files in current folder	
OR the files was filtered out because of white spaces in the filename.

Press OK to exit." 0 0
	exit 0
fi

/usr/bin/dialog --title "add_exif.sh" --checklist "Chose image files

Note: files with spaces does not work yet!
" 0 50 10 $LIST --output-fd 1 |sed 's/ /\ \n/g'> $HOME/tmp/add_exif/.list || break



#sh "$HOME"/tmp/add_exif/.command




#read bah



dialog --title "Execute for..." --yesno "Does this look ok?

`cat "$HOME"/tmp/add_exif/.list`" 25 40
           if [ $? = 1 ]
	     then exit 0 
	   fi

## Apply bash-settings for script: ###

if [ `ls script.*.out|wc -l` -ge 1 ]
	then for AB in $(ls script.*.out); do
	     if [ `grep '#!/bin/bash' $AB|wc -l` -eq 0 ]
	       then sed --in-place '1 i shopt -s nullglob' "$AB"
		    sed --in-place '1 i \#\!\/bin\/bash' "$AB"
	     fi
	done
fi



## APPLY ON: ##

	if [ -e "$HOME"/.add_exif.config/apply_on ]
	   then APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
	   else APPLYON='{tif,jpg}'
	fi

EXT () {
 	dialog --title "File extensions" --inputbox "The following extensions were found in this folder.
	Be aware that choosen extensions are case sensitive.

	Examples: {jpg,JPG,tif,TIF} or {jpg,jpeg}

	I have found that raw-files like NEF might
	be currupted if exiv2 writes exif to them.

`ls *.$APPLYON|sed 's/.*\(...\)/\1/'|sort|uniq`" 0 0 "$APPLYON" --output-fd 1 >"$HOME"/.add_exif.config/apply_on
}

EXT
 	if [ `cat "$HOME"/.add_exif.config/apply_on|wc -c` -ne $(expr `cat "$HOME"/.add_exif.config/apply_on|sed 's/{//g ; s/}//g'|wc -c` + 2) ]
		then dialog --title 'Really??' --msgbox "Your input `cat "$HOME"/.add_exif.config/apply_on` does not seem right

should be syntax like: {jpg,TIF}"

		     EXT
	fi

        APPLYON=`cat "$HOME"/.add_exif.config/apply_on`

	if [ `ls script.*.out|wc -l` -ge 1 ]
	  then for BE in $(ls script.*.out); do
            sed -i "s/\*.*$/\*.$APPLYON/g" $BE
		# Also erase empty lines: #
	    sed --in-place '/^[[:space:]]*$/d' $BE
	done
	fi

## Grab previous chosen options ##

grep DATE "$HOME"/.add_exif.config/menu && date=on || date=off
grep PROGRAM "$HOME"/.add_exif.config/menu && program=on || program=off
grep APERTURE "$HOME"/.add_exif.config/menu && aperture=on || aperture=off
grep SPEED "$HOME"/.add_exif.config/menu && speed=on || speed=off
grep LENS "$HOME"/.add_exif.config/menu && lens=on || lens=off
grep LENSMODEL "$HOME"/.add_exif.config/menu && lensmodel=on || lensmodel=off
grep ISO "$HOME"/.add_exif.config/menu && iso=on || iso=off
grep FILM "$HOME"/.add_exif.config/menu && film=on || film=off
grep DEVELOPMENT "$HOME"/.add_exif.config/menu && development=on || development=off
grep ROLLNR "$HOME"/.add_exif.config/menu && rollnr=on || rollnr=off
grep CAMERA "$HOME"/.add_exif.config/menu && camera=on || camera=off
grep SOFTWARE "$HOME"/.add_exif.config/menu && software=on || software=off
grep PHOTOGRAPHER "$HOME"/.add_exif.config/menu && photographer=on || photographer=off
grep COMMENT "$HOME"/.add_exif.config/menu && comment=on || comment=off
grep GPSDATA "$HOME"/.add_exif.config/menu && gpsdata=on || gpsdata=off

if [ ! -e "$HOME"/.add_exif.config/menu ]
	then dialog --title "No previous menu settings found" --yesno "Select all?" 7 40 
		if [ $? = 0 ]
			then date=on ; program=on ; aperture=on ; speed=on ; lensmodel=on ; iso=on ; film=on ; development=on ; rollnr=on ; camera=on ; software=on ; photographer=on ; comment=on ; gpsdata=on
		fi
fi


#Removed. Only adding focal length, which is added alongside LENSMODEL
#        LENS "Focallength only" $lens \


   	   rm -rf "$HOME"/tmp/add_exif/.dialogout 
           dialog --separate-output --checklist "Choose exifdata:" 0 0 0 \
        DATE " " $date \
        PROGRAM "PSAM" $program \
        APERTURE " " $aperture \
        SPEED " " $speed \
	LENSMODEL " " $lensmodel \
        ISO " " $iso \
        FILM " " $film \
	DEVELOPMENT " " $development \
	ROLLNR " " $rollnr \
        CAMERA " " $camera \
        SOFTWARE " " $software \
        PHOTOGRAPHER " " $photographer \
	COMMENT " " $comment \
	GPSDATA " " $gpsdata \
2> "$HOME"/tmp/add_exif/.dialogout

rm -rf "$HOME"/.add_exif.config/menu
for A in $(cat "$HOME"/tmp/add_exif/.dialogout); do
	echo $A >> "$HOME"/.add_exif.config/menu
done


for Y in $(cat "$HOME"/tmp/add_exif/.list); do
  exiv2 -dx "$Y"
  for DLG in $(cat "$HOME"/tmp/add_exif/.dialogout); do
    $DLG $DEBUG #; clear
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

exiv2 rm FOOBAR.jpg   <-- removes all exif from file
sh script.FOOBAR.out  <-- execute script to add  to file
" 0 0 0 "1" "Execute ALL generated script-files in dir" "0" "Menu-list for each script" --output-fd 1)

#echo debug
#read

case $FIN in
0) for pkg in $(ls $DIR/script.*)
    do pkglist="$pkglist $pkg ~ "; done

   echo $pkglist

# Debugging, to stop from proceeding.
   if [ $1 = Y ]; then read D; fi

 

   while choise=`/usr/bin/dialog --stdout --menu "Items:" 0 45 0 $pkglist`; do
#   echo 1 ; read
   if [ $? = 1 ]
     then break
   fi

# clean file prior to exifiation
APPLYON=`cat "$HOME"/.add_exif.config/apply_on`
   dialog --title "Remove existing exif in files" --yesno "Clean files before execute script?" 7 40 
 #  echo 2 ; read
   if [ $? = 0 ]
     then clear
          EXIVDEL=$(exiv2 delete `echo $choise$APPLYON | sed 's/script\.//g;s/\.out/\./g'`)
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
		then clear
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

### Why did I add $X here?! Changed to $1 for DEBUG variable.
#FINAL $X
FINAL $1

done
exit 0
}


DEBUG=N
case $1 in
 -h|--help|--h)HELP ; exit 0;;
# -gps|-GPS|gps|GPS);;
 -remove|-r)touch $HOME/tmp/add_exif/.remove && rm -rf "$HOME"/tmp/add_exif/.dialogout && RUNREMOVE;;
       -gps)RUNGPS;;
     -debug)DEBUG=Y ; RUN $DEBUG;;
	  *)RUN $DEBUG;;
esac

