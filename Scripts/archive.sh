#!/bin/bash
# Builds a signed App Store archive and export for Rhetorix.
#
# Prerequisites:
#   - Apple Developer Program membership, signed in to Xcode (Settings > Accounts)
#   - TEAM_ID exported in the environment (Apple Developer > Membership > Team ID)
#
# Usage:
#   TEAM_ID=ABCDE12345 ./Scripts/archive.sh
#
# Output: build/Rhetorix.xcarchive and build/export/Rhetorix.ipa,
# ready for upload via Xcode Organizer or `xcrun altool`/Transporter.

set -euo pipefail

if [ -z "${TEAM_ID:-}" ]; then
  echo "error: set TEAM_ID to your Apple Developer Team ID (Membership page)." >&2
  exit 1
fi

cd "$(dirname "$0")/.."

ARCHIVE_PATH="build/Rhetorix.xcarchive"
EXPORT_PATH="build/export"
EXPORT_OPTIONS="build/ExportOptions.plist"

mkdir -p build
cat > "$EXPORT_OPTIONS" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store-connect</string>
	<key>teamID</key>
	<string>${TEAM_ID}</string>
	<key>signingStyle</key>
	<string>automatic</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>
PLIST

xcodebuild archive \
  -project Rhetorix.xcodeproj \
  -scheme Rhetorix \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_STYLE=Automatic

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS"

echo
echo "Archive: $ARCHIVE_PATH"
echo "IPA:     $EXPORT_PATH/Rhetorix.ipa"
echo "Upload with Xcode Organizer (Window > Organizer) or Transporter."
