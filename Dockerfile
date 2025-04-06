FROM ubuntu:20.04

# Cài đặt các phụ thuộc và cấu hình tzdata để tránh yêu cầu nhập múi giờ
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    tzdata \
    wget curl unzip git sudo \
    proot pulseaudio \
    tightvncserver novnc websockify \
    python3 xterm \
    && apt-get clean

# Cấu hình múi giờ mặc định (ví dụ: UTC)
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Tạo thư mục cho Android 9.0 x86
RUN mkdir -p /root/android-fs && cd /root/android-fs \
    && wget https://www.fosshub.com/Android-x86.html?dwl=android-x86-9.0-r2.iso -O android-x86-9.0-r2.iso \
    && mkdir /root/android-fs/iso \
    && mount -o loop android-x86-9.0-r2.iso /root/android-fs/iso

# Cài mật khẩu cho VNC
RUN echo "password" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# Tạo file script để chạy VNC và Android 9.0
RUN echo '#!/bin/bash\n\
# Start VNC server để hiển thị Android UI\n\
vncserver :1 -geometry 1080x1920 -depth 24\n\
\n\
# Dùng noVNC để expose VNC qua web\n\
/root/utils/launch.sh --vnc localhost:5901 --listen 8080 &\n\
\n\
# Start Android x86 rootfs với proot (không qua XFCE, chạy Android 9.0 trực tiếp)\n\
cd /root/android-fs\n\
proot -S . /bin/bash -c "DISPLAY=:1 /usr/bin/start-android"\n' > /start.sh

RUN chmod +x /start.sh

# Mở cổng 8080 để truy cập noVNC
EXPOSE 8080

# Chạy script khi container khởi động
CMD ["/start.sh"]
