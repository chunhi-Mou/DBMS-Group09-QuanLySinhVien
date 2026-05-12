package com.qlsv.util;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtUtil {
    private final SecretKey key;
    private final long ttlSeconds;

    public JwtUtil(@Value("${qlsv.jwt.secret}") String secret,
                   @Value("${qlsv.jwt.ttl-seconds:86400}") long ttl) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes());
        this.ttlSeconds = ttl;
    }

    public String generate(String username, String role, Integer thanhVienId) {
        Date now = new Date();
        return Jwts.builder()
            .subject(username)
            .claim("role", role)
            .claim("tvid", thanhVienId)
            .issuedAt(now)
            .expiration(new Date(now.getTime() + ttlSeconds * 1000))
            .signWith(key)
            .compact();
    }

    public String getUsername(String token) { return parse(token).getSubject(); }
    public String getRole(String token)     { return parse(token).get("role", String.class); }
    public Integer getThanhVienId(String token) { return parse(token).get("tvid", Integer.class); }

    public boolean isValid(String token) {
        try { parse(token); return true; } catch (JwtException | IllegalArgumentException e) { return false; }
    }

    private Claims parse(String token) {
        return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
    }
}
