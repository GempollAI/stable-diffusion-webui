#!/usr/bin/zsh

# Default values
CUDA_VISIBLE_DEVICES=""
EXPECTED_PYTHON_PATH="/home/ai/mambaforge/envs/webui/bin/python"
PORT=""

# Function to validate if a string is an integer
is_valid_integer() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --gpu)
            CUDA_VISIBLE_DEVICES="$2"
            shift 2
            ;;
        --port)
            if is_valid_integer "$2"; then
                PORT="$2"
                shift 2
            else
                echo "Error: Invalid port number specified."
                exit 1
            fi
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
done

# Check if required options are provided
if [ -z "$CUDA_VISIBLE_DEVICES" ] || [ -z "$PORT" ]; then
    echo "Error: Required options --gpu and --port are missing."
    exit 1
fi

# Set CUDA_VISIBLE_DEVICES
export CUDA_VISIBLE_DEVICES

source ~/mambaforge/bin/activate webui

# Check python path
current_python_path=$(which python)
if [ "$current_python_path" != "$EXPECTED_PYTHON_PATH" ]; then
    echo "Error: Unexpected python path. Aborting."
    exit 1
fi

# Set proxy
export http_proxy="http://localhost:9910" https_proxy="http://localhost:9910" HTTP_PROXY="http://localhost:9910" HTTPS_PROXY="http://localhost:9910"
echo "Using proxy ${http_proxy}"

# Set TCMalloc 
export TCMALLOC="$(PATH=/usr/sbin:$PATH ldconfig -p | grep -Po "libtcmalloc(_minimal|)\.so\.\d" | head -n 1)"
export LD_LIBRARY_PATH="/home/ai/mambaforge/envs/webui/lib/python3.10/site-packages/tensorrt_libs:$LD_LIBRARY_PATH"
# Use TCMalloc
echo "Using TCMalloc ${TCMALLOC}"
export LD_PRELOAD="${TCMALLOC}"

python launch.py --listen --enable-insecure-extension-access --xformers --port $PORT
