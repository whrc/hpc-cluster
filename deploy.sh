#!/bin/bash

cluster-toolkit/gcluster create blueprints/vpc.yaml -w
cluster-toolkit/gcluster deploy vpc-network --auto-approve

cluster-toolkit/gcluster create blueprints/slurm.yaml -w
cluster-toolkit/gcluster deploy slurm-lustre --auto-approve

echo "Sleeping 60 seconds to let Slurm setup complete..."
sleep 60
echo "Everything's set. You can login to the cluster!"
