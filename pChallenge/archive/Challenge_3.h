/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: Challenge.h                                          */
/*    DATE:                                                 */
/************************************************************/

#ifndef Challenge_HEADER
#define Challenge_HEADER

#include "MOOS/libMOOS/MOOSLib.h"

class Challenge : public CMOOSApp
{
 public:
   Challenge();
   ~Challenge();

 protected: // Standard MOOSApp functions to overload  
   bool OnNewMail(MOOSMSG_LIST &NewMail);
   bool Iterate();
   bool OnConnectToServer();
   bool OnStartUp();

 protected:
   void RegisterVariables();

 private: // Configuration variables

 private: // State variables
  double _navX;
  double _navY;
  double _navDepth;
  double _navSpeed;
  double _navHeading;

  std::vector<std::string> _nodeReports;
};

#endif 
