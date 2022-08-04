#--------------------------------------------------------
# The CMakeLists.txt for:                       pUnderwater
# Author(s):                              
#--------------------------------------------------------

SET(SRC
  Underwater.cpp
  Underwater_Info.cpp
  main.cpp
)

ADD_EXECUTABLE(pUnderwater ${SRC})

TARGET_LINK_LIBRARIES(pUnderwater
   ${MOOS_LIBRARIES}
   mbutil
   m
   pthread)

