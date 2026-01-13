#!/bin/bash
set -e

PROJECT_ID="pdg-wg-carbon"
ZONE="us-central1-a"
VM_NAME="cluster-image-builder"
IMAGE_FAMILY="dvmdostem-slurm-v1"
BASE_IMAGE_FAMILY="slurm-gcp-6-11-ubuntu-2404-lts-nvidia-570"
BASE_IMAGE_PROJECT="schedmd-slurm-public"

# echo "=== Step 1: Creating temporary VM ==="
# gcloud compute instances create $VM_NAME \
#   --project=$PROJECT_ID \
#   --zone=$ZONE \
#   --machine-type=n2-standard-4 \
#   --image-family=$BASE_IMAGE_FAMILY \
#   --image-project=$BASE_IMAGE_PROJECT \
#   --boot-disk-size=200GB \
#   --scopes=cloud-platform

# echo ""
# echo "=== Step 2: Waiting for VM to be ready ==="
# sleep 30

echo ""
echo "=== Step 3: Establishing SSH connection and adding host keys ==="
gcloud compute ssh $VM_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --command="echo 'SSH connection established'"

echo ""
echo "=== Step 4: Copying installation script to VM ==="
gcloud compute scp install-dependencies-startup.sh \
  $VM_NAME:/tmp/install.sh \
  --project=$PROJECT_ID \
  --zone=$ZONE

echo ""
echo "=== Step 5: Running installation script on VM ==="
echo "This will take a while..."
gcloud compute ssh $VM_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE \
  --command="sudo bash /tmp/install.sh"

echo ""
echo "=== Step 6: Stopping VM ==="
gcloud compute instances stop $VM_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE

echo ""
echo "=== Step 7: Creating custom image ==="
IMAGE_NAME="${IMAGE_FAMILY}-$(date +%s)"
gcloud compute images create $IMAGE_NAME \
  --project=$PROJECT_ID \
  --source-disk=$VM_NAME \
  --source-disk-zone=$ZONE \
  --family=$IMAGE_FAMILY \
  --description="Custom Slurm image with DVMDOSTEM dependencies"

echo ""
echo "=== Step 8: Cleaning up temporary VM ==="
gcloud compute instances delete $VM_NAME \
  --project=$PROJECT_ID \
  --zone=$ZONE \

echo ""
echo "✓ Custom image created successfully!"
echo "  Image name: $IMAGE_NAME"
echo "  Image family: $IMAGE_FAMILY"
echo ""
echo "You can now deploy your cluster using:"
echo "  cd cluster-toolkit"
echo "  ./ghpc create ../cluster.yaml --vars \"project_id=$PROJECT_ID\" -w"
echo "  ./ghpc deploy cluster"
