:- import load_csv/2 from proc_files.
:- import format/2 from format.
:- import member/2 from basics.

:- [degree_requirement].

:- load_csv('../../input/letter_gpa.csv',   letter_gpa(atom,float)).
:- load_csv('../../input/course.csv',       course(atom,atom,integer,integer)).
:- load_csv('../../input/student.csv',      student(atom,atom,atom)).
:- load_csv('../../input/taken.csv',        taken(atom,atom,atom,atom,integer)).
:- load_csv('../../input/course_group.csv', course_group(atom,atom)).

prog_req(cse_major, [1,2,3,4,5,6,7,8,9,10,residency,total_credits]).

check_req(Prog, S) :-
  ( gpa(S, GPA)
  -> write('GPA = '), write(GPA), nl
  ;  write('GPA: not available'), nl
  ),
  prog_req(Prog, Ns),
  member(N, Ns),
  write(Prog), write(' requirement '),
  ( req(Prog, N, S)
  -> write(N), write(': yes'), nl
  ;  write(N), write(': no'),  nl
  ),
  fail ; true.