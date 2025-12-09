import csv

# 4. AMS 151, AMS 161 Applied Calculus I, II
# Note: The following alternate calculus course sequences may be substituted for AMS 151, AMS 161 in major requirements or prerequisites: MAT 125, MAT 126, MAT 127, or MAT 131, MAT 132. Equivalency for MAT courses achieved through the Mathematics Placement Examination is accepted to meet MAT course requirements.

# 5. One of the following:
# MAT 211 Introduction to Linear Algebra
# AMS 210 Applied Linear Algebra

# 6. Both of the following:
# AMS 301 Finite Mathematical Structures
# AMS 310 Survey of Probability and Statistics or AMS 311 Probability Theory 

# 7. At least one of the following natural science lecture/laboratory combinations:
# BIO 201/204 or BIO 202/204 or BIO 203/204 or CHE 131/133 or CHE 152/154 or PHY 126/133 or PHY 131/133 or PHY 141/133

# 8. Additional natural science courses selected from above and the following list:
# AST 203, AST 205, CHE 132, CHE 321, CHE 322, CHE 331, CHE 332, GEO 102, GEO 103, GEO 112, GEO 113, GEO 122, PHY 125, PHY 127, PHY 132, PHY 134, PHY 142, PHY 251, PHY 252

# Note: The courses selected in 7 and 8 must carry at least 9 credits.

# course = {('CSE 114', 3), ('CSE 214', 3), ('CSE 215', 3),
#           ('CSE 150', 3), ('CSE 216', 3), ('CSE 220', 3),
#           ('CSE 160', 3), ('CSE 161', 3), ('CSE 260', 3), ('CSE 261', 3),
#           ...}

# maps letter grades to point values
letter_point = {
    'A': 4.00,
    'A-': 3.67,
    'B+': 3.33,
    'B': 3.00,
    'B-': 2.67,
    'C+': 2.33,
    'C': 2.00,
    'C-': 1.67,
    'D+': 1.33,
    'D': 1.00,
    'F': 0.00,
    'Q': 0.0
}

taken = set()

# loading the courses taken by students
with open("../input/taken.csv", newline="") as f:
    reader = csv.reader(f)
    for s, c, g, where, when in reader:
        taken.add((s, c, g, where, when))

def C_or_higher(grade): # where grade g is C or higher
  return grade in letter_point and letter_point[grade] >= letter_point['C']

def passed(grade): # where grade g is D or higher
  return grade in letter_point and letter_point[grade] >= letter_point['D'] or grade == 'P'

def passed_C_or_higher(s, c): # whether student s has taken course c with grade C or higher
  return any(C_or_higher(grade) for (s2, c2, grade, where_, when_) in taken if s2==s and c2==c)

def gpa_calc(s, courses_taken): # calculate GPA for student s and a list of courses taken by s.
  total_points = sum(letter_point[grade] * cr 
                     for (s2, c2, grade, where_, when_) in taken for (c, cr) in courses_taken
                     if s2 == s and c2 == c)
  total_credits = sum(cr for (c_, cr) in courses_taken)
  return total_points / total_credits if total_credits > 0 else 0.0

courses_taken_bob = {(c, cr) for (s, c, g, where_, when_) in taken for c, cr in  if s == 'bob'}

print(gpa_calc('bob', courses_taken_bob))

req4_course_sequences = (
    (('ams151', 3), ('ams161', 3)),
    (('mat125', 3), ('mat126', 3)),
    (('mat127', 3), ('mat131', 3), ('mat132', 3))
)

def req4_seq_sat(s, seq) -> bool:
  return all(passed_C_or_higher(s, c) for c, credit_ in seq)

def req4(s) -> bool:
  return any((req4_seq_sat(s, seq) for seq in req4_course_sequences))

def req5(s) -> bool: # bob should fail req5 since he did not take any of those
  return passed_C_or_higher(s, 'mat211') or passed_C_or_higher(s, 'ams210')

def req6(s) -> bool:
  return passed_C_or_higher(s, 'ams301') and (passed_C_or_higher(s, 'ams310') or passed_C_or_higher(s, 'ams311'))

req7_sci_combos = (
    (('bio201', 3), ('bio204', 3)),
    (('bio202', 3), ('bio204', 3)),
    (('bio203', 3), ('bio204', 3)),
    (('che131', 3), ('che133', 3)),
    (('che152', 3), ('che154', 3)),
    (('phy126', 3), ('phy133', 3)),
    (('phy131', 3), ('phy133', 3)),
    (('phy141', 3), ('phy133', 3))
)

# The grade point average for the courses in Requirements 7 and 8 must be at least 2.00. 

def req7(s) -> bool:
  course_req = any(passed(s, lecture[0]) and passed(s, lab[0]) for lecture, lab in req7_sci_combos)
  total_req7_courses_taken = (c for sci_combo in req7_sci_combos for c in sci_combo if passed(s, c))
  total_credits = sum(cr for _, cr in total_req7_courses_taken)
  
  return course_req and gpa_req >= 2.0

req8_courses = {
  ('ast203', 3), ('ast205', 3), ('che132', 3), ('che321', 3), 
  ('che322', 3), ('che331', 3), ('che332', 3), ('geo102', 3), 
  ('geo103', 3), ('geo112', 3), ('geo113', 3), ('geo122', 3), 
  ('phy125', 3), ('phy127', 3), ('phy132', 3), ('phy134', 3), 
  ('phy142', 3), ('phy251', 3), ('phy252', 3)
}

def req8(s) -> bool:
  return sum(cr for (c, cr) 
              in req8_courses | {(c, cr) for sci_combo in req7_sci_combos for c, cr in sci_combo}
              if passed(s, c)) >= 9

print(req4('bob'))
print(req5('bob'))
print(req6('bob'))
print(req7('bob'))
print(req8('bob'))