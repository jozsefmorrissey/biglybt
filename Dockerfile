# ------------------------------------------------------------------------------
# Pull base image
FROM fullaxx/ubuntu-desktop
MAINTAINER Brett Kuskie <fullaxx@gmail.com>

# ------------------------------------------------------------------------------
# Set environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C

# ------------------------------------------------------------------------------
# Install prerequisites (openjdk,openvpn) and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libswt-gtk-3-jni \
      libwebkitgtk-3.0-0 \
      openjdk-11-jre-headless \
      openvpn \
      tree \
      gnupg && \
    sed -e 's/^assistive_technologies/#assistive_technologies/' \
      -i /etc/java-11-openjdk/accessibility.properties && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*


# ------------------------------------------------------------------------------
# Install BiglyBT
RUN wget -q https://files.biglybt.com/installer/BiglyBT_Installer.sh \
      -O /app/BiglyBT_Installer.sh && chmod +x /app/BiglyBT_Installer.sh && \
    USER="root" app_java_home="/usr/lib/jvm/java-11-openjdk-amd64/" /app/BiglyBT_Installer.sh -q && \
    rm /app/BiglyBT_Installer.sh

# ------------------------------------------------------------------------------
# Install Sonarr
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0xA236C58F409091A18ACA53CBEBFF6B99D9B78493 && \
    echo "deb http://apt.sonarr.tv/ master main" | sudo tee /etc/apt/sources.list.d/sonarr.list && \
    sudo apt update && \
    sudo apt install -y nzbdrone


# ------------------------------------------------------------------------------
# Provide default BiglyBT config
COPY conf/biglybt.config /usr/share/biglybt/biglybt.config.default

# ------------------------------------------------------------------------------
# Install startup scripts
COPY app/*.sh /app/

# ------------------------------------------------------------------------------
# Identify Volumes
VOLUME /in
VOLUME /out

# ------------------------------------------------------------------------------
# Expose ports
EXPOSE 5901

# ------------------------------------------------------------------------------
# Define default command
CMD ["/app/app.sh"]
