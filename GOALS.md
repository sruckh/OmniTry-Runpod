 - The goal of this project is to create a container from the github project, https://github.com/Kunbyte-AI/OmniTry, that can run on the Runpod platform.
 - ask context7 for documentation for creating Runpod containers
 - Use nvidia/12.3.2-cudnn9-runtime-ubuntu22.04 as the base image for our OmniTry application. The container will only use AMD64 architecture.  This base image is the ONLY thing that should be done at build time.  As this is for RUNPOD everything else will be installed after the container is already started.

**Installation steps at runtime for OmniTry**  REPEAT!!!! EVERYTHING BELOW GETS DONE AFTER THE CONTAINER HAS STARTED!!!!

**NEW ROBUST INSTALLATION METHOD:**
- Run the robust installation script: `./install_runtime.sh`
- This script handles all installation steps with error recovery and retry logic

**MANUAL INSTALLATION STEPS (if script fails):**
 - install miniconda
 - Install pytorch using this command:  conda install pytorch\==2.4.0 torchvision\==0.19.0 torchaudio==2.4.0 pytorch-cuda=12.4 -c pytorch -c nvidia"
 - RUN apt-get update && \
        apt-get install -y software-properties-common && \
        apt-get update && \
        apt-get install -y python python3-pip
 - clone github repository https://github.com/Kunbyte-AI/OmniTry.git (with directory existence check)
 - cd OmniTry
 - 1. Create the checkpoint directory:  `mkdir checkpoints`
**ask context7 how to use hf to download huggingface models now that huggingface-cli has been deprecated**
 - 2.	Download the  [FLUX.1-Fill-dev](https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev)  into  `checkpoints/FLUX.1-Fill-dev`
 - 3. Download the [LoRA of OmniTry](https://huggingface.co/Kunbyte/OmniTry) into `checkpoints/omnitry_v1_unified.safetensors`.  Also download `omnitry_v1_clothes.safetensors`
 - 4. pip install -r requirements.txt
 - 5. Install Flash Attention with retry logic: `pip install --no-cache-dir --timeout=600 https://github.com/Dao-AILab/flash-attention/releases/download/v2.6.3/flash_attn-2.6.3+cu123torch2.4cxx11abiFALSE-cp310-cp310-linux_x86_64.whl`
 - 6. The entrypoint for the container is: python gradio_demo.py

**Changes that are necessary**
From step 3 above there were two different safetensors to download.  The current gradio_demo.py only supports using one of the saftetensor files.  This is controlled by `setting lora_path` in `configs/omnitry_v1_unified.yaml`.  It is desired that the user can easily switch between using each of the safetensors files for inference in the gradio web interface.

**Absolute rules to follow**
- Never build this container on the localhost as it will not run on the server.  This project is specifically for building a container to launch from Runpod.
- Never install software or dependencies on the local host.  All software to be installed should be done inside the container. NEVER on the localhost!!!
- Note that 'docker-compose' has been deprecated 'docker compose' is the correct syntax.
- Never expose secrets or API keys to github repository.  Alway scan code to make sure code is secure and private keys and secrets never end up on the github repository.  Use placeholders in the github files.

**MPC Servers**
- ask serena for memories to get context about the project.  also ask serena to write memories to document the changes that are made to the project.
- use context7 to get up to date documentation
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
