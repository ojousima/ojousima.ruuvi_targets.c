#!/bin/bash
NAME="dev"
VERSION="0.0.1"
while getopts "n:v:" option;
do
case "${option}"
in
n) NAME=${OPTARG};;
v) VERSION=${OPTARG};;
esac
done

nrfutil settings generate --family NRF52 --application _build/nrf52832_xxaa.hex --application-version 1 --application-version-string "$VERSION" --bootloader-version 1 --bl-settings-version 1 settings.hex
mergehex -m ../../../../nRF5_SDK_15.0.0_a53641a/components/softdevice/s132/hex/s132_nrf52_6.0.0_softdevice.hex ./ruuvi_bootloader.hex settings.hex -o sbc.hex
mergehex -m sbc.hex _build/nrf52832_xxaa.hex -o packet.hex
nrfjprog --family nrf52 --eraseall
nrfjprog --family nrf52 --program packet.hex
nrfjprog --family nrf52 --reset


echo "preparing ruuvi_${NAME}_${VERSION}"
mv packet.hex ruuvi_${NAME}_${VERSION}_full.hex
cp _build/nrf52832_xxaa.hex ruuvi_${NAME}_${VERSION}_app.hex
nrfutil pkg generate --application _build/nrf52832_xxaa.hex --application-version 1 --application-version-string "$VERSION" --hw-version 0x00000b --sd-req 0xA8 --key-file ~/git/ruuvitag_fw/keys/ruuvi_open_private.pem ruuvi_${NAME}_${VERSION}_dfu.zip