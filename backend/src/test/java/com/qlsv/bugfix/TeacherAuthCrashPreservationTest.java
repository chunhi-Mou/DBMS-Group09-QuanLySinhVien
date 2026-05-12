package com.qlsv.bugfix;

import com.qlsv.util.JwtUtil;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;

/**
 * Preservation Property Tests for Teacher Authentication Crash Fix
 * 
 * **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**
 * 
 * Property 2: Preservation - Valid Authentication Behavior
 * 
 * IMPORTANT: Follow observation-first methodology
 * GOAL: Capture baseline behavior that must be preserved after the fix
 * 
 * Test Cases:
 * 1. GET /api/teacher/dashboard with valid token returns dashboard data
 * 2. GET /api/teacher/classes with valid token returns classes list
 * 3. GET /api/teacher/schedule?kiHocId=1 with valid token returns schedule data
 * 4. PUT /api/teacher/lhp/1/grades with valid token saves grades successfully
 * 5. POST /api/teacher/lhp/1/finalize with valid token finalizes grades
 * 
 * Expected Outcome: Tests PASS on unfixed code (confirms baseline behavior to preserve)
 * 
 * Note: These tests use multiple examples to simulate property-based testing behavior
 * while maintaining compatibility with Spring Boot's dependency injection.
 */
@SpringBootTest
@AutoConfigureMockMvc
public class TeacherAuthCrashPreservationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * Property 1: Dashboard endpoint with valid token returns HTTP 200 with expected data structure
     * 
     * For all valid teacher JWT tokens, dashboard endpoint returns HTTP 200 with expected data structure
     * 
     * This test runs multiple examples to simulate property-based testing behavior
     */
    @Test
    void testDashboardWithValidToken() throws Exception {
        // Test with multiple teacher usernames and IDs to simulate property-based testing
        String[][] testCases = {
            {"teacher001", "1"},
            {"teacher002", "2"},
            {"teacher010", "10"},
            {"teacher050", "50"},
            {"teacher100", "100"}
        };

        for (String[] testCase : testCases) {
            String username = testCase[0];
            Integer thanhVienId = Integer.parseInt(testCase[1]);

            // Generate valid teacher token
            String validToken = jwtUtil.generate(username, "GV", thanhVienId);

            // Call dashboard endpoint
            MvcResult result = mockMvc.perform(get("/api/teacher/dashboard")
                    .header("Authorization", "Bearer " + validToken))
                    .andReturn();

            int status = result.getResponse().getStatus();
            String responseBody = result.getResponse().getContentAsString();

            // Assert HTTP 200 (successful response)
            if (status != 200) {
                throw new AssertionError(
                    String.format("[%s, %d] Expected HTTP 200 but got %d. Response: %s", 
                        username, thanhVienId, status, responseBody)
                );
            }

            // Assert response contains expected data structure (hoTen, maGv, soLopKyHienTai, tongSv, theoKi)
            if (!responseBody.contains("\"hoTen\"") || 
                !responseBody.contains("\"maGv\"") ||
                !responseBody.contains("\"soLopKyHienTai\"") ||
                !responseBody.contains("\"tongSv\"")) {
                throw new AssertionError(
                    String.format("[%s, %d] Expected dashboard data structure but got: %s", 
                        username, thanhVienId, responseBody)
                );
            }

            // Assert response does NOT contain error messages
            if (responseBody.contains("\"error\"") || 
                responseBody.contains("NullPointerException")) {
                throw new AssertionError(
                    String.format("[%s, %d] Response contains error: %s", 
                        username, thanhVienId, responseBody)
                );
            }
        }
    }

    /**
     * Property 2: Classes endpoint with valid token returns HTTP 200 with classes array
     * 
     * For all valid teacher JWT tokens, classes endpoint returns HTTP 200 with classes array
     * 
     * This test runs multiple examples to simulate property-based testing behavior
     */
    @Test
    void testClassesWithValidToken() throws Exception {
        // Test with multiple teacher usernames and IDs
        String[][] testCases = {
            {"teacher001", "1"},
            {"teacher005", "5"},
            {"teacher020", "20"},
            {"teacher075", "75"}
        };

        for (String[] testCase : testCases) {
            String username = testCase[0];
            Integer thanhVienId = Integer.parseInt(testCase[1]);

            // Generate valid teacher token
            String validToken = jwtUtil.generate(username, "GV", thanhVienId);

            // Call classes endpoint
            MvcResult result = mockMvc.perform(get("/api/teacher/classes")
                    .header("Authorization", "Bearer " + validToken))
                    .andReturn();

            int status = result.getResponse().getStatus();
            String responseBody = result.getResponse().getContentAsString();

            // Assert HTTP 200 (successful response)
            if (status != 200) {
                throw new AssertionError(
                    String.format("[%s, %d] Expected HTTP 200 but got %d. Response: %s", 
                        username, thanhVienId, status, responseBody)
                );
            }

            // Assert response is a JSON array (starts with '[')
            if (!responseBody.trim().startsWith("[")) {
                throw new AssertionError(
                    String.format("[%s, %d] Expected JSON array but got: %s", 
                        username, thanhVienId, responseBody)
                );
            }

            // Assert response does NOT contain error messages
            if (responseBody.contains("\"error\"") || 
                responseBody.contains("NullPointerException")) {
                throw new AssertionError(
                    String.format("[%s, %d] Response contains error: %s", 
                        username, thanhVienId, responseBody)
                );
            }
        }
    }

    /**
     * Property 3: Schedule endpoint with valid token and kiHocId returns HTTP 200 with schedule data
     * 
     * For all valid teacher JWT tokens and kiHocId values, schedule endpoint returns HTTP 200 with buoi array
     * 
     * This test runs multiple examples to simulate property-based testing behavior
     */
    @Test
    void testScheduleWithValidToken() throws Exception {
        // Test with multiple combinations of teacher usernames, IDs, and kiHocId values
        String[][] testCases = {
            {"teacher001", "1", "1"},
            {"teacher002", "2", "2"},
            {"teacher010", "10", "5"},
            {"teacher025", "25", "10"}
        };

        for (String[] testCase : testCases) {
            String username = testCase[0];
            Integer thanhVienId = Integer.parseInt(testCase[1]);
            Integer kiHocId = Integer.parseInt(testCase[2]);

            // Generate valid teacher token
            String validToken = jwtUtil.generate(username, "GV", thanhVienId);

            // Call schedule endpoint
            MvcResult result = mockMvc.perform(get("/api/teacher/schedule")
                    .param("kiHocId", kiHocId.toString())
                    .header("Authorization", "Bearer " + validToken))
                    .andReturn();

            int status = result.getResponse().getStatus();
            String responseBody = result.getResponse().getContentAsString();

            // Assert HTTP 200 (successful response)
            if (status != 200) {
                throw new AssertionError(
                    String.format("[%s, %d, kiHocId=%d] Expected HTTP 200 but got %d. Response: %s", 
                        username, thanhVienId, kiHocId, status, responseBody)
                );
            }

            // Assert response contains expected data structure (kiHocId, tenKi, buoi, lhp)
            if (!responseBody.contains("\"kiHocId\"") || 
                !responseBody.contains("\"tenKi\"") ||
                !responseBody.contains("\"buoi\"") ||
                !responseBody.contains("\"lhp\"")) {
                throw new AssertionError(
                    String.format("[%s, %d, kiHocId=%d] Expected schedule data structure but got: %s", 
                        username, thanhVienId, kiHocId, responseBody)
                );
            }

            // Assert response does NOT contain error messages
            if (responseBody.contains("\"error\"") || 
                responseBody.contains("NullPointerException")) {
                throw new AssertionError(
                    String.format("[%s, %d, kiHocId=%d] Response contains error: %s", 
                        username, thanhVienId, kiHocId, responseBody)
                );
            }
        }
    }

    /**
     * Property 4: Save grades endpoint with valid token returns HTTP 200
     * 
     * For all valid teacher JWT tokens and grade data, save grades endpoint returns HTTP 200 with success response
     * 
     * This test runs multiple examples to simulate property-based testing behavior
     */
    @Test
    void testSaveGradesWithValidToken() throws Exception {
        // Test with multiple combinations of teacher usernames, IDs, and lhpId values
        String[][] testCases = {
            {"teacher001", "1", "1"},
            {"teacher005", "5", "5"},
            {"teacher015", "15", "10"}
        };

        for (String[] testCase : testCases) {
            String username = testCase[0];
            Integer thanhVienId = Integer.parseInt(testCase[1]);
            Integer lhpId = Integer.parseInt(testCase[2]);

            // Generate valid teacher token
            String validToken = jwtUtil.generate(username, "GV", thanhVienId);

            // Create valid grade payload
            String gradePayload = "{\"entries\":[{\"dangKyHocId\":1,\"dauDiemId\":1,\"diem\":8.5}]}";

            // Call save grades endpoint
            MvcResult result = mockMvc.perform(put("/api/teacher/lhp/" + lhpId + "/grades")
                    .header("Authorization", "Bearer " + validToken)
                    .contentType("application/json")
                    .content(gradePayload))
                    .andReturn();

            int status = result.getResponse().getStatus();
            String responseBody = result.getResponse().getContentAsString();

            // Assert HTTP 200 or 204 (successful response - PUT may return no content)
            if (status != 200 && status != 204) {
                throw new AssertionError(
                    String.format("[%s, %d, lhpId=%d] Expected HTTP 200/204 but got %d. Response: %s", 
                        username, thanhVienId, lhpId, status, responseBody)
                );
            }

            // Assert response does NOT contain error messages (if there's a body)
            if (!responseBody.isEmpty() && 
                (responseBody.contains("\"error\"") || responseBody.contains("NullPointerException"))) {
                throw new AssertionError(
                    String.format("[%s, %d, lhpId=%d] Response contains error: %s", 
                        username, thanhVienId, lhpId, responseBody)
                );
            }
        }
    }

    /**
     * Property 5: Finalize endpoint with valid token returns HTTP 200 with finalization result
     * 
     * For all valid teacher JWT tokens and lhpId values, finalize endpoint returns HTTP 200 with finalization result
     * 
     * This test runs multiple examples to simulate property-based testing behavior
     */
    @Test
    void testFinalizeWithValidToken() throws Exception {
        // Test with multiple combinations of teacher usernames, IDs, and lhpId values
        String[][] testCases = {
            {"teacher001", "1", "1"},
            {"teacher003", "3", "3"},
            {"teacher008", "8", "8"}
        };

        for (String[] testCase : testCases) {
            String username = testCase[0];
            Integer thanhVienId = Integer.parseInt(testCase[1]);
            Integer lhpId = Integer.parseInt(testCase[2]);

            // Generate valid teacher token
            String validToken = jwtUtil.generate(username, "GV", thanhVienId);

            // Call finalize endpoint
            MvcResult result = mockMvc.perform(post("/api/teacher/lhp/" + lhpId + "/finalize")
                    .header("Authorization", "Bearer " + validToken))
                    .andReturn();

            int status = result.getResponse().getStatus();
            String responseBody = result.getResponse().getContentAsString();

            // Assert HTTP 200 (successful response)
            if (status != 200) {
                throw new AssertionError(
                    String.format("[%s, %d, lhpId=%d] Expected HTTP 200 but got %d. Response: %s", 
                        username, thanhVienId, lhpId, status, responseBody)
                );
            }

            // Assert response contains expected data structure (done, failed)
            if (!responseBody.contains("\"done\"") || 
                !responseBody.contains("\"failed\"")) {
                throw new AssertionError(
                    String.format("[%s, %d, lhpId=%d] Expected finalization result structure but got: %s", 
                        username, thanhVienId, lhpId, responseBody)
                );
            }

            // Assert response does NOT contain error messages
            if (responseBody.contains("\"error\"") || 
                responseBody.contains("NullPointerException")) {
                throw new AssertionError(
                    String.format("[%s, %d, lhpId=%d] Response contains error: %s", 
                        username, thanhVienId, lhpId, responseBody)
                );
            }
        }
    }
}
