#!/bin/bash

set -e

cluster-toolkit/gcluster create blueprints/slurm.yaml -w
cluster-toolkit/gcluster deploy slurm-cluster --auto-approve

echo "Sleeping 30 seconds to let Slurm setup complete..."
sleep 30
echo "Everything's set. You can login to the cluster!"
