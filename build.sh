killall -9 ilimi

rm -rf ~/Library/Input\ Methods/ilimi.app
rm -rf ~/Library/Input\ Methods/ilimi.swiftmodule
rm -rf ~/Library/Containers/com.lennylxx.inputmethod.ilimi/
rm -rf ~/Library/Developer/Xcode/DerivedData/ilimi-*/
rm -rf ./build

xcodebuild -scheme ilimi build CONFIGURATION_BUILD_DIR=/Users/$(id -un)/Library/Input\ Methods/

ls -al ~/Library/Input\ Methods
