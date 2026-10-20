package com.example.pay.auth;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LoginService {
    private static final Logger log = LoggerFactory.getLogger(LoginService.class);

    public boolean login(String username, String password) {
        log.info("login user={} pwd={}", username, password);
        return password != null && password.length() >= 6;
    }
}
