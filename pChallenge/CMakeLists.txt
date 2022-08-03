#--------------------------------------------------------
# The CMakeLists.txt for:                       pChallenge
# Author(s):                              
#--------------------------------------------------------

SET(SRC
  Challenge.cpp
  Challenge_Info.cpp
  main.cpp
)

ADD_EXECUTABLE(pChallenge ${SRC})

TARGET_LINK_LIBRARIES(pChallenge
   ${MOOS_LIBRARIES}
   mbutil
   m
   pthread)

