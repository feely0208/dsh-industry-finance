#!/bin/bash
# 双向验证：正例每一条都必须报，反例必须 0 命中（误报是安全工具的头号杀手）
set -uo pipefail
export PATH="/usr/local/bin:$PATH"
cd "$(dirname "$0")/.."
PASS=0; FAIL=0
ok(){ echo "  ✅ $1"; PASS=$((PASS+1)); }
bad(){ echo "  ❌ $1"; FAIL=$((FAIL+1)); }

echo ""; echo "  $(node -p "require('./package.json').name") · 双向验证"
echo "  ────────────────────────────────────────────────"

echo ""; echo "  【正例】违规样本（7 条判据必须逐条报出）"
J=$(node bin/cli.mjs --root tests/fixtures/fail/demo-project --json 2>&1)
for rid in FIN-PAY-SENSITIVE-RETENTION FIN-AUTH-PLAINTEXT FIN-PAN-DISPLAY FIN-AMC-10Y FIN-CLIENT-LOCAL-STORE FIN-TRANSPORT-PLAINTEXT FIN-TESTENV-PROD-DATA; do
  c=$(echo "$J" | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    print(len([f for f in d.get('findings',[]) if f.get('ruleId')=='$rid']))
except Exception:
    print(0)" 2>/dev/null)
  [ "${c:-0}" -gt 0 ] && ok "$rid 报出（${c} 处）" || bad "$rid 未报出 —— 死规则"
done
R=$(echo "$J" | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    print(len(d.get('stats',{}).get('ruleErrors') or []))
except Exception:
    print(9)" 2>/dev/null)
[ "${R:-9}" = "0" ] && ok "规则执行无报错" || bad "有规则执行出错（${R} 条）"

echo ""; echo "  【反例】合规样本（必须 0 命中）"
M=$(node bin/cli.mjs --root tests/fixtures/pass/clean-project --quiet 2>&1 | grep -oE '^[0-9]+' | head -1)
[ "${M:-1}" = "0" ] && ok "0 命中" || bad "误报 ${M} 条"
C=$(node bin/cli.mjs --root tests/fixtures/pass/clean-project --json 2>&1)
for rid in FIN-PAY-SENSITIVE-RETENTION FIN-AUTH-PLAINTEXT FIN-PAN-DISPLAY FIN-AMC-10Y FIN-CLIENT-LOCAL-STORE FIN-TRANSPORT-PLAINTEXT FIN-TESTENV-PROD-DATA; do
  c=$(echo "$C" | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    print(len([f for f in d.get('findings',[]) if f.get('ruleId')=='$rid']))
except Exception:
    print(0)" 2>/dev/null)
  [ "${c:-1}" = "0" ] && ok "$rid 反例 0 命中" || bad "$rid 反例误报 ${c} 条"
done

echo ""; echo "  【溯源】每条规则必须带 source 与 advice（≥40 字）"
python3 - <<'PY' && ok "全部规则均有 source 且 advice ≥40 字" || bad "有规则缺 source 或 advice 过短"
import json,glob,sys
bad=[]
for f in sorted(glob.glob('rules/*.json')):
    r=json.load(open(f,encoding='utf-8'))
    if not r.get('source'): bad.append((r.get('id'),'缺 source'))
    if len(r.get('advice') or '')<40: bad.append((r.get('id'),'advice <40 字'))
if bad: print(bad,file=sys.stderr); sys.exit(1)
PY

echo ""; echo "  【高优】高风险规则必须配 when（限定项目类型，避免误报）"
python3 - <<'PY' && ok "全部 high 规则都有 when" || bad "有 high 规则没配 when"
import json,glob,sys
bad=[]
for f in sorted(glob.glob('rules/*.json')):
    r=json.load(open(f,encoding='utf-8'))
    if r.get('severity')=='high' and not (r.get('check') or {}).get('when'):
        bad.append(r.get('id'))
if bad: print(bad,file=sys.stderr); sys.exit(1)
PY

echo ""; echo "  ────────────────────────────────────────────────"
echo "  通过 $PASS · 失败 $FAIL"; echo ""
[ "$FAIL" -eq 0 ] || exit 1
