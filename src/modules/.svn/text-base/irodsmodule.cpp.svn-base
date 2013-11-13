#include "irodsmodule.h"
#include "exceptions.h"
#include <string>
using std::string;
#define MAXERRLEN 2048

int IrodsModule::initialize( XMLElement* rods)
{
	this->location = const_cast<char*>(rods->FirstAttribute()->Value());
	this->rodsHost = const_cast<char*>(rods->FirstChildElement("rodsHost")->GetText());
	this->rodsPort = atoi (rods->FirstChildElement("rodsPort")->GetText());
	this->rodsUserName = const_cast<char*>(rods->FirstChildElement("rodsUserName")->GetText());
	this->rodsUserPasswd = const_cast<char*>(rods->FirstChildElement("rodsUserPasswd")->GetText());
	this->rodsZone = const_cast<char*>(rods->FirstChildElement("rodsZone")->GetText());
	return 0;
};

int IrodsModule::connect()
{
	rErrMsg_t errMsg;
	memset(&errMsg, 0, sizeof(rErrMsg_t));

	conn = rcConnect(rodsHost, rodsPort, rodsUserName, rodsZone, 0, &errMsg);

	if (conn == NULL)
	{   
		MyException ex("irods rcConnect() error",730);
		throw ex;
		//		fprintf(stderr, "rcConnect() error\n");
		//		return(-1);
	} 

	int status = clientLoginWithPassword(conn, rodsUserPasswd);
	if (status != 0) 
	{   
		rcDisconnect(conn);
		MyException ex("irods client login err,check the password",731);
		throw ex;
		//		return(-1);                                                                                  
	}

	return 0;
};

int IrodsModule::disconnect()
{
	rcDisconnect(conn);
	return 0;
};

int IrodsModule::adduser(char* username)
{
	generalAdminInp_t generalAdminInp;

	generalAdminInp.arg0 = "add";
	generalAdminInp.arg1 = "user";
	generalAdminInp.arg2 = username;
	generalAdminInp.arg3 = "rodsuser";
	generalAdminInp.arg4 = "";
	generalAdminInp.arg5 = "";
	generalAdminInp.arg6 = "";
	generalAdminInp.arg7 = "";
	generalAdminInp.arg8 = "";
	generalAdminInp.arg9 = "";

	int status = rcGeneralAdmin(conn, &generalAdminInp);
	char reason[MAXERRLEN];
	sprintf(reason,"irods make user failed\n");
	if (conn->rError) {
		rError_t *Err;
		rErrMsg_t *ErrMsg;
		int i, len;
		Err = conn->rError;
		len = Err->len;
		for (i=0;i<len;i++) {
			ErrMsg = Err->errMsg[i];
			char s[MAXERRLEN];
			sprintf(s,"Level %d message: %s\n",i, ErrMsg->msg);
			strcat(reason,s);
			//			printf("Level %d message: %s\n",i, ErrMsg->msg);
		}
	}

	char *mySubName;
	char *myName;
	if (status<0) {
		myName = rodsErrorName(status, &mySubName);
		char s[MAXERRLEN];
		sprintf(s,"failed with error %d %s %s", status, myName, mySubName);
		strcat(reason,s);
		//	rodsLog (LOG_ERROR, "failed with error %d %s %s", status, myName, mySubName);
		rcDisconnect(conn);
		MyException ex(reason,732);
		throw ex;
	}

	return 0;
};

int IrodsModule::deluser(char* username)
{
	generalAdminInp_t generalAdminInp;

	generalAdminInp.arg0 = "rm";
	generalAdminInp.arg1 = "user";
	generalAdminInp.arg2 = username;
	generalAdminInp.arg3 = "";
	generalAdminInp.arg4 = "";
	generalAdminInp.arg5 = "";
	generalAdminInp.arg6 = "";
	generalAdminInp.arg7 = "";
	generalAdminInp.arg8 = "";
	generalAdminInp.arg9 = "";

	int status = rcGeneralAdmin(conn, &generalAdminInp);
	char reason[MAXERRLEN];
	sprintf(reason,"irods delete user failed\n");
	if (conn->rError) {
		rError_t *Err;
		rErrMsg_t *ErrMsg;
		int i, len;
		Err = conn->rError;
		len = Err->len;
		for (i=0;i<len;i++) {
			ErrMsg = Err->errMsg[i];
			char s[MAXERRLEN];
			sprintf(s,"Level %d message: %s\n",i, ErrMsg->msg);
			strcat(reason,s);
			//printf("Level %d message: %s\n",i, ErrMsg->msg);
		}
	}

	char *mySubName;
	char *myName;
	if (status<0) {
		myName = rodsErrorName(status, &mySubName);
		char s[MAXERRLEN];
		sprintf(s,"failed with error %d %s %s", status, myName, mySubName);
		strcat(reason,s);
		//	rodsLog (LOG_ERROR, "failed with error %d %s %s", status, myName, mySubName);
		//	return (-1);
		rcDisconnect(conn);
		MyException ex(reason,733);
		throw ex;
	}

	return 0;
};



