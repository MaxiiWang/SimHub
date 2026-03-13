# Hub 安装指南

本指南帮助你从零开始部署 Hub 分布式认知市场。

## 系统要求

- **操作系统**: Linux / macOS / Windows (WSL2)
- **Python**: 3.10+
- **内存**: 512MB+
- **磁盘**: 1GB+

## 安装步骤

### 1. 克隆项目

```bash
git clone https://github.com/MaxiiWang/Hub.git
cd Hub
```

### 2. 创建虚拟环境

```bash
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# 或 venv\Scripts\activate  # Windows
```

### 3. 安装依赖

```bash
pip install -r requirements.txt
```

### 4. 配置环境变量

```bash
cp .env.example .env
```

编辑 `.env` 文件：

```bash
# 服务配置
HUB_HOST=0.0.0.0
HUB_PORT=8080

# JWT 密钥（必须修改！）
JWT_SECRET=your-random-secret-key-at-least-32-chars

# 数据库
DATABASE_PATH=data/hub.db

# 新用户初始积分
INITIAL_ATP=100
```

**重要**：请生成随机的 JWT_SECRET：

```bash
openssl rand -hex 32
```

### 5. 初始化数据库

首次启动会自动创建数据库和表结构。

### 6. 启动服务

```bash
chmod +x start.sh
./start.sh
```

或手动启动：

```bash
cd api
python -m uvicorn main:app --host 0.0.0.0 --port 8080
```

### 7. 验证安装

```bash
# 检查 API
curl http://localhost:8080/api/stats

# 检查页面
curl -I http://localhost:8080/
```

访问 `http://localhost:8080` 查看首页。

---

## 生产环境部署

### 使用 systemd（推荐）

创建服务文件 `/etc/systemd/system/hub.service`：

```ini
[Unit]
Description=Hub - Distributed Cognitive Market
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/path/to/Hub
Environment="PATH=/path/to/Hub/venv/bin"
ExecStart=/path/to/Hub/venv/bin/python -m uvicorn api.main:app --host 127.0.0.1 --port 8080
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable hub
sudo systemctl start hub
```

### Nginx 反向代理

```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### HTTPS 证书（Let's Encrypt）

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

---

## 与 SimWorld 集成

### 发布 Agent

1. 确保 SimWorld 可视化 API 运行中
2. 在 Hub 注册账号
3. 进入仪表盘 → 发布 Agent
4. 输入 Agent URL（如 `http://your-server:8000`）
5. Hub 会自动探测 Agent 信息

### 添加 Token

1. 在 SimWorld 生成 Token：
   ```bash
   ./brain visual --duration 15d --scope qa_public --count 10
   ```
2. 在 Hub Agent 管理中添加 Token
3. Token 会自动验证有效性

---

## 故障排除

### 端口被占用

```bash
# 查找占用端口的进程
lsof -i :8080

# 或使用其他端口
HUB_PORT=8081 ./start.sh
```

### 数据库错误

```bash
# 检查数据库文件
ls -la data/

# 重建数据库（会丢失数据！）
rm data/hub.db
./start.sh
```

### JWT 认证失败

确保 `.env` 中的 `JWT_SECRET` 已正确设置且足够长（至少 32 字符）。

---

## 升级指南

```bash
cd Hub
git pull origin main
pip install -r requirements.txt
sudo systemctl restart hub  # 如果使用 systemd
```

---

## 下一步

1. 注册第一个用户
2. 部署 [SimWorld](https://github.com/MaxiiWang/SimWorld) 作为你的 Agent
3. 在 Hub 发布你的 Agent
4. 开始交易！
