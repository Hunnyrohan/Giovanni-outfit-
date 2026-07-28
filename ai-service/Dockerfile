# StyleSense AI - AI Service
# CPU-friendly base image. For real GPU-backed inference, swap the base
# image for an official CUDA image (e.g. nvidia/cuda:12.4.1-runtime-ubuntu22.04)
# and install a CUDA-enabled torch build - not needed while providers are mocked.
FROM python:3.11-slim

WORKDIR /app

# System dependencies required by opencv-python at runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p uploads outputs

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
