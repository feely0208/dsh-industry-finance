# 金融行业专项检查（dsh-industry-finance）

**什么时候用**：项目涉及银行、支付、收单、消金、保险、证券业务，想知道「支付敏感信息有没有被落库、卡号有没有明文展示、反洗钱的十年留存够不够、测试环境会不会连到生产」。用户会说：「CVV 能不能存」「卡号展示怎么脱敏」「反洗钱要留几年」「测试库连的是不是生产」「支付敏感信息能不能写日志」。

## 怎么用

```bash
<cli 路径> --root <项目目录>       # 检查一个项目
<cli 路径> --demo                  # 用内置样本看检出效果
<cli 路径> --list-rules            # 列出判据与出处
<cli 路径> --html finance.html     # 出 HTML 报告（可截图存档）
```

## 它查什么

7 条判据，全部对准金融行业「支付敏感信息 + 十年留存 + 传输/环境隔离」这条线：

| 规则 | 级别 | 查什么 |
|---|---|---|
| `FIN-PAY-SENSITIVE-RETENTION` | 🔴 高 | 字段/模型/配置里出现 `cvv`、`cvn`、`track1/2`、`magnetic_stripe`、`card_pwd`、`pay_pwd` —— 支付敏感信息不应留存 |
| `FIN-AUTH-PLAINTEXT` | 🔴 高 | 口令/PIN/短信验证码明文落库（`password varchar`）、写日志、直接打印 |
| `FIN-PAN-DISPLAY` | 🟡 中 | 模板/日志里 `${cardNo}`、`{{cardNo}}` 直接插值，没走 mask/substring |
| `FIN-AMC-10Y` | 🔴 高 | 留存配置 < 3650 天、`INTERVAL <10 YEAR/DAY`、分区清理短于十年 |
| `FIN-CLIENT-LOCAL-STORE` | 🔴 高 | 客户端把卡号/CVV/口令存进 SharedPreferences/MMKV/UserDefaults/localStorage |
| `FIN-TRANSPORT-PLAINTEXT` | 🟡 中 | `useSSL=false`、`sslMode=DISABLED`、`verifyServerCertificate=false`、支付/鉴权链路 `http://`、`ftp://`、`TLSv1.0` |
| `FIN-TESTENV-PROD-DATA` | 🟡 中 | `application-test/dev/uat/sit` 里 jdbc/redis 指向 prod/prd/生产，或 `profiles.active=prod`，且同文件没有脱敏开关 |

高风险规则都配了 `when`（例如支付敏感信息只在项目里出现 card/支付 相关代码时才跑），
不适用的项目会进 `notApplicable`，**不报也不假装查过**。

## 怎么读结果

1. **先看扫描范围和「检查规则 N/M 条」**。若 M < 7，说明有规则因 `when` 不适用没跑，报告里会写明是哪几条。
2. **命中 ≠ 违规**。它是提示你确认，不是下结论：
   - `FIN-AMC-10Y`：命中 `retentionDays: 1825` 这类值，先确认这条配置是不是交易/客户主数据；会话、缓存、日志、风控快照可以短留存，把这类短配置改成独立命名并加注释即可。
   - `FIN-PAY-SENSITIVE-RETENTION`：命中字段名时，先确认它是不是「只透传、不落库」；是的话在命名/注释里写明。
   - `FIN-TESTENV-PROD-DATA`：如果测试环境连的确实是脱敏副本，把脱敏开关（`desensitize` / `脱敏`）显式写进同一份配置，规则识别到后就不再报。
3. **不要把它当合规审计报告**。它只做静态线索，不含数据流分析、不含人工访谈与制度检查。

## 不要做什么

- 不要因为 `FIN-AUTH-PLAINTEXT` 命中就盲改列类型 —— 先看这一列是否真的在存口令，还是历史遗留字段
- 不要为了「全绿」把扫描范围缩小到某个子目录
- 不要把「0 命中」当成合规证明 —— 它只是没发现静态线索

## 相关插件

- `dsh-data-scan` —— 通用敏感数据（身份证/手机号/银行卡号）扫描，本插件更关注支付 C3 与金融条款
- `dsh-data-lifecycle` —— 通用数据留存策略，本插件补的是反洗钱「十年」这条金融专线
- `dsh-cn-log-retention` —— 网络日志六个月的留存（与十年交易记录留存是两条不同的线）
