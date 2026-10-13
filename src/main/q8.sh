#!/bin/bash
# Q8：repair 时识别并停止采集器、修复 HTTP 服务；cleanup 时停止修复后的服务。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

action=${3:-repair}

# 判断进程是否仍在运行（僵尸进程视为已结束）。
alive() {
    ps -o stat= -p "$1" 2>/dev/null | grep -qv '^Z'
}

# 对指定 PID 发送 SIGTERM 并等待其结束。
stop_pid() {
    local pid=$1 attempt
    kill "$pid" 2>/dev/null || true
    for attempt in $(seq 1 50); do
        if ! alive "$pid"; then
            return 0
        fi
        sleep 0.1
    done
    printf '进程 %s 未在预期时间内退出\n' "$pid" >&2
    return 1
}

case "$action" in
    repair)
        # shellcheck source=/dev/null
        source "$input/process.env"
        user=$(ps -o user= -p "$TARGET_PID")
        state=$(ps -o stat= -p "$TARGET_PID")
        command_line=$(ps -o args= -p "$TARGET_PID")
        {
            printf 'pid=%s\n' "$TARGET_PID"
            printf 'user=%s\n' "$user"
            printf 'state=%s\n' "$state"
            printf 'command=%s\n' "$command_line"
        } > "$output/process.txt"
        grep -F "TICK $TARGET_TOKEN " "$WORKER_LOG" > "$output/collector-sample.log" || true
        stop_pid "$TARGET_PID"
        stop_pid "$SERVICE_PID"
        printf 'bind=127.0.0.1\nport=%s\nroute=%s\n' "$TARGET_PORT" "/status" > "$output/server.conf"
        bash "$START_TOOL" "$output/server.conf" "$output/service"
        for _ in $(seq 1 80); do
            if body=$(curl -s --noproxy '*' --max-time 2 "http://127.0.0.1:$TARGET_PORT/status" 2>/dev/null) \
                && [ "$body" = "SENTRY READY" ]; then
                break
            fi
            sleep 0.1
        done
        status=$(curl -s --noproxy '*' -o "$output/http-body.txt" -w '%{http_code}' "http://127.0.0.1:$TARGET_PORT/status")
        printf '%s\n' "$status" > "$output/http-status.txt"
        ;;
    cleanup)
        if [ -f "$output/service/pid" ]; then
            service_pid=$(cat "$output/service/pid")
            stop_pid "$service_pid"
        fi
        ;;
    *)
        printf '未知动作：%s\n' "$action" >&2
        exit 2
        ;;
esac
