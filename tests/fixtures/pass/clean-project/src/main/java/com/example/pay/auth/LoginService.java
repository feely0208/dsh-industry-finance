package com.example.pay.auth;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;

public class LoginService {
    private static final Logger log = LoggerFactory.getLogger(LoginService.class);

    private final PasswordEncoder passwordEncoder;

    public LoginService(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }

    public boolean login(String username, String rawPassword, String hashFromDb) {
        log.info("login attempt user={}", username);
        return passwordEncoder.matches(rawPassword, hashFromDb);
    }
}
