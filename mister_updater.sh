#!/bin/bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Copyright 2019-2020 Alessandro "Locutus73" Miele
# Adapted to MiSTer-DB9 fork by José Manuel Barroso Galindo "theypsilon" © 2021

URL="https://github.com"
CURL_RETRY="--connect-timeout 15 --max-time 120 --retry 3 --retry-delay 5 --silent --show-error"
ALLOW_INSECURE_SSL="true"

ORIGINAL_SCRIPT_PATH="$0"
if [ "$ORIGINAL_SCRIPT_PATH" == "bash" ]
then
	ORIGINAL_SCRIPT_PATH=$(ps | grep "^ *$PPID " | grep -o "[^ ]*$")
fi

echo "${ORIGINAL_SCRIPT_PATH} is obsolete"
sleep 2s
echo

INI_PATH="${ORIGINAL_SCRIPT_PATH%.*}.ini"
if [[ -f "${INI_PATH}" ]] ; then
	TMP=$(mktemp)
	# preventively eliminate DOS-specific format and exit command  
	dos2unix < "${INI_PATH}" 2> /dev/null | grep -v "^exit" > ${TMP}
	source ${TMP}
	rm -f ${TMP}
fi

SSL_SECURITY_OPTION=""
curl ${CURL_RETRY} "${URL}" > /dev/null 2>&1
case $? in
	0)
		;;
	60)
		if [[ "${ALLOW_INSECURE_SSL}" == "true" ]]
		then
			SSL_SECURITY_OPTION="--insecure"
		else
			echo "CA certificates need"
			echo "to be fixed for"
			echo "using SSL certificate"
			echo "verification."
			echo "Please fix them i.e."
			echo "using security_fixes.sh"
			exit 2
		fi
		;;
	*)
		echo "No Internet connection"
		exit 1
		;;
esac

UPDATER_LAUNCHER_URL="https://raw.githubusercontent.com/MiSTer-DB9/Updater_script_MiSTer_DB9/master/update.sh"
UPDATER_LAUNCHER_CHECKSUM="aefe4ba942fe8a589590d6f4cc566ba8"

UPDATER_REPLACEMENT_TMP="/tmp/update_db9_replacement.sh"
rm "${UPDATER_REPLACEMENT_TMP}" 2> /dev/null || true

echo "Downloading updated launcher"
echo "${UPDATER_LAUNCHER_URL}"
echo ""
curl \
	${CURL_RETRY} \
	${SSL_SECURITY_OPTION} \
	--fail \
	--location \
	"${UPDATER_LAUNCHER_URL}" \
	-o "${UPDATER_REPLACEMENT_TMP}"

if [[ "${UPDATER_LAUNCHER_CHECKSUM}" != "$(md5sum ${UPDATER_REPLACEMENT_TMP} | awk '{print $1}')" ]] || [[ ! -f "${ORIGINAL_SCRIPT_PATH}"  ]] ; then
    echo "Error! An updated launcher could not be installed automatically!"
    echo "You have to manually update your file '$ORIGINAL_SCRIPT_PATH'"
    echo "Please download the new one from here:"
    echo "${UPDATER_LAUNCHER_URL}"
    exit 1
fi

echo "Deleting old launcher"
sleep 2s
rm "${ORIGINAL_SCRIPT_PATH}"
echo
echo "Installing new launcher"
sleep 2s
cp "${UPDATER_REPLACEMENT_TMP}" "${ORIGINAL_SCRIPT_PATH}"
echo
echo "Running new launcher"
sleep 2s
chmod +x "${ORIGINAL_SCRIPT_PATH}"
"${ORIGINAL_SCRIPT_PATH}"
