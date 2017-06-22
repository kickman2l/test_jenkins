#!/usr/bin/env bash

# Rating variables
MISTAKES_COUNTER=0
SUCC_ANSWERS=0
WRONG_ANSWERS=0

STUDENT_NAME=$1
IP_ADDR_VM=192.168.56.100
succ_counters()
{
  let "MISTAKES_COUNTER=MISTAKES_COUNTER+1"
  let "SUCC_ANSWERS=SUCC_ANSWERS+1"
}

err_counters()
{
  let "MISTAKES_COUNTER=MISTAKES_COUNTER-1"
  let "WRONG_ANSWERS=WRONG_ANSWERS+1"
}

check_directory()
{
    DIR_PAHT_CHK=$1
    # Check is directory /apps/mongo exists.
    echo "### Checking is directory ${DIR_PAHT_CHK} exists. ###"
    if (ssh root@${IP_ADDR_VM} '[ -d ${DIR_PAHT_CHK} ]'); then
      echo "RESPONCE  -->  Directory ${DIR_PAHT_CHK} exists. - OK!";
      succ_counters
    else
      echo "RESPONCE  -->  Directory ${DIR_PAHT_CHK} doesn't exists. - FAIL!"
      err_counters
    fi

}

# Block with ckecks
# Check right uid and git is settuped
echo "### Checking user UID and GID. ${STUDENT_NAME} ###"
UID_R=$(ssh root@${IP_ADDR_VM} id -u ${STUDENT_NAME})
GID_R=$(ssh root@${IP_ADDR_VM} id -g ${STUDENT_NAME})
if [[ $UID_R == 500 && $GID_R == 500 ]]; then
  echo "RESPONCE  -->  UID: $UID_R. GID: $GID_R. - OK!";
  succ_counters
else
  echo "RESPONCE  -->  Something goes wrong. Check ID's. UID: $UID_R. GID: $GID_R. - FAIL!"
  err_counters
fi

# Check connection to remote host.
echo "### Checking ssh connection to VM. ###"
RESPONCE_CODE=$(ssh -T root@${IP_ADDR_VM} echo $?)
if [[ $RESPONCE_CODE == 0 ]]; then
  echo "RESPONCE  -->  Conncetion established. - OK!"
  succ_counters
else
  echo "RESPONCE  -->  Something goes wrong. - FAIL!"
  err_counters
fi


# Check right uid and git mongo user
echo "### Checking user UID mongo. ###"
UID_R=$(ssh root@${IP_ADDR_VM} id -u mongo)
if [[ $UID_R == 600 ]]; then
  echo "RESPONCE  -->  UID: $UID_R. - OK!";
  succ_counters
else
  echo "RESPONCE  -->  Something goes wrong. Check ID's. UID: $UID_R. - FAIL!"
  err_counters
fi

# Check right git staff group
echo "### Checking staff group GID. ###"
GID_R=$(ssh root@${IP_ADDR_VM} getent group staff | awk -F: '{print $3}')
if [[ $GID_R == 600 ]]; then
  echo "RESPONCE  -->  GID: $GID_R. - OK!";
  succ_counters
else
  echo "RESPONCE  -->  Something goes wrong. Check ID's. GID: $GID_R. - FAIL!"
  err_counters
fi

check_directory "/apps/mongo"


#


#
#
## Check directories permissions
#echo "### Check permissions on directory. ###"
#PERMS=$(ssh root@${IP_ADDR_VM} stat /apps/mongodb/ | sed -n '/^Access: (/{s/Access: (\([0-9]\+\).*$/\1/;p}')
#if [[ $PERMS == 0700 ]]; then
#  echo "RESPONCE  --> Permissions: $PERMS. - OK!"
#  succ_counters
#else
#  echo "RESPONCE  -->  Something goes wrong. Permissions: $PERMS. - FAIL!"
#  err_counters
#fi




echo "Total rating: $MISTAKES_COUNTER. Mistakes: $WRONG_ANSWERS. Correct answers: $SUCC_ANSWERS."
