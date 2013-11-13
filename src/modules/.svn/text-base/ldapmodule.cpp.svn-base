#include "ldapmodule.h"
#include <stdlib.h>
#define LEN 512
#define MAXERRLEN 2408

extern volatile long int MAXUID;

int LdapModule::initialize(XMLElement* ldap)
{
	this->host   = ldap->FirstChildElement("ldapHost")->GetText();
	this->port   = atoi(ldap->FirstChildElement("ldapPort")->GetText());
	this->baseDn = ldap->FirstChildElement("ldapBaseDn")->GetText();
	this->rootDn = ldap->FirstChildElement("ldapRootDn")->GetText();
	this->rootPw = ldap->FirstChildElement("ldapRootPw")->GetText();
	this->userDn = ldap->FirstChildElement("ldapUserDn")->GetText();
	this->homeDr = ldap->FirstChildElement("ldapHomeDr")->GetText();

	return 0;
};

int LdapModule::connect()
{

	/* Get a handle to an LDAP connection and set any session preferences. */
	if ( (ld = ldap_init( host,port) )
				== NULL ){
		//ldap_perror(ld, "ldap_init");
		MyException ex("ldap init failed",701);
		throw ex;
	}

	/* Binding  simple_bind_s */
	int ld_errno;
	ld_errno = ldap_simple_bind_s(ld,rootDn ,rootPw);
	if(ld_errno != LDAP_SUCCESS){
		char reason[MAXERRLEN];
		sprintf(reason,"ldap binding failed: %s",ldap_err2string(ld_errno));
		MyException ex(reason,702);
		throw ex;
	}

	return 0;
};

int LdapModule::disconnect()
{
	ldap_unbind( ld );
	return 0;

};


int LdapModule::valuser( char* username )
{
	int		ld_errno ;
	char	validDN[LEN];
	sprintf( validDN, "uid=%s,%s", username, userDn );
	ld_errno= ldap_search_s( ld, validDN, LDAP_SCOPE_BASE, "uid=*" , NULL, 0, &result );
	ldap_msgfree( this->result );
	return ld_errno;

	/*
	if(ld_errno = LDAP_SUCCESS){
		ldap_unbind( ld );
		sprintf(reason,"the username %s already exist",username);
		MyException ex(reason,723);
		throw ex;
	}else{
		ldap_msgfree( this->result );
		ldap_unbind( ld );
		return 

	return 0;
	*/
};


int LdapModule::adduser( char* username, char* password)
{
	int ld_errno;
	char reason[MAXERRLEN];

	if( valuser(username) == LDAP_SUCCESS)
	{
		sprintf(reason,"the username %s already exist",username);
		MyException ex(reason,723);
		throw ex;
	}

	char addDn[LEN];
	char homedir[LEN],gecos[LEN],uidNum[LEN];
	sprintf(addDn, "uid=%s,%s", username, userDn);
	sprintf(homedir,"%s/%s",homeDr,username);
	sprintf(uidNum, "%d",MAXUID);

	LDAPMod *modst[12];

	char* uidVal[] = { username, NULL };
	modst[0]  = loadTemplate("uid",uidVal);
	char* cnVal[]  = { username, NULL };
	modst[1]  = loadTemplate("cn", cnVal);
	char* objVal[] = { "account","top","posixAccount","shadowAccount",NULL };
	modst[2]  = loadTemplate("objectClass",objVal);
	char* pwVal[]  = { password,NULL };
	modst[3]  = loadTemplate("userPassword",pwVal);
	char* slVal[]  = { "13048",NULL};
	modst[4]  = loadTemplate("shadowLastChange",slVal);
	char* smVal[]  = { "99999",NULL};
	modst[5]  = loadTemplate("shadowMax",smVal);
	char* swVal[]  = { "7",NULL };
	modst[6]  = loadTemplate("shadowWarning",swVal);
	char* unVal[]  = { uidNum, NULL };
	modst[7]  = loadTemplate("uidNumber",unVal);
	char* gnVal[]  = { "1000",NULL };
	modst[8]  = loadTemplate("gidNumber",gnVal);
	char* hdVal[]  = { homedir,NULL };
	modst[9] = loadTemplate("homeDirectory",hdVal);
	char* lsVal[]  = { "/bin/bash",NULL };
	modst[10] = loadTemplate("loginShell",lsVal);
	modst[11] = NULL;

	ld_errno = ldap_add_s(ld,addDn,modst);
	if (ld_errno != LDAP_SUCCESS){
		for(int i=0;i<12;i++)
		  delete (modst[i]);
		ldap_unbind( ld );
		sprintf(reason,"ldap add user %s failed: %s",username,ldap_err2string(ld_errno));
		MyException ex(reason,724);
		throw ex;
	}

	for(int i=0;i<12;i++)
	  delete (modst[i]);

	return 0;
};

int LdapModule::moduser( char* username, char* password )
{
	int ld_errno;
	char reason[MAXERRLEN];

	if (valuser(username) != LDAP_SUCCESS)
	{
		sprintf(reason,"the username %s didn't exist",username);
		MyException ex(reason,725);
		throw ex;
	}

	LDAPMod pwAttr;
	char* pwVal[] = { password, NULL };
	pwAttr.mod_op     = LDAP_MOD_REPLACE;
	pwAttr.mod_type   = "userPassword";
	pwAttr.mod_values =  pwVal;

	LDAPMod* mods[2];
	mods[0] = &pwAttr;
	mods[1] = NULL;

	char modDn[LEN];
	sprintf(modDn,"uid=%s,%s",username, userDn);
	ld_errno = ldap_modify_s (ld,modDn,mods);
	if (ld_errno!=LDAP_SUCCESS){
		sprintf(reason,"ldap modify user %s failed: %s",username,ldap_err2string(ld_errno));
		MyException ex(reason,726);
		ldap_unbind(ld);
		throw ex;
	}

	return 0;
};

int LdapModule::deluser( char* username)
{
	int ld_errno;
	char reason[MAXERRLEN];

	/*
	if (valuser(username) != LDAP_SUCCESS)
	{   
		sprintf(reason,"the username %s didn't exist",username);
		MyException ex(reason,725);
		throw ex; 
	}  
	*/

	char delDn[LEN];
	sprintf(delDn,"uid=%s,%s",username,userDn);
	ld_errno = ldap_delete_s(ld, delDn);
	if (ld_errno != LDAP_SUCCESS){
		sprintf(reason,"ldap delete user %s failed: %s",username,ldap_err2string(ld_errno));
		MyException ex(reason,726);
		ldap_unbind(ld);
		throw ex;
	}

	return 0;
};


int LdapModule::getMaxUid( volatile long int& MAXUID)
{
	int ld_errno;
	char reason[MAXERRLEN];
	ld_errno = ldap_search_s( ld, baseDn, LDAP_SCOPE_SUBTREE, "uid=*" , NULL, 0, &result );

	if ( ld_errno != LDAP_SUCCESS ) {
		sprintf(reason,"ldap search failed, cannot get maxuid: %s",ldap_err2string(ld_errno));
		MyException ex(reason,727);
		ldap_msgfree( this->result );
		ldap_unbind(ld);
		throw ex;
	}

	// descending sort the entries by uidNumber attribute
	// <<NOTE>> the overhead choice between sort and iteration <<PRIORITY:LOW>> || REVISED

	for ( entry = ldap_first_entry(ld, result); entry != NULL;
				entry = ldap_next_entry(ld, entry) )
	{

		// get the max uidNumber 
		vals = ldap_get_values( ld, entry, "uidNumber" );
		int i = atol(vals[0]);  // only one value in this attribute or no ?
		if ( i>MAXUID)
		  MAXUID = i; 
	}

	ldap_value_free( this->vals );
	ldap_msgfree( this->result );

	return 0;
};


LDAPMod* LdapModule::loadTemplate ( char* attrType,char** attrValue )
{
	LDAPMod* attr = new LDAPMod;
	attr->mod_op     = LDAP_MOD_ADD;
	attr->mod_type   = attrType;
	attr->mod_values = attrValue;

	return attr;
};

