#!/usr/bin/zsh
source /home/jenson/miniforge3/bin/activate
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
mamba install -y GitPython einops fastapi gradio inflection jsonmerge kornia lark numpy omegaconf open-clip-torch piexif psutil requests safetensors scikit-image timm torchdiffeq
python -m pip install -y accelerate basicsr blendmodes clean-fid gfpgan pytorch_lightning realesrgan resize-right tomesd torchsde
mamba install -y -c huggingface transformers
mamba install -y xformers -c xformers
mamba clean --all -y
python -m pip cache purge