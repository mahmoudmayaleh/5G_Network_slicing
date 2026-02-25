FROM baseimage:nova

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gnuradio \
    python3 \
    python3-numpy \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY flowgraphs/ /app/

CMD ["python3", "/app/multi_ue_scenario.py"]

