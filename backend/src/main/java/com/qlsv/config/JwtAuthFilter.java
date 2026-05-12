package com.qlsv.config;

import com.qlsv.util.JwtUtil;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.security.SignatureException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthFilter extends OncePerRequestFilter {
    private final JwtUtil jwt;

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest req, @NonNull HttpServletResponse res, @NonNull FilterChain chain)
            throws java.io.IOException, jakarta.servlet.ServletException {
        String header = req.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ") && SecurityContextHolder.getContext().getAuthentication() == null) {
            String token = header.substring(7);
            try {
                // Attempt to validate and extract token information
                if (jwt.isValid(token)) {
                    String user = jwt.getUsername(token);
                    String role = jwt.getRole(token);
                    var auth = new UsernamePasswordAuthenticationToken(
                        user, null, List.of(new SimpleGrantedAuthority("ROLE_" + role))
                    );
                    auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(req));
                    SecurityContextHolder.getContext().setAuthentication(auth);
                } else {
                    // Token validation failed - attempt to determine specific reason
                    logTokenValidationFailure(token, req.getRequestURI());
                }
            } catch (Exception e) {
                // Catch any unexpected exceptions during token processing
                log.error("Unexpected exception during JWT token validation for request to {}: {}", req.getRequestURI(), e.getMessage(), e);
            }
        }
        chain.doFilter(req, res);
    }

    private void logTokenValidationFailure(String token, String requestUri) {
        try {
            // Attempt to parse token to get specific failure reason
            jwt.getUsername(token);
            log.warn("JWT token validation failed for request to {}: token is invalid (unknown reason)", requestUri);
        } catch (ExpiredJwtException e) {
            log.warn("JWT token validation failed for request to {}: token expired at {}", requestUri, e.getClaims().getExpiration());
        } catch (SignatureException e) {
            log.warn("JWT token validation failed for request to {}: invalid signature", requestUri);
        } catch (MalformedJwtException e) {
            log.warn("JWT token validation failed for request to {}: malformed token", requestUri);
        } catch (IllegalArgumentException e) {
            log.warn("JWT token validation failed for request to {}: illegal argument - {}", requestUri, e.getMessage());
        } catch (Exception e) {
            log.warn("JWT token validation failed for request to {}: {}", requestUri, e.getClass().getSimpleName());
        }
    }
}
