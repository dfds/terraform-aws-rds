import json
from string import Template
import re
import os
import shutil

absolute_path=os.path.dirname(__file__)
DOCKER_TEMPLATE=os.path.join(absolute_path,"templates/compose.yml.template")
ENV_TEMPLATE=os.path.join(absolute_path,"templates/env.template")
DOCKER_SCRIPT_TEMPLATE=os.path.join(absolute_path, "templates/restore.sh.template")
OUTPUT_DOCKER=os.path.join(absolute_path, "auto-generated/docker/compose.yml")
OUTPUT_ENV=os.path.join(absolute_path, "auto-generated/docker/.env")
OUTPUT_DOCKER_SCRIPT=os.path.join(absolute_path, "auto-generated/docker/restore.sh")

vars_sub = {
    'pgpassword': 'example',
    'pgdatabase': 'example',
    'pghost': 'example',
    'pgport': 'example',
    'pguser': 'example'
}

with open(ENV_TEMPLATE, 'r') as f:
    src = Template(f.read())
    result = src.substitute(vars_sub)

with open(OUTPUT_ENV, "w") as f:
    f.write(result)

shutil.copy(DOCKER_TEMPLATE, OUTPUT_DOCKER)

shutil.copy(DOCKER_SCRIPT_TEMPLATE, OUTPUT_DOCKER_SCRIPT)