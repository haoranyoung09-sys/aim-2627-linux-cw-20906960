#!/bin/bash
# Bonus：start 时创建分离的 tmux 会话和采集器；stop 时正常停止采集器并结束会话。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

action=${3:-start}

alive() {
    ps -o stat= -p "$1" 2>/dev/null | grep -qv '^Z'
}

# shellcheck source=/dev/null
source "$input/bonus.env"
case "$action" in
    start)
        tmux -L "$TMUX_SOCKET" new-session -d -s "$SESSION" \
            "python3 '$WORKER_TOOL' --token '$TOKEN' --log '$output/bonus.log'"
        ;;
    stop)
        tmux -L "$TMUX_SOCKET" kill-session -t "$SESSION" 2>/dev/null || true
        # 保险：若采集器仍在运行，按日志中的 PID 正常终止。
        if [ -f "$output/bonus.log" ]; then
            worker_pid=$(awk -v token="$TOKEN" '$1 == "START" && $2 == token {split($3, part, "="); print part[2]}' "$output/bonus.log" | head -n 1)
            if [ -n "$worker_pid" ] && alive "$worker_pid"; then
                kill "$worker_pid" 2>/dev/null || true
            fi
        fi
        ;;
    *)
        printf '未知动作：%s\n' "$action" >&2
        exit 2
        ;;
esac
