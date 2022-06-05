#!/bin/bash

##########################################################################
# Shellscript:  RemoteServer - Remote nc server for SublimeText build system use.
# Author     :  CiLun Zeng <cilun0812@gmail.com>
# Date       :  08/02/2020
# Category   :  Server
##########################################################################
# Changes
# Date: 2020/08/02 11:36:40
#   - Initial 1st version.
###########################################################################

# set -eu -o pipefail # fail on error , debug all lines

. ~/Work/Calvin_Script/bashrcScript/Function/ANSIColor.sh/ANSIColor.sh
. ~/Work/Calvin_Script/bashrcScript/Function/ANSIColor.sh/package.sh
# . ~/bashrcScript/Function/ANSIColor.sh
# . ~/bashrcScript/Function/package.sh

next() { echo $1; }
rest() { shift; echo $*; }

while :
do
    # Clear all global variavle.
    tLinuxFlag=0
    tAllFlag=0
    tPackageFlag=0
    tParam=""
    tString=""

    #　Receive string from nc
    tString=$(nc -l 5000)
    echo "Received:"$tString

    for i in $tString; do
        # echo $(next $tString)

        # Handle SDK path.
        # [1-9] ...
        if [ -z "$SDK_PATH" ]; then
            case $tString in
                1*)
                    SDK_PATH="/home/carl_zeng/RP342M/mtk-openwrt-cc-v3.6_RP342Mv2/"
                    tString=$(rest $tString)
                    echo "SDK:$SDK_PATH"
                    cd "$SDK_PATH"
                ;;
                2*)
                    SDK_PATH="/home/carl_zeng/RP342M/mtk-v2/"
                    tString=$(rest $tString)
                    echo "SDK:$SDK_PATH"
                    cd "$SDK_PATH"
                ;;
                3*)
                    SDK_PATH="/home/carl_zeng/RP342M/v2/"
                    tString=$(rest $tString)
                    echo "SDK:$SDK_PATH"
                    cd "$SDK_PATH"
                ;;
            esac
        fi

        # Parse type.
        #  ... [package/linux] ...
        case $tString in
            package*)
                echo "Handle package"
                tPackageFlag=1
                tString=$(rest $tString)
                ;;
            linux*)
                echo "Handle package"
                tLinuxFlag=1
                tString=$(rest $tString)
                ;;
            all*)
                echo "Handle FwBin"
                tAllFlag=1
                tString=$(rest $tString)
                ;;
        esac

        # Handle package type.
        # ... [-v/-r/-c/-m] ...
        if [[ tPackageFlag -eq 1 ]]; then
            case $tString in
                -v*)
                    echo "Enable verbose"
                    tParam="$tParam -v"
                    tString=$(rest $tString)
                    ;;
                -r*)
                    echo "Rebuild Package..."
                    tParam="$tParam -r"
                    tString=$(rest $tString)
                    ;;
                -m*)
                    echo "Only Compile&install Package..."
                    tParam="$tParam -m"
                    tString=$(rest $tString)
                    ;;
                -c*)
                    echo "Clean Package..."
                    tParam="$tParam -c"
                    tString=$(rest $tString)
                    ;;
                *)
                    echo "Command: $tParam $tString"
                    package $tParam $tString
                    if [ $? -ne 0 ]; then
                        echo -en "$Red$On_White $tString package failed,stop. $Color_Off$On_White $Color_Off  \r\n"
                        alert "Package package failed,stop."
                        break
                    fi
                    break
                    ;;
            esac
        fi

        # Handle linux type.
        # ... [-v/-r] ...
        if [[ tLinuxFlag -eq 1 ]]; then
            case $tString in
                -v*)
                    echo "Enable verbose"
                    tParam="$tParam -v"
                    tString=$(rest $tString)
                    ;;
                -r*)
                    echo "Rebuild Linux..."
                    tParam="$tParam -l"
                    tString=$(rest $tString)
                    ;;
                *)
                    echo "Command: $tParam $tString"
                    package $tParam clean
                    package $tParam compile
                    if [ $? -ne 0 ]; then
                        echo -en "$Red$On_White linux failed,stop. $Color_Off$On_White $Color_Off  \r\n"
                        alert "linux package failed,stop."
                        break
                    fi
                    package $tParam install
                    break
                    ;;
            esac
        fi

        # Handle FwBin type.
        # ... [-v/-r/-c/-m] ...
        if [[ tAllFlag -eq 1 ]]; then
            case $tString in
                -v*)
                    echo "Enable verbose"
                    tParam="$tParam V=s"
                    tString=$(rest $tString)
                    ;;
                -r*)
                    echo "Rebuild FwBin..."
                    tString=$(rest $tString)
                    # echo $(next $tString)
                    echo "Cleaning OpenWrt..."
                    make clean
                    echo "make defconfig PRODUCT=$(next $tString)"
                    make defconfig PRODUCT=$(next $tString)
                    echo "Start Building FwBin..."
                    make "$tParam"
                    if [ $? -ne 0 ]; then
                        echo -en "$Red$On_White FwBin package failed,stop. $Color_Off$On_White $Color_Off  \r\n"
                        alert "FwBin package failed,stop."
                        break
                    fi
                    break
                    ;;
                -m*)
                    echo "Build FwBin..."
                    tString=$(rest $tString)
                    # echo $(next $tString)
                    echo "Start Building FwBin..."
                    make "$tParam"
                    if [ $? -ne 0 ]; then
                        echo "FwBin compile failed,stop."
                        alert "FwBin compile failed,stop."
                        break
                    fi
                    break
                    ;;
                *)
                    echo "Nothing Todo..."
                    ;;
            esac
        fi
    done
done

