-- 合规写法：卡号只存掩码与令牌，鉴别信息存不可逆哈希
CREATE TABLE t_card_bind (
  id            BIGINT PRIMARY KEY,
  user_id       BIGINT NOT NULL,
  card_mask     VARCHAR(32) NOT NULL,
  card_token    VARCHAR(128) NOT NULL,
  bank_code     VARCHAR(16),
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE t_user (
  id            BIGINT PRIMARY KEY,
  username      VARCHAR(64) NOT NULL,
  password      VARCHAR(255) NOT NULL COMMENT 'bcrypt hash, cost=12',
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_card_bind_user ON t_card_bind (user_id);
