#!/bin/bash
# Test cases for disable_gpu.sh
## Conditionally source test file

[[ "$(type -t 't_start')" = 'function' ]] || source test_helper.sh
source "$NVOC/helpers/disable_gpu.sh" 
# unset RUN_ALL

#
# _dgh_main
t_start '_dgh_main'
  tf 'without DISABLED_GPUS' '' 'DISABLED_GPUS not set' 1
  DISABLED_GPUS='0 10 17'
  te 'Update Disabled GPU' ' _dgh_main' '' 0
  te '' '${!DISABLED_GPU_ARRAY[@]}' '0 10 17'
  te '' '$CUDA_DEVICE_ORDER' 'PCI_BUS_ID'
t_end
#
# dgh_int_to_alphanumeric
t_start 'dgh_int_to_alphanumeric' 
  tf '' '' '' 127
  tf '' ',' '' 127
  tf '' 0 0 0
  tf '' 1 1 0
  tf '' 10 a 0
  tf '' 35 z 0
  tf '' 36 '' 127
  tf '' -1 '' 127
t_end

#
# dgh_alphanumeric_to_int
t_start 'dgh_alphanumeric_to_int'
  tf '' '' '' 127
  tf '' ',' '' 127
  tf '' 10 '' 127
  tf '' -1 '' 127
  tf '' A '' 127
  tf '' 0 0 0
  tf '' 9 9 0
  tf '' a 10 0
  tf '' z 35 0
t_end

#
# dgh_is_gpu_disabled
t_start 'dgh_is_gpu_disabled'
  unset DISABLED_GPU_ARRAY
  DISABLED_GPUS='0 10 17'
  te 'Update DISABLED_GPU_ARRAY' ' _dgh_main' '' 0
  te 'Check DISABLED_GPU_ARRAY' '${!DISABLED_GPU_ARRAY[@]}' '0 10 17'
  tf '' '' '' 127
  tf '' ',' '' 127
  tf '' 0 '' 0
  tf '' 1 '' 1
  tf '' 10 '' 0
  tf '' a '' 0
  tf '' A '' 127
  tf '' 17 '' 0
  tf '' h '' 0 # h=17 acording to a=10, b=11 ..
t_end

#
# dgh_gpu_count
t_start 'dgh_gpu_count'
  unset GPUS
  tf 'empty GPUS' '' 0 1
  GPUS=8
  tf 'with 8 GPUS' '' 8 0
t_end

#
# dgh_update_devices
t_start 'dgh_update_devices'
  unset DISABLED_GPU_ARRAY
  tf 'missing DISABLED_GPU_ARRAY' "'--device ' ' ' '--devices 0 1 2 3 a z --api-port -33330 -other'" \
    '--devices 0 1 2 3 a z --api-port -33330 -other' 1
  
  DISABLED_GPUS='0 10 35'
  te 'Update DISABLED_GPU_ARRAY' ' _dgh_main' '' 0
  te 'Check DISABLED_GPU_ARRAY' '${!DISABLED_GPU_ARRAY[@]}' '0 10 35'

  tf 'Match prefix, unmatch delimiter' '"--device " " " "019abyz --devices 019abyz --api-port -33330 -other"' \
    '019abyz --devices 019abyz --api-port -33330 -other' 0
  tf 'Unmatch prefix, match delimiter' '"--dev " "" "019abyz --devices 019abyz --api-port -33330 -other"' \
    '019abyz --devices 019abyz --api-port -33330 -other' 0
  tf 'Empty prefix' '"" "" "019abyz --devices 019abyz --api-port -33330 -other"' \
    '019abyz --devices 019abyz --api-port -33330 -other' 1
  tf 'Empty prefix, comma delimiter' '"" "" "0,1,9,a,b,y,z --devices 0,1,9,a,b,y,z --api-port -33330 -other"' \
    '0,1,9,a,b,y,z --devices 0,1,9,a,b,y,z --api-port -33330 -other' 1
  
  tf 'All match, no delimiter' '"-device " "" "--some other 019abyz --device 019abyz --api-port -33330 -other"' \
    '--some other 019abyz --device 19by --api-port -33330 -other' 0
  tf 'All match, space delimiter' '"-device " " " "--some other 0 1 9 a b y z --device 0 1 9 a b y z --api-port -33330 -other"' \
    '--some other 0 1 9 a b y z --device 1 9 b y --api-port -33330 -other' 0
  tf 'All match, comma delimiter' '"-device " "," "--some other 0,1,9,a,b,y,z --device 0,1,9,a,b,y,z --api-port -33330 -other"' \
    '--some other 0,1,9,a,b,y,z --device 1,9,b,y --api-port -33330 -other' 0
  
  unset DISABLED_GPU_ARRAY
  DISABLED_GPUS='1 9 11 34'
  te 'Update DISABLED_GPU_ARRAY' ' _dgh_main' '' 0
  te 'Check DISABLED_GPU_ARRAY' '${!DISABLED_GPU_ARRAY[@]}' '1 9 11 34'
  
  tf 'All match, no delimiter' '"-device " "" "--some other 019abyz --device 019abyz --api-port -33330 -other"' \
    '--some other 019abyz --device 0az --api-port -33330 -other' 0
  tf 'All match space delimiter' '"--device " " " "--some other 0 1 9 a b y z --device 0 1 9 a b y z --api-port -33330 -other"' \
    '--some other 0 1 9 a b y z --device 0 a z --api-port -33330 -other' 0
  tf 'All match, comma delimiter' '"--device " "," "--some other 0,1,9,a,b,y,z --device 0,1,9,a,b,y,z --api-port -33330 -other"' \
    '--some other 0,1,9,a,b,y,z --device 0,a,z --api-port -33330 -other' 0
  tf 'Empty input' '"--device " "," ""' \
     '' 0
  tf 'All gpu disabled' '"--device " "," "--some other 0,1,9,a,b,y,z --device 1,9,b,y --api-port -33330 -other"' \
    '--some other 0,1,9,a,b,y,z --device --api-port -33330 -other' 0
t_end

#
# dgh_all_enabled_devices
t_start 'dgh_all_enabled_devices' 
  unset DISABLED_GPU_ARRAY
  unset GPUS
  
  tf 'Without DISABLED_GPU_ARRAY, GPUS, arguments' '' '' 0 #test no DISABLED_GPU_ARRAY

  GPUS=13

  tf 'Without DISABLED_GPU ARRAY and arguments' '' \
    '0 1 2 3 4 5 6 7 8 9 10 11 12' 0

  unset DISABLED_GPU_ARRAY
  DISABLED_GPUS='0 10 12'
  te 'Update DISABLED_GPU_ARRAY' ' _dgh_main' '' 0
  te 'Check DISABLED_GPU_ARRAY' '${!DISABLED_GPU_ARRAY[@]}' '0 10 12'

  tf 'Without arguments' '' '1 2 3 4 5 6 7 8 9 11' 0
  tf 'gpu arg=15' '"-dev " "," "" 15' '-dev 1,2,3,4,5,6,7,8,9,11,13,14' 0
  tf 'gpu arg=0' '"-dev " "," "" 0' '-dev ' 0
  tf 'type arg=a' '"-dev " "," a' '-dev 1,2,3,4,5,6,7,8,9,b' 0
  tf 'delimiter arg=""' '"-dev " "" a' '-dev 123456789b' 0

  unset DISABLED_GPU_ARRAY
  DISABLED_GPUS='1 9 11 13'
  GPUS=15
  te 'Update DISABLED_GPU_ARRAY' ' _dgh_main' '' 0
  te 'Check DISABLED_GPU_ARRAY' '${!DISABLED_GPU_ARRAY[@]}' '1 9 11 13'

  tf 'Without arguments' '' '0 2 3 4 5 6 7 8 10 12 14' 0
  tf 'type arg=a' '"-dev " "," a' '-dev 0,2,3,4,5,6,7,8,a,c,e' 0
  tf 'type arg=x' '"-dev " "," x' '-dev 0,2,3,4,5,6,7,8,10,12,14' 0
  tf 'delimiter arg=""' '"-dev " "" a' '-dev 02345678ace' 0

  unset DISABLED_GPU_ARRAY
  DISABLED_GPUS='0 1 2'
  GPUS=3
  te 'Update DISABLED_GPU_ARRAY' ' _dgh_main' '' 0
  te 'Check DISABLED_GPU_ARRAY' '${!DISABLED_GPU_ARRAY[@]}' '0 1 2'

  tf 'All gpu is disabled' '"-dev " "" a' '-dev ' 0
t_end

#
# dgh_enabled_devices
t_start 'dgh_enabled_devices' 
  unset DISABLED_GPU_ARRAY
  unset GPUS
    
  tf 'Without DISABLED_GPU_ARRAY, GPUS, arguments' '' '' 0 #test no DISABLED_GPU_ARRAY

  DISABLED_GPUS='0 10 12'
  GPUS=13
  te 'Update DISABLED_GPU_ARRAY' ' _dgh_main' '' 0
  te 'Check DISABLED_GPU_ARRAY' '${!DISABLED_GPU_ARRAY[@]}' '0 10 12'

  tf 'Without arguments' '' '1 2 3 4 5 6 7 8 9 11' 0
  tf 'Without input' '"--di " " " a ""' '--di 1 2 3 4 5 6 7 8 9 b' 0
  tf 'With prefix unmatch' '"--di " "" a "--some --thing --here"' '--some --thing --here --di 123456789b' 0
  tf 'input absent gpu' '"--di " "" a "--some --di --thing --here"' '--some --di --thing --here' 0
  tf 'all gpu disabled' '"--di " "" a "--some --di 0ac --thing --here"' '--some --di --thing --here' 0
  tf 'With partial gpus' '"--di " "" a "--some --di 012346789abcd --thing --here" 14' '--some --di 12346789bd --thing --here' 0

  unset DISABLED_GPU_ARRAY
  DISABLED_GPUS='1 9 11 13'
  GPUS=14
  te 'Update DISABLED_GPU_ARRAY' ' _dgh_main' '' 0
  te 'Check DISABLED_GPU_ARRAY' '${!DISABLED_GPU_ARRAY[@]}' '1 9 11 13'

  tf 'With partial gpus' '"--di " " " n "--some --di 0 2 4 6 8 10 12 14 --thing --here" ' '--some --di 0 2 4 6 8 10 12 14 --thing --here' 0
  tf 'With partial gpus' '"--di " " " n "--some --di 1 3 5 7 13 --thing --here" ' '--some --di 3 5 7 --thing --here' 0
t_end

#
# dgh_get_miner_opts
t_start 'dgh_get_miner_opts' 
  ZEC_MINER='ZMINER'
  ZEC_EMINER_OPTS='1 2 3'
  ZEC_ZMINER_OPTS='4 5 6'
  ZEC_MMINER_OPTS='7 8 9'
  EQUIHASH_MINER='EMINER'
  EQUIHASH_EMINER_OPTS='1 2 3 4'
  EQUIHASH_ZMINER_OPTS='4 5 6 7'
  EQUIHASH_MMINER_OPTS='7 8 9 10'
  EMINER_OPTS='1 2 3 4 5'
  ZMINER_OPTS='4 5 6 7 8'
  MMINER_OPTS='7 8 9 10 11'
  COIN='ZEC'
  ALGO='EQUIHASH'

  tf 'empty argument' '' '' 1
  tf 'without coin and miner' "'' '' '$ALGO'" '1 2 3 4' 0
  tf 'without algo and miner' "'' '$COIN'" '4 5 6' 0
  tf 'with miner only' "'MMINER' '' '' ''" '7 8 9 10 11' 0
  tf 'with miner and algo' "'MMINER' '' '$ALGO' ''" '7 8 9 10' 0
  tf 'with miner and coin' "'MMINER' '$COIN' '' ''" '7 8 9' 0
  tf 'With ZEC_ZMINER_OPTS' "'' $COIN $ALGO" '4 5 6' 0
  unset ZEC_ZMINER_OPTS
  tf 'Without ZEC_ZMINER_OPTS' "'' $COIN $ALGO" '4 5 6 7' 0
  unset EQUIHASH_ZMINER_OPTS
  tf 'Without EQUIHASH_ZMINER_OPTS' "'' $COIN $ALGO" '4 5 6 7 8' 0
  unset ZMINER_OPTS
  tf 'Without ZMINER_OPTS' "'' $COIN $ALGO" '' 1

  ZEC_ZMINER_OPTS='4 5 6'
  te 'Reset ZEC_ZMINER_OPTS' '$ZEC_ZMINER_OPTS' '4 5 6' 0
  EQUIHASH_ZMINER_OPTS='4 5 6 7'
  te 'Reset EQUIHASH_ZMINER_OPTS' '$EQUIHASH_ZMINER_OPTS' '4 5 6 7' 0
  ZMINER_OPTS='4 5 6 7 8'
  te 'Reset ZMINER_OPTS' '$ZMINER_OPTS' '4 5 6 7 8' 0
  unset ZEC_MINER
  tf 'Without ZEC_MINER' "'' $COIN $ALGO" '1 2 3' 0
  unset ZEC_EMINER_OPTS
  tf 'Without ZEC_EMINER_MINER' "'' $COIN $ALGO" '1 2 3 4' 0
  unset EQUIHASH_EMINER_OPTS
  tf 'Without EQUIHASH_EMINER_OPTS' "'' $COIN $ALGO" '1 2 3 4 5' 0
  unset EMINER_OPTS
  tf 'Without EMINER_OPTS' "'' $COIN $ALGO" '' 1

t_end