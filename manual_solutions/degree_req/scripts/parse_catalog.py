import re
import csv
import sys
import os
from collections import defaultdict

# DIR_UNPARSED_DOCS = os.path.join('..', 'documents', 'unparsed')
DIR_PARSED = os.path.join('..', 'documents', 'parsed')

KEY_PROGRAM = 'program'
KEY_NUMBER = 'number'
KEY_NAME = 'name'
KEY_CREDIT = 'credit'
KEY_PREREQUISITE = 'prerequisite'
KEY_COREQUISITE = 'corequisite'
KEY_ANTIREQUISITE = 'anti-requisite'
KEY_ADVISORY_PREREQUISITE = 'advisory prerequisite'

FIELDNAMES = [
  KEY_PROGRAM,
  KEY_NUMBER,
  KEY_NAME,
  KEY_CREDIT,
  KEY_PREREQUISITE,
  KEY_COREQUISITE,
  KEY_ANTIREQUISITE,
  KEY_ADVISORY_PREREQUISITE,
]

# Any three-letter program code, e.g., CSE, MAT, AMS, etc.
# Now also capture the course name after the colon on the header line.
COURSE_HEADER_RE = re.compile(r'^([A-Z]{3})\s+(\d+):\s*(.+)$', re.MULTILINE)

REQ_LABEL_RE = re.compile(
  r'(Advisory\s+Pre-?\s*-\s*or\s+Corequisite|'
  r'Advisory\s+Prerequisite[s]?|'
  r'Prerequisite[s]?|'
  r'Corequisite[s]?|'
  r'Anti-requisite)\s*:',
  re.IGNORECASE
)

def split_courses(text):
  """Yield (program, number, name, block_text) for each course."""
  matches = list(COURSE_HEADER_RE.finditer(text))
  for i, m in enumerate(matches):
    start = m.start()
    end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
    block = text[start:end]
    program = m.group(1).upper()
    number = m.group(2)
    name = m.group(3).strip()
    yield program, number, name, block

def get_credits(block):
  """Return credit string like '3' or '0-3' or ''."""
  m = re.search(r'(\d+(?:-\d+)?)\s+credit[s]?', block, re.IGNORECASE)
  return m.group(1) if m else ''

def parse_requisite_line(line, rec):
  """
  Parse a single line that may contain multiple labels like:
  'Advisory Prerequisite: CSE 101  Corequisite: CSE 161'
  and fill fields in the record dict.
  """
  matches = list(REQ_LABEL_RE.finditer(line))
  if not matches:
    return

  for i, m in enumerate(matches):
    label = m.group(1).lower()
    start = m.end()
    end = matches[i + 1].start() if i + 1 < len(matches) else len(line)
    text = line[start:end].strip()
    if not text:
      continue

    if label.startswith('prerequisite') and not label.startswith('advisory'):
      key = KEY_PREREQUISITE
    elif label.startswith('corequisite'):
      key = KEY_COREQUISITE
    elif label.startswith('anti-requisite'):
      key = KEY_ANTIREQUISITE
    elif label.startswith('advisory'):
      key = KEY_ADVISORY_PREREQUISITE
    else:
      print(f"Warning: unrecognized label '{label}' in line: {line}")

    if rec[key]:
      rec[key] += ' ' + text
    else:
      rec[key] = text

def parse_course_block(program, number, name, block):
  """Return a dict with all required fields for one course."""
  rec = {
    KEY_PROGRAM: program,
    KEY_NUMBER: number,
    KEY_NAME: name,
    KEY_CREDIT: get_credits(block),
    KEY_PREREQUISITE: '',
    KEY_COREQUISITE: '',
    KEY_ANTIREQUISITE: '',
    KEY_ADVISORY_PREREQUISITE: '',
  }

  for raw_line in block.splitlines():
    line = raw_line.strip()
    if not line:
      continue
    if 'requisite' in line.lower():
      parse_requisite_line(line, rec)
  return rec

def main():
  if len(sys.argv) < 2:
    print("Usage: python parse_catalog.py <path_to_catalog_text_file>")
    print("Example: python parse_catalog.py ../documents/unparsed/cse_courses.txt")
    sys.exit(1)

  catalog_path = sys.argv[1]

  # Read the whole file into CATALOG_TEXT
  with open(catalog_path, 'r', encoding='utf-8') as f:
    CATALOG_TEXT = f.read()

  rows_by_program = defaultdict(list)

  for program, number, name, block in split_courses(CATALOG_TEXT):
    rows_by_program[program].append(parse_course_block(program, number, name, block))

  # Write one CSV per program, e.g., CSE_courses.csv, MAT_courses.csv, etc.
  for program, rows in rows_by_program.items():
    filename = f'{program.lower()}_courses.csv'
    with open(os.path.join(DIR_PARSED, filename), 'w', newline='', encoding='utf-8') as f:
      writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
      writer.writeheader()
      for r in rows:
        writer.writerow(r)

if __name__ == '__main__':
  main()
