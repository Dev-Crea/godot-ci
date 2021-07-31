FROM ubuntu:focal

LABEL author="https://github.com/aBARICHELLO/godot-ci/graphs/contributors"

# SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_HOME="/lib/android-sdk/"
ENV PATH="${PATH}:${ANDROID_HOME}build-tools/:${ANDROID_HOME}platform-tools/:/opt/butler/bin"
ENV GODOT_VERSION="3.3.2"
ENV CMD_TOOL_VERSION="7583922"

COPY getbutler.sh /opt/butler/getbutler.sh

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20210119~20.04.1 \
    git=1:2.25.1-1ubuntu3.1 \
    git-lfs=2.9.2-1 \
    python3-openssl=19.0.0-1build1 \
    unzip=6.0-25ubuntu1 \
    wget=1.20.3-1ubuntu1 \
    zip=3.0-11build1 \
    openjdk-8-jdk-headless=8u292-b10-0ubuntu1~20.04 \
  && wget -q https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
  && wget -q https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
  && mkdir -p \
    ~/.cache \
    ~/.config/godot \
    ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
  && unzip Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
  && mv Godot_v${GODOT_VERSION}-stable_linux_headless.64 /usr/local/bin/godot \
  && unzip Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
  && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.stable \
  && bash /opt/butler/getbutler.sh \
  && /opt/butler/bin/butler -V \
  && wget -q https://dl.google.com/android/repository/commandlinetools-linux-${CMD_TOOL_VERSION}_latest.zip \
  && unzip commandlinetools-linux-${CMD_TOOL_VERSION}_latest.zip \
  && yes | ./cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" "build-tools;30.0.3" "platforms;android-29" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;21.4.7075529" \
  && keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 \
  && mv debug.keystore /root/debug.keystore \
  && godot -e -q \
  && echo 'export/android/adb = "/usr/bin/adb"' >> ~/.config/godot/editor_settings-3.tres \
  && echo 'export/android/jarsigner = "/usr/bin/jarsigner"' >> ~/.config/godot/editor_settings-3.tres \
  && echo 'export/android/debug_keystore = "/root/debug.keystore"' >> ~/.config/godot/editor_settings-3.tres \
  && echo 'export/android/debug_keystore_user = "androiddebugkey"' >> ~/.config/godot/editor_settings-3.tres \
  && echo 'export/android/debug_keystore_pass = "android"' >> ~/.config/godot/editor_settings-3.tres \
  && echo 'export/android/force_system_user = false' >> ~/.config/godot/editor_settings-2.tres \
  && echo 'export/android/timestamping_authority_url = ""' >> ~/.config/godot/editor_settings-3.tres \
  && echo 'export/android/android_sdk_path = "'${ANDROID_HOME}'"' >> ~/.config/godot/editor_settings-3.tres \
  && echo 'export/android/shutdown_adb_on_exit = true' >> ~/.config/godot/editor_settings-3.tres \
  && apt-get remove -y \
    wget \
    zip \
    unzip \
  && apt-get clean -y \
  && rm -rf \
    /var/lib/apt/lists/* \
    commandlinetools-linux-${CMD_TOOL_VERSION}_latest.zip \
    Godot_v${GODOT_VERSION}-stable_export_templates.tpz \
    Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip
