#!/usr/bin/env bash

# Get absolute folder for this script
sh_gdk_selfFolderPath="`cd "${BASH_SOURCE[0]%/*}"; pwd -P`/" # Command to get the absolute path

# Include util functions
. "${sh_gdk_selfFolderPath}bashUtils/utils.sh"

# Include openssl functions
. "${sh_gdk_selfFolderPath}openssl_utils.sh"

# Note: For backward compatibility, files are still named dsa_pub.pem and dsa_priv.pem, although they now contain EdDSA (ed25519) keys
generateKeys()
{
	getOS osName
	if [[ $osName == "win" ]];
	then
		echo -n "Generating EdDSA keys... "
		local dsa_pub_key="${outputFolder}/dsa_pub.pem"
		local dsa_priv_key="${outputFolder}/dsa_priv.pem"
		if [ -f "$dsa_pub_key" ];
		then
			echo "already found in resources, not generating new ones"
			if grep -q "BEGIN PUBLIC KEY" "$dsa_pub_key";
			then
				echo "WARNING: Found a legacy DSA key, which is deprecated by WinSparkle. Remove both $dsa_pub_key and $dsa_priv_key files to generate EdDSA keys."
				echo "         Changing the key is a breaking change: already deployed versions will not accept updates signed with the new key (use a new appcast)."
			fi
		else
			local errorMessage
			errorMessage="$(checkOpenSSLEdDSASupport)"
			if [ $? -ne 0 ];
			then
				echo "failed, $errorMessage"
				exit 1
			fi
			# Never overwrite an existing private key
			if [ -f "$dsa_priv_key" ];
			then
				local privKeyType
				getPrivateKeyType "$dsa_priv_key" privKeyType
				if [[ $privKeyType != "eddsa" ]];
				then
					echo "failed, $dsa_priv_key already exists but is not an EdDSA private key (remove it to generate new keys)"
					exit 1
				fi
				echo -n "using existing private key... "
			else
				openssl genpkey -algorithm ed25519 > "$dsa_priv_key"
				if [ $? -ne 0 ];
				then
					echo "failed to generate private key"
					rm -f "$dsa_priv_key"
					exit 1
				fi
				chmod 600 "$dsa_priv_key" 2>&1
			fi
			local eddsaPubKey
			getEdDSAPublicKey "$dsa_priv_key" eddsaPubKey
			if [ -z "$eddsaPubKey" ];
			then
				echo "failed to extract public key"
				exit 1
			fi
			echo "$eddsaPubKey" > "$dsa_pub_key"
			chmod 644 "$dsa_pub_key" 2>&1
			echo "done"
		fi

	elif [[ $osName == "mac" ]];
	then
		echo -n "Generating EdDSA keys... "
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
				local generateKeysResult="$("$generateKeys" -p)"
				if [ $? -ne 0 ];
				then
					echo "failed, unexpected result from $generateKeys command, have you accepted keychain access?"
					exit 1
				fi
				# local ed25519PubKey="$(echo "$generateKeysResult" | head -n 6 | tail -n 1)"
				# echo "$ed25519PubKey" > "$dsa_pub_key"
				echo "$generateKeysResult" > "$dsa_pub_key"
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
	echo "Generates EdDSA (ed25519) keys in <Output Folder>/dsa_pub.pem (and <Output Folder>/dsa_priv.pem on Windows, macOS stores it in the Keychain)"
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
