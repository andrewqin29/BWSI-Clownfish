#!/bin/bash -e


#----------------------------------------------------------
# Part 1
#----------------------------------------------------------
TIME_WARP=1
GUI="yes"

### Declare all vehicles
V1="Bob"
V2="Nancy"
V3="Sally"
HOSTIP=`hostname -I | awk '{print $3}'`
SHOREIP=$HOSTIP
VEHICLES=($V1 $V2 $V3)
TYPES=("dory" "octopus" "nemo")
AUV_PORTS=("9001" "9002" "9003")
AUV_PSHARE=("9201" "9202" "9203")
START_POS=("x=-21.09,y=194.34,speed=0,heading=0,depth=0" "x=-166.57,y=-31.80,speed=0,heading=0,depth=0" "x=--10.00,y=190,speed=0,heading=0,depth=0")
LOITER_POS=("x=-250.00,y=250.00" "x=-195.00,y=250.00" "x=100,y=200")

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
		LOITER_POS=${LOITER_POS[$i]} \
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
