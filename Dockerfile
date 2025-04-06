FROM ubuntu:20.04

# Cài đặt các phụ thuộc
RUN apt-get update && apt-get install -y \
    wget curl unzip git sudo \
    proot pulseaudio \
    tightvncserver novnc websockify \
    python3 xterm \
    && apt-get clean

# Tạo thư mục cho Android 10 x86
RUN mkdir -p /root/android-fs && cd /root/android-fs \
    && wget https://github.com/android-x86/android-x86/releases/download/10.0-r2/android-x86_64-10.0-r2.iso \
    && mkdir /root/android-fs/iso \
    && mount -o loop android-x86_64-10.0-r2.iso /root/android-fs/iso

# Cài mật khẩu cho VNC
RUN echo "password" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# Tạo file script để chạy VNC và Android 10
RUN echo '#!/bin/bash\n\
# Start VNC server để hiển thị Android UI\n\
vncserver :1 -geometry 1080x1920 -depth 24\n\
\n\
# Dùng noVNC để expose VNC qua web\n\
/root/utils/launch.sh --vnc localhost:5901 --listen 8080 &\n\
\n\
# Start Android x86 rootfs với proot (không qua XFCE, chạy Android 10 trực tiếp)\n\
cd /root/android-fs\n\
proot -S . /bin/bash -c "DISPLAY=:1 /usr/bin/start-android"\n' > /start.sh

RUN chmod +x /start.sh

# Mở cổng 8080 để truy cập noVNC
EXPOSE 8080

# Chạy script khi container khởi động
CMD ["/start.sh"]
