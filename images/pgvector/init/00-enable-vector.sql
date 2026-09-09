-- 示例初始化脚本 - 启用 pgvector 扩展
-- 此脚本在 PostgreSQL 首次启动时自动执行

CREATE EXTENSION IF NOT EXISTS vector;

-- 创建示例表 (可选)
-- CREATE TABLE IF NOT EXISTS documents (
--     id SERIAL PRIMARY KEY,
--     content TEXT,
--     embedding VECTOR(1536)
-- );
