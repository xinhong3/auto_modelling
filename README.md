# High-Level Automatic Code Generation with LLMs
(**Contributions are welcome!**) Generate and evaluate high-level code (e.g., Python, Datalog) from natural language descriptions using large language models.

We focus on high-level implementations that use either comprehensions or declarative languages that captures/stays close to the problem specification.

## Problems

Current problems (problem descriptions in `./problems`):
- `checkAccess`: Implement a function to check user access based on roles and permissions.
- `graduation requirements`: Determine if a student meets graduation requirements based on completed courses.

A problem JSON file has the following structure (`/problems/template.json`):
```json
{
    "problem": "Short name for the problem, or some id.", 
    "description": "High-level description of the problem.",
    "input_spec": "Specification of the input, note that this is not the actual input.",
    "output_spec": "Specification of the desired output. Possibly includes the language, function signature, or any general structure of the program.",
    "output_language": "The output language, e.g., python, datalog, sql, etc.",
    "input": "This could be optional if the description and input_spec are sufficient."
}
```

## Setup

This was created with Python 3.13.3 but the version should not matter too much.

1. Create your own virtual environment in the project directory:
```
python -m venv .venv
```
2. install dependencies:
```
pip install -r requirements.txt
```
3. Create a config file `./config.yaml` with your OpenAI API key. It should look like this:
```yaml 
api_keys:
  openai: "sk-proj-s..."
```

## Usage
To run the hello world example for LLM interaction:
```
python llm.py
```

To generate a solution for a problem:
```
python solgen.py --path ./problems/{problem}.json
```