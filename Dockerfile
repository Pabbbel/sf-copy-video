FROM ashleykza/comfyui:cu128-py311-v0.3.76

# ============================================================
# aria2 для быстрого многопоточного скачивания моделей
# ============================================================
RUN apt-get update && apt-get install -y --no-install-recommends aria2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ============================================================
# Запекаем публичные ноды в образ (без дубликатов)
# ============================================================
RUN cd /ComfyUI/custom_nodes && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-WanVideoWrapper.git && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-KJNodes.git && \
    git clone --depth 1 https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-WanAnimatePreprocess.git && \
    git clone --depth 1 https://github.com/Fannovel16/comfyui_controlnet_aux.git && \
    git clone --depth 1 https://github.com/rgthree/rgthree-comfy.git && \
    git clone --depth 1 https://github.com/kijai/ComfyUI-segment-anything-2.git && \
    git clone --depth 1 https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git

# Устанавливаем pip-зависимости всех нод
RUN . /ComfyUI/venv/bin/activate && \
    for dir in /ComfyUI/custom_nodes/*/; do \
        if [ -f "${dir}requirements.txt" ]; then \
            echo "Installing deps for $(basename $dir)..." && \
            pip install -r "${dir}requirements.txt" --quiet; \
        fi; \
    done && \
    deactivate

# ============================================================
# Runtime-скрипт: приватные ноды + модели
# ============================================================
COPY custom_setup.sh /custom_setup.sh
RUN chmod +x /custom_setup.sh
RUN sed -i '/^# Start application manager/i # === Custom setup: private nodes + models ===\n/custom_setup.sh\n' /pre_start.sh
