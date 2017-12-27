#!/bin/sh
# Build Projects



#Read command line arguments
for i in "$@"
do
case $i in
    -workspace:*|-w:*)
    Workspace=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -project:*|-p:*)
    Project=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -build_number:*|-b:*)
    BuildNumber=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`


    ;;
    -file_suffix:*|-f:*)
    FileSuffix=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -app_profile:*|-app:*)
    AppPP=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -watch_app_profile:*|-wpp:*)
    WatchAppPP=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -watch_extension_app_profile:*|-wepp:*)
    WathExtenstionPP=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -bundle_id:*|-aid:*)
    AppBundleID=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -watch_bundle_id:*|-wid:*)
    WatchAppBundleID=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -watch_extension_bundle_id:*|-weid:*)
    WatchExtenstionBundleID=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -version:*|-v:*)
    AppVersion=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -major_version:*|-m:*)
    BundleMajorVersion=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -app_name:*|-a:*)
    AppName=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -team_id:*|-tid:*)
    TeamID=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    -config:*|-cnfg:*)
     Config=`echo $i | sed 's/[-a-zA-Z0-9_]*://'`

    ;;
    *)
	echo Unknown Option: $i
    ;;
esac
done

#Initialize variables
curDir="$(pwd)"
Workspace="$(cd $Workspace; pwd)"
PPDir="$(cd ~/Library/MobileDevice/Provisioning\ Profiles; pwd)"
cd "$curDir"
ProjectName=`basename "$Project"`
ProjectDir="$Workspace/$Project"

#App name defaults to project name
if [ -z $AppName ]; then
	AppName="$ProjectName"
fi

#Scheme defaults to app name
if [ -z $Scheme ]; then
    Scheme="$ProjectName"
fi

TempDir="$Workspace/iOS/builds/$AppName-$FileSuffix"
ResultsDir="$Workspace/iOS/builds/results"
mkdir -p $ResultsDir

#Print variables
echo -----------------------------
echo AppName                 = $AppName
echo Workspace               = $Workspace
echo Project                 = $Project
echo ProjectName             = $ProjectName
echo Scheme                  = $Scheme
echo BuildNumber             = $BuildNumber
echo AppBundleID             = $AppBundleID
echo WatchAppBundleID        = $WatchAppBundleID
echo WatchExtenstionBundleID = $WatchExtenstionBundleID
echo TeamID                  = $TeamID
echo Config                  = $Config
echo AppVersion              = $AppVersion
echo BundleMajorVersion      = $BundleMajorVersion
echo ProjectDir              = $ProjectDir
echo TempDir                 = $TempDir
echo -----------------------------

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $AppVersion" "$ProjectDir/$ProjectName/$ProjectName"-Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BundleMajorVersion.$BuildNumber" "$ProjectDir/$ProjectName/$ProjectName"-Info.plist

rm -rf "$TempDir"
# remove old file
rm -rf $ProjectName.txt

bundlesIDs=("$AppBundleID")
appPProfiles=("$AppPP")

#if watch app bundle id passed
if [ ! -z $WatchAppBundleID ]; then

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $AppVersion" "$ProjectDir/${ProjectName}WatchKitApp/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BundleMajorVersion.$BuildNumber" "$ProjectDir/${ProjectName}WatchKitApp/Info.plist"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $AppVersion" "$ProjectDir/${ProjectName}WatchKitApp Extension/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BundleMajorVersion.$BuildNumber" "$ProjectDir/${ProjectName}WatchKitApp Extension/Info.plist"

#update bundle ids and app profiles for apps which have watch app
bundlesIDs=("$AppBundleID" "$WatchAppBundleID" "$WatchExtenstionBundleID")
appPProfiles=("$AppPP" "$WatchAppPP" "$WathExtenstionPP")

fi

xcodebuild \
    -project "$ProjectDir/$ProjectName.xcodeproj" \
    -scheme "$Scheme" \
    -configuration "$Config" \
    -archivePath "$TempDir/$Scheme" \
    -derivedDataPath "$TempDir" \
    OTHER_CFLAGS="-fembed-bitcode" \
    DEVELOPMENT_TEAM="$TeamID" \
    clean archive | xcpretty > $ProjectName.txt

last_error="${PIPESTATUS[0]}"

grep -w '❌\|[x]' $ProjectName.txt >> "$WORKSPACE/iOS/builds/errors.txt"
grep -w '⚠️\|[!]' $ProjectName.txt >> "$WORKSPACE/iOS/builds/warnings.txt"

if [ $last_error -ne 0 ]; then
echo "xcodebuild failed with error $last_error"
exit $last_error
fi

#update export options  plist file
. ./updatePlistFile.sh "$WORKSPACE/iOS/Scripts/App$FileSuffix.plist" "bundlesIDs[@]" dummyValue "appPProfiles[@]"

# create IPA
# Export the archive to an ipa
xcodebuild \
-exportArchive \
-archivePath "$TempDir/$Scheme.xcarchive" \
-exportOptionsPlist "$WORKSPACE/iOS/Scripts/App$FileSuffix.plist" \
-exportPath "$ResultsDir" \
PRODUCT_BUNDLE_IDENTIFIER="$AppBundleID"

# create directory for dSYM and symbol map files, and then copy files
mkdir -p "$ResultsDir/extras/$AppName-$FileSuffix"
cp -rf "$TempDir/$Scheme.xcarchive/BCSymbolMaps" "$ResultsDir/extras/$AppName-$FileSuffix/"
cp -rf "$TempDir/$Scheme.xcarchive/dSYMs" "$ResultsDir/extras/$AppName-$FileSuffix/"

# rename ipa file

mv "$ResultsDir/$Scheme.ipa" "$ResultsDir/extras/$AppName-$AppVersion-$BuildNumber$FileSuffix.ipa"

last_error=$?
if [ $last_error -ne 0 ]; then
echo "xcodebuild exportArchive failed with error $last_error"
exit $last_error
fi

