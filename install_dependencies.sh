#!/usr/bin/zsh
source /home/jenson/miniforge3/bin/activate
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY
pip config set global.index-url https://mirror.sjtu.edu.cn/pypi/web/simple
python -m pip install -r requirements_versions.txt
python -m pip install tensorrt huggingface
python -m pip install -U xformers --index-url https://download.pytorch.org/whl/cu124
mamba clean --all -y
python -m pip cache purge