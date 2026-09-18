#!/bin/bash
# Script for checking environment variables

# Check if $1 is in $parameters. If so, return 1, otherwise 0
check_parameter()
{
  for p in $parameters;
  do
    if [ "$p" == "$1" ]; then
      return 1;
    fi
  done;
  return 0
}

# Check if one of the words in $1 is in $parameters.
# If so, return 1, otherwise 0
check_parameters()
{
  for word in $*
  do
    check_parameter $word
    if [ "$?" == "1" ]; then
      return 1;
    fi
  done
  return 0
}

# Echo a warning message if the string $1 is not a env variable.
warning_variable()
{
  var_name='$'$1
  eval var_content=`echo $var_name`
  if [ "$2" != "" ]; then
    check_parameters $2
    is_parameter=$?
  else
    is_parameter="1"
  fi

  if [ "$is_parameter" == 1 ] &&  [ "$var_content" == "" ]; then
    echo "*******************************************************************************"
    echo "* WARNING: environment variable $var_name is not set"
    echo "*******************************************************************************"
  fi
  return 0
}

# Echo a error message if the string $1 is not a env variable, and then exit.
error_variable()
{
  var_name='$'$1
  eval var_content=`echo $var_name`
  if [ "$2" != "" ]; then
    check_parameters $2
    is_parameter=$?
  else
    is_parameter="1"
  fi

  if [ "$is_parameter" == 1 ] &&  [ "$var_content" == ""  ]; then
    echo "*******************************************************************************"
    echo "* ERROR: environment variable $var_name is not set"
    echo "*******************************************************************************"
    exit 1
  fi
  return 0
}
