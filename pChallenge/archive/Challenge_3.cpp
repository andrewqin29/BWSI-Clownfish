/************************************************************/
/*    NAME:                                               */
/*    ORGN: MIT                                             */
/*    FILE: Challenge.cpp                                        */
/*    DATE:                                                 */
/************************************************************/

#include <iterator>
#include "MBUtils.h"
#include "Challenge.h"

using namespace std;

//---------------------------------------------------------
// Constructor

Challenge::Challenge()
{
}

//---------------------------------------------------------
// Destructor

Challenge::~Challenge()
{
}

//---------------------------------------------------------
// Procedure: OnNewMail

bool Challenge::OnNewMail(MOOSMSG_LIST &NewMail)
{
  MOOSMSG_LIST::iterator p;
   
  for(p=NewMail.begin(); p!=NewMail.end(); p++) {
    CMOOSMsg &msg = *p;

    //--------------------------------------------
    //BWSI added code
    std::string key = msg.GetKey();

    if (key.compare("NAV_X")==0) {
      _navX = msg.GetDouble();
      std::cout << "NAV_X = " << _navX <<std::endl;
    }
    else if (key.compare("NAV_Y")==0) {
      _navY = msg.GetDouble();
      std::cout << "NAV_Y = " << _navY <<std::endl;
    }
    else if (key.compare("NAV_DEPTH")==0) {
      _navDepth = msg.GetDouble();
      std::cout << "NAV_DEPTH = " << _navDepth <<std::endl;
    }
    else if (key.compare("NAV_HEADING")==0) {
      _navHeading = msg.GetDouble();
      std::cout << "NAV_HEADING = " << _navHeading <<std::endl;
    }
    else if (key.compare("NAV_SPEED")==0) {
      _navSpeed = msg.GetDouble();
      std::cout << "NAV_SPEED = " << _navSpeed <<std::endl;
    }
    else if (key.compare("NODE_REPORT")==0) {
      _nodeReports.push_back(msg.GetString());
      std::cout << "NODE_REPORT = " << msg.GetString() << std::endl;
    }
    else {
      std::cerr << "Unknown message type: " << key << std::endl;
    }
    //
    //-----------------------------------------

#if 0 // Keep these around just for template
    string key   = msg.GetKey();
    string comm  = msg.GetCommunity();
    double dval  = msg.GetDouble();
    string sval  = msg.GetString(); 
    string msrc  = msg.GetSource();
    double mtime = msg.GetTime();
    bool   mdbl  = msg.IsDouble();
    bool   mstr  = msg.IsString();
#endif
   }
	
   return(true);
}

//---------------------------------------------------------
// Procedure: OnConnectToServer

bool Challenge::OnConnectToServer()
{
   RegisterVariables();
   return(true);
}

//---------------------------------------------------------
// Procedure: Iterate()
//            happens AppTick times per second

bool Challenge::Iterate()
{
  return(true);
}

//---------------------------------------------------------
// Procedure: OnStartUp()
//            happens before connection is open

bool Challenge::OnStartUp()
{
  list<string> sParams;
  m_MissionReader.EnableVerbatimQuoting(false);
  if(m_MissionReader.GetConfiguration(GetAppName(), sParams)) {
    list<string>::iterator p;
    for(p=sParams.begin(); p!=sParams.end(); p++) {
      string line  = *p;
      string param = tolower(biteStringX(line, '='));
      string value = line;
      
      if(param == "foo") {
        //handled
      }
      else if(param == "bar") {
        //handled
      }
    }
  }
  
  RegisterVariables();	
  return(true);
}

//---------------------------------------------------------
// Procedure: RegisterVariables

void Challenge::RegisterVariables()
{
  //--------------------------
  // BWSI added code
  Register("NAV_X", 0);
  Register("NAV_Y", 0);
  Register("NAV_DEPTH", 0);
  Register("NAV_HEADING", 0);
  Register("NAV_SPEED", 0);

  Register("NODE_REPORT", 0);
  // BWSI added code
  //--------------------------
}

