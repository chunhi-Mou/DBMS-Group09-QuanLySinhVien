package com.qlsv.exception;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<Map<String,Object>> handleApi(ApiException ex) {
        return ResponseEntity.status(ex.getStatus())
            .body(Map.of("success", false, "error",
                Map.of("code", ex.getCode(), "message", ex.getMessage())));
    }

    @ExceptionHandler(NullPointerException.class)
    public ResponseEntity<Map<String,Object>> handleNullPointer(NullPointerException ex) {
        // Check if this is an authentication-related NPE
        String message = ex.getMessage();
        if (message != null && (message.contains("UserDetails") || message.contains("getUsername()") || 
                                message.contains("Principal") || message.contains("getName()"))) {
            return ResponseEntity.status(401).body(Map.of(
                "success", false,
                "error", Map.of("code", "UNAUTHORIZED", "message", "Session expired. Please log in again.")
            ));
        }
        // For other NPEs, fall through to generic handler
        return handleAny(ex);
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<Map<String,Object>> handleAuthentication(AuthenticationException ex) {
        return ResponseEntity.status(401).body(Map.of(
            "success", false,
            "error", Map.of("code", "UNAUTHORIZED", "message", "Session expired. Please log in again.")
        ));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String,Object>> handleValidation(MethodArgumentNotValidException ex) {
        Map<String,String> details = new HashMap<>();
        ex.getBindingResult().getFieldErrors()
          .forEach(fe -> details.put(fe.getField(), fe.getDefaultMessage()));
        return ResponseEntity.badRequest().body(Map.of(
            "success", false,
            "error", Map.of("code", "VALIDATION", "message", "Dữ liệu không hợp lệ", "details", details)
        ));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<Map<String,Object>> handleForbidden(AccessDeniedException ex) {
        return ResponseEntity.status(403).body(Map.of(
            "success", false,
            "error", Map.of("code", "FORBIDDEN", "message", "Không có quyền")
        ));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String,Object>> handleAny(Exception ex) {
        return ResponseEntity.internalServerError().body(Map.of(
            "success", false,
            "error", Map.of("code", "INTERNAL", "message", ex.getMessage())
        ));
    }
}
