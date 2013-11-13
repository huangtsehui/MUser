#include "soapH.h" 
#include "UserManager.nsmap"
#include <pthread.h> 
#define BACKLOG (100)	// Max. request backlog 
#define MAX_THR (10) // Size of thread pool 
#define MAX_QUEUE (1000) // Max. size of request queue 
#include <stdlib.h>

SOAP_SOCKET queue[MAX_QUEUE]; // The global request queue of sockets 
int head = 0, tail = 0; // Queue head and tail 
void *process_queue(void*); 
int enqueue(SOAP_SOCKET); 
SOAP_SOCKET dequeue(); 
pthread_mutex_t queue_cs; 
pthread_cond_t queue_cv; 

int http_get(struct soap *soap);


// Global user id
volatile long int MAXUID = 1000;  // THE MAX UID in LDAP SERVER

// Global logger
Logger logger = Logger:::getInstance(LOG4CPLUS_TEXT("Global Logger"));

// Global Configuration
XMLDocument configure;


int main(int argc, char **argv) 
{ 
	// program initialize
	// log4cplus configuration
	PropertyConfigurator::doConfigure(LOG4CPLUS_TEXT("./conf/Log4Cplus.inp"));

	// program configuration
	if(configure.LoadFile("conf/config.xml")){
		fprintf(stderr,"fail to read configure file\n");
		return(-1);
	}   

	// get ladp current max uid
	LdapModule* ld = new LdapModule;
    ld->conn();
    ld->initMaxUid(MAXUID);
    ld->disconn();
    delete ld;

	// Web Service
	struct soap soap; 
	soap_init(&soap); 
	soap.fget = http_get;
	if (argc < 2) // no args: assume this is a CGI application 
	{ 
		soap_serve(&soap); // serve request, one thread, CGI style 
		soap_destroy(&soap); // dealloc C++ data 
		soap_end(&soap); // dealloc data and clean up 
	} 
	else
	{ 
		struct soap *soap_thr[MAX_THR]; // each thread needs a runtime context 
		pthread_t tid[MAX_THR]; 
		int port = atoi(argv[1]); // first command-line arg is port 
		SOAP_SOCKET m, s; 
		int i; 
		m = soap_bind(&soap, NULL, port, BACKLOG); 
		if (!soap_valid_socket(m)) 
		  exit(1); 
		fprintf(stderr, "Socket connection successful %d\n", m); 
		pthread_mutex_init(&queue_cs, NULL); 
		pthread_cond_init(&queue_cv, NULL); 
		for (i = 0; i < MAX_THR; i++) 
		{ 
			soap_thr[i] = soap_copy(&soap); 
			fprintf(stderr, "Starting thread %d\n", i); 
			pthread_create(&tid[i], NULL, (void*(*)(void*))process_queue, (void*)soap_thr[i]); 
		} 
		for (;;) 
		{ 
			s = soap_accept(&soap); 
			if (!soap_valid_socket(s)) 
			{ 
				if (soap.errnum) 
				{ 
					soap_print_fault(&soap, stderr); 
					continue; // retry 
				} 
				else
				{ 
					fprintf(stderr, "Server timed out\n"); 
					break; 
				} 
			} 
			fprintf(stderr, "Thread %d accepts socket %d connection from IP %d.%d.%d.%d\n", i, s, (soap.ip >> 24)&0xFF, (soap.ip >> 16)&0xFF, (soap.ip >> 8)&0xFF, soap.ip&0xFF); 
			while (enqueue(s) == SOAP_EOM) 
			  sleep(1); 
		} 
		for (i = 0; i < MAX_THR; i++) 
		{ 
			while (enqueue(SOAP_INVALID_SOCKET) == SOAP_EOM) 
			  sleep(1); 
		} 
		for (i = 0; i < MAX_THR; i++) 
		{ 
			fprintf(stderr, "Waiting for thread %d to terminate... ", i); 
			pthread_join(tid[i], NULL); 
			fprintf(stderr, "terminated\n"); 
			soap_done(soap_thr[i]); 
			free(soap_thr[i]); 
		} 
		pthread_mutex_destroy(&queue_cs); 
		pthread_cond_destroy(&queue_cv); 
	} 
	soap_done(&soap); 
	return 0; 
} 
void *process_queue(void *soap) 
{ 
	struct soap *tsoap = (struct soap*)soap; 
	for (;;) 
	{ 
		tsoap->socket = dequeue(); 
		if (!soap_valid_socket(tsoap->socket)) 
		  break; 
		soap_serve(tsoap); 
		soap_destroy(tsoap); 
		soap_end(tsoap); 
		fprintf(stderr, "served\n"); 
	} 
	return NULL; 
} 
int enqueue(SOAP_SOCKET sock) 
{ 
	int status = SOAP_OK; 
	int next; 
	pthread_mutex_lock(&queue_cs); 
	next = tail + 1; 
	if (next >= MAX_QUEUE) 
	  next = 0; 
	if (next == head) 
	  status = SOAP_EOM; 
	else
	{ 
		queue[tail] = sock; 
		tail = next; 
	} 
	pthread_cond_signal(&queue_cv); 
	pthread_mutex_unlock(&queue_cs); 
	return status; 
} 
SOAP_SOCKET dequeue() 
{ 
	SOAP_SOCKET sock; 
	pthread_mutex_lock(&queue_cs); 
	while (head == tail)       pthread_cond_wait(&queue_cv, &queue_cs); 
	sock = queue[head++]; 
	if (head >= MAX_QUEUE) 
	  head = 0; 
	pthread_mutex_unlock(&queue_cs); 
	return sock; 
}

int ns__adduser(struct soap* soap, char* username, char* password, int* errcode ){

	/* LDAP */
	LdapModule* ldap = new LdapModule;
	ldap->conn();
	if (ldap->valUser(username) == 0){
		*errcode = 723;
		fprintf(stderr,"[LDAP]: The user %s already exist\n",username);
		return SOAP_OK;
	}
	if (ldap->addUser(username,password) == 0){
		fprintf(stderr,"[LDAP]: <%s> success\n",username);
	}else{
		*errcode = 724;
		fprintf(stderr,"[LDAP]: <%s> failed\n",username);
		return SOAP_OK;
	}
	ldap->disconn();

	/* MULTI IRODS */
	for( XMLElement* instance = conf.FirstChildElement()->FirstChildElement("irods")->FirstChildElement("rods");
				instance; instance = instance->NextSiblingElement() ){
		IrodsModule rods;
		rods.init(instance);
		fprintf(stderr,">>>Proccessing [%s] irods : %s \n",rods.location,rods.rodsHost);
		rods.connect();
		rods.disconnect();
	}

	return SOAP_OK;
}

int ns__moduser(struct soap* soap, char* username, char* password, int* errcode ){

	LdapModule* ldap = new LdapModule;
	ldap->conn();
	if( (ldap->valUser(username)) != 0 ){
		fprintf(stderr,"[LDAP]: user %s didn't exist!\n",username);
		*errcode = 731;
		return SOAP_OK;
	}
	if( (ldap->modUser(username,password) ) != 0 ){
		fprintf(stderr,"[LDAP]: user %s change passwd failed\n",username );
		*errcode = 732;
		return SOAP_OK;
	}else{
		fprintf(stderr,"[LDAP]: user %s change passwd success\n",username );
	}
	ldap->disconn();
	delete ldap;

	*errcode = 0;
	return SOAP_OK;

	return SOAP_OK;
}

int http_get(struct soap *soap)
{
	FILE*fd = NULL;
	fd = fopen("UserManager.wsdl", "rb"); //open WSDL file to copy
	if (!fd)
	{   
		return 404; //return HTTP not found error
	}   
	soap->http_content = "text/xml";  //HTTP header with text /xml content
	soap_response(soap,SOAP_FILE);
	for(;;)
	{   
		size_t r = fread(soap->tmpbuf,1, sizeof(soap->tmpbuf), fd);
		if (!r)
		{   
			break;
		}   
		if (soap_send_raw(soap, soap->tmpbuf, r)) 
		{   
			break; //cannot send, but little we can do about that
		}   
	}   
	fclose(fd);
	soap_end_send(soap);
	return SOAP_OK;
}
