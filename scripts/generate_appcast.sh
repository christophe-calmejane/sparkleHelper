#!/usr/bin/env bash
# Useful script to generate appcast files

# Get absolute folder for this script
sh_ga_selfFolderPath="`cd "${BASH_SOURCE[0]%/*}"; pwd -P`/" # Command to get the absolute path

# Include util functions
. "${sh_ga_selfFolderPath}bashUtils/utils.sh"

# Include openssl functions
. "${sh_ga_selfFolderPath}openssl_utils.sh"

getSignatureHash()
{
	local filePath="$1"
	local privKey="$2"
	local _retval="$3"
	local _retvalAttribute="$4"
	local result=""
	local attribute="sparkle:edSignature"

	if isWindows;
	then
		if [ ! -f "$privKey" ];
		then
			echo "ERROR: Private key not found: $privKey"
			exit 1
		fi
		local privKeyType
		getPrivateKeyType "$privKey" privKeyType
		# Check openssl supports EdDSA (unless signing with a legacy DSA key), also detects an openssl too old to read an EdDSA key
		if [[ $privKeyType != "dsa" ]];
		then
			local errorMessage
			errorMessage="$(checkOpenSSLEdDSASupport)"
			if [ $? -ne 0 ];
			then
				echo "ERROR: $errorMessage"
				exit 1
			fi
		fi

		if [[ $privKeyType == "eddsa" ]];
		then
			getEdDSASignature "$filePath" "$privKey" result

		elif [[ $privKeyType == "dsa" ]];
		then
			echo "WARNING: Signing with a legacy DSA key, which is deprecated by WinSparkle. Consider migrating to EdDSA (see generate_dsa_keys.sh)."
			attribute="sparkle:dsaSignature"
			local opensslPrivKey
			getOpenSSLPath "$privKey" opensslPrivKey
			result=$(openssl dgst -sha1 -binary < "$filePath" | openssl dgst -sha1 -sign "$opensslPrivKey" | openssl enc -base64 -A)

		else
			echo "ERROR: Unsupported private key (EdDSA or legacy DSA PEM key expected): $privKey"
			exit 1
		fi

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
	eval $_retvalAttribute="'${attribute}'"
}

generateAppcast()
{
	local installerPath="$1"
	local marketingVersion="$2"
	local buildNumber="$3"
	local privKeyPath="$4"
	local changelogURL="$5"
	local installerURL="$6"
	local installerArgs="$7"

	local installerName="${installerPath##*/}"
	local installerExtension="${installerPath##*.}"

	if isWindows;
	then
		local appcastFile="appcastItem-win-${marketingVersion}.xml"
	elif isMac;
	then
		local appcastFile="appcastItem-mac-${marketingVersion}.xml"
	else
		local appcastFile="appcastItem-${marketingVersion}.xml"
	fi

	# For the time being, error if we are requested to generate an appcast for a DMG (Sparkle V1 only update the .app so if we have other files in the DMG, it will not work)
	if [[ "${installerExtension}" == "dmg" ]]; then
		echo "ERROR: Sparkle V1 only supports .app updates, so you should not use it with a DMG installer."
		echo "       If you want to use Sparkle, please use installer instead."
		exit 1
		# If we want a more flexible solution, we could check if the DMG only contains a single .app file and allow it
	fi
	# For the time being, error if we are requested to generate an appcast for a ZIP (Sparkle V1 only update the .app/.exe so if we have other files in the ZIP, it will not work)
	if [[ "${installerExtension}" == "zip" ]]; then
		echo "ERROR: Sparkle V1 only supports .app/.exe updates, so you should not use it with a ZIP installer."
		echo "       If you want to use Sparkle, please use installer instead."
		exit 1
		# If we want a more flexible solution, we could check if the ZIP only contains a single .app file and allow it
	fi

	local fileSize
	getFileSize "$installerPath" fileSize

	local fileSignature
	local fileSignatureAttribute
	getSignatureHash "$installerPath" "$privKeyPath" fileSignature fileSignatureAttribute

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
		echo "				${fileSignatureAttribute}=\"${fileSignature}\"" >> "$appcastFile"
		echo "				sparkle:installerArguments=\"${installerArgs}\"" >> "$appcastFile"
		echo "				sparkle:os=\"windows\"" >> "$appcastFile"

	elif isMac;
	then
		echo "				${fileSignatureAttribute}=\"${fileSignature}\"" >> "$appcastFile"
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
	echo "Usage: generate_appcast.sh <Installer Path> <Installer Marketing Version> <Build Number> <Private Key Path> <ChangeLog URL> <Installer URL> <Windows Installer Arguments>"
	echo "Note: <Private Key Path> is only used on Windows (EdDSA or legacy DSA PEM key), macOS uses the key stored in the Keychain"
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
