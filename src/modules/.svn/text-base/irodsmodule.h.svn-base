#ifndef _IRODSMODULE_H_
#define _IRODSMODULE_H_
#include "tinyxml2.h"
#include "module.h"
#include "rodsClient.h"
#include "exceptions.h"
using namespace tinyxml2;

// IRODS Class

class IrodsModule : public Module
{
	public:
		IrodsModule ():Module() {};
		virtual ~IrodsModule(){};

		virtual int initialize(XMLElement* irods);
		virtual int connect();
		virtual int valuser( char* username ) { };
		virtual int adduser(  char* username, char* password ) {}; 
		virtual int adduser(  char* username );
		virtual int moduser( char* username,char* password ) { };
		virtual int deluser( char* username );
		virtual int disconnect();
		virtual int dump(){ printf("irods working\n");}
		virtual char* getLocation(){return location;}


	private:
		// confiure
		char* location;
		char* rodsHost;
		int   rodsPort;
		char* rodsUserName;
		char* rodsUserPasswd;
		char* rodsZone;
		// agent connection
		rcComm_t* conn;
};


#endif


