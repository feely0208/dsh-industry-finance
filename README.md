# @deepwhale-cn/dsh-industry-finance

[![dshfind 收录](https://dshfind.com/api/badge/feely0208/dsh-industry-finance?lang=zh)](https://dshfind.com/zh/plugins/feely0208/dsh-industry-finance)

[![Listed on dsh-plugin.org](https://dsh-plugin.org/badges/listed.svg)](https://dsh-plugin.org/plugins/feely0208/dsh-industry-finance)

**金融行业专项检查**：装它之后，支付敏感信息、口令明文、卡号裸展示、留存不足十年、客户端乱存卡、明文传输、测试环境连生产 —— 这七类问题在代码里就能先筛一遍。

**关键词**：金融 · 支付 · 银行卡 · 反洗钱 · 金融数据安全 · 支付敏感信息 · 卡号脱敏 · 数据安全
**Keywords**: finance · payment security · PCI · cardholder data · AML retention · China financial data security

---

## 不装它会怎样

支付项目最怕的不是「有 bug」，而是**数据留下了不该留的东西**。

```sql
CREATE TABLE t_card_bind (
  card_no  VARCHAR(32),
  cvv2     VARCHAR(4),      -- 存了
  track2   VARCHAR(104),    -- 也存了
  card_pwd VARCHAR(64)      -- 还存了
);
```

开发觉得「方便排查」，跑起来也没报错。直到出事那天，监管问的是：

- 支付敏感信息（CVN/CVN2、磁道、卡密码）为什么会被**留存**？
- 口令为什么是**明文列**？
- 交易记录为什么只留了 **1825 天**？
- 线上事故复盘时，为什么测试库连的是**生产**？

这些问题的共同点是：**代码里的一个小配置，事后要用很高的代价解释**。

## 先说清楚它是什么、不是什么

**是**：一个**静态线索检查器**。它扫 `rules/` 里 7 条判据，把可疑的字段名、DDL、日志、模板插值、留存配置、传输配置、环境配置挑出来，附上**条款出处**，让你去确认。

**不是**：

- 不是合规审计。它没有数据流分析、不做接口画像、不做制度与流程核查。
- 不是「合规通过」的证明。0 命中只说明**没扫到静态线索**。
- 不是代码修改器。它只报位置，不改代码。
- 不是 PCI DSS 扫描器。它用的是中国金融行业规范与支付条例的条款。

## 它查什么

7 条判据，全部围绕金融行业「支付敏感信息 + 十年留存 + 传输/环境隔离」这条线：

| 级别 | 规则 | 查什么 |
|---|---|---|
| 🔴 高 | `FIN-PAY-SENSITIVE-RETENTION` | 字段/模型/配置出现 `cvv`、`cvn`、`track1/2`、`magnetic_stripe`、`card_pwd`、`pay_pwd`（支付敏感信息不应留存） |
| 🔴 高 | `FIN-AUTH-PLAINTEXT` | 口令/PIN/短信验证码明文落库（`password varchar`）、写日志、`System.out` 打印 |
| 🟡 中 | `FIN-PAN-DISPLAY` | 模板/日志里 `${cardNo}`、`{{cardNo}}` 直接插值，没走 mask/substring/脱敏工具 |
| 🔴 高 | `FIN-AMC-10Y` | 留存配置 < 3650 天、`INTERVAL <10 YEAR/DAY`、分区清理短于十年 |
| 🔴 高 | `FIN-CLIENT-LOCAL-STORE` | 客户端把卡号/CVV/口令存进 SharedPreferences/MMKV/UserDefaults/localStorage |
| 🟡 中 | `FIN-TRANSPORT-PLAINTEXT` | `useSSL=false`、`sslMode=DISABLED`、`verifyServerCertificate=false`、支付/鉴权链路 `http://`、`ftp://`、`TLSv1.0` |
| 🟡 中 | `FIN-TESTENV-PROD-DATA` | `application-test/dev/uat/sit` 指向 prod/prd/生产，或 `profiles.active=prod`，且同文件没有脱敏开关 |

判据出处（每条规则 JSON 里都带完整 source，`--list-rules` 可看）：

- 《个人金融信息保护技术规范》（JR/T 0171—2020）6.1.2 c)、6.1.3 a)/c)/d)、6.1.4.1 c)
- 《非银行支付机构监督管理条例》（国令第768号）第二十六条
- 《银行保险机构数据安全管理办法》（金规〔2024〕24号）第四十四条、第四十五条、第四十八条
- 《中华人民共和国反洗钱法》（2024 修订）第三十四条

> 规则编号只用于定位，判据以官方原文为准。本工具不展开法条解释。

## 它怎么避免误报

- **高风险规则带 `when`**：项目里没有支付/卡/客户端相关代码时，规则不跑，进 `notApplicable`，报告里写清楚「N 条因不适用未运行」。
- **边界写法不报**：
  - `card_mask` / `card_token` 字段不算支付敏感信息
  - `passwordEncoder` / `bcrypt` / `PBKDF2` / `SM3` / `SHA-256` 同行的口令列不报
  - `password: ${DB_PWD}`、已打码 `****`、`passwordPolicy` 命名不报
  - 模板里已调 `substring` / `mask` / `DesensitizedUtil` 的卡号不报
  - `session` / `cache` / `log` / 风控快照的短留存不报
  - 客户端只存 `access_token`、掩码、生物识别开关不报
  - `localhost` / `127.0.0.1` / 内网地址 / 已终止 TLS 的配置不报
  - 测试配置里有 `desensitize` / `脱敏` 开关的不报

## 安装

```bash
dsh plugin --profile web add @deepwhale-cn/dsh-industry-finance
# 或纯 CLI
npx @deepwhale-cn/dsh-industry-finance
```

## 用法

```bash
dsh-industry-finance --demo          # 看检出效果
dsh-industry-finance --list-rules    # 列出判据和依据
dsh-industry-finance --root ./my-app # 检查指定项目
dsh-industry-finance --html r.html   # HTML 报告（可截图存档）
```

## 边界

- **只看静态线索** —— 不做数据流、不做运行时抓包、不读数据库实际数据。
- **不做缺项判定** —— 没有留存配置不代表没留十年（可能由 DBA/归档平台统一做）。
- **不判断加密强度** —— 只查「有没有明文/明文通道的迹象」，密钥管理与算法强度交给 `dsh-cn-crypto`。
- **条款以官方原文为准** —— 本工具输出的是「去确认」的提示，不是法律意见。

## 与其它插件的分工

- `dsh-data-scan` —— 通用敏感数据（身份证/手机号/银行卡号）扫描；本插件聚焦支付 C3 与金融条款
- `dsh-data-lifecycle` —— 通用数据留存策略；本插件补反洗钱「十年」这条金融专线
- `dsh-cn-log-retention` —— 网络日志六个月留存；与十年交易记录留存是两条不同的线
- `dsh-industry-medical` / `dsh-industry-education` —— 医疗、教育行业层，与金融层互不重叠

本插件是一个工具。使用者必须遵守所在地区法律法规，**对使用本项目造成的任何后果自行承担责任。**

---

## 深鲸网安守护系列（共 39 个）

> 一个插件做一件事。**安全问题是链式的** —— 配套用才完整。

**国内合规**（12）｜ [等保对照](https://github.com/feely0208/dsh-cn-mlps) · [日志留存](https://github.com/feely0208/dsh-cn-log-retention) · [备案公示](https://github.com/feely0208/dsh-cn-filing) · [用户同意](https://github.com/feely0208/dsh-consent-guard) · [个人信息权利](https://github.com/feely0208/dsh-data-rights) · [未成年人保护](https://github.com/feely0208/dsh-minor-guard) · [影响评估](https://github.com/feely0208/dsh-pipia) · [数据分类分级](https://github.com/feely0208/dsh-data-classify) · [算法备案](https://github.com/feely0208/dsh-algorithm-filing) · [数据出境](https://github.com/feely0208/dsh-cn-data-export) · [国密合规](https://github.com/feely0208/dsh-cn-crypto) · [AI 内容标识](https://github.com/feely0208/dsh-cn-ai-labeling)

**AI 与 Agent 治理**（6）｜ [AI 输出信任](https://github.com/feely0208/dsh-ai-output-trust) · [外部内容信任](https://github.com/feely0208/dsh-content-trust) · [MCP 安全](https://github.com/feely0208/dsh-mcp-audit) · [Agent 权限](https://github.com/feely0208/dsh-agent-scope) · [策略核对](https://github.com/feely0208/dsh-agent-policy) · [可疑指令](https://github.com/feely0208/dsh-phishing-guard)

**数据与凭据**（5）｜ [敏感数据](https://github.com/feely0208/dsh-data-scan) · [密钥轮换](https://github.com/feely0208/dsh-key-rotate) · [数据留存](https://github.com/feely0208/dsh-data-lifecycle) · [配置审计](https://github.com/feely0208/dsh-env-audit) · [密钥扫描](https://github.com/feely0208/dsh-secret-scan)

**供应链与构建**（5）｜ [开源许可](https://github.com/feely0208/dsh-license-guard) · [依赖投毒](https://github.com/feely0208/dsh-dep-audit) · [CI 安全](https://github.com/feely0208/dsh-ci-guard) · [工具审查](https://github.com/feely0208/dsh-tool-vet) · [物料清单](https://github.com/feely0208/dsh-sbom)

**权限与应急**（3）｜ [最小权限](https://github.com/feely0208/dsh-least-privilege) · [告警外发](https://github.com/feely0208/dsh-alert-relay) · [应急证据包](https://github.com/feely0208/dsh-incident-package)

**行业专项**（4）｜ [医疗行业专项](https://github.com/feely0208/dsh-industry-medical) · [教育行业专项](https://github.com/feely0208/dsh-industry-education) · [金融行业专项](https://github.com/feely0208/dsh-industry-finance) · [地方数据条例](https://github.com/feely0208/dsh-local-regulation)

**编排与交付**（4）｜ [一键体检](https://github.com/feely0208/dsh-guard-suite) · [改前改后复核](https://github.com/feely0208/dsh-fix-verify) · [合规可交付文档](https://github.com/feely0208/dsh-compliance-doc) · [整改建议](https://github.com/feely0208/dsh-remediation)

都在 DSH 插件市场（dsh-plugin.org）、npm 和 deepwhale.org.cn/guard.html 上。
