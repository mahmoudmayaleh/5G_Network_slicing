# ---- starlab_node:20-compat ----
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Etc/UTC

# 复刻旧镜像的 apt 优化配置
RUN set -eux; \
    echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d; chmod +x /usr/sbin/policy-rc.d; \
    dpkg-divert --local --rename --add /sbin/initctl; \
    cp -a /usr/sbin/policy-rc.d /sbin/initctl; \
    sed -i 's/^exit.*/exit 0/' /sbin/initctl; \
    echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup; \
    echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean; \
    echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true";' >> /etc/apt/apt.conf.d/docker-clean; \
    echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean; \
    echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages; \
    echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes; \
    echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests; \
    apt-get update; \
    # 系统工具 + 网络工具
    apt-get install -y --no-install-recommends \
        iproute2 iputils-ping net-tools traceroute tcpdump procps \
        ifupdown isc-dhcp-client \
        coreutils findutils grep sed tar gzip bzip2 xz-utils less vim \
        curl wget gnupg lsb-release ca-certificates \
        make gcc g++ build-essential cmake \
        python3 python3-pip \
        bird \
    ; \
    rm -rf /var/lib/apt/lists/*

# 为了兼容旧脚本，做些软链接
RUN ln -sf /usr/bin/python3 /usr/bin/python || true \
 && ln -sf /usr/bin/pip3 /usr/bin/pip || true

# systemd 标记
RUN mkdir -p /run/systemd && echo docker > /run/systemd/container

RUN mkdir -p /run/bird

# 默认命令与旧镜像一致
CMD ["ping", "www.baidu.com"]

