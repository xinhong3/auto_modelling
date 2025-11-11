:- import aggregate_all/3 from c_aggregate.

is_letter_grade(G) :-
  letter_gpa(G, _).

passed(S, Cid) :-
  student(S, _, _),
  taken(S, Cid, G, _, _),
  is_letter_grade(G),
  G \= 'F'.

passed(S, Cid) :-
  student(S, _, _),
  taken(S, Cid, 'P', _, _).

passed_with_c_or_higher(S, Cid) :-
  student(S, _, _),
  taken(S, Cid, G, _, _),
  letter_gpa(G, PointPerCredit),
  PointPerCredit >= 2.00.

is_cse_upper_electives(C) :-
  course(C, cse, Num, _),
  Num >= 300.

course_taken_for_letter_grade(S, C) :-
  student(S, _, _),
  taken(S, C, G, _, _),
  is_letter_grade(G).

total_quality_points(S, TotalQP) :-
  student(S, _, _),
  aggregate_all(
    sum(QP),
    ( taken(S, C, Grade, _, _),
      is_letter_grade(Grade),
      course(C, _, _, Credit),
      letter_gpa(Grade, PointPerCredit),
      QP is Credit * PointPerCredit
    ),
    TotalQP
  ).

total_letter_credits(S, TotalLC) :-
  student(S, _, _),
  aggregate_all(
    sum(LCf),
    ( taken(S, C, Grade, _, _),
      is_letter_grade(Grade),
      course(C, _, _, LetterCredit),
      LCf is LetterCredit
    ),
    TotalLC
  ).

gpa(S, GPA) :-
  total_quality_points(S, TotalQP),
  total_letter_credits(S, TotalLC),
  TotalLC > 0,
  GPA is TotalQP / TotalLC.

req1_option1(S) :-
  student(S, _, _),
  aggregate_all(
    count,
    (passed_with_c_or_higher(S, C), course_group(cse_maj_req1_opt1, C)),
    NReq
  ),
  NReq is 4,
  (passed_with_c_or_higher(S, C2); course_group(cse_maj_req1_choice, C2)).

req1_option2(S) :-
  student(S, _, _),
  aggregate_all(
    count,
    (passed_with_c_or_higher(S, C), course_group(cse_maj_req1_opt2, C)),
    NReq
  ),
  NReq is 5,
  (passed_with_c_or_higher(S, C2), course_group(cse_maj_req1_choice, C2)).

req(cse_major, 1, S) :-
  req1_option1(S).
req(cse_major, 1, S) :-
  req1_option2(S).

req(cse_major, 2, S) :-
  student(S, _, _),
  aggregate_all(
    count,
    (passed_with_c_or_higher(S, C), course_group(cse_maj_req2, C)),
    NCore
  ),
  NCore is 4,
  (passed_with_c_or_higher(S, C2); course_group(cse_maj_req2_theory, C2)),
  (passed_with_c_or_higher(S, C3); course_group(cse_maj_req2_algo, C3)).

req(cse_major, 3, S) :-
  student(S, _, _),
  aggregate_all(
    count,
    (passed_with_c_or_higher(S, C), is_cse_upper_electives(C)),
    N
  ),
  N >= 4.

req(cse_major, 4, S) :-
  student(S, _, _),
  aggregate_all(
    count,
    (passed_with_c_or_higher(S, C), course_group(cse_maj_req4_seq1, C)),
    N
  ),
  N is 2.

req(cse_major, 4, S) :-
  student(S, _, _),
  aggregate_all(
    count,
    (passed_with_c_or_higher(S, C), course_group(cse_maj_req4_seq2, C)),
    N
  ),
  N is 3.

req(cse_major, 4, S) :-
  student(S, _, _),
  aggregate_all(
    count,
    (passed_with_c_or_higher(S, C), course_group(cse_maj_req4_seq3, C)),
    N
  ),
  N is 2.

req(cse_major, 5, S) :-
  passed_with_c_or_higher(S, mat221).
req(cse_major, 5, S) :-
  passed_with_c_or_higher(S, mat222).

req(cse_major, 6, S) :-
  passed_with_c_or_higher(S, ams301),
  (passed_with_c_or_higher(S, ams310) ; passed_with_c_or_higher(S, ams311)).

sci_combo(bio201, bio204).
sci_combo(bio202, bio204).
sci_combo(bio203, bio204).
sci_combo(che131, che133).
sci_combo(che152, che154).
sci_combo(phy126, phy133).
sci_combo(phy131, phy133).
sci_combo(phy141, phy133).

req(cse_major, 7, S) :-
  student(S, _, _),
  sci_combo(Lecture, Lab),
  course(Lecture, _, _, Cr1),
  course(Lab, _, _, Cr2),
  taken(S, Lecture, Grade1, _, _),
  letter_gpa(Grade1, PointPerCredit1),
  taken(S, Lab, Grade2, _, _),
  letter_gpa(Grade2, PointPerCredit2),
  QP is Cr1 * PointPerCredit1 + Cr2 * PointPerCredit2,
  LC is Cr1 + Cr2,
  GPA is QP / LC,
  GPA >= 2.00.

req7or8_course(C) :-
  course_group(cse_maj_req7, C).
req7or8_course(C) :-
  course_group(cse_maj_req8, C).

req(cse_major, 8, S) :-
  student(S, _, _),
  aggregate_all(
    sum(Cr),
    (course(C, _, _, Cr), req7or8_course(C), taken(S, C, _, _, _)),
    TotalCr
  ),
  TotalCr >= 9,
  aggregate_all(
    sum(QP),
    (course(C2, _, _, Cr2), req7or8_course(C2),
     taken(S, C2, Grade, _, _),
     letter_gpa(Grade, PointPerCredit),
     QP is Cr2 * PointPerCredit),
    TotalQP
  ),
  GPA is TotalQP / TotalCr,
  GPA >= 2.00.

req(cse_major, 9, S) :-
  passed_with_c_or_higher(S, cse312).

req(cse_major, 10, S) :-
  passed_with_c_or_higher(S, cse300).

course_group_one_to_three(C) :-
  course_group(GroupName, C),
  sub_atom(GroupName, _, _, _, cse_maj_req1).
course_group_one_to_three(C) :-
  course_group(GroupName, C),
  sub_atom(GroupName, _, _, _, cse_maj_req2).
course_group_one_to_three(C) :-
  is_cse_upper_electives(C).

course_group_two_or_three(C) :-
  course_group(GroupName, C),
  sub_atom(GroupName, _, _, _, cse_maj_req2).
course_group_two_or_three(C) :-
  is_cse_upper_electives(C).

req(cse_major, residency, S) :-
  student(S, _, _),
  aggregate_all(
    sum(Cr1_),
    (taken(S, C, _, stonybrook, _),
     course_group_one_to_three(C),
     course(C, _, _, Cr1_)),
    Cr1
  ),
  Cr1 >= 24,
  aggregate_all(
    sum(Cr2_),
    (taken(S, C2, _, stonybrook, _),
     course_group_two_or_three(C2),
     course(C2, _, _, Cr2_)),
    Cr2
  ),
  Cr2 >= 18.

req(cse_major, total_credits, S) :-
  student(S, _, _),
  aggregate_all(
    sum(Cr),
    (taken(S, C, _, _, _), course(C, _, _, Cr)),
    TotalCr
  ),
  TotalCr >= 80.

req(cse_major, all, S) :-
  req(cse_major, 1, S),
  req(cse_major, 2, S),
  req(cse_major, 3, S),
  req(cse_major, 4, S),
  req(cse_major, 5, S),
  req(cse_major, 6, S),
  req(cse_major, 7, S),
  req(cse_major, 8, S),
  req(cse_major, 9, S),
  req(cse_major, 10, S),
  req(cse_major, residency, S),
  req(cse_major, total_credits, S).
