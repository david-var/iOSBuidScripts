# iOS Automated Build Scripts
=================


Just run build.sh file with appropriate parameters to build your iOS app from command line/Jenkins or other build automation system.


BUILD PARAMETERS
-----------------

* __Workspace__(required)

The configration that should be build
e.g. 'Release', 'Debug' or 'Distribution'

* __Project__(required)

Path to the project file

* __BuildNumber__(required)

Build Number

* __FileSuffix__(optional)

Used to differntiate same app for enterprise and app store

* __AppPP__(required)

Application provisoning profile

* __WatchAppPP__(optional)

Watch provisoning profile

* __WathExtenstionPP__(optional)

Watch extension provisoning profile

* __AppBundleID__(required)

Application bundle ID

* __WatchAppBundleID__(optional)

Watch  bundle ID

* __WatchExtenstionBundleID__(optional)

Watch  extension bundle ID

* __AppVersion__(required)

Application version

* __BundleMajorVersion__(required)

Bundle major version

* __AppName__(required)

Application name

* __TeamID__(required)

Your apple team ID

* __Config__(required)

The configration that should be build
e.g. 'Release', 'Debug' or 'Distribution'
