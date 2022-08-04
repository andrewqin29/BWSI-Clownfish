#----------------------------------------------------------
TIME_WARP=1

### Declare all vehicles
V0="Halfmoon"
V1="Bobtail_snipe_eel"
V2="Worm_eel"
V3="Kokanee"
V4="Pencilsmelt"
V5="Pineconefish"
V6="Kanyu"
V7="Rattail"
V8="Trunkfish"
V9="Northern_pike"
V10="Yellowtail_horse_mackerel"
V11="Frogfish"

HOSTIP=`hostname -I | awk '{print $3}'`
SHOREIP=$HOSTIP
VEHICLES=($V0 $V1 $V2 $V3 $V4 $V5 $V6 $V7 $V8 $V9 $V10 $V11)
TYPES=("fish" "fish" "fish" "fish" "fish" "fish" "fish" "fish" "fish" "fish" "fish" "fish")
AUV_PORTS=(9311 9312 9313 9314 9315 9316 9317 9318 9319 9320 9321 9322)
AUV_PSHARE=(9411 9412 9413 9414 9415 9416 9417 9418 9419 9420 9421 9422)
START_POS=("x=-416.0,y=-436.0,speed=0,depth=200,heading=181" "x=1484.0,y=525.0,speed=0,depth=200,heading=355" "x=314.0,y=-1254.0,speed=0,depth=200,heading=306" "x=-434.0,y=1067.0,speed=0,depth=200,heading=276" "x=119.0,y=1269.0,speed=0,depth=200,heading=318" "x=1293.0,y=453.0,speed=0,depth=200,heading=335" "x=396.0,y=-792.0,speed=0,depth=200,heading=236" "x=-782.0,y=1205.0,speed=0,depth=200,heading=181" "x=-1253.0,y=-948.0,speed=0,depth=200,heading=241" "x=446.0,y=-964.0,speed=0,depth=200,heading=212" "x=880.0,y=-697.0,speed=0,depth=200,heading=6" "x=-684.0,y=-980.0,speed=0,depth=200,heading=49")
BHV=("polygon=radial::x=-416.23,y=-449.00,radius=3,pts=6,label=Halfmoon_loiter" "polygon=radial::x=1482.43,y=542.93,radius=3,pts=6,label=Bobtail_snipe_eel_loiter" "polygon=radial::x=305.10,y=-1247.53,radius=3,pts=6,label=Worm_eel_loiter" "polygon=radial::x=-447.92,y=1068.46,radius=3,pts=6,label=Kokanee_loiter" "polygon=radial::x=108.29,y=1280.89,radius=3,pts=6,label=Pencilsmelt_loiter" "polygon=radial::x=1283.28,y=473.85,radius=3,pts=6,label=Pineconefish_loiter" "polygon=radial::x=377.76,y=-804.30,radius=3,pts=6,label=Kanyu_loiter" "polygon=radial::x=-782.42,y=1181.00,radius=3,pts=6,label=Rattail_loiter" "polygon=radial::x=-1266.12,y=-955.27,radius=3,pts=6,label=Trunkfish_loiter" "polygon=radial::x=436.46,y=-979.26,radius=3,pts=6,label=Northern_pike_loiter" "polygon=radial::x=882.51,y=-673.13,radius=3,pts=6,label=Yellowtail_horse_mackerel_loiter" "polygon=radial::x=-666.64,y=-964.91,radius=3,pts=6,label=Frogfish_loiter")

#----------------------------------------------------------
#  Part 3: Launch the processes
#----------------------------------------------------------
for i in ${!VEHICLES[@]}; do
	echo "Launching ${VEHICLES[$i]} MOOS Community. WARP is" $TIME_WARP
	nsplug fish_base.bhv targ_${VEHICLES[$i]}.bhv AUV_NAME="${VEHICLES[$i]}" \
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
		MAX_SPEED=3 \
		MAX_DEPTH=300 \
		SHOREIP="${SHOREIP}" \
		SHORESIDE_PORT=9000 \
		SHORESIDE_PSHARE=9200
	pAntler targ_${VEHICLES[$i]}.moos --MOOSTimeWarp=$TIME_WARP >& /dev/null &
done

#echo "Launching shoreside MOOS Community, WARP is" $TIME_WARP
#nsplug shoreside_base.moos targ_shoreside.moos WARP=$TIME_WARP SHORESIDE_PORT=9000 SHORESIDE_PSHARE=9200
#pAntler targ_shoreside.moos --MOOSTimeWarp=$TIME_WARP >& /dev/null &
