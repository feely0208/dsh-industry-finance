# pay-gateway-demo

一个用于演示的支付网关工程（Java + Kotlin + MySQL）。

- `db/schema/payment.sql` —— 绑卡与用户表结构
- `src/main/java/.../LoginService.java` —— 登录鉴权
- `src/main/resources/templates/` —— 收银台页面模板
- `config/retention.yml` —— 数据留存策略
- `android/.../CardStore.kt` —— Android 客户端本地缓存
- `src/main/resources/application*.yml|properties` —— 环境配置

```bash
mvn -q spring-boot:run
```
