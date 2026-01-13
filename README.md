# HPC Cluster - Arctic

This repository contains deployment configurations for the HPC Cluster of the Arctic team.

## Dependencies

Follow the instructions of [cluster-toolkit](https://github.com/GoogleCloudPlatform/cluster-toolkit) and make sure it's installed correctly because the deployment of this infrastructure is dependent on that project.

## Pre-flight Checklist

- Authenticate using `gcloud auth login`
- Make sure the output of `gcloud config get project` matches with `project_id` in [cluster.yaml](todo). If it doesn't, run `gcloud config set project <project_id>`

## Deploy

*This section assumes that the image to be used in deployment is already created and stored in GCP. See the [Image Creation](#image-creation) section for more details.*

Check the `project_id` and update it if it's necessary to deploy it on the correct GCP project.

Once cluster-toolkit is installed and `project_id` is correct, run the following commands to deploy the cluster:

```bash
cluster-toolkit/ghpc create -w cluster.yaml
cluster-toolkit/ghpc deploy cluster --auto-approve
```

**Do not manually delete any cluster-related files, either locally or remotely. This would cause a lot of problems and prevent future deployments.**

## Destroy

```bash
cluster-toolkit/ghpc destroy cluster --auto-approve
rm -rf cluster/  # not super important, necessary if you want to remove Terraform files
```

## Detailed Instructions

If you want to deploy the cluster in multiple steps and have more control over the deployment, see the `cluster/instructions.txt` file after running `cluster-toolkit/ghpc create -w cluster.yaml` for detailed deployment commands.

## Image Creation

The referenced image in the YAML file is already built and ready to use.
See the image family and the related images [in the GCP console.](https://console.cloud.google.com/compute/images?referrer=search&tab=images&hl=en&project=spherical-berm-323321&pageState=(%22images%22:(%22f%22:%22%255B%257B_22k_22_3A_22_22_2C_22t_22_3A10_2C_22v_22_3A_22_5C_22cluster_5C_22_22%257D%255D%22)))
However, if a new dependency, version upgrade, etc. is needed, the image needs rebuilding.
`image-build.sh` takes care of that job.
It installs the dependencies using the `install-dependencies-startup.sh` script.
So, modify that file to tweak the dependencies.

## Troubleshooting

- **Image creation fails:** The image creation script handles everything to build an image. While doing that, it connects via SSH to a temporary machine to install the dependencies. However, it may fail at that step if you don't have SSH configured on your machine through `gcloud`. If you experience this issue, you can manually run the Bash commands that are clearly separated in the `image-build.sh` file.
