#!/bin/bash
# Q6：用 dpkg 的非 root 选项把 aim-sentry-tools 安装到 sysroot，并运行安装产物。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

sysroot=$output/sysroot
mkdir -p "$sysroot/var/lib/dpkg/updates" "$sysroot/var/lib/dpkg/info"
[ -e "$sysroot/var/lib/dpkg/status" ] || : > "$sysroot/var/lib/dpkg/status"
dpkg --root="$sysroot" --force-not-root --log=/dev/null -i "$input/aim-sentry-tools.deb"
"$sysroot/usr/bin/aim-sentry-info" > "$output/tool-output.txt"
