-- Create Students table
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    age INT
);


-- Create Courses table
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    teacher VARCHAR(100)
);

-- Create Enrollments table (many-to-many relationship)
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES
 courses(course_id)
);


-- Students
INSERT INTO students VALUES
(1, 'Alice', 20),
(2, 'Bob', 21),
(3, 'Carol', 22);

-- Courses
INSERT INTO courses VALUES
(101, 'Math', 'Mr. Smith'),
(102, 'Science', 'Ms. Lee'),
(103, 'English', 'Mr. Brown');

-- Enrollments
INSERT INTO enrollments VALUES
(1, 1, 101, '2024-01-10', 85),
(2, 1, 102, '2024-01-12', 90),
(3, 2, 101, '2024-01-15', 78),
(4, 3, 102, '2024-01-18', 88),
(5, 3, 103, '2024-01-20', 92);