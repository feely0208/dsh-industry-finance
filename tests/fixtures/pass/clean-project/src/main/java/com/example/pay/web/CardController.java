package com.example.pay.web;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import cn.hutool.core.util.DesensitizedUtil;

public class CardController {
    private static final Logger log = LoggerFactory.getLogger(CardController.class);

    public String query(String cardNo) {
        String masked = DesensitizedUtil.bankCard(cardNo);
        log.info("query card, cardNo={}", masked);
        return masked;
    }
}
