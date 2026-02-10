-- This query calculates the total credits each student is attempting per semester,
-- and ranks students within each semester by their total credits (highest first).
SELECT
    s.student_name,
    e.semester,
    SUM(c.credits) AS total_credits,
    RANK() OVER (PARTITION BY e.semester ORDER BY SUM(c.credits) DESC) AS semester_rank
FROM enrollments e
JOIN students s 
    ON e.student_id = s.student_id
JOIN courses c 
    ON e.course_id = c.course_id
GROUP BY s.student_name, e.semester
ORDER BY e.semester, semester_rank;


-- This query calculates the percent rank of each student's grade within their course.
-- PERCENT_RANK() returns a value between 0 and 1, showing the relative standing of each grade.
SELECT
    c.course_name,
    s.student_name,
    e.grade,
    PERCENT_RANK() OVER (PARTITION BY c.course_id ORDER BY e.grade) AS rank_percent
FROM enrollments e
JOIN students s 
    ON e.student_id = s.student_id
JOIN courses c 
    ON e.course_id = c.course_id
ORDER BY c.course_name, rank_percent;

-- This query calculates the cumulative distribution (CUME_DIST) of each student's grade within their course.
-- CUME_DIST() shows the proportion of students with a grade less than or equal to the current grade.
SELECT
    c.course_name,
    s.student_name,
    e.grade,
    CUME_DIST() OVER (PARTITION BY c.course_id ORDER BY e.grade) AS cumulative_distribution
FROM enrollments e
JOIN students s 
    ON e.student_id = s.student_id
JOIN courses c 
    ON e.course_id = c.course_id
ORDER BY c.course_name, cumulative_distribution;

-- This query finds the average grade in Science, then selects students who scored above that average.
SELECT s.student_name, e.grade
FROM enrollments e
JOIN students s 
    ON e.student_id = s.student_id
WHERE e.course_id = 102
  AND e.grade > (
      SELECT AVG(grade)
      FROM enrollments
      WHERE course_id = 102
  );
  
  -- This view calculates the average grade for each student.
CREATE VIEW student_avg_grade AS
SELECT
    s.student_id,
    s.student_name,
    AVG(e.grade) AS avg_grade
FROM students s
JOIN enrollments e 
    ON s.student_id = e.student_id
GROUP BY s.student_id, s.student_name;

SELECT * FROM student_avg_grade;

-- This materialized view stores the count of enrollments per course.
-- Step 1: Create a table to store the aggregated results.
-- Reason: MySQL does not support materialized views, so we use a physical table to store the summary data.
CREATE TABLE course_enrollment_count AS
SELECT
    c.course_id,
    c.course_name,
    COUNT(e.enrollment_id) AS num_enrollments
FROM courses c
LEFT JOIN enrollments e 
    ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name;

-- Step 2: To refresh the data in the table, first remove all existing rows.
-- Reason: This ensures the table always contains up-to-date aggregated data, just like a materialized view would after a refresh.
TRUNCATE TABLE course_enrollment_count;

-- Step 3: Re-insert the latest aggregated data into the table.
-- Reason: This repopulates the table with current counts, simulating the refresh behavior of a materialized view.
INSERT INTO course_enrollment_count
SELECT
    c.course_id,
    c.course_name,
    COUNT(e.enrollment_id) AS num_enrollments
FROM courses c
LEFT JOIN enrollments e 
    ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name;

-- This stored procedure inserts a new student into the students table.
DELIMITER //
CREATE PROCEDURE add_student(
    IN p_student_id INT,
    IN p_student_name VARCHAR(100),
    IN p_age INT
)
BEGIN
    INSERT INTO students (student_id, student_name, age)
    VALUES (p_student_id, p_student_name, p_age);
END //
DELIMITER ;

CALL add_student(4, 'David', 23);
-- updated table
SELECT * FROM students

-- This function returns 'Pass' if grade >= 80, else 'Fail'.
DELIMITER //
CREATE FUNCTION pass_fail(grade INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    RETURN CASE WHEN grade >= 80 THEN 'Pass' ELSE 'Fail' END;
END //
DELIMITER ;

SELECT s.student_name, e.grade, pass_fail(e.grade) AS result
FROM enrollments e
JOIN students s 
    ON e.student_id = s.student_id;