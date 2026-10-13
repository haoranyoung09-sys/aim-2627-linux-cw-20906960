#!/bin/bash
# Q3：复制脚本与配置、备份配置、归档草稿、清理临时目录并设置精确权限。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

ws=$output/sentry_ws
rm -rf "$ws"
mkdir -p "$ws/scripts" "$ws/config" "$ws/backup" "$ws/archive"
cp "$input/hello.sh" "$ws/scripts/hello.sh"
cp "$input/robot.conf" "$ws/config/robot.conf"
cp "$input/robot.conf" "$ws/backup/robot.conf"
cp "$input/draft.conf" "$ws/archive/draft.conf.old"
chmod 750 "$ws/scripts/hello.sh"
chmod 640 "$ws/config/robot.conf"
"$ws/scripts/hello.sh" > "$output/hello-output.txt"
