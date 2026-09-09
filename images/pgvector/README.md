# phpgao/pgvector

PostgreSQL + pgvector 向量数据库镜像，专为 AI Agent 场景设计。

## 背景

pgvector 是 PostgreSQL 的开源向量相似度搜索扩展，支持精确和近似最近邻搜索。相比专用向量数据库，它具有以下优势：

- **ACID 兼容**: 完整的事务支持，保证数据一致性
- **SQL 接口**: 使用标准 SQL 查询，学习成本低
- **生态成熟**: 复用 PostgreSQL 的工具链和连接器
- **混合查询**: 可在同一查询中结合关系数据和向量搜索

## 镜像信息

| 属性 | 值 |
|------|-----|
| 基础镜像 | postgres:18-alpine |
| PostgreSQL 版本 | 18.x |
| pgvector 版本 | 0.8.x |
| 端口 | 5432 |

## 快速开始

### Docker Run

```bash
# 启动容器
docker run -d \
  --name pgvector \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data \
  ghcr.io/phpgao/pgvector:latest

# 等待启动完成，连接数据库
docker exec -it pgvector psql -U postgres
```

### Docker Compose

```yaml
services:
  pgvector:
    image: ghcr.io/phpgao/pgvector:latest
    environment:
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: ai_agent
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./init:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"

volumes:
  pgdata:
```

### SQL 示例

```sql
-- 启用向量扩展
CREATE EXTENSION IF NOT EXISTS vector;

-- 创建向量表 (1536 维，适用于 OpenAI embeddings)
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding VECTOR(1536)
);

-- 插入示例数据
INSERT INTO documents (content, embedding) VALUES
('Hello world', '[0.1, 0.2, 0.3, ...]');

-- 向量相似度搜索 (余弦距离)
SELECT content, 1 - (embedding <=> '[0.1, 0.2, 0.3, ...]') AS similarity
FROM documents
ORDER BY embedding <=> '[0.1, 0.2, 0.3, ...]'
LIMIT 5;
```

## 初始化脚本

将 `.sql` 文件放入 `init/` 目录，容器首次启动时自动执行：

```bash
docker run -d \
  -v ./my-init.sql:/docker-entrypoint-initdb.d/my-init.sql \
  -e POSTGRES_PASSWORD=secret \
  ghcr.io/phpgao/pgvector:latest
```

## 向量索引

为加速查询，可创建 HNSW 或 IVFFlat 索引：

```sql
-- HNSW 索引 (推荐，查询速度快)
CREATE INDEX ON documents USING hnsw (embedding vector_cosine_ops);

-- IVFFlat 索引 (适合大数据集)
CREATE INDEX ON documents USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
```

## 距离运算符

| 运算符 | 含义 | 说明 |
|--------|------|------|
| `<->` | 欧几里得距离 | L2 距离 |
| `<#>` | 负内积 | 用于归一化向量 |
| `<=>` | 余弦距离 | 1 - 余弦相似度 |

## 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `POSTGRES_PASSWORD` | postgres 用户密码 | 必填 |
| `POSTGRES_USER` | 用户名 | postgres |
| `POSTGRES_DB` | 默认数据库 | postgres |
| `PGDATA` | 数据目录 | /var/lib/postgresql/data |

## 构建说明

镜像基于 `postgres:18-alpine`，其 PostgreSQL 以 **LLVM 21** 编译。pgvector 在 `make` 时会通过 PGXS 生成 `.bc` 位码（调用 `clang-21`），`make install` 还需 `llvm21` 的 `llvm-lto` 完成 thinlink。因此编译依赖必须安装 **`clang21` + `llvm21`**（默认 `clang` 为 22 版，位码不兼容会导致 thinlink 失败）。

