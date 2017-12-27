#!/bin/sh
# Run from Jenkins
# It is expected that WORKSPACE, BUILD_NUMBER, APP_VERSION, VPREFIX and BUNDLE_MAJOR_VERSION are set


#E-Enterprise
#A-AppStore
#Pp-Provisioning Profile
#Ap -Application
#Wa-Watch Application
#We-Watch Extenstion

SampleAppEPp="SampleApp PP"
SampleAppEWaPp="Sampleapp watchkitapp PP"
SampleAppEWePp="Sampleapp watchkitextension PP"
SampleEID="com.ios.sampleapp"
SampleEWaID="com.ios.sampleapp.watchkitapp"
SampleEWeID="com.ios.sampleapp.watchkitapp.watchkitextension"

AppStoreID="You App Store Team ID"
EnterpriseID="You Enterprise Team ID"


### Build SampleApp Enterprise #####
"./build.sh" -w:"$WORKSPACE" -b:"$BUILD_NUMBER" -v:"$APP_VERSION" -m:"$BUNDLE_MAJOR_VERSION" -p:"iOS/SampleApp" -a:"OnRamp" -f:"-Enterprise"  -tid:"$EnterpriseID"  -app:"$SampleAppEPp" -wpp:"$SampleAppEWaPp" -wepp:"$SampleAppEWePp" -aid:"$SampleEID" -wid:"$SampleEWaID" -weid:"$SampleEWeID" -cnfg:"Release"

