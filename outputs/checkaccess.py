## LLM generated code: python solgen.py --path problems/check_access.json
def checkAccess(s, op, obj, ROLES, SR, PR):
    return {r for r in ROLES if (s, r) in SR and ((op, obj), r) in PR}