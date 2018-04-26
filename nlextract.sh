#!/bin/bash
#
# ETL voor NLExtract GML met gebruik Stetl.
#
# Dit is een front-end/wrapper shell-script om uiteindelijk Stetl met een configuratie
# (project/etl/conf/default.cfg) en parameters (options/default.args) aan te roepen.
#
# Author: Just van den Broecke
#
mkdir -p temp

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -p|--project)
    PROJECT="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--data)
    DATA="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd $DIR >/dev/null

NLX_HOME=.
export STETL_PROJECTETL=$PROJECT/etl

# Gebruik Stetl meegeleverd met NLExtract (kan in theorie ook Stetl via pip install stetl zijn)
if [ -z "$STETL_HOME" ]; then
  STETL_HOME=externals/stetl
fi

# Nodig voor imports
if [ -z "$PYTHONPATH" ]; then
  export PYTHONPATH=$STETL_HOME:$NLX_HOME:$STETL_PROJECTETL
else
  export PYTHONPATH=$STETL_HOME:$NLX_HOME:$STETL_PROJECTETL:$PYTHONPATH
fi

if [ -z "$STETL_GFS_TEMPLATE" ]; then
  export STETL_GFS_TEMPLATE=${STETL_PROJECTETL}/gfs/default.gfs
fi

# Default arguments/optionsproject
options_file=options/default.args

# Optionally overules default options file by using a host-based file options/<your hostname>.args
# To add your localhost add <your hostname>.args in options directory
host_options_file=options/`hostname`.args

[ -f "$host_options_file" ] && options_file=$host_options_file

# Evt via commandline overrulen: etl-top10nl.sh <my options file>
[ -f "$1" ] && options_file=$1

# Uiteindelijke commando. Kan ook gewoon "stetl -c conf/etl-top10nl-v1.2.cfg -a ..." worden indien Stetl installed
# python $STETL_HOME/stetl/main.py -c conf/etl-top10nl-v1.2.cfg -a "$pg_options temp_dir=temp max_features=$max_features gml_files=$gml_files $multi $spatial_extent"
python $STETL_HOME/stetl/main.py -c $PROJECT/etl/conf/default.cfg -a $options_file 

popd >/dev/null
