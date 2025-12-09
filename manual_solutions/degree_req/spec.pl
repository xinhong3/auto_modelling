% Degree Requirements Specification (core rules only)
% undefined predicates: calculate_gpa, total_credits, upper_div_tech_cse_elective, 
%   natural_science_combination, additional_natural_science, req1_course, req2_course, req3_course.

% Check if a student S has taken course C satisfying Constraint
required(S, C, Constraint) :-
  taken(S, C, G, Where),
  call(Constraint, S, C, G, Where).

% Constraint: C or higher
grade_is_c_or_higher(G) :- member(G, [a, a-, b+, b, b-, c+, c]).
c_or_higher(_S, _C, G, _Where) :- grade_is_c_or_higher(G).

% Constraint: taken for letter grade ('letter grade' is not defined in degree req)
grade_is_letter_grade(G) :- member(G, [a, a-, b+, b, b-, c+, c, d+, d, f]).
taken_letter_grade(_S, _C, G, _Where) :- grade_is_letter_grade(G).

% Degree Requirements Rules. The English for each requirement is in the comments above each rule.
% For letter grade and c or higher constraints, see the comments in req1. We don't repeat them
%   in each requirement to avoid redundancy. But they apply to all requirements as specified.

% 1. Required Introductory Courses
%  CSE 114, CSE 214, CSE 215 or CSE 150, CSE 216, CSE 220
% All courses taken to satisfy Requirements 1 through 10 must be taken for a letter grade.
% The courses in Requirements 1-6, 9, and 10 must be passed with a letter grade of C or higher.
req1(S) :-
  required(S, cse114, c_or_higher),
  required(S, cse214, c_or_higher),
  (required(S, cse215, c_or_higher); required(S, cse150, c_or_higher)),
  required(S, cse216, c_or_higher),
  required(S, cse220, c_or_higher).

% Note: Students may substitute the four courses CSE 160, CSE 161, CSE 260 and CSE 261 
% for the three courses CSE 114, CSE 214 and CSE 216.
req1(S) :-
  required(S, cse160, c_or_higher),
  required(S, cse161, c_or_higher),
  required(S, cse260, c_or_higher),
  required(S, cse261, c_or_higher),
  (required(S, cse215, c_or_higher); required(S, cse150, c_or_higher)),
  required(S, cse220, c_or_higher).

% 2. Required Advanced Courses
% 	CSE 303 or CSE 350, CSE 310, CSE 316, CSE 320, CSE 373 or CSE 385, CSE 416
req2(S) :-
  (required(S, cse303, c_or_higher); required(S, cse350, c_or_higher)),
  required(S, cse310, c_or_higher),
  required(S, cse316, c_or_higher),
  required(S, cse320, c_or_higher),
  (required(S, cse373, c_or_higher); required(S, cse385, c_or_higher)),
  required(S, cse416, c_or_higher).

% 3. Computer Science Electives
% 	Four upper-division technical CSE electives, each of which must carry at least three credits. 
req3(S) :-
  setof(C, Cr^(   % not to bind Cr, only care about C.
    upper_div_tech_cse_elective(C),
    course(C, Cr),
    Cr >= 3,
    required(S, C, c_or_higher)
  ), L),
  length(L, N),
  N >= 4.

% 4. AMS 151, AMS 161
% Note: The following alternate calculus course sequences may be substituted for AMS 151, AMS 161 
%  in major requirements or prerequisites: MAT 125, MAT 126, MAT 127, or MAT 131, MAT 132. 
%  Equivalency for MAT courses achieved through the Mathematics Placement Examination is 
%  accepted to meet MAT course requirements.
req4(S) :-
  (required(S, ams151, c_or_higher), required(S, ams161, c_or_higher));
  (required(S, mat125, c_or_higher), required(S, mat126, c_or_higher), required(S, mat127, c_or_higher));
  (required(S, mat131, c_or_higher), required(S, mat132, c_or_higher)).
  % passed_math_placement_exam_for_req4(S). % Placeholder for placement exam logic

% 5. One of the following:
%     MAT 211 or AMS 210
req5(S) :-
  (required(S, mat211, c_or_higher); required(S, ams210, c_or_higher)).

% 6. Both of the following:
%     AMS 301 and AMS 310 or AMS 311
req6(S) :-
  required(S, ams301, c_or_higher),
  (required(S, ams310, c_or_higher); required(S, ams311, c_or_higher)).

% 7. At least one of the following natural science lecture/laboratory combinations...
% All courses taken to satisfy Requirements 1 through 10 must be taken for a letter grade.
req7(S) :-
  natural_science_combination(C1, C2),
  required(S, C1, taken_letter_grade),
  required(S, C2, taken_letter_grade).

% 8. Additional natural science courses selected from above and the following list...
% All courses taken to satisfy Requirements 1 through 10 must be taken for a letter grade.
% The grade point average for the courses in Requirements 7 and 8 must be at least 2.00.
% The courses selected in 7 and 8 must carry at least 9 credits.
req8(S) :-
  setof(C, Other^(    % not to bind Other (the other course), only care about C.
    (natural_science_combination(Other, C); natural_science_combination(C, Other); additional_natural_science(C)),
    required(S, C, taken_letter_grade)
  ), L),
  calculate_gpa(S, L, GPA), GPA >= 2.0,
  total_credits(L, TotalCr), TotalCr >= 9.

% 9. Professional Ethics: CSE 312
req9(S) :-
  required(S, cse312, c_or_higher).

% 10. Upper-Division Writing Requirement: CSE 300
req10(S) :-
  required(S, cse300, c_or_higher).

% Credit req1: At least 24 credits from items 1 to 3 completed at Stony Brook.
credit_req1(S) :-
  setof(C, G^(  % not to bind G, only care about C. Same in credit_req2.
    (req1_course(C); req2_course(C); req3_course(C)),
    taken(S, C, G, stonybrook)
  ), L),
  total_credits(L, TotalCr), TotalCr >= 24.

% Credit req2: At least 18 credits from items 2 and 3 completed at Stony Brook.
credit_req2(S) :-
  setof(C, G^(
    (req2_course(C); req3_course(C)),
    taken(S, C, G, stonybrook)
  ), L),
  total_credits(L, TotalCr), TotalCr >= 18.