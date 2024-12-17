#!/usr/bin/zsh

# Default values
CUDA_VISIBLE_DEVICES="0" # Set default GPU to 0
EXPECTED_PYTHON_PATH="/home/jenson/miniforge3/bin/python"
PORT=""
ENABLE_PLUGIN_INSTALL=false # Flag to track plugin installation option

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
        --enable-plugin-install)
            ENABLE_PLUGIN_INSTALL=true
            shift
            ;;
        *)
            echo "Invalid option: $1"
            exit 1
            ;;
    esac
done

# Check if required option --port is provided
if [ -z "$PORT" ]; then
    echo "Error: Required option --port is missing."
    exit 1
fi

# Set CUDA_VISIBLE_DEVICES
export CUDA_VISIBLE_DEVICES

source /home/jenson/miniforge3/bin/activate

# Check python path
current_python_path=$(which python)
if [ "$current_python_path" != "$EXPECTED_PYTHON_PATH" ]; then
    echo "Error: Unexpected python path. Aborting."
    exit 1
fi

# Set proxy
export http_proxy="http://host.docker.internal:9910";
export https_proxy="http://host.docker.internal:9910";
export HTTP_PROXY="http://host.docker.internal:9910";
export HTTPS_PROXY="http://host.docker.internal:9910";
export ALL_PROXY="http://host.docker.internal:9910";
echo "Using proxy ${http_proxy}"

# Set TCMalloc
export TCMALLOC="$(PATH=/usr/sbin:$PATH ldconfig -p | grep -Po "libtcmalloc(_minimal|)\.so\.\d" | head -n 1)"
export LD_LIBRARY_PATH="/home/jenson/miniforge3/lib/python3.10/site-packages/tensorrt_libs:$LD_LIBRARY_PATH"
# Use TCMalloc
echo "Using TCMalloc ${TCMALLOC}"
export LD_PRELOAD="${TCMALLOC}"

# Launch command with conditional insecure extension access flag
if $ENABLE_PLUGIN_INSTALL; then
    python launch.py --listen --enable-insecure-extension-access --xformers --port $PORT
else
    python launch.py --listen --xformers --port $PORT
fi
