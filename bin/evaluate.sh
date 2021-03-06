#!/bin/bash

# Run ML model evaluation
#
# e.g. bin/evaluate.sh model_config dataset job_id label
#
# @param {model_config} Name of ML model configuration to use.
#            This should correspond to a configuration file named as follows:
#            config/${model_config}.sh.
# @param {dataset} Dataset identifier.
#            Check the variable `eval_file` to make sure that this maps to the
#            correct data.
# @param {job_id} Job ID of the ML model to evaluate.
#            Check the variable `ckpt` to make sure that this maps to the 
#            correct ML model checkpoint.
# @param {label} Optional label to add to the job name.

# Get arguments
model_config=$1
dataset=$2
job_id=$3
label=$4

# Check the datapath config file
datapath_file=config/datapath.sh
if [ ! -f "$datapath_file" ]; then
  echo "Datapath config file not found: $datapath_file";
  exit 1;
fi

# Set datapaths
. "config/datapath.sh"
eval_file="${DATAPATH}/tfrecords/${dataset}/test-*.tfrecord.gz"
ckpt="${DATAPATH}/models/${job_id}/ckpt"

# Check the ML model config file
config_file=config/$model_config.sh
if [ ! -f "$config_file" ]; then
  echo "ML model config file not found: $config_file";
  exit 1;
fi

# Read the ML model config file
. "$config_file"

# Define the job name
now=$(date +%Y%m%d_%H%M%S)
job_name=evaluate_${now}_${model_config}_${dataset}_${label}
log_file="log/${job_name}.log"

# Set package and module name
package_path=ml_framework/
module_name=ml_framework.evaluate

# Run the job
echo 'Running ML evaluation.'
echo "Logging to file: $log_file"
python -m $module_name \
--job_dir=$ckpt \
$MODULE_ARGS \
--eval_file=$eval_file 2>&1 | tee $log_file