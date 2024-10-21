#!/bin/bash
# Copyright (c) Meta Platforms, Inc. and affiliates.

#SBATCH --job-name=env_creation
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --gres=gpu:8
#SBATCH --exclusive
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH --mem=0
#SBATCH --time=01:00:00

# Exit immediately if a command exits with a non-zero status
set -e

module load conda

# Start timer
start_time=$(date +%s)

# Get the current date
current_date=$(date +%y%m%d)

# Create environment name with the current date
env_prefix=lingua_$current_date

# Create the conda environment

#source $CONDA_ROOT/etc/profile.d/conda.sh
conda create -n $env_prefix python=3.11 -y -c anaconda
conda activate $env_prefix

echo "Currently in env $(which python)"

# Install packages
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm6.1
pip install ninja
pip install -U xformers --index-url https://download.pytorch.org/whl/rocm6.1
# Currently, xformers will downgrade from pytorhc 2.5.* to pytorch 2.4.* which will break the codebase.
pip install --requirement requirements.txt
pip uninstall -y pynvml # See https://github.com/Haidra-Org/horde-worker-reGen/commit/229dd72ce31cd5499986364dd12adc3284b47dc9#diff-c6996df53d5f62ca4f9cbb14ddeb813dfab1effa678b1d71b60dbacb72e026fcR43

# End timer
end_time=$(date +%s)

# Calculate elapsed time in seconds
elapsed_time=$((end_time - start_time))

# Convert elapsed time to minutes
elapsed_minutes=$((elapsed_time / 60))

echo "Environment $env_prefix created and all packages installed successfully in $elapsed_minutes minutes!"


