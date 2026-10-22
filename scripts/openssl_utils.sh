#!/usr/bin/env bash
# OpenSSL helper functions to generate EdDSA (ed25519) keys and sign files (Windows only, macOS is using Sparkle's own tools)
# Requires bashUtils/utils.sh to be included first
# Note: Local variables have unique names, as a local variable with the same name than the return variable would hide it

# Converts a path so it can be passed to openssl, whatever its flavor (native, msys or cygwin)
# getOpenSSLPath <Path> <Return Variable>
getOpenSSLPath()
{
	local _path="$1"
	local _retval="$2"
	local opensslPath="$_path"

	# utils.sh disables MSYS automatic path conversion, so native openssl builds would not understand msys/cygwin absolute paths
	if isWindows && [ ! -z "$(getCommandPath cygpath)" ];
	then
		opensslPath="$(cygpath -m "$_path")"
	fi

	eval $_retval="'${opensslPath}'"
}

# Checks that openssl is available and supports EdDSA (ed25519) keys generation, signing and verification (requires OpenSSL 1.1.1 or later)
# Prints an error message and returns 1 if not supported
# checkOpenSSLEdDSASupport
checkOpenSSLEdDSASupport()
{
	if [ -z "$(getCommandPath openssl)" ];
	then
		echo "openssl not found"
		return 1
	fi

	local tmpFolder="$(mktemp -d)"
	# Run in tmpFolder with relative paths, so we do not care about the openssl flavor
	(
		cd "$tmpFolder" &&
		openssl genpkey -algorithm ed25519 -out priv.pem &&
		openssl pkey -in priv.pem -pubout -out pub.pem &&
		echo "Sparkle EdDSA test data" > data.bin &&
		openssl pkeyutl -sign -rawin -inkey priv.pem -in data.bin -out sig.bin &&
		openssl pkeyutl -verify -pubin -inkey pub.pem -rawin -in data.bin -sigfile sig.bin
	) &> /dev/null
	local result=$?
	rm -rf "$tmpFolder"

	if [ $result -ne 0 ];
	then
		echo "$(getCommandPath openssl) ($(openssl version 2>&1)) does not support EdDSA (ed25519) keys, OpenSSL 1.1.1 or later is required"
		return 1
	fi

	return 0
}

# Gets the type of a PEM private key: "eddsa", "dsa" (legacy) or "" if not a valid key
# getPrivateKeyType <Private Key Path> <Return Variable>
getPrivateKeyType()
{
	local privKey="$1"
	local _retval="$2"
	local keyType=""

	if openssl pkey -noout -text < "$privKey" 2> /dev/null | head -n 1 | grep -q "ED25519";
	then
		keyType="eddsa"
	elif openssl dsa -noout < "$privKey" &> /dev/null;
	then
		keyType="dsa"
	fi

	eval $_retval="'${keyType}'"
}

# Gets the base64 encoded EdDSA public key (Sparkle/WinSparkle format) of an EdDSA private key
# getEdDSAPublicKey <Private Key Path> <Return Variable>
getEdDSAPublicKey()
{
	local privKey="$1"
	local _retval="$2"
	local publicKey=""

	# The raw public key is the last 32 bytes of the DER encoded SubjectPublicKeyInfo
	publicKey=$(set -o pipefail; openssl pkey -pubout -outform DER < "$privKey" | tail -c 32 | openssl base64 -A)
	if [ $? -ne 0 ];
	then
		publicKey=""
	fi

	eval $_retval="'${publicKey}'"
}

# Gets the base64 encoded EdDSA signature of a file (Sparkle/WinSparkle format)
# getEdDSASignature <File Path> <Private Key Path> <Return Variable>
getEdDSASignature()
{
	local filePath="$1"
	local privKey="$2"
	local _retval="$3"
	local signature=""

	local opensslFilePath
	getOpenSSLPath "$filePath" opensslFilePath
	local opensslPrivKey
	getOpenSSLPath "$privKey" opensslPrivKey

	# ed25519 is a oneshot algorithm: data cannot be piped through stdin (openssl needs to know the file size)
	signature=$(set -o pipefail; openssl pkeyutl -sign -rawin -inkey "$opensslPrivKey" -in "$opensslFilePath" | openssl base64 -A)
	if [ $? -ne 0 ];
	then
		signature=""
	fi

	eval $_retval="'${signature}'"
}
