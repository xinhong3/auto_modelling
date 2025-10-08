# OpenAi api ref: https://platform.openai.com/docs/api-reference/responses/create?lang=python

import yaml
import argparse
from openai import OpenAI

# load configurations, just api keys for now
with open("config.yaml", "r") as file:
    config = yaml.safe_load(file)
api_keys = config.get("api_keys", {})

OPENAI_API_KEY = api_keys.get("openai")

# base class for LLM providers, only interfaces (should have a generate method)
class LLMProvider: pass

class OpenAIProvider(LLMProvider):
    def __init__(self, *args, **kwargs):
        self.client = OpenAI(*args, **kwargs)

    def generate(self,
                 prompt=None,
                 messages=None,
                 model="gpt-4.1",
                 temperature=0.0,               # should be in [0, 2]
                 max_tokens=None,
                 **kwargs):
        if messages is None:
            messages = [{"role": "user", "content": prompt or ""}]
        resp = self.client.chat.completions.create(
            model=model,
            messages=messages,
            temperature=temperature,
            max_tokens=max_tokens,
            **kwargs
        )

        # do some parsing here
        content = (resp.choices[0].message.content or "")
        return content, resp        # return the content text and the full response for now

def main():     # a minimal test
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default="gpt-4.1")
    ap.add_argument("--prompt", default="hello world")
    args = ap.parse_args()
    client = OpenAIProvider(api_key=OPENAI_API_KEY)
    text, _ = client.generate(prompt=args.prompt, model=args.model)
    print(text)

if __name__ == "__main__":
    main()