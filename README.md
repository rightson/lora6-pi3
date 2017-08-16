# LoRa6 Pi3

### Usage:

##### On host:
  `make`

Then everything will be placed to rootfs/ folder automatically.

##### On target:
  `sudo ldattach -8n1 -s 57600 26 $DEVICE_FILE`
  `sudo insmod lora6`
  `sudo rmmod lora6`
