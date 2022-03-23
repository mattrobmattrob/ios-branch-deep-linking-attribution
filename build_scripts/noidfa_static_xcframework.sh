# config
IOS_PATH="./build/ios/ios.xcarchive"
IOS_SIM_PATH="./build/ios/ios_sim.xcarchive"
XCFRAMEWORK_PATH="./build/Branch.xcframework"
CATALYST_PATH="./build/catalyst/catalyst.xcarchive"
STATIC_LIB_SIM_PATH="./build/Branch.sim"
STATIC_LIB_PATH="./build/Branch.a"

# delete previous build
rm -rf "./build"

# build iOS framework
xcodebuild archive \
    -project Branch-frameworks.xcodeproj \
    -scheme Branch-static \
    -archivePath "${IOS_PATH}" \
    -sdk iphoneos \
    SKIP_INSTALL=NO \
    GCC_PREPROCESSOR_DEFINITIONS='${inherited} BRANCH_EXCLUDE_IDFA_CODE=1'
    
# build iOS simulator framework
xcodebuild archive \
    -project Branch-frameworks.xcodeproj \
    -scheme Branch-static \
    -archivePath "${IOS_SIM_PATH}" \
    -sdk iphonesimulator \
    SKIP_INSTALL=NO \
    GCC_PREPROCESSOR_DEFINITIONS='${inherited} BRANCH_EXCLUDE_IDFA_CODE=1'

# build Catalyst framework
xcodebuild archive \
    -project Branch-frameworks.xcodeproj \
    -scheme Branch-static \
    -archivePath "${CATALYST_PATH}" \
    -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' \
    SKIP_INSTALL=NO \
    GCC_PREPROCESSOR_DEFINITIONS='${inherited} BRANCH_EXCLUDE_IDFA_CODE=1'
    
# package frameworks
xcodebuild -create-xcframework \
    -framework "${IOS_PATH}/Products/Library/Frameworks/Branch.framework" \
    -framework "${IOS_SIM_PATH}/Products/Library/Frameworks/Branch.framework" \
    -framework "${CATALYST_PATH}/Products/Library/Frameworks/Branch.framework" \
    -output "${XCFRAMEWORK_PATH}"

# build a static fat library from the xcframework
# this is used by xamarin
TEMP_LIB_PATH="./build/Branch.sim"
LIBRARY_PATH="./build/Branch.a"

# create simulator library without m1
lipo -output "${TEMP_LIB_PATH}" -remove arm64 "${XCFRAMEWORK_PATH}/ios-arm64_i386_x86_64-simulator/Branch.framework/Branch"

# create a fat static library
lipo "${XCFRAMEWORK_PATH}/ios-arm64_armv7/Branch.framework/Branch" "${TEMP_LIB_PATH}" -create -output "${LIBRARY_PATH}"
