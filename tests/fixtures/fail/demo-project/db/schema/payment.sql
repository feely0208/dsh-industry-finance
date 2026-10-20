-- 支付网关表结构（示例）
CREATE TABLE t_card_bind (
  id            BIGINT PRIMARY KEY,
  user_id       BIGINT NOT NULL,
  bank_code     VARCHAR(16),
  card_no       VARCHAR(32),
  cvv2          VARCHAR(4),
  track2        VARCHAR(104),
  card_pwd      VARCHAR(64),
  expire_month  VARCHAR(2),
  expire_year   VARCHAR(4),
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE t_user (
  id            BIGINT PRIMARY KEY,
  username      VARCHAR(64) NOT NULL,
  password      VARCHAR(32) NOT NULL,
  phone         VARCHAR(20),
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_card_bind_user ON t_card_bind (user_id);
