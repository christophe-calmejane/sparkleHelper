#!/usr/bin/env bash
# Useful script to generate appcast files

# Get absolute folder for this script
sh_ga_selfFolderPath="`cd "${BASH_SOURCE[0]%/*}"; pwd -P`/" # Command to get the absolute path

# Include util functions
. "${sh_ga_selfFolderPath}bashUtils/utils.sh"

getSignatureHash()
{
	local filePath="$1"
	local privKey="$2"
	local _retval="$3"
	local result=""

	if isWindows;
	then
		result=$(openssl dgst -sha1 -binary < "$filePath" | openssl dgst -sha1 -sign "$privKey" | openssl enc -base64)

	elif isMac;
	then
		local signUpdateFile="${sh_ga_selfFolderPath}../3rdparty/sparkle/sign_update"
		if [ ! -f "$signUpdateFile" ];
		then
			echo "ERROR: $signUpdateFile not found, did you run setup_fresh_env.sh?"
			exit 1
		fi
		result=$(${signUpdateFile} "$filePath" | cut -d '"' -f 2)

	else
		echo "getSignatureHash: TODO"
	fi

	eval $_retval="'${result}'"
}

generateAppcast()
{
	local installerPath="$1"
	local marketingVersion="$2"
	local buildNumber="$3"
	local dsaPrivKeyPath="$4"
	local changelogURL="$5"
	local installerURL="$6"
	local installerArgs="$7"

	local installerName="${installerPath##*/}"
	local appcastFile="appcastItem-${marketingVersion}.xml"

	local fileSize
	getFileSize "$installerPath" fileSize

	local fileSignature
	getSignatureHash "$installerPath" "$dsaPrivKeyPath" fileSignature

	if [ "x$fileSignature" == "x" ];
	then
		echo "Failed to generate Appcast: Cannot sign file"
		exit 1
	fi

	# Common Appcast Item header
	echo "		<item>" > "$appcastFile"
	echo "			<title>Version $marketingVersion</title>" >> "$appcastFile"
	echo "			<sparkle:releaseNotesLink>" >> "$appcastFile"
	echo "				${changelogURL}" >> "$appcastFile"
	echo "			</sparkle:releaseNotesLink>" >> "$appcastFile"
	echo "			<pubDate>`date -R`</pubDate>" >> "$appcastFile"
	echo "			<enclosure url=\"${installerURL}\"" >> "$appcastFile"

	# OS-dependant Item values
	if isWindows;
	then
		echo "				sparkle:dsaSignature=\"${fileSignature}\"" >> "$appcastFile"
		echo "				sparkle:installerArguments=\"${installerArgs}\"" >> "$appcastFile"
		echo "				sparkle:os=\"windows\"" >> "$appcastFile"

	elif isMac;
	then
		echo "				sparkle:edSignature=\"${fileSignature}\"" >> "$appcastFile"
		echo "				sparkle:os=\"macos\"" >> "$appcastFile"

	else
		echo "Appcast generation not supported on this OS"
		return;
	fi

	# Common Appcast Item footer
	echo "				sparkle:shortVersionString=\"${marketingVersion}\"" >> "$appcastFile"
	echo "				sparkle:version=\"${buildNumber}\"" >> "$appcastFile"
	echo "				length=\"${fileSize}\"" >> "$appcastFile"
	echo "				type=\"application/octet-stream\"" >> "$appcastFile"
	echo "			/>" >> "$appcastFile"
	echo "		</item>" >> "$appcastFile"

	# Done
	echo "Appcast item generated to file: $appcastFile (add it to your appcast.xml file)"
}

printHelp()
{
	echo "Usage: generate_appcast.sh <Installer Path> <Installer Marketing Version> <Build Number> <DSA Private Key Path> <ChangeLog URL> <Installer URL> <Windows Installer Arguments>"
}

if [ $# -ne 7 ]; then
	echo "ERROR: Missing parameters"
	printHelp
	exit 1
fi

if [ ! -f "$1" ]; then
	echo "ERROR: Installer does not exist: $1"
	printHelp
	exit 1
fi

generateAppcast "$1" "$2" "$3" "$4" "$5" "$6" "$7"

exit 0
