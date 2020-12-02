
#Use library
if [[ -z $ALEXPRO100_LIB_VERSION ]]; then
  if [[ -z $ALEXPRO100_LIB_LOCATION ]]; then
    if [[ -f ${BASH_SOURCE[0]%/*}/alexpro100_lib.sh ]]; then
      ALEXPRO100_LIB_LOCATION="${BASH_SOURCE[0]%/*}/alexpro100_lib.sh"
      echo "Using $ALEXPRO100_LIB_LOCATION."
    else
      echo -e "ALEXPRO100_LIB_LOCATION is not set!"; return 1
    fi
  fi
  source $ALEXPRO100_LIB_LOCATION
fi
