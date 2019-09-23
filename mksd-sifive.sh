#/bin/sh
device=$1
cmd="sudo ./sgdisk"
#cmd="sudo echo"
if [ -z $2 ] || [ $2 == "8G" ]; then
    endblk=15523806
elif [ $2 == "16G" ]; then
    endblk=30375902
else
    echo "usage: $0 device [8G|16G]"
    exit 1;
fi   
       
${cmd} --backup mmc.gpt.info.backup ${device}
# Zap all partitions
${cmd} -Z ${device}
# Make partition 1 32M 5202(SiFive bootloader)
${cmd} --new=1:2048:67583   ${device}
${cmd} --typecode=1:5202    ${device}
# Make partition 2 Linux 7.3G
${cmd} --new=2:264192:${endblk} ${device}
${cmd} --typecode=2:8300   ${device}
# Make partition 4 128K 5201(SiFive FSBL)
${cmd} --new=4:67584:67839 ${device}
${cmd} --typecode=4:5201   ${device} 
