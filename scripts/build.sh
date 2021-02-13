# altool credentials.
# AC_PASSWORD is the name of the keychain item with App Connect password
# Grant access to Xcode if prompted by Xcode.
AC_USERNAME="$APPLEID"
AC_PASSWORD="$APPLE_PASSWORD"

if [[ $AC_USERNAME == "" ]]; then
  echo "error: no username"
  exit 1
  break
fi

if [[ $AC_PASSWORD == "" ]]; then
  echo "error: no pass"
  exit 1
  break
fi

# Do all of the work in a subdirectory of /tmp, and use a
# unique ID so that there's no collision with previous builds.
PRODUCT_NAME="YPaste"
SCRIPTROOT=$(cd "$(dirname "$0")";pwd)
SRCROOT=$(dirname "$SCRIPTROOT")
ARCHIVE_PATH="$SRCROOT/archive-YPaste.xcarchive"
EXPORT_PATH="$SRCROOT/apps"
APP_PATH="$EXPORT_PATH/$PRODUCT_NAME.app"
DMG_ROOT="$EXPORT_PATH/dmg"
DMG_PATH="$DMG_ROOT/$PRODUCT_NAME.dmg"
PRODUCT_BUNDLE_IDENTIFIER="com.qwertyyb.YPaste"

echo $SRCROOT

echo "clean build fold"
rm -rf "$EXPORT_PATH"

echo "build archive"
xcodebuild archive -workspace YPaste.xcworkspace -scheme YPaste -archivePath "$SRCROOT/archive-YPaste" -configuration Release || { echo "Archive and Notarization Failed : xcodebuild archive action failed"; exit 1; }

# Xcode doesn't show run script errors in build log.
# Uncomment to save any messages aside.
# exec > "/tmp/Xcode run script.log" 2>&1

# Ask xcodebuild(1) to export the app. Use the export options
# from a previous manual export that used a Developer ID.

echo "export archive"
/usr/bin/xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportOptionsPlist "$SRCROOT/scripts/ExportOptions.plist" -exportPath "$EXPORT_PATH" || { echo "Export Archive Failed : xcodebuild exportArchive action failed"; exit 1; }

# Create a UDIF bzip2-compressed disk image.
cd "$EXPORT_PATH/"
mkdir dmg
# mv "$APP_PATH" "$PRODUCT_NAME"

# /usr/bin/hdiutil create -srcfolder "$PRODUCT_NAME" -format UDBZ "$DMG_PATH"

echo "use appdmg create DMG file"
appdmg "$SRCROOT/scripts/appdmg.json" "$DMG_PATH"

# Submit the finished deliverables for notarization. The "--primary-bundle-id" 
# argument is only used for the response email. 
echo "notarize app"
xcrun altool --notarize-app --primary-bundle-id ${PRODUCT_BUNDLE_IDENTIFIER}.dmg -u "$AC_USERNAME" -p "$AC_PASSWORD" -f "$DMG_PATH" > "NotarizationUUIDs.log"

uuid=`cat $EXPORT_PATH/NotarizationUUIDs.log | grep -Eo '\w{8}-(\w{4}-){3}\w{12}$'`
echo "uuid=$uuid"
while true; do
    echo "checking for notarization..."
 
    xcrun altool --notarization-info "$uuid" --username "$AC_USERNAME" --password "$AC_PASSWORD" &> check.log
    r=`cat check.log`
    t=`echo "$r" | grep "success"`
    f=`echo "$r" | grep "invalid"`
    if [[ "$t" != "" ]]; then
        echo "notarization done!"
        xcrun stapler staple "$APP_PATH"
        xcrun stapler staple "$DMG_PATH"
        echo "stapler done!"
        break
    fi
    if [[ "$f" != "" ]]; then
        echo "$r"
        exit 1
    fi
    echo "not finish yet, sleep 2m then check again..."
    sleep 120
done

APPCAST_PATH="$DMG_ROOT/appcast.xml"
echo "generate appcast.xml"
"$SRCROOT/bin/generate_appcast" -s $sparkle_key "$DMG_ROOT"

echo "update appcast.xml download url"
appcast=$(cat "$DMG_ROOT/appcast.xml")
echo "$appcast" | sed -e "s/url[^ ]*/url=\"https:\/\/github.com\/qwertyyb\/YPaste\/releases\/latest\/download\/YPaste.dmg\"/g" > "$EXPORT_PATH/appcast.xml"
