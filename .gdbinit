target extended-remote :4242
monitor semihosting enable
monitor reset halt
load
monitor reset init
