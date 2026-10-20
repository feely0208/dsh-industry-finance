# pay-gateway-clean

反例样本：与 demo-project 同类业务，但按支付敏感信息与留存要求写。

- 卡号只存掩码与令牌，磁道/CVN 不落库
- 口令用 bcrypt 哈希
- 卡号展示前走 `mask` / `substring` 脱敏
- 交易记录留存 3650 天（十年）
- 客户端只用 Keychain / EncryptedSharedPreferences 存 token
- 传输全程 TLS
- 测试环境连脱敏副本
