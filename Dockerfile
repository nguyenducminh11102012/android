# Sử dụng image Ubuntu làm base
FROM ubuntu:20.04

# Thiết lập môi trường để không hỏi múi giờ khi cài đặt
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Cài đặt các dependencies
RUN apt-get update && apt-get install -y \
    curl \
    qemu-system-x86 \
    novnc \
    websockify \
    gunzip \
    && rm -rf /var/lib/apt/lists/*

# Tải và giải nén Windows 7 image
WORKDIR /root
RUN curl -L -o win7.gz https://ia902208.us.archive.org/35/items/w7-qcow2/win7lite.img.gz \
    && echo "Wait..." \
    && gunzip win7.gz \
    && mv win7 win7.img

# Chạy QEMU trong một background process
CMD /bin/bash -c "qemu-system-x86_64 -vnc :0 -hda win7.img -smp cores=2 -m 1024M -machine usb=on -device usb-tablet > /dev/null 2>&1 & \
    websockify --web /usr/share/novnc 8080 localhost:5900"
