GenjiXinyu
#5117

Kenji Guo — Yesterday at 1:11 PM
https://oceanai.mit.edu/ivpman/pmwiki/pmwiki.php?n=Tools.GeometryUtils
Andrew Qin — Today at 7:18 AM
```
#!/bin/bash -e


#----------------------------------------------------------
# Part 1
Expand
message.txt
3 KB
/----------------------------------------------
Behavior = BHV_Loiter
{
  name      = loiter
  pwt       = 100
  condition = MODE==LOITERING
  updates   = UP_LOITER
  runflag   = VEHICLE_UNDERWAY = TRUE
  endflag   = VEHICLE_UNDERWAY = FALSE

  ipf_type = zaic_spd

   post_suffix = A
         speed = 1.4
     clockwise = best
        radius = 1.0
     nm_radius = 720
       polygon = radial:: x=0,y=0,radius=4243,pts=4, snap=1, label=$(AUV_NAME)_LOITER
  visual_hints = nextpt_color=white, nextpt_lcolor=khaki
  visual_hints = edge_color=orange, vertex_color=white
  visual_hints = edge_size=1, vertex_size=2
}
﻿
```
#!/bin/bash -e


#----------------------------------------------------------
# Part 1
#----------------------------------------------------------
TIME_WARP=1
GUI="yes"

### Declare all vehicles
V1="clownfish1"
V2="clownfish2"
V3="clownfish3"
V4="clownfish4"
V5="clownfish5"
V6="clownfish6"
V7="clownfish7"
HOSTIP=`hostname -I | awk '{print $3}'`
SHOREIP=10.116.0.2
VEHICLES=($V1 $V2 $V3 $V4 $V5 $V6)
TYPES=("AUV" "AUV" "AUV" "kayak" "kayak" "kayak")
AUV_PORTS=("9001" "9002" "9003" "9004" "9005" "9006")
AUV_PSHARE=("9201" "9202" "9203" "9204" "9205" "9206")
START_POS=("x=-3000,y=3000,speed=0,heading=0,depth=0" "x=-2000,y=3000,speed=0,heading=0,depth=0" "x=-1000,y=3000,speed=0,heading=0,depth=0" "x=0,y=3000,speed=0,heading=0,depth=0"
"x=1000,y=3000,speed=0,heading=0,depth=0" "x=2000,y=3000,speed=0,heading=0,depth=0" "x=0,y=0,speed=0,heading=0,depth=0")


#----------------------------------------------------------
#  Part 2: Check for and handle command-line arguments
#----------------------------------------------------------
SHORT=h,w:
LONG=help,nogui,warp:
OPTS=$(getopt --options $SHORT --longoptions $LONG -- "$@")
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1; fi

eval set -- "$OPTS"

while true;
do
	case "$1" in
		-h | --help )
			echo "./launch.sh <OPTIONS>"
			echo "-w <#> or --warp <#> is the warp factor"
		echo "--nogui turns off the GUI"
			echo "-h or --help prints this message"
			exit 2
			;;
		--nogui )
			GUI="no"
			shift
			;;
		-w | --warp )
			TIME_WARP=$2
			shift 2
			;;
		-- )
			shift;
			break
			;;
		*)
			echo "Unexpected option: $1"
			break
			;;
	esac
done

#----------------------------------------------------------
#  Part 3: Launch the processes
#----------------------------------------------------------
for i in ${!VEHICLES[@]}; do
	echo "Launching ${VEHICLES[$i]} MOOS Community. WARP is" $TIME_WARP
	nsplug ${VEHICLES[$i]}_base.bhv targ_${VEHICLES[$i]}.bhv AUV_NAME="${VEHICLES[$i]}" \
		AUV_PORT=${AUV_PORTS[$i]} \
		AUV_PSHARE=${AUV_PSHARE[$i]} \
		AUV_TYPE=${TYPES[$i]} \
		START_POS=${START_POS[$i]} \
		WARP=${TIME_WARP} \
		SHORESIDE_PORT=9000
	nsplug ${VEHICLES[$i]}_base.moos targ_${VEHICLES[$i]}.moos \
		AUV_NAME="${VEHICLES[$i]}" \
		HOSTIP="${HOSTIP}" \
		AUV_PORT=${AUV_PORTS[$i]} \
		AUV_PSHARE=${AUV_PSHARE[$i]} \
		AUV_TYPE=${TYPES[$i]} \
		WARP=${TIME_WARP} \
		START_POS=${START_POS[$i]} \
		SHOREIP="${SHOREIP}" \
		SHORESIDE_PORT=9000 \
		SHORESIDE_PSHARE=9200
	pAntler targ_${VEHICLES[$i]}.moos --MOOSTimeWarp=$TIME_WARP >& ${VEHICLES[$i]}.txt &
done

echo "Launching shoreside MOOS Community, WARP is" $TIME_WARP
nsplug shoreside_base.moos targ_shoreside.moos WARP=${TIME_WARP} SHORESIDE_PSHARE=9200 SHORESIDE_PORT=9000
pAntler targ_shoreside.moos --MOOSTimeWarp=$TIME_WARP >& /dev/null &
```
message.txt
3 KB