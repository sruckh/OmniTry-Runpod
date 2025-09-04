 - The goal of this project is to create a container from the github project, https://github.com/Kunbyte-AI/OmniTry, that can run on the Runpod service
 - ask context7 for documentation for creating Runpod containers
 - Use nvidia/12.3.2-cudnn9-runtime-ubuntu22.04 as the base image for our OmniTry application. The container will only use AMD64 architecture.  This base image is the ONLY thing that should be done at build time.  As this is for RUNPOD everything else will be installed after the container is already started.

**Installation step at runtime for OmniTry**  REPEAT!!!! EVERYTHING BELOW GETS DONE AFTER THE CONTAINER HAS STARTED!!!!

 - Install pytorch using this command:  conda install pytorch\==2.4.0 torchvision\==0.19.0 torchaudio==2.4.0 pytorch-cuda=12.4 -c pytorch -c nvidia"
 - Install python use deadsnake PPA
		RUN apt-get update && \
        apt-get install -y software-properties-common && \
        add-apt-repository ppa:deadsnakes/ppa && \
        apt-get update && \
        apt-get install -y python3.11 python3-pip
		RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1
- clone github repository https://github.com/Kunbyte-AI/OmniTry.git
- 1.  Create the checkpoint directory:  `mkdir checkpoints`
- 2.	Download the  [FLUX.1-Fill-dev](https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev)  into  `checkpoints/FLUX.1-Fill-dev`
- 3. Download the [LoRA of OmniTry](https://huggingface.co/Kunbyte/OmniTry) into `checkpoints/omnitry_v1_unified.safetensors`. You can also download the `omnitry_v1_clothes.safetensors` that specifically finetuned on the clothes data only
- 4. pip install -r requirements.txt
- 5. Install https://github.com/Dao-AILab/flash-attention/releases/download/v2.6.3/flash_attn-2.6.3+cu123torch2.4cxx11abiFALSE-cp311-cp311-linux_x86_64.whl
- 6. The entrypoint for the container is: python gradio_demo.py

**Changes that are necessary**
From step 3 above there were two different safetensors to download.  The current gradio_demo.py only supports using one of the saftetensor files.  This is controlled by `setting lora_path` in `configs/omnitry_v1_unified.yaml`.  It is desired that the user can easily switch between using each of the safetensors files for inference.

**Absolute rules to follow**
- Never build this container on the localhost as it will not run on the server.  This is strictly for running as a container on the Runpod platform.
- Never install software or dependencies on the local host.  All software to be installed should be done inside the container.
- Note that 'docker-compose' has been deprecated 'docker compose' is the correct syntax.
- Never expose secrets or API keys to github repository.  Alway scan code to make sure code is secure and private keys and secrets never end up on the github repository.  Use placeholders in the github files.

**MPC Servers**
- ask serena for memories to get context about the project.  also ask serena to write memories to document the changes that are made to the project.
- use context7 to get up to date documentation
- For more complex tasks ask claude flow to spawn agents to complete tasks
- use fetch to read internet web pages

**Github information**
- The upstream github project is https://github.com/Kunbyte-AI/OmniTry.git .  The repository we will be working on is https://github.com/sruckh/OmniTry-Runpod .  All changes will be pushed to the sruckh/OmniTry-Runpod repository.
- two github secrets have been configured:  DOCKER_USERNAME and DOCKER_PASSWORD.  These should be used for pushing container image to Dockerhub

**Dockerhub**
- The dockerhub repository for this container is gemneye/

**Github action**
- If it has not already been completed set up the github action to automatically build and push the container to dockerhub.  Also create a description for the container that users can see on dockerhub.

**Environmental Variables**
- Any environmental variables that are necessary will be configured on Runpod.
