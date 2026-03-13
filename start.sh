#!/bin/bash

# Hub 启动脚本
# 用法: ./start.sh [port]

PORT=${1:-8080}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

# 激活虚拟环境（如果存在）
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# 加载环境变量
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo "🌐 启动 Hub..."
echo "   端口: $PORT"
echo "   访问: http://localhost:$PORT"
echo ""

python -m uvicorn api.main:app --host 0.0.0.0 --port $PORT
