#ifndef _LDAPMODULE_H_
#define _LDAPMODULE_H_
#include "tinyxml2.h"
#include "exceptions.h"
#include "module.h"
#include <ldap.h>
using namespace tinyxml2;

// LDAP Class declare
class LdapModule : public Module
{
	public:
		LdapModule(){ }
		virtual ~LdapModule(){ }

		virtual int initialize( XMLElement* ldap );
		virtual int connect();
		virtual int valuser( char* username );
		virtual int adduser( char* username, char* password);
		virtual	int moduser( char* username, char* password);
		virtual int deluser( char* username );
		virtual int disconnect();
		virtual int dump(){ printf("ldap working\n");}

		int getMaxUid( volatile long int& MAXUID);

	private:
		LDAP          *ld;
		LDAPMessage   *result, *entry;
		char          **vals;

		const char* host;
		int         port;
		const char* baseDn;
		const char* rootDn;
		const char* userDn;
		const char* rootPw;
		const char* homeDr;

		LDAPMod* loadTemplate( char* attrType,char** attrValue );

};

#endif // _LDAPMODULE_H_
