/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: Underwater.h                                          */
/*    DATE:                                                 */
/************************************************************/

#ifndef Underwater_HEADER
#define Underwater_HEADER

#include "MOOS/libMOOS/MOOSLib.h"
#include<queue>

class Underwater : public CMOOSApp
{
 public:
   Underwater();
   ~Underwater();

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

  double _minChaseDist;
  double _maxChaseDist;
  std::string _mode;
  std::queue<std::string> _nodeReports;
  std::list<std::map<std::string, std::string> > _contactList;
  std::list<std::map<std::string, std::string> > _contactsCollected;
};

#endif 
