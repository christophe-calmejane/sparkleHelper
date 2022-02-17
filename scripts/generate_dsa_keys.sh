#!/usr/bin/env bash

# Get absolute folder for this script
sh_gdk_selfFolderPath="`cd "${BASH_SOURCE[0]%/*}"; pwd -P`/" # Command to get the absolute path

# Include util functions
. "${sh_gdk_selfFolderPath}bashUtils/utils.sh"

generateKeys()
{
	getOS osName
	if [[ $osName == "win" ]];
	then
		echo -n "Generating DSA keys... "
		local dsa_params="${outputFolder}/dsa_param.pem"
		local dsa_pub_key="${outputFolder}/dsa_pub.pem"
		local dsa_priv_key="${outputFolder}/dsa_priv.pem"
		if [ -f "$dsa_pub_key" ];
		then
			echo "already found in resources, not generating new ones"
		else
			result=$(which openssl 2>&1)
			if [ $? -ne 0 ];
			then
				echo "failed, openssl not found"
			else
				openssl dsaparam 1024 < /dev/random > "$dsa_params" 2>&1
				openssl gendsa -out "$dsa_priv_key" "$dsa_params" 2>&1
				openssl dsa -in "$dsa_priv_key" -pubout -out "$dsa_pub_key" 2>&1
				chmod 600 "$dsa_priv_key" 2>&1
				chmod 644 "$dsa_pub_key" 2>&1
				rm -f "$dsa_params" 2>&1
				echo "done"
			fi
		fi

	elif [[ $osName == "mac" ]];
	then
		echo -n "Generating DSA keys... "
		local dsa_pub_key="${outputFolder}/dsa_pub.pem"
		if [ -f "$dsa_pub_key" ];
		then
			echo "already found in resources, not generating new ones"
		else
			local generateKeys="${sh_gdk_selfFolderPath}../3rdparty/sparkle/generate_keys"
			if [ ! -f "$generateKeys" ];
			then
				echo "failed, $generateKeys not found"
			else
				echo -n "Keychain access might be requested, accept it... "
				"$generateKeys" &> /dev/null
				# Run it a second time as only the second successfull run will print the public key
				local generateKeysResult="$("$generateKeys")"
				if [ `echo "$generateKeysResult" | wc -l` -ne 6 ];
				then
					echo "failed, unexpected result from $generateKeys command, have you accepted keychain access?"
					exit 1
				fi
				local ed25519PubKey="$(echo "$generateKeysResult" | head -n 6 | tail -n 1)"
				echo "$ed25519PubKey" > "$dsa_pub_key"
				echo "done"
			fi
		fi

	elif [[ $osName == "linux" ]];
	then
		local dsa_pub_key="${outputFolder}/dsa_pub.pem"
		touch "$dsa_pub_key"

	fi
}

printHelp()
{
	echo "Usage: generate_dsa_keys.sh <Output Folder>"
}

if [ $# -ne 1 ]; then
	echo "ERROR: Missing parameters"
	printHelp
	exit 1
fi

outputFolder="$1"

if [ ! -d "$outputFolder" ]; then
	echo "ERROR: Output folder does not exist: $outputFolder"
	printHelp
	exit 1
fi

generateKeys

exit 0
