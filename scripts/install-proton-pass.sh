#!/usr/bin/env bash
# Install the Proton Pass desktop app from its .deb (Proton has no apt repository).
# Reads the latest Stable release from version.json, checks the .deb's SHA-512 and
# installs it with apt. Run by the desktop `mise bootstrap` post-packages hook only
# when proton-pass isn't installed. To update, quit Proton Pass first (tray → Quit),
# then run this script again.
set -euo pipefail

VERSION_JSON=https://proton.me/download/pass/linux/version.json

if pgrep -f /usr/lib/proton-pass >/dev/null; then
  echo "Proton Pass is running; quit it from the tray first." >&2
  exit 1
fi

# Prints "<version> <url> <sha512>" for the Stable .deb
read -r version url sha512 < <(
  curl -fsSL "$VERSION_JSON" | python3 -I -c '
import json, sys
for release in json.load(sys.stdin)["Releases"]:
    if release["CategoryName"] == "Stable":
        for f in release["File"]:
            if f["Url"].endswith(".deb"):
                print(release["Version"], f["Url"], f["Sha512CheckSum"])
                sys.exit(0)
sys.exit("no Stable .deb in version.json")
'
)

case "$url" in
  https://proton.me/download/*) ;;
  *) echo "Unexpected download URL: $url" >&2; exit 1 ;;
esac

dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT
deb="$dir/proton-pass_${version}_amd64.deb"

echo "Downloading Proton Pass $version"
curl -fsSL -o "$deb" "$url"
echo "$sha512  $deb" | sha512sum -c --quiet
# _apt reads the file during install
chmod 755 "$dir"
chmod 644 "$deb"
sudo=sudo
[ "$(id -u)" -eq 0 ] && sudo=
$sudo apt-get install -y "$deb"
dpkg-query -W proton-pass
