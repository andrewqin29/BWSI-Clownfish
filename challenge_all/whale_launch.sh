#----------------------------------------------------------
TIME_WARP=1

### Declare all vehicles
V0="Vaquita"
V1="Australian_snubfin_dolphin"
V2="Indo-pacific_beaked_whale"
V3="Andrews_beaked_whale"
V4="Common_bottlenose_dolphin"
V5="North_Pacific_right_whale"

HOSTIP=`hostname -I | awk '{print $3}'`
SHOREIP=$HOSTIP
VEHICLES=($V0 $V1 $V2 $V3 $V4 $V5)
TYPES=("whale" "whale" "whale" "whale" "whale" "whale")
AUV_PORTS=(9305 9306 9307 9308 9309 9310)
AUV_PSHARE=(9405 9406 9407 9408 9409 9410)
START_POS=("x=-155.0,y=-71.0,speed=0,depth=5,heading=358" "x=99.0,y=-487.0,speed=0,depth=5,heading=71" "x=-859.0,y=-176.0,speed=0,depth=5,heading=23" "x=-258.0,y=-1347.0,speed=0,depth=5,heading=295" "x=141.0,y=1331.0,speed=0,depth=5,heading=121" "x=-1175.0,y=-1079.0,speed=0,depth=5,heading=180")
BHV=("polygon=format=ellipse,x=-155.84,y=-47.01,degs=16,minor=341,major=991,pts=16,label=Vaquita_wpt" "polygon=format=ellipse,x=117.91,y=-480.49,degs=90,minor=446,major=1062,pts=16,label=Australian_snubfin_dolphin_wpt" "polygon=format=ellipse,x=-853.92,y=-164.03,degs=81,minor=458,major=1149,pts=16,label=Indo-pacific_beaked_whale_wpt" "polygon=format=ellipse,x=-271.59,y=-1340.66,degs=77,minor=427,major=1392,pts=16,label=Andrews_beaked_whale_wpt" "polygon=format=ellipse,x=152.14,y=1324.30,degs=-144,minor=588,major=1442,pts=16,label=Common_bottlenose_dolphin_wpt" "polygon=format=ellipse,x=-1175.00,y=-1098.00,degs=36,minor=516,major=1346,pts=16,label=North_Pacific_right_whale_wpt")

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
	nsplug whale_base.bhv targ_${VEHICLES[$i]}.bhv AUV_NAME="${VEHICLES[$i]}" \
		AUV_PORT=${AUV_PORTS[$i]} \
		AUV_PSHARE=${AUV_PSHARE[$i]} \
		AUV_TYPE=${TYPES[$i]} \
		START_POS=${START_POS[$i]} \
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
		MAX_SPEED=8 \
		MAX_DEPTH=100 \
		SHOREIP="${SHOREIP}" \
		SHORESIDE_PORT=9000 \
		SHORESIDE_PSHARE=9200
	pAntler targ_${VEHICLES[$i]}.moos --MOOSTimeWarp=$TIME_WARP >& /dev/null &
done

echo "Launching shoreside MOOS Community, WARP is" $TIME_WARP
nsplug shoreside_base.moos targ_shoreside.moos WARP=$TIME_WARP SHOREIP=$SHOREIP SHORESIDE_PORT=9000 SHORESIDE_PSHARE=9200
pAntler targ_shoreside.moos --MOOSTimeWarp=$TIME_WARP >& /dev/null &
