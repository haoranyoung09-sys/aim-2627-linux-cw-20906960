#!/bin/bash
# Q2：建立 sentry_ws 工作区结构、空文件、启动脚本和配置文本。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

ws=$output/sentry_ws
mkdir -p "$ws/scripts" "$ws/config" "$ws/logs" "$ws/tmp"
: > "$ws/logs/.keep"
: > "$ws/tmp/scratch.txt"
cat > "$ws/scripts/hello.sh" <<'EOF'
#!/bin/bash
echo "Hello, AIM Linux!"
EOF
cat > "$ws/config/robot.conf" <<'EOF'
robot=sentry
mode=training
log_level=INFO
EOF
