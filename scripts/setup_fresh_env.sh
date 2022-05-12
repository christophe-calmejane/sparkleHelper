#!/usr/bin/env bash
# Optional parameters:
#  $1: Signing identity to sign Sparkle Framework

# Get absolute folder for this script
sh_sfe_selfFolderPath="`cd "${BASH_SOURCE[0]%/*}"; pwd -P`/" # Command to get the absolute path

# Include util functions
. "${sh_sfe_selfFolderPath}bashUtils/utils.sh"

setupEnv()
{
	local signingIdentity="$1"

	echo -n "Fetching submodules... "
	local log=$(git submodule update --init --recursive 2>&1)
	if [ $? -ne 0 ];
	then
		echo "failed!"
		echo ""
		echo "Error log:"
		echo $log
		exit 1
	fi
	echo "done"
  
	getOS osName
	if [[ $osName == "win" ]];
	then
		local baseSparkleFolder="${sh_sfe_selfFolderPath}../3rdparty/winsparkle"
		if [[ ! -d "${baseSparkleFolder}/bin" || ! -d "${baseSparkleFolder}/include" || ! -d "${baseSparkleFolder}/lib" ]];
		then
			echo -n "Downloading WinSparkle... "
			local result
			result=$(which wget 2>&1)
			if [ $? -ne 0 ];
			then
				echo "failed, wget not found (see ${baseSparkleFolder}/README.me for manually installation instructions)"
			else
				local wspkloutputFile="_WinSparkle.zip"
				rm -f "$wspkloutputFile"
				local spklVersion="0.6.0"
				local spklZipName="WinSparkle-${spklVersion}"
				local log=$("$result" https://github.com/vslavik/winsparkle/releases/download/v${spklVersion}/${spklZipName}.zip -O "$wspkloutputFile" 2>&1)
				if [ $? -ne 0 ];
				then
					echo "failed!"
					echo ""
					echo "Error log:"
					echo $log
					rm -f "$wspkloutputFile"
					exit 1
				fi
				echo "done"

				echo -n "Installing WinSparkle... "
				result=$(which unzip 2>&1)
				if [ $? -ne 0 ];
				then
					echo "failed, unzip not found (see ${baseSparkleFolder}/README.me for manually installation instructions)"
					rm -f "$wspkloutputFile"
				else
					local wspklOutputFolder="_WinSparkle"
					rm -rf "$wspklOutputFolder"
					local log=$("$result" -d "$wspklOutputFolder" "$wspkloutputFile" 2>&1)
					if [ $? -ne 0 ];
					then
						echo "failed!"
						echo ""
						echo "Error log:"
						echo $log
						rm -f "$wspkloutputFile"
						rm -rf "$wspklOutputFolder"
						exit 1
					fi
					mkdir -p "${baseSparkleFolder}/bin/x86"
					mkdir -p "${baseSparkleFolder}/bin/x64"
					mkdir -p "${baseSparkleFolder}/lib/x86"
					mkdir -p "${baseSparkleFolder}/lib/x64"
					mv "${wspklOutputFolder}/${spklZipName}/include" "${baseSparkleFolder}/"
					mv "${wspklOutputFolder}/${spklZipName}/Release/WinSparkle.dll" "${baseSparkleFolder}/bin/x86"
					mv "${wspklOutputFolder}/${spklZipName}/Release/WinSparkle.lib" "${baseSparkleFolder}/lib/x86"
					mv "${wspklOutputFolder}/${spklZipName}/x64/Release/WinSparkle.dll" "${baseSparkleFolder}/bin/x64"
					mv "${wspklOutputFolder}/${spklZipName}/x64/Release/WinSparkle.lib" "${baseSparkleFolder}/lib/x64"
					rm -f "$wspkloutputFile"
					rm -rf "$wspklOutputFolder"
					echo "done"
				fi
			fi
		fi

	elif [[ $osName == "mac" ]];
	then
		echo -n "Downloading Sparkle... "
		local baseSparkleFolder="${sh_sfe_selfFolderPath}../3rdparty/sparkle"
		local result
		result=$(which wget 2>&1)
		if [ $? -ne 0 ];
		then
			echo "failed, wget not found (see ${baseSparkleFolder}/README.me for manually installation instructions)"
		else
			local spkloutputFile="_Sparkle.tar.xz"
			rm -f "$spkloutputFile"
			local spklVersion="1.27.1"
			local log=$("$result" https://github.com/sparkle-project/Sparkle/releases/download/${spklVersion}/Sparkle-${spklVersion}.tar.xz -O "$spkloutputFile" 2>&1)
			if [ $? -ne 0 ];
			then
				echo "failed!"
				echo ""
				echo "Error log:"
				echo $log
				rm -f "$spkloutputFile"
				exit 1
			fi
			echo "done"

			echo -n "Installing Sparkle... "
			result=$(which tar 2>&1)
			if [ $? -ne 0 ];
			then
				echo "failed, tar not found (see ${baseSparkleFolder}/README.me for manually installation instructions)"
				rm -f "$spkloutputFile"
			else
				local spklOutputFolder="_Sparkle"
				rm -rf "$spklOutputFolder"
				mkdir -p "$spklOutputFolder"
				local log=$("$result" xvJf "$spkloutputFile" --directory "$spklOutputFolder" 2>&1)
				if [ $? -ne 0 ];
				then
					echo "failed!"
					echo ""
					echo "Error log:"
					echo $log
					rm -f "$spkloutputFile"
					rm -rf "$spklOutputFolder"
					exit 1
				fi
				rm -rf "${baseSparkleFolder}/Sparkle.framework"
				mv -f "${spklOutputFolder}/Sparkle.framework" "${baseSparkleFolder}/"
				mv -f "${spklOutputFolder}/bin/generate_keys" "${baseSparkleFolder}/"
				mv -f "${spklOutputFolder}/bin/sign_update" "${baseSparkleFolder}/"
				rm -f "$spkloutputFile"
				rm -rf "$spklOutputFolder"
				echo "done"
				if [ ! -z "$signingIdentity" ];
				then
					echo -n "Codesigning Sparkle Framework... "
					local log=$(codesign -s "$signingIdentity" --timestamp --deep --strict --force --options=runtime "${baseSparkleFolder}/Sparkle.framework/Resources/Autoupdate.app" 2>&1)
					if [ $? -ne 0 ];
					then
						echo "failed!"
						echo ""
						echo "Error log:"
						echo $log
						exit 1
					fi
				else
					echo "You need to manually codesign Sparkle Autoupdate bundle:"
					echo "  codesign -s YourCodeSigningIdentityOrDash --timestamp --deep --strict --force --options=runtime ${baseSparkleFolder}/Sparkle.framework/Resources/Autoupdate.app"
				fi
			fi
		fi

	fi
}

setupEnv "$1"

exit 0
