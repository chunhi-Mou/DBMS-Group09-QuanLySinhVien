/**
 * Semester Validation Utilities
 * 
 * This module provides utility functions for validating semester selection
 * and filtering semesters based on student enrollment date and current date.
 * 
 * Requirements: 3, 8
 */

/**
 * Validates if a semester is selectable based on enrollment date and current date
 * 
 * A semester is valid if:
 * 1. It starts on or after the student's enrollment date
 * 2. It does not start in the future
 * 
 * @param {Object} semester - Semester object
 * @param {string} semester.batDau - Start date (ISO format)
 * @param {string} enrollmentDate - Student enrollment date (ISO format)
 * @returns {boolean} - True if semester is valid for selection
 */
export function isSemesterValid(semester, enrollmentDate) {
  const semesterStart = new Date(semester.batDau);
  const enrollment = new Date(enrollmentDate);
  const now = new Date();
  
  // Semester must start after enrollment date
  if (semesterStart < enrollment) {
    return false;
  }
  
  // Semester must not be in the future
  if (semesterStart > now) {
    return false;
  }
  
  return true;
}

/**
 * Filters semesters to only include valid ones
 * 
 * Uses isSemesterValid to filter out semesters that are:
 * - Before the student's enrollment date
 * - In the future
 * 
 * @param {Array} semesters - Array of semester objects
 * @param {string} enrollmentDate - Student enrollment date
 * @returns {Array} - Filtered array of valid semesters
 */
export function filterValidSemesters(semesters, enrollmentDate) {
  return semesters.filter(sem => isSemesterValid(sem, enrollmentDate));
}

/**
 * Gets the active (current) semester from a list
 * 
 * The active semester is the one where the current date falls between
 * the start date (batDau) and end date (ketThuc).
 * 
 * @param {Array} semesters - Array of semester objects
 * @returns {Object|null} - Active semester or null if none found
 */
export function getActiveSemester(semesters) {
  const now = new Date();
  
  return semesters.find(sem => {
    const start = new Date(sem.batDau);
    const end = new Date(sem.ketThuc);
    return start <= now && now <= end;
  }) || null;
}
