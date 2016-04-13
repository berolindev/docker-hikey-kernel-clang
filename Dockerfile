FROM openmandriva/cooker
MAINTAINER Bernhard Rosenkraenzer <bero@linaro.org>

WORKDIR /
ENV HOSTNAME kernelbuild

RUN useradd -u 1000 -m -g users -G wheel kernelbuild
RUN echo -n root:kernelbuild |chpasswd
RUN wget http://people.linaro.org/~bernhard.rosenkranzer/cross-aarch64-linux-gnu-binutils-2.26-2-omv2015.0.x86_64.rpm
RUN urpmi --auto --no-verify-rpm --auto-update
RUN urpmi --auto --no-verify-rpm sudo clang make 'pkgconfig(ncursesw)' bc vim-enhanced git-core cross-aarch64-linux-gnu-binutils-2.26-2-omv2015.0.x86_64.rpm
# Unbreak su inside docker
RUN sed -i -e '/\*.*nice/d' /etc/security/limits.conf
# Make sudo passwordless
RUN sed -i -e 's,^%wheel,#%wheel,;s,^# %wheel,%wheel,' /etc/sudoers

USER kernelbuild
WORKDIR /home/kernelbuild
RUN git clone -b android-hikey-linaro-4.4-clang --depth 1 git://android-git.linaro.org/kernel/hikey-clang.git
RUN echo 'cat <<EOF' >>.bashrc
RUN echo 'To build the kernel, use' >>.bashrc
RUN echo 'cd hikey-clang' >>.bashrc
RUN echo 'make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- CC=clang HOSTCC=clang hikey_defconfig' >>.bashrc
RUN echo 'make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- CC=clang HOSTCC=clang -j`getconf _NPROCESSORS_ONLN`' >>.bashrc
RUN echo 'EOF' >>.bashrc

CMD ["/bin/bash", "-l"]
