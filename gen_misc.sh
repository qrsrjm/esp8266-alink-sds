#!/bin/bash
set -e

export SDK_PATH=$(pwd)/esp8266-rtos-sdk-alink
export BIN_PATH=$(pwd)/bin

if [ ! -d "bin" ]; then
    mkdir bin

    for((i=0;i<12*1024;i++))
    do
        echo -e '\0377\c' >> 'bin/blank_12k.bin'
    done
fi

if [ ! -d "device_id" ]; then
    mkdir device_id
fi

boot=new
app=1
spi_speed=40
spi_mode=QIO
spi_size_map=5

cd platforms
# make clean
make
cd -
make clean
make BOOT=$boot APP=$app SPI_SPEED=$spi_speed SPI_MODE=$spi_mode SPI_SIZE_MAP=$spi_size_map
# copy bin
cp esp8266-rtos-sdk-alink/bin/*.bin bin/

echo -e "\033[32m"
echo "------------ makefile config ------------"
echo "boot mode    : $boot"
echo "generate bin : user1.bin"
echo "spi speed    : $spi_speed MHz"
echo "spi mode     : $spi_mode"
echo "spi size     : 2048KB"
echo "spi ota map  : 1024KB + 1024KB"
echo "BIN_PATH: $BIN_PATH"
echo "SDK_PATH: $SDK_PATH"

echo ""
echo "------------ download address ------------"
echo "boot.bin------------------->0x000000"
echo "user1.2048.new.5.bin------->0x001000"
echo "device_id.bin-------------->0x1F7000"
echo "blank_12k.bin-------------->0x1F8000"
echo "blank.bin------------------>0x1FB000"
echo "esp_init_data_default.bin-->0x1FC000"
echo "blank.bin------------------>0x1FE000"

echo ""
echo "------------    device id    -------------"
while read line
do
    OLD_IFS="$IFS"
    IFS=" "
    arr=($line)
    IFS="$OLD_IFS"

    if grep '^[[:digit:]]*$' <<< ${arr[0]} >/dev/null;then
        device_id_file="device_id/"${arr[1]}.bin
        echo -e ${arr[1]}"\c" > $device_id_file
        echo -e ${arr[2]}"\c" >> $device_id_file
        echo -e "\033[32m"$device_id_file
    fi
done < device_id_secret.txt

echo -e "\033[00m"
