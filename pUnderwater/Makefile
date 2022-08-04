NAME=Underwater

INSTALL_DIR=${HOME}/moos-bwsi/behaviors/bin

MOOS_LIBDIR=${HOME}/moos-ivp/lib
MOOSCORE_LIBDIR=${HOME}/moos-ivp/build/MOOS/MOOSCore/lib/
MOOS_INCLUDE=${HOME}/moos-ivp/include/ivp/
MOOSAPP_INCLUDE=${HOME}/moos-ivp/MOOS/MOOSCore/Core/libMOOS/App/include
MOOSCORE_INCLUDE=${HOME}/moos-ivp/MOOS/MOOSCore/Core/libMOOS/include/
MOOSUTIL_INCLUDE=${HOME}/moos-ivp/MOOS/MOOSCore/Core/libMOOS/Utils/include
MOOSCOMM_INCLUDE=${HOME}/moos-ivp/MOOS/MOOSCore/Core/libMOOS/Comms/include
GETPOT_INCLUDE=${HOME}/moos-ivp/MOOS/MOOSCore/Core/libMOOS/Thirdparty/getpot/include/
POCOBITS_INCLUDE=${HOME}/moos-ivp/MOOS/MOOSCore/Core/libMOOS/Thirdparty/PocoBits/include
LIBS=-lMOOS -lmbutil -lpthread -lm


SRC=${NAME}.cpp ${NAME}_Info.cpp main.cpp
INCL=${NAME}.h

all: clean default install 

default: ${SRC}
	g++ -Wall -o p${NAME} ${SRC} -I${MOOS_INCLUDE} -I${MOOSCORE_INCLUDE} -I${MOOSUTIL_INCLUDE} -I${MOOSCOMM_INCLUDE} -I${GETPOT_INCLUDE} -I${POCOBITS_INCLUDE} -I${MOOSAPP_INCLUDE} -L${MOOS_LIBDIR} -L${MOOSCORE_LIBDIR} ${LIBS}

install:
	mkdir -p ${INSTALL_DIR}
	mv p${NAME} ${INSTALL_DIR}

clean:
	rm -f *.o
	rm -f ${INSTALL_DIR}/p${NAME}


