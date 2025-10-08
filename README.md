# High-Level Automatic Code Generation with LLMs
Generate and evaluate high-level code (e.g., Python, Datalog) from natural language descriptions using large language models.

Current problems (problem descriptions in `./problems`):
- `checkAccess`: Implement a function to check user access based on roles and permissions.
- `graduation requirements`: Determine if a student meets graduation requirements based on completed courses.

## Setup
Python version: 3.13.3

To install dependencies (create your own venv first: `python -m venv .venv`):

```
pip install -r requirements.txt
```

Create a config file `./config.yaml` with your OpenAI API key:

```yaml 
api_keys:
  openai: "sk-proj-s..."
```

## Usage
To run the hello world example:

```
python llm.py
```

To generate a solution for a problem:
```
python solgen.py --path ./problems/{problem}.json
```