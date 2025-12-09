% Global:
% 	1. Completion of the major requires approximately 80 credits.  At least 24 credits from items 1 to 3 below, and at least 18 credits from items 2 and 3, must be completed at Stony Brook. 

% 	- need: list of courses for item 1, 2, 3. aggregation.

% 	2. Note: The courses selected in 7 and 8 must carry at least 9 credits.

% 	- need: list of courses for item 7, 8. aggregation.

% 	3. All courses taken to satisfy Requirements 1 through 10 must be taken for a letter grade. The courses in Requirements 1-6, 9, and 10 must be passed with a letter grade of C or higher. The grade point average for the courses in Requirements 7 and 8 must be at least 2.00. 

% 	- need: check whether a course was taken for letter grade (missing def). check student passes a course with C or higher. list of courses for item 7, 8. aggregation.

% Local (each requirement):
% 	1. Required Introductory Courses
% 	CSE 114 Introduction to Object-Oriented Programming
% 	CSE 214 Data Structures
% 	CSE 215 Foundations of Computer Science or CSE 150 Foundations of Computer Science: Honors
% 	CSE 216 Programming Abstractions
% 	CSE 220 Systems Fundamentals I
% 	Note: Students may substitute the four courses CSE 160, CSE 161, CSE 260 and CSE 261 for the three courses CSE 114, CSE 214 and CSE 216.

% 	- needed: required courses, substitute logic/rule.

% 	2. Required Advanced Courses
% 	CSE 303 Introduction to the Theory of Computation or CSE 350 Theory of Computation: Honors
% 	CSE 310 Computer Networks
% 	CSE 316 Fundamentals of Software Development
% 	CSE 320 Systems Fundamentals II
% 	CSE 373 Analysis of Algorithms or CSE 385 Analysis of Algorithms: Honors
% 	CSE 416 Software Engineering

% 	- needed: required courses

% 	3. Computer Science Electives
% 	Four upper-division technical CSE electives, each of which must carry at least three credits. Technical electives do not include teaching practica (CSE 475), the senior honors project (CSE 495, 496), and courses designated as non-technical in the course description (such as CSE 301).

% 	- needed: select number of courses from a list (upper-division technical CSE electives, assuming the list exists) and constaint on the courses selected.

% 	4. AMS 151, AMS 161 Applied Calculus I, II
% 	Note: The following alternate calculus course sequences may be substituted for AMS 151, AMS 161 in major requirements or prerequisites: MAT 125, MAT 126, MAT 127, or MAT 131, MAT 132. Equivalency for MAT courses achieved through the Mathematics Placement Examination is accepted to meet MAT course requirements.

% 	- needed: required courses, substitution logic/rule, placement exam.

% 	5. One of the following:
% 	MAT 211 Introduction to Linear Algebra
% 	AMS 210 Applied Linear Algebra

% 	- needed: required courses

% 	6. Both of the following:
% 	AMS 301 Finite Mathematical Structures
% 	AMS 310 Survey of Probability and Statistics or AMS 311 Probability Theory

% 	- needed: required courses

% 	7. At least one of the following natural science lecture/laboratory combinations:
% 	BIO 201/204 or BIO 202/204 or BIO 203/204 or CHE 131/133 or CHE 152/154 or PHY 126/133 or PHY 131/133 or PHY 141/133

% 	- needed: required courses

% 	8. Additional natural science courses selected from above and the following list:
% 	AST 203, AST 205, CHE 132, CHE 321, CHE 322, CHE 331, CHE 332, GEO 102, GEO 103, GEO 112, GEO 113, GEO 122, PHY 125, PHY 127, PHY 132, PHY 134, PHY 142, PHY 251, PHY 252

% 	- needed: required courses


% 	9. Professional Ethics
% 	CSE 312 Social, Legal, and Ethical Issues in Computing

% 	- needed: required courses


% 	10. Upper-Division Writing Requirement: CSE 300 Technical Communications
% 	All degree candidates must demonstrate technical writing skills at a level that would be acceptable in an industrial setting. To satisfy the requirement, students must pass CSE 300, a course that requires the completion of various writing assignments, including at least one significant technical paper.

% 	- needed: required courses

% 	Note: All students are encouraged to discuss their program with an undergraduate advisor. In Requirement 2 above, CSE/ESE double majors may substitute ESE 440, ESE 441 Electrical Engineering Design I, II for CSE 416 Software Engineering provided that the design project contains a significant software component. Approval of the Department of Computer Science is required.

% 	- needed: 


% Data Structure:

% From global 1 and 3, need relation taken(Student, Course, Grade, Where).

% From global 1,2,3, need relation course(CourseNumber, Credit)

% Rules:

% For each requirement 1-10, use: req{x}(S) :- ... For example, req1(S) :- ...
% requirement 8 does not have any constaints other than the credit requirement (global 2)

% 2 rules for global 1.

% 1 rule for global 3 (The grade point average for the courses in Requirements 7 and 8 must be at least 2.00.)
% other requirements in global 3 should be in each individual requirement.

% Things missing:
% defintions: letter grade, upper-division technical CSE electives, gpa scale.

% undefined predicates used: c_or_higher, taken_letter_grade, calculate_gpa, total_credits, upper_div_tech_cse_elective, req7_combination, additional_natural_science, req1_course, req2_course, req3_course.

% Check if a student S has taken course C satisfying Constraint
satisfied(S, C, Constraint) :-
  taken(S, C, G, Where, When),
  call(Constraint, S, C, Grade, Where).

% Constraint: C or higher
c_or_higher(G) :- member(G, [a, a-, b+, b, b-, c+, c]).
grade_c_or_higher(_S, _C, G, _Where) :- c_or_higher(G).

% Constraint: taken for letter grade
is_letter_grade(G) :- member(G, [a, a-, b+, b, b-, c+, c, d+, d, f]).
taken_letter_grade(S, C) :-
  satisfied(S, C, grade_c_or_higher).

req1(S) :-
  satisfied(S, cse114, grade_c_or_higher),
  c_or_higher(S, cse214),
  (c_or_higher(S, cse215); c_or_higher(S, cse150)),
  c_or_higher(S, cse216),
  c_or_higher(S, cse220).

% Substitute sequence
req1(S) :-
  c_or_higher(S, cse160),
  c_or_higher(S, cse161),
  c_or_higher(S, cse260),
  c_or_higher(S, cse261),
  (c_or_higher(S, cse215); c_or_higher(S, cse150)),
  c_or_higher(S, cse220).

req2(S) :-
  (c_or_higher(S, cse303); c_or_higher(S, cse350)),
  c_or_higher(S, cse310),
  c_or_higher(S, cse316),
  c_or_higher(S, cse320),
  (c_or_higher(S, cse373); c_or_higher(S, cse385)),
  c_or_higher(S, cse416).

req3(S) :-
  aggregate_all(count, (
    taken(S, C, _, _),
    upper_div_tech_cse_elective(C),
    course(C, Cr),
    Cr >= 3,
    c_or_higher(S, C)
  ), N),
  N >= 4.

req4(S) :-
  (c_or_higher(S, ams151), c_or_higher(S, ams161));
  (c_or_higher(S, mat125), c_or_higher(S, mat126), c_or_higher(S, mat127));
  (c_or_higher(S, mat131), c_or_higher(S, mat132)).

req5(S) :-
  (c_or_higher(S, mat211); c_or_higher(S, ams210)).

req6(S) :-
  c_or_higher(S, ams301),
  (c_or_higher(S, ams310); c_or_higher(S, ams311)).

req7(S) :-
  req7_combination(C1, C2),
  taken_letter_grade(S, C1),
  taken_letter_grade(S, C2),
  calculate_gpa(S, [C1, C2], GPA),
  GPA >= 2.0.

% Req 8: Aggregates all valid science courses to check total credit > 9 and GPA > 2.0
req8(S) :-
  setof(C, (
    taken_letter_grade(S, C),
    (req7_combination(_, C); req7_combination(C, _); additional_natural_science(C))
  ), L),
  calculate_gpa(S, UniqueL, GPA),
  GPA >= 2.0,
  total_credits(L, TotalCr),
  TotalCr >= 9.

req9(S) :-
  c_or_higher(S, cse312).

req10(S) :-
  c_or_higher(S, cse300).

% Credit req1: At least 24 credits from items 1 to 3 completed at Stony Brook.
credit_req1(S) :-
  setof(C, (
    (req1_course(C); req2_course(C); req3_course(C)),
    taken(S, C, _, stony_brook)
  ), L),
  total_credits(L, TotalCr),
  TotalCr >= 24.

% Credit req2: At least 18 credits from items 2 and 3 completed at Stony Brook.
credit_req2(S) :-
  setof(C, (
    (req2_course(C); req3_course(C)),
    taken(S, C, _, stony_brook)
  ), L),
  total_credits(L, TotalCr),
  TotalCr >= 18.