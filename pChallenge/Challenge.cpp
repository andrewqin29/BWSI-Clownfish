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

//-----------------------------------------
// Utility functions
std::map<std::string, std::string> ReadNodeReport(std::string report) {
  std::map<std::string, std::string> thisMap;

  std::string key, val;
  std::istringstream iss(report);

  while (std::getline(std::getline(iss, key, '=') >> std::ws, val, ','))
    thisMap[key] = val;

  return thisMap;

}

bool SameContact(std::map<std::string, std::string> A, std::map<std::string, std::string> B) {
  return ( (A["NAME"].compare(B["NAME"])==0) && (A["TYPE"].compare(B["TYPE"])==0));
}
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
    }
    else if (key.compare("NAV_Y")==0) {
      _navY = msg.GetDouble();
    }
    else if (key.compare("NAV_DEPTH")==0) {
      _navDepth = msg.GetDouble();
    }
    else if (key.compare("NAV_HEADING")==0) {
      _navHeading = msg.GetDouble();
    }
    else if (key.compare("NAV_SPEED")==0) {
      _navSpeed = msg.GetDouble();
    }
    else if (key.compare("MODE")==0) {
      _mode = msg.GetString();
    }
    else if (key.compare("NODE_REPORT")==0) {
      _nodeReports.push(msg.GetString());
      // std::cout << "Node Report: " << msg.GetString() << std::endl;
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
  //--------------------------------------------------
  //BWSI added code
  // Process the node reports that have come in since the last call to Iterate()
  while (!_nodeReports.empty()) {
    std::string report = _nodeReports.front();

    // convert the report into a "dictionary"
    std::map<std::string, std::string> thisContact = ReadNodeReport(report);
    
    // check if this contact is in our list
    bool isNew = true;
    for (std::map<std::string, std::string>& contact : _contactList) {
      if (SameContact(contact, thisContact)) {
        // We already have a record of this contact, so update it
        //std::cout << "Known contact " << contact["NAME"] << ", updating..." << std::endl;
        for (std::map<std::string,std::string>::iterator it=contact.begin(); it!=contact.end();it++) {
          contact[it->first] = thisContact[it->first];
        }
        isNew = false;
        break;
      } 
    }
    // if it was not on our list, then add it
    if (isNew)
      _contactList.push_back(thisContact);

    // remove the report from the queue  
    _nodeReports.pop();
  }

  // loop through our contact list and decide what to do
  for (std::map<std::string, std::string> contact : _contactList) {
    double distance = sqrt(pow(std::stof(contact["X"]) - _navX, 2) + pow(std::stof(contact["Y"])-_navY,2));
    std::cout << "Dist = " << distance << " to " << contact["NAME"] << std::endl;
    std::cout << "Contact type: " << contact["TYPE"] << std::endl;
    std::cout << "Max: " << _maxChaseDist << std::endl;
    std::cout << "Min: " << _minChaseDist << std::endl;

    if (contact["TYPE"] == "shark" && distance < 100) {
      std::ostringstream message;
      message << "contact = " << contact["NAME"];
      // std::cout << "contact is: " << contact["NAME"] << std::endl;

      if (contact["MODE"] == "MODE@ACTIVE:CHASING" && distance < 100) {
        // std::cout << "trying to avoid: " << contact["NAME"] << std::endl;
        // std::cout << "contact mode is: " << contact["MODE"] << std::endl;
        _prevMode = _mode;
        Notify("AVOID_UPDATES", message.str());
        Notify("AVOID", "true");
        Notify("LOITER1", "false");
        Notify("LOITER2", "false");
      }
      else {
        // shark ended chase behavior
        // how to get previous mode the vehicle was in and then change it back
        // std::cout << "previous mode: " << _prevMode << std::endl;
        // std::cout << "current mode: " << _mode << std::endl;
        if (_prevMode == "MODE@ACTIVE:CHASING") {
          // if it was chasing a whale, fish, or treasure resume chase bhv
          Notify("AVOID", "false");
          Notify("CLOSE", "true");
          Notify("LOITER1", "false");
          Notify("LOITER2", "false");
        }
        else if (_prevMode == "MODE@ACTIVE:LOITERING1") {
          // switch back to Loitering 1
          Notify("AVOID", "false");
          Notify("CLOSE", "false");
          Notify("LOITER1", "true");
          Notify("LOITER2", "false");
        }
        else {
          // last case should only be if previous mode was Loitering 2
          Notify("AVOID", "false");
          Notify("CLOSE", "false");
          Notify("LOITER1", "false");
          Notify("LOITER2", "true");
        }
      }
    }
    else if(contact["TYPE"] != "shark") { // contact["TYPE"].compare("shark")!=0
      std::cout << "Not shark" << std::endl;
      // assumes that the mode change radius, _minChaseDist, is constant among the animals and objects
      if (distance < _minChaseDist) { 
        // picked up target, don't need to chase again
        if (contact["TYPE"] != "whale" && abs(std::stod(contact["DEP"]) - _navDepth) < 5) {
          std::cout << "tagged" << std::endl;
          _contactsCollected.push_back(contact);
          if (_prevMode == "MODE@ACTIVE:LOITERING1") {
            // switch back to Loitering 1
            Notify("CLOSE", "false");
            Notify("LOITER1", "true");
            Notify("LOITER2", "false");
          }
          else {
            // last case should only be if previous mode was Loitering 2
            // or if it starts off in range to chase
            Notify("CLOSE", "false");
            Notify("LOITER1", "false");
            Notify("LOITER2", "true");
          }
        }
        else if (contact["TYPE"] == "whale") {
          std::cout << "tagged" << std::endl;
          _contactsCollected.push_back(contact);
          if (_prevMode == "MODE@ACTIVE:LOITERING1") {
            // switch back to Loitering 1
            Notify("CLOSE", "false");
            Notify("LOITER1", "true");
            Notify("LOITER2", "false");
          }
          else {
            // last case should only be if previous mode was Loitering 2
            // or if it starts off in range to chase
            Notify("CLOSE", "false");
            Notify("LOITER1", "false");
            Notify("LOITER2", "true");
          }
        }
        
      }
      // runs when not correct depth. Is it necessary?
      // else if ( (distance < _minChaseDist) || (distance > _maxChaseDist) ) {
      //   // call off the chase
      //   // std::cout << "not within range" << std::endl;
      //   // std::cout << "Distance: " << distance << std::endl;
      //   if (_prevMode == "MODE@ACTIVE:LOITERING1") {
      //     // switch back to Loitering 1
      //     Notify("CLOSE", "false");
      //     Notify("LOITER1", "true");
      //     Notify("LOITER2", "false");
      //   }
      //   else {
      //     // last case should only be if previous mode was Loitering 2
      //     Notify("CLOSE", "false");
      //     Notify("LOITER1", "false");
      //     Notify("LOITER2", "true");
      //   }
      // }
      else if (distance < _maxChaseDist) {
        // std::cout << "in range" << std::endl;
        // check if this is a contact we have already pursued
        bool isCollected = false;
        for (std::map<std::string, std::string> completed : _contactsCollected) {
          if (SameContact(contact, completed)) {
            isCollected = true;
            break;
          }
        }

        if (!isCollected) {
          // start the chase
          std::cout << "chasing" << std::endl;
          _prevMode = _mode;
          std::ostringstream message;
          message << "contact = " << contact["NAME"];
          std::cout << "vehicle speed is: " << _navSpeed << std::endl;
          // std::ostringstream message2;
          // message2 << "speed = 6";
          // finding vehicle type based on speed
          if (contact["TYPE"] == "whale" && _navSpeed > 10) { 
            std::cout << "chasing whale" << std::endl;
            Notify("CHASE_UPDATES", message.str());
            Notify("CLOSE", "true");
            Notify("LOITER1", "false");
            Notify("LOITER2", "false");
            // Notify("MAX_SPEED_UPDATES", message2.str());
          }
          else if (contact["TYPE"] == "fish" && _navSpeed < 10) {
            std::cout << "chasing fish" << std::endl;
            std::ostringstream depth_msg;
            depth_msg << "depth = " << contact["DEP"];
            std::cout << "fish depth = " << contact["DEP"] << " vehicle depth = " << _navDepth << std::endl;
            Notify("CHASE_UPDATES", message.str());
            Notify("CONST_DEPTH_UPDATES", depth_msg.str()); // need to check if this is the correct constant depth behavior
            Notify("CLOSE", "true");
            Notify("LOITER1", "false");
            Notify("LOITER2", "false");
          }
          // else if (contact["TYPE"] == "treasure" && _navSpeed < 10) {
          //   // need to add final behavior to bring treasure to shore, probably change mode to return and return point to starting point
          //   std::cout << "chasing treasure" << std::endl;
          //   std::ostringstream depth_msg;
          //   depth_msg << "depth = " << contact["DEP"];
          //   std::cout << "treasure depth = " << contact["DEP"] << " vehicle depth = " << _navDepth << std::endl;
          //   Notify("CHASE_UPDATES", message.str());
          //   Notify("CONST_DEPTH_UPDATES", depth_msg.str()); // need to check if this is the correct constant depth behavior
          //   Notify("CLOSE", "true");
          //   Notify("LOITER1", "false");
          //   Notify("LOITER2", "false");
          // }
        }
      }
    } 
  }
  //
  //---------------------------------------------------

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
      
      if(param == "max_chase_distance") {
        _maxChaseDist = 100;
      }
      else if(param == "min_chase_distance") {
        _minChaseDist = 5;
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

