# Use RunPod PyTorch base image with Jupyter already set up
FROM runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04

# Configure environment variables
ARG PYTHON_VERSION=3.10
ENV DEBIAN_FRONTEND=noninteractive
ENV MUJOCO_GL="egl"
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

# Install dependencies and set up Python in a single layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git \
    libglib2.0-0 libgl1-mesa-glx libegl1-mesa ffmpeg \
    speech-dispatcher libgeos-dev \
    python${PYTHON_VERSION}-dev python${PYTHON_VERSION}-venv \
    curl wget vim htop screen tmux \
    && rm -f /usr/bin/python && ln -s /usr/bin/python${PYTHON_VERSION} /usr/bin/python \
    && python -m venv /opt/venv \
    && rm -f /usr/local/bin/jupyter* \
    && python3.11 -m pip install jupyterlab ipywidgets \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && echo "source /opt/venv/bin/activate" >> /root/.bashrc

# Clone LeRobot repository and install
RUN git clone https://github.com/huggingface/lerobot.git /lerobot

# Set working directory
WORKDIR /lerobot

# Install LeRobot with all dependencies
RUN /opt/venv/bin/pip install --upgrade --no-cache-dir pip \
    && /opt/venv/bin/pip install --no-cache-dir ".[test, aloha, xarm, pusht, dynamixel]"

# Create necessary directories for your data
RUN mkdir -p /workspace/data /workspace/models /workspace/logs /workspace/outputs

# Set proper permissions
RUN chmod -R 755 /workspace && chmod -R 755 /lerobot

# Expose JupyterLab port
EXPOSE 8888

# Set working directory back to workspace for user convenience
WORKDIR /workspace