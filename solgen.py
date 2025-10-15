import argparse
import json
import os

from llm import OpenAIProvider, OPENAI_API_KEY


def load_json(path):            # works with relative paths too
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

LANGUAGE_REF = load_json('language_references.json')

def to_text(x):
    if x is None:
        return ""
    if isinstance(x, list):
        return "\n".join(x)
    return str(x)

def build_prompt(d, with_ref=True):
    parts = []
    parts.append(f"Output language: {d.get('output_language','')}")
    parts.append(f"Problem: {d.get('problem','')}")
    if d.get("description"):
        parts.append(f"Description:\n{to_text(d['description'])}")
    if d.get("input_spec"):
        parts.append(f"Input spec:\n{to_text(d['input_spec'])}")
    if d.get("output_spec"):
        parts.append(f"Output spec:\n{to_text(d['output_spec'])}")
    if d.get("_more_instructions"):
        parts.append(f"Extra instructions:\n{to_text(d['_more_instructions'])}")
    if d.get("input"):
        parts.append(f"Input:\n{d['input']}")
    parts.append("Produce only the final program for the language above, with no explanations.")
    parts.append(LANGUAGE_REF.get(d.get('output_lanaguge',''), ''))

    print(parts) # debugging
    return "\n\n".join(parts).strip()

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--path", required=True, help="path to the problem json")
    ap.add_argument("--with_ref", type=int, choices=[0, 1], default=0,
                help="include language reference in prompt (0 or 1)")
    ap.add_argument("--model", default="gpt-4.1")
    ap.add_argument("--temperature", type=float, default=0.0)
    args = ap.parse_args()

    data = load_json(args.path)
    prompt = build_prompt(data, with_ref=bool(args.with_ref))

    api_key = OPENAI_API_KEY or os.getenv("OPENAI_API_KEY")
    client = OpenAIProvider(api_key=api_key)

    # TODO: should also record the full request so it is reproducible
    text, _ = client.generate(
        prompt=prompt,
        model=args.model,
        temperature=args.temperature,
        max_tokens=None,
    )
    print(text)

if __name__ == "__main__":
    main()