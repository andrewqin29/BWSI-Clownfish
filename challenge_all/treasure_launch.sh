#----------------------------------------------------------
TIME_WARP=1

### Declare all vehicles
V0="Queen_Annes_Revenge"
V1="1715_Spanish_Fleet"
V2="Esmeralda"

HOSTIP=`hostname -I | awk '{print $3}'`
SHOREIP=$HOSTIP
VEHICLES=($V0 $V1 $V2)
TYPES=("treasure" "treasure" "treasure")
AUV_PORTS=(9323 9324 9325)
AUV_PSHARE=(9423 9424 9425)
START_POS=("x=1146.0,y=-260.0,speed=0,depth=500,heading=44" "x=-270.0,y=1034.0,speed=0,depth=500,heading=188" "x=-1216.0,y=-664.0,speed=0,depth=500,heading=92")

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
	nsplug treasure_base.bhv targ_${VEHICLES[$i]}.bhv AUV_NAME="${VEHICLES[$i]}" \
		AUV_PORT=${AUV_PORTS[$i]} \
		AUV_PSHARE=${AUV_PSHARE[$i]} \
		AUV_TYPE=${TYPES[$i]} \
		START_POS=${START_POS[$i]} \
		MAX_SPEED=5.0 \
		MAX_DEPTH=500 \
		WARP=${TIME_WARP} \
		BHV=${BHV[$i]} \
		SHORESIDE_PORT=9000
	nsplug animal_base.moos targ_${VEHICLES[$i]}.moos \
		AUV_NAME="${VEHICLES[$i]}" \
		HOSTIP="${HOSTIP}" \
		AUV_PORT=${AUV_PORTS[$i]} \
		AUV_PSHARE=${AUV_PSHARE[$i]} \
		AUV_TYPE=${TYPES[$i]} \
		START_POS=${START_POS[$i]} \
		WARP=${TIME_WARP} \
		MAX_SPEED=5.0 \
		MAX_DEPTH=500 \
		SHOREIP="${SHOREIP}" \
		SHORESIDE_PORT=9000 \
		SHORESIDE_PSHARE=9200
	pAntler targ_${VEHICLES[$i]}.moos --MOOSTimeWarp=$TIME_WARP >& /dev/null  &
done

#echo "Launching shoreside MOOS Community, WARP is" $TIME_WARP
#nsplug shoreside_base.moos targ_shoreside.moos WARP=$TIME_WARP SHORESIDE_PORT=9000 SHORESIDE_PSHARE=9200
#pAntler targ_shoreside.moos --MOOSTimeWarp=$TIME_WARP >& /dev/null &
