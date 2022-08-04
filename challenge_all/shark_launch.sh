#----------------------------------------------------------
TIME_WARP=1

### Declare all vehicles
V0="Spotted-belly_catshark"
V1="Cenderawasih_epaulette_shark"
V2="Longnose_houndshark"
V3="Ghost_catshark"

HOSTIP=`hostname -I | awk '{print $3}'`
SHOREIP=$HOSTIP
VEHICLES=($V0 $V1 $V2 $V3)
TYPES=("shark" "shark" "shark" "shark")
AUV_PORTS=(9301 9302 9303 9304)
AUV_PSHARE=(9401 9402 9403 9404)
START_POS=("x=312.0,y=-168.0,speed=0,depth=5,heading=160" "x=-691.0,y=807.0,speed=0,depth=5,heading=274" "x=-870.0,y=-503.0,speed=0,depth=5,heading=138" "x=186.0,y=824.0,speed=0,depth=5,heading=309")
BHV=("points=format=bowtie,x=319.87,y=-189.61,height=177,wid1=544.25,wid2=1141.6,wid3=2177,label=Spotted-belly_catshark_bwt" "points=zigzag:-706.96,808.12,-90,2228,481,51" "points=format=bowtie,x=-856.62,y=-517.86,height=752,wid1=193.0,wid2=461.6,wid3=852,label=Longnose_houndshark_bwt" "points=zigzag:172.01,835.33,-165,2029,289,120")

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
	nsplug shark_base.bhv targ_${VEHICLES[$i]}.bhv AUV_NAME="${VEHICLES[$i]}" \
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
		MAX_SPEED=18 \
		MAX_DEPTH=50 \
		SHOREIP="${SHOREIP}" \
		SHORESIDE_PORT=9000 \
		SHORESIDE_PSHARE=9200
	pAntler targ_${VEHICLES[$i]}.moos --MOOSTimeWarp=$TIME_WARP >& /dev/null &
done

#echo "Launching shoreside MOOS Community, WARP is" $TIME_WARP
#nsplug shoreside_base.moos targ_shoreside.moos WARP=$TIME_WARP SHOREIP=$SHOREIP SHORESIDE_PORT=9000 SHORESIDE_PSHARE=9200
#pAntler targ_shoreside.moos --MOOSTimeWarp=$TIME_WARP >& /dev/null &
