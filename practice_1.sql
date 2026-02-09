-- Insert operation
INSERT INTO students (student_id, student_name, age) VALUES (4, 'David', 23);

SET SQL_SAFE_UPDATES = 0;

-- Update operation
UPDATE students SET age = 23 WHERE student_name = 'Carol';

-- Step 1: Drop the existing foreign key constraint (if it doesn't have ON DELETE CASCADE)
ALTER TABLE enrollments
DROP FOREIGN KEY enrollments_ibfk_1;

-- Step 2: Add the foreign key constraint back with ON DELETE CASCADE
ALTER TABLE enrollments
ADD CONSTRAINT enrollments_ibfk_1
FOREIGN KEY (student_id) REFERENCES students(student_id)
ON DELETE CASCADE;

-- Step 3: Now you can safely delete a student, and all related enrollments will be deleted automatically
DELETE FROM students WHERE student_name = 'Bob';

-- Upsert operation
INSERT INTO courses (course_id, course_name, teacher)
VALUES (104, 'History', 'Ms. Green')
ON DUPLICATE KEY UPDATE teacher = VALUES(teacher);

-- Merge operation
-- Upsert operation: Insert or update a single enrollment record
INSERT INTO enrollments (enrollment_id, student_id, course_id, enrollment_date, grade)
VALUES (101, 1, 104, '2026-02-09', 55)
ON DUPLICATE KEY UPDATE
    grade = VALUES(grade);
    
    
-- This query retrieves the names of all students and the courses they are enrolled in.
-- It uses INNER JOINs, so only students with enrollments will appear.
SELECT s.student_name, c.course_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id;

-- This query lists all students, even if they are not enrolled in any course.
-- Students without enrollments will have NULL in the course_name column.
SELECT s.student_name, c.course_name
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c ON e.course_id = c.course_id;

-- This query lists all courses and the students enrolled in them.
-- Courses with no students will have NULL in the student_name column.
-- (Note: RIGHT JOIN is not supported in all SQL dialects; LEFT JOIN with reversed order is equivalent.)
SELECT c.course_name, s.student_name
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
LEFT JOIN students s ON e.student_id = s.student_id;


-- This query ranks students within each course based on their grade, highest first.
-- RANK() is a window function that assigns a rank starting from 1 for the highest grade in each course.
SELECT
    c.course_name,
    s.student_name,
    e.grade,
    RANK() OVER (PARTITION BY c.course_id ORDER BY e.grade DESC) AS grade_rank
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

-- This query shows each student's grade along with the average grade for the course they are enrolled in.
-- AVG() OVER (PARTITION BY c.course_id) calculates the average grade for each course.
SELECT
    s.student_name,
    c.course_name,
    e.grade,
    AVG(e.grade) OVER (PARTITION BY c.course_id) AS avg_course_grade
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

-- This query divides students enrolled in Math into 2 groups (tiles) based on their grades.
-- NTILE(2) OVER (ORDER BY e.grade DESC) assigns each student to one of two groups, with higher grades in the first group.
SELECT
    s.student_name,
    e.grade,
    NTILE(2) OVER (ORDER BY e.grade DESC) AS grade_group
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
WHERE e.course_id = 101;

-- This query uses a Common Table Expression (CTE) to first calculate the average grade for each student.
-- The main query then selects only those students whose average grade is above 85.
WITH avg_grades AS (
    SELECT
        s.student_id,
        s.student_name,
        AVG(e.grade) AS avg_grade
    FROM students s
    JOIN enrollments e ON s.student_id = e.student_id
    GROUP BY s.student_id, s.student_name
)
SELECT * FROM avg_grades WHERE avg_grade > 85;