#!/bin/bash

# CogNexus 一键安装脚本
# 用法: chmod +x setup.sh && ./setup.sh

set -e

echo "🌐 CogNexus 安装脚本"
echo "===================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 未安装${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python3 已安装${NC}"

# 创建虚拟环境
echo ""
echo "📦 配置 Python 环境..."

if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}✓ 虚拟环境已创建${NC}"
else
    echo -e "${YELLOW}! 虚拟环境已存在，跳过${NC}"
fi

source venv/bin/activate

# 安装依赖
echo ""
echo "📚 安装依赖..."
pip install -q --upgrade pip
pip install -q -r requirements.txt
echo -e "${GREEN}✓ 依赖已安装${NC}"

# 配置环境变量
echo ""
echo "⚙️  配置环境变量..."

if [ ! -f ".env" ]; then
    cp .env.example .env
    
    # 生成随机 JWT 密钥
    JWT_SECRET=$(openssl rand -hex 32)
    
    # 替换密钥
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/your-random-secret-key-change-this-immediately/$JWT_SECRET/" .env
    else
        sed -i "s/your-random-secret-key-change-this-immediately/$JWT_SECRET/" .env
    fi
    
    echo -e "${GREEN}✓ .env 已创建${NC}"
    echo -e "${YELLOW}  JWT 密钥已自动生成${NC}"
else
    echo -e "${YELLOW}! .env 已存在，跳过${NC}"
fi

# 创建数据目录
mkdir -p data logs

# 验证
echo ""
echo "🔍 验证安装..."

python3 -c "
import sys
sys.path.insert(0, 'api')
from main import app
print('✓ FastAPI 应用加载成功')
"

echo ""
echo "================"
echo -e "${GREEN}🎉 安装完成！${NC}"
echo ""
echo "启动服务:"
echo "  ./start.sh"
echo ""
echo "访问:"
echo "  http://localhost:8080"
echo ""
