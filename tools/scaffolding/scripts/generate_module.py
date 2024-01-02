
import json
from string import Template
import re
import os
import sys

SOURCE = sys.argv[1]
INPUT = sys.argv[2]
TEMPLATE = sys.argv[3]
OUTPUT = sys.argv[4]

with open(SOURCE, "r") as f:
    lines = f.readlines()

with open(INPUT, "w") as f:
    for line in lines:
        if not(line.strip("\n") == "<!-- BEGIN_TF_DOCS -->" or line.strip("\n") == "<!-- END_TF_DOCS -->"):
            f.write(line)
inputList=[]
outputList=[]
outputTemplate = """output "$out_name" {
  description = "$output_description"
  value       = try(module.db_instance_example.$out_value, null)
}"""

with open(INPUT, "r") as f: # TODO: source="" should load the latest release!
    data = json.load(f)
    for i in data['inputs']:
        if i['name'].startswith('is_'): # Support to show toggles
            extractedFeature=re.search('(?<=is_)(.*?)(?=_)', i['name'])
            if extractedFeature:
                desc=i['description']
                inputList.append("")
                for line in desc.splitlines():
                    inputList.append('# ' + line)
                feature=extractedFeature.group(0)
                print(feature)
                if i['required'] == False:
                    if i['type'] == 'bool':
                        paramVal=i['default']
                        inputList.append(i['name'] + ' = ' + str(paramVal).lower())
        elif i['required'] == True:
            desc=i['description']
            inputList.append("")
            for line in desc.splitlines():
                inputList.append('# ' + line)
            inputList.append(i['name'] + ' = "example"')
    for y in data['outputs']:
        outputSub = {
            'out_name': y['name'],
            'output_description': y['description'],
            'out_value': y['name'],
        }
        outputList.append(Template(outputTemplate).substitute(outputSub))

vars_sub = {
    'inputs': '\n'.join(inputList),
    'outputs': '\n'.join(outputList),
}

with open(TEMPLATE, 'r') as f:
    src = Template(f.read())
    result = src.substitute(vars_sub)

with open(OUTPUT, "w") as f:
    f.write(result)
