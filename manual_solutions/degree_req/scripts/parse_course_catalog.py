import re
import csv
import sys
import os
import requests
from bs4 import BeautifulSoup

DIR_PARSED = os.path.join('..', 'documents', 'parsed')

BASE_URL = (
    "https://www.stonybrook.edu/sb/bulletin/current-fall24/"
    "academicprograms/{prog}/courses.php"
)

KEY_PROGRAM = 'program'
KEY_NUMBER = 'number'
KEY_NAME = 'name'
KEY_CREDIT = 'credit'
KEY_PREREQUISITE = 'prerequisite'
KEY_PRE_OR_COREQUISITE = 'pre- or corequisite'
KEY_COREQUISITE = 'corequisite'
KEY_ANTIREQUISITE = 'anti-requisite'
KEY_ADVISORY_PREREQUISITE = 'advisory prerequisite'

FIELDNAMES = [
    KEY_PROGRAM,
    KEY_NUMBER,
    KEY_NAME,
    KEY_CREDIT,
    KEY_PREREQUISITE,
    KEY_PRE_OR_COREQUISITE,
    KEY_COREQUISITE,
    KEY_ANTIREQUISITE,
    KEY_ADVISORY_PREREQUISITE,
]

COURSE_HEADER_RE = re.compile(r'^([A-Z]{3})\s+(\d+):\s*(.+)$')

REQ_LABEL_RE = re.compile(
    r'(Advisory\s+Pre-?\s*-\s*or\s+Corequisite[s]?|'   # Advisory Pre- or Corequisite:
    r'Advisory\s+Prerequisite[s]?|'                   # Advisory Prerequisite(s):
    r'Pre-?\s*-\s*or\s+Corequisite[s]?|'              # Pre- or Corequisite(s):
    r'Prerequisite[s]?|'                              # Prerequisite(s):
    r'Corequisite[s]?|'                               # Corequisite(s):
    r'Anti-requisite[s]?'                             # Anti-requisite(s):
    r')\s*:',
    re.IGNORECASE
)

def get_credits(text: str) -> str:
    m = re.search(r'(\d+(?:-\d+)?)\s+credit[s]?', text, re.IGNORECASE)
    return m.group(1) if m else ''

def parse_requisite_line(line: str, rec: dict) -> None:
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
        elif 'pre-' in label and 'corequisite' in label:
            # Distinguish "Pre- or Corequisite"
            if label.startswith('advisory'):
                # "Advisory Pre- or Corequisite" → keep in advisory column
                key = KEY_ADVISORY_PREREQUISITE
            else:
                key = KEY_PRE_OR_COREQUISITE
        elif label.startswith('corequisite'):
            key = KEY_COREQUISITE
        elif label.startswith('anti-requisite'):
            key = KEY_ANTIREQUISITE
        elif label.startswith('advisory'):
            key = KEY_ADVISORY_PREREQUISITE
        else:
            print(f"Warning: unrecognized label '{label}' in line: {line}")
            continue

        if rec[key]:
            rec[key] += ' ' + text
        else:
            rec[key] = text

def parse_course_div(course_div):
    h3 = course_div.find('h3')
    if not h3:
        return None

    header_text = h3.get_text(" ", strip=True).replace('\xa0', ' ')
    m = COURSE_HEADER_RE.match(header_text)
    if not m:
        print(f"Warning: could not parse course header: {header_text}")
        return None

    program_code = m.group(1).upper()
    number = m.group(2)
    name = m.group(3).strip()

    rec = {
        KEY_PROGRAM: program_code,
        KEY_NUMBER: number,
        KEY_NAME: name,
        KEY_CREDIT: '',
        KEY_PREREQUISITE: '',
        KEY_PRE_OR_COREQUISITE: '',
        KEY_COREQUISITE: '',
        KEY_ANTIREQUISITE: '',
        KEY_ADVISORY_PREREQUISITE: '',
    }

    for p in course_div.find_all('p'):
        text = p.get_text(" ", strip=True)
        if not text:
            continue

        lower = text.lower()

        if 'credit' in lower and not rec[KEY_CREDIT]:
            c = get_credits(text)
            if c:
                rec[KEY_CREDIT] = c

        if 'requisite' in lower:
            parse_requisite_line(text, rec)

    return rec

def fetch_program_html(prog: str) -> str:
    url = BASE_URL.format(prog=prog)
    resp = requests.get(url)
    resp.raise_for_status()
    return resp.text

def parse_program(prog: str):
    html = fetch_program_html(prog)
    soup = BeautifulSoup(html, 'html.parser')

    rows = []
    for course_div in soup.find_all('div', class_='course'):
        rec = parse_course_div(course_div)
        if rec:
            rows.append(rec)

    return rows

# ----------------- main -----------------

def main():
    if len(sys.argv) < 2:
        print("Usage: python scrape_courses.py <prog1> [<prog2> ...]")
        print("Example: python scrape_courses.py cse mat geo")
        sys.exit(1)

    os.makedirs(DIR_PARSED, exist_ok=True)
    prog_list = [p.lower() for p in sys.argv[1:]]

    for prog in prog_list:
        rows = parse_program(prog)

        if not rows:
            print(f"No courses parsed for program '{prog}'.")
            continue

        # Use program code from parsed data (e.g., GEO, MAT, CSE)
        filename = f"{prog.lower()}_courses.csv"
        out_path = os.path.join(DIR_PARSED, filename)

        with open(out_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=FIELDNAMES)
            writer.writeheader()
            for r in rows:
                writer.writerow(r)

        print(f"Wrote {len(rows)} rows to {out_path}")

if __name__ == '__main__':
    main()
