"""This scripts generate boiler plates for using docker compose files. Input: Template files, Output: Docker compose files."""
from string import Template
import shutil
import sys

DOCKER_TEMPLATE=sys.argv[1]
OUTPUT_DOCKER = sys.argv[2]
ENV_TEMPLATE = sys.argv[3]
OUTPUT_ENV = sys.argv[4]
DOCKER_SCRIPT_TEMPLATE = sys.argv[5]
OUTPUT_DOCKER_SCRIPT = sys.argv[6]

vars_sub = {
    'pgpassword': 'example',
    'pgdatabase': 'example',
    'pghost': 'example',
    'pgport': 'example',
    'pguser': 'example'
}

with open(ENV_TEMPLATE, 'r', encoding='UTF-8') as f:
    src = Template(f.read())
    result = src.substitute(vars_sub)

with open(OUTPUT_ENV, "w", encoding='UTF-8') as f:
    f.write(result)

shutil.copy(DOCKER_TEMPLATE, OUTPUT_DOCKER)

shutil.copy(DOCKER_SCRIPT_TEMPLATE, OUTPUT_DOCKER_SCRIPT)
