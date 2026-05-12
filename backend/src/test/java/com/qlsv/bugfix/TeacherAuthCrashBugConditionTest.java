package com.qlsv.bugfix;

import com.qlsv.util.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;

/**
 * Bug Condition Exploration Test for Teacher Authentication Crash
 * 
 * **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6**
 * 
 * Property 1: Authentication Failure Returns HTTP 401
 * 
 * CRITICAL: This test MUST FAIL on unfixed code - failure confirms the bug exists.
 * The bug manifests as HTTP 500 with NullPointerException instead of HTTP 401.
 * 
 * DO NOT attempt to fix the test or code when it fails - document the counterexamples.
 * 
 * Test Cases:
 * 1. GET /api/teacher/dashboard with expired JWT token
 * 2. GET /api/teacher/classes with malformed JWT token
 * 3. GET /api/teacher/schedule?kiHocId=1 with no Authorization header
 * 4. PUT /api/teacher/lhp/1/grades with invalid token signature
 * 
 * Expected Outcome: Test FAILS (proves bug exists - HTTP 500 with NullPointerException)
 */
@SpringBootTest
@AutoConfigureMockMvc
public class TeacherAuthCrashBugConditionTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtUtil jwtUtil;

    private String validTeacherToken;
    private String expiredToken;
    private String malformedToken;
    private String invalidSignatureToken;

    @BeforeEach
    public void setup() {
        // Generate a valid teacher token for reference
        validTeacherToken = jwtUtil.generate("teacher001", "GV", 1);
        
        // Create an expired token (manually crafted JWT with past expiration)
        // For simplicity, we'll use a token that's been tampered with
        expiredToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ0ZWFjaGVyMDAxIiwicm9sZSI6IkdWIiwiZXhwIjoxNjAwMDAwMDAwfQ.invalid";
        
        // Create a malformed token (not a valid JWT structure)
        malformedToken = "not.a.valid.jwt.token";
        
        // Create a token with invalid signature (valid structure but wrong signature)
        invalidSignatureToken = validTeacherToken.substring(0, validTeacherToken.lastIndexOf('.')) + ".invalidSignature";
    }

    /**
     * Test Case 1: Dashboard with expired JWT token
     * 
     * Bug Condition: GET /api/teacher/dashboard with expired token
     * Expected Behavior (after fix): HTTP 401 with friendly error message
     * Current Behavior (unfixed): HTTP 500 with NullPointerException
     */
    @Test
    void testDashboardWithExpiredToken() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/teacher/dashboard")
                .header("Authorization", "Bearer " + expiredToken))
                .andReturn();

        int status = result.getResponse().getStatus();
        String responseBody = result.getResponse().getContentAsString();

        // Assert HTTP 401 (not 500)
        if (status != 401) {
            throw new AssertionError(
                String.format("Expected HTTP 401 but got %d. Response: %s", status, responseBody)
            );
        }

        // Assert response contains standardized error format
        if (!responseBody.contains("\"success\":false") || 
            !responseBody.contains("\"code\":\"UNAUTHORIZED\"") ||
            !responseBody.contains("Session expired")) {
            throw new AssertionError(
                String.format("Expected standardized error format but got: %s", responseBody)
            );
        }

        // Assert response does NOT contain NullPointerException
        if (responseBody.contains("NullPointerException") || 
            responseBody.contains("getUsername()") ||
            responseBody.contains("because \"u\" is null")) {
            throw new AssertionError(
                String.format("Response exposes NullPointerException: %s", responseBody)
            );
        }
    }

    /**
     * Test Case 2: Classes with malformed JWT token
     * 
     * Bug Condition: GET /api/teacher/classes with malformed token
     * Expected Behavior (after fix): HTTP 401 with friendly error message
     * Current Behavior (unfixed): HTTP 500 with NullPointerException
     */
    @Test
    void testClassesWithMalformedToken() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/teacher/classes")
                .header("Authorization", "Bearer " + malformedToken))
                .andReturn();

        int status = result.getResponse().getStatus();
        String responseBody = result.getResponse().getContentAsString();

        // Assert HTTP 401 (not 500)
        if (status != 401) {
            throw new AssertionError(
                String.format("Expected HTTP 401 but got %d. Response: %s", status, responseBody)
            );
        }

        // Assert response contains standardized error format
        if (!responseBody.contains("\"success\":false") || 
            !responseBody.contains("\"code\":\"UNAUTHORIZED\"")) {
            throw new AssertionError(
                String.format("Expected standardized error format but got: %s", responseBody)
            );
        }

        // Assert response does NOT contain NullPointerException
        if (responseBody.contains("NullPointerException") || 
            responseBody.contains("getUsername()")) {
            throw new AssertionError(
                String.format("Response exposes NullPointerException: %s", responseBody)
            );
        }
    }

    /**
     * Test Case 3: Schedule with no Authorization header
     * 
     * Bug Condition: GET /api/teacher/schedule?kiHocId=1 with no Authorization header
     * Expected Behavior (after fix): HTTP 401 with friendly error message
     * Current Behavior (unfixed): HTTP 500 with NullPointerException
     */
    @Test
    void testScheduleWithNoAuthHeader() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/teacher/schedule")
                .param("kiHocId", "1"))
                .andReturn();

        int status = result.getResponse().getStatus();
        String responseBody = result.getResponse().getContentAsString();

        // Assert HTTP 401 (not 500)
        if (status != 401) {
            throw new AssertionError(
                String.format("Expected HTTP 401 but got %d. Response: %s", status, responseBody)
            );
        }

        // Assert response contains standardized error format
        if (!responseBody.contains("\"success\":false") || 
            !responseBody.contains("\"code\":\"UNAUTHORIZED\"")) {
            throw new AssertionError(
                String.format("Expected standardized error format but got: %s", responseBody)
            );
        }

        // Assert response does NOT contain NullPointerException
        if (responseBody.contains("NullPointerException") || 
            responseBody.contains("getUsername()")) {
            throw new AssertionError(
                String.format("Response exposes NullPointerException: %s", responseBody)
            );
        }
    }

    /**
     * Test Case 4: Grade save with invalid token signature
     * 
     * Bug Condition: PUT /api/teacher/lhp/1/grades with invalid token signature
     * Expected Behavior (after fix): HTTP 401 with friendly error message
     * Current Behavior (unfixed): HTTP 500 with NullPointerException
     */
    @Test
    void testGradeSaveWithInvalidSignature() throws Exception {
        String gradePayload = "{\"grades\":[{\"sinhVienId\":1,\"diem\":8.5}]}";
        
        MvcResult result = mockMvc.perform(put("/api/teacher/lhp/1/grades")
                .header("Authorization", "Bearer " + invalidSignatureToken)
                .contentType("application/json")
                .content(gradePayload))
                .andReturn();

        int status = result.getResponse().getStatus();
        String responseBody = result.getResponse().getContentAsString();

        // Assert HTTP 401 (not 500)
        if (status != 401) {
            throw new AssertionError(
                String.format("Expected HTTP 401 but got %d. Response: %s", status, responseBody)
            );
        }

        // Assert response contains standardized error format
        if (!responseBody.contains("\"success\":false") || 
            !responseBody.contains("\"code\":\"UNAUTHORIZED\"")) {
            throw new AssertionError(
                String.format("Expected standardized error format but got: %s", responseBody)
            );
        }

        // Assert response does NOT contain NullPointerException
        if (responseBody.contains("NullPointerException") || 
            responseBody.contains("getUsername()")) {
            throw new AssertionError(
                String.format("Response exposes NullPointerException: %s", responseBody)
            );
        }
    }
}
