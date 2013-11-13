HOME=/home/huangzehui/irodsAPI
g++ -g \
src/MUSer2.cpp \
src/modules/ldapmodule.cpp \
src/modules/irodsmodule.cpp \
src/webservice/soapC.c \
src/webservice/soapServer.c \
src/webservice/stdsoap2.cpp \
lib/tinyxml2.cpp \
/usr/local/lib/liblog4cplus.a \
-I src/ \
-I ./include/ \
-I $HOME/lib/api/include/ \
-I $HOME/lib/core/include/ \
-I $HOME/lib/md5/include/ \
-I $HOME/server/core/include/ \
-I $HOME/server/icat/include/ \
-I $HOME/server/drivers/include/ \
-I $HOME/server/re/include/ \
-L $HOME/lib/core/obj/ \
-I src/webservice \
-I src/modules \
-I lib/ \
-lm -lpthread -lRodsAPIs -lstdc++ \
-DLDAP_DEPRECATED=1 -lldap \
-o MUSer
  
