#!/bin/sh
### RELEASE: 20221125.1635
### Change this line to set the icon to use
CURRENT_ICON_THEME="${HOME}/.icons/BlackCodec"

CURRENT_DIR=$1
EXEC_FILE_NAME=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
EXEC_FILE_NAME=$(echo ${EXEC_FILE_NAME}/$(basename ${0}))

function printStart() {
  echo "<?xml version=\"1.0\"?>"
  echo "<JWM>"
}

function printSep() {
  echo "<Separator/>"
}

function printEnd() {
  echo "</JWM>"
}

function getIconFile() {
  SRCFILE=$1
  MIMEDIR="${CURRENT_ICON_THEME}/mimes"
  if [ ! -d "${MIMEDIR}" ]; then
    MIMEDIR="${CURRENT_ICON_THEME}/mimetypes"
    if [ ! -d "${MIMEDIR}" ]; then
      MIMEDIR="${CURRENT_ICON_THEME}"
    fi
  fi
  ICON=""
  if [ -d "${MIMEDIR}" ]; then
    EXT=$(file --mime-type ${SRCFILE} | awk -F ":" '{print $2}' | awk -F "/" '{print $2}')
    ICON=$(find ${MIMEDIR}/ -name "${EXT}.*" | head -n 1)
    if [ -z "${ICON}" ]; then
      EXT=$(file --mime-type ${SRCFILE} | awk -F ":" '{print $2}' | sed "s| ||g" | sed "s|/|-|g")
      ICON=$(find ${MIMEDIR}/ -name "${EXT}.*" | head -n 1)
    fi
    if [ -z "${ICON}" ]; then
      EXT=$(file --mime-type ${SRCFILE} | awk -F ":" '{print $2}' | awk -F "/" '{print $1}' | sed "s| ||g")
      ICON=$(find ${MIMEDIR}/ -name "${EXT}.*" | head -n 1)
    fi
  fi
  echo "${ICON}"
}

function getIconDir() {
  echo $(find ${CURRENT_ICON_THEME}/ -name "inode-directory.*" | head -n 1)
}

function printDir() {
  SRCDIR=$1
  DIRICO=$(getIconDir)
  echo "<Program icon=\"${DIRICO}\" label=\"Open folder\">xdg-open \"${SRCDIR}/\"</Program>"
  if [ $(find ${SRCDIR} -mindepth 1 -maxdepth 1 -type d | wc -l) -gt 0 ]; then
    printSep
    for THE_DIR_NAME in $(find ${SRCDIR} -mindepth 1 -maxdepth 1 -type d | sort ); do
      THE_DIR_NAME=$(echo "${THE_DIR_NAME}" | sed "s|//|/|g")
      echo "<Dynamic icon=\"${DIRICO}\" label=\"$(basename ${THE_DIR_NAME})\">"
      echo "exec:${EXEC_FILE_NAME} \"${THE_DIR_NAME}\""
      echo "</Dynamic>"
    done
  fi
}

function printFile() {
  FILEDIR=$1
  if [ $(find ${FILEDIR} -maxdepth 1 -type f | wc -l) -gt 0 ]; then
    for THE_FILE_NAME in $(find ${FILEDIR} -maxdepth 1 -type f | sort ); do
      THE_FILE_NAME=$(echo "${THE_FILE_NAME}" | sed "s|//|/|g")
      FILEICO=$(getIconFile ${THE_FILE_NAME})
      echo "<Program icon=\"${FILEICO}\" label=\"$(basename ${THE_FILE_NAME})\">xdg-open \"${THE_FILE_NAME}\"</Program>"
    done
  fi
}

BCK_IFS="${IFS}"
IFS=$'\n'
printStart
printDir ${CURRENT_DIR}
printSep
printFile ${CURRENT_DIR}
printEnd
IFS="${BCK_IFS}"
exit 1
