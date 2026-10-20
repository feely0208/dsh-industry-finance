import { createPlugin, pkgRootFrom } from '@deepwhale-cn/dsh-guard-core/plugin';

export const { name, inject, apply } = createPlugin({
  name: 'industry-finance',
  pkgRoot: pkgRootFrom(import.meta.url),
  skillFile: 'skill/industry-finance.md',
  binFile: 'bin/cli.mjs',
  description: '支付敏感信息、十年留存，金融这条线查得更严',
  whenToUse: '用户在做银行、支付、消金、保险、证券类项目时用；会说的话：「支付敏感信息能不能落库」「CVV 能不能存」「反洗钱留存十年怎么配」「卡号展示要不要脱敏」「测试环境能不能连生产库」。',
});
