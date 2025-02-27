"""
Flood model job submission script

This script was written to run a flood model over more than 50,000 water sheds.
It is a straightforward and quick script to prepare thousands of jobs and submit them to Slurm.

Note: Better to run the script in detacted mode
"""


import os
import subprocess
import time
from dataclasses import dataclass
from string import Template

import gcsfs


@dataclass
class Batch:
    folder_name: str
    remote_path: str

    def __repr__(self):
        return f"{self.folder_name}, {self.remote_path}"


def create_slurm_script(template, batch_obj, base_log_path):
    substitute_values = {
        "job_name": batch_obj.folder_name,
        "partition": "compute",
        "log_file_path": os.path.join(base_log_path, f"{batch_obj.folder_name}.out"),
        "gcs_path": f"gs://{batch_obj.remote_path}",
        "folder_name": batch_obj.folder_name,
        "parameter_file": f"Ethiopia_{batch_obj.folder_name}_100yr.par"
    }

    script_str = template.substitute(substitute_values)
    return script_str


def get_num_jobs():
    try:
        process = subprocess.run(['squeue', '-u', os.getenv("USER"), '-h'], capture_output=True, text=True, check=True)
        output = process.stdout
        num_jobs = len(output.strip().split('\n')) if output.strip() else 0
        return num_jobs
    except subprocess.CalledProcessError as e:
        print(f"Error executing squeue: {e}")
        return -1


slurm_script = Template("""#!/bin/bash

#SBATCH --job-name $job_name
#SBATCH --partition $partition
#SBATCH --nodes=1
#SBATCH -o $log_file_path

cd /data

export GCS_PATH=$gcs_path
echo "Copying remote data from $$GCS_PATH"
/snap/google-cloud-cli/current/bin/gsutil -m cp -r $$GCS_PATH .

cd $folder_name/

~/flood_model/build/lisflood $parameter_file

/snap/google-cloud-cli/current/bin/gsutil -m cp -r Ethiopia_results_$folder_name $$GCS_PATH
""")

bucket_path = "mizuroute_streamflow/ethiopia_flood"
fs = gcsfs.GCSFileSystem()
paths = fs.ls(bucket_path)

print("Creating batch objects")
objects = []
for elem in paths:
    input_data = elem.replace(f"{bucket_path}/", "")
    if input_data == "":
        continue

    new_batch_object = Batch(folder_name=input_data, remote_path=elem)
    objects.append(new_batch_object)


home = os.getenv("HOME")
base_log_path = os.path.join(home, "logs")
os.makedirs(base_log_path, exist_ok=True)

scripts_path = os.path.join(home, "scripts")
os.makedirs(scripts_path, exist_ok=True)

print("Creating slurm_runner.sh files")
slurm_runners = []
for elem in objects[:10]:
    script = create_slurm_script(slurm_script, elem, base_log_path)
    slurm_runner_path = os.path.join(scripts_path, f"slurm_runner_{elem.folder_name}.sh")
    with open(slurm_runner_path, "w") as file:
        file.write(script)

    slurm_runners.append(slurm_runner_path)

print("Job submission started")
index = 0
while index < len(slurm_runners):
    current_job_count = get_num_jobs()
    if current_job_count < 2000:
        print("Green light! Submitting 100 jobs")
        for file in slurm_runners[index: min(index+100, len(slurm_runners))]:
            process = subprocess.run(["sbatch", file], check=True, capture_output=True)
        index += 100
    else:
        print("The queue is too crowded. Sleeping for 7 minutes.")
        time.sleep(60 * 7)
