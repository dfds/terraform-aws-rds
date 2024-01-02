
# SOURCE_MODULE_PATH="../../"
# OUTPUT_FILE="$PWD/temp/doc.json"

SCRIPTS_PATH="/scripts"
SOURCE_MODULE_PATH="/input"

# TERRAFORM
OUTPUT_JSON_FILE="/tmp/doc.json"
SOURCE_JSON_DOC=$OUTPUT_JSON_FILE
GENERATED_TF_MODULE_DATA="/tmp/tf_module.json"
TF_MODULE_TEMPLATE="/templates/main.tf.template"
TF_MODULE_OUTPUT="/output/terraform/module.tf"
TF_OUTPUT_FOLDERS="/output/terraform"
mkdir -p $TF_OUTPUT_FOLDERS

# DOCKER
DOCKER_COMPOSE_TEMPLATE="/templates/compose.yml.template"
DOCKER_COMPOSE_OUTPUT="/output/docker/compose.yml"
DOCKER_ENV_TEMPLATE="/templates/.env.template"
DOCKER_ENV_OUTPUT="/output/docker/.env"
DOCKER_SCRIPT_TEMPLATE="/templates/restore.sh.template"
DOCKER_SCRIPT_OUTPUT="/output/docker/restore.sh"
DOCKER_OUTPUT_FOLDERS="/output/docker"

mkdir -p $DOCKER_OUTPUT_FOLDERS

if [ -z "$(ls -A $SOURCE_MODULE_PATH)" ]; then
   echo "Empty"
else
   echo "Not Empty"
fi
# TODO: CHECK FOR output folder mounted


# terraform-docs json --show "all" $SOURCE_MODULE_PATH --output-file $OUTPUT_JSON_FILE

# mkdir -p temp

# 1) Generate docs for all modules in a repo
terraform-docs json --show "all" $SOURCE_MODULE_PATH --output-file $OUTPUT_JSON_FILE

 # 2) Generate files
# mkdir -p auto-generated/terraform
python3 $SCRIPTS_PATH/generate_module.py $SOURCE_JSON_DOC $GENERATED_TF_MODULE_DATA $TF_MODULE_TEMPLATE $TF_MODULE_OUTPUT

# mkdir -p auto-generated/docker
python3 $SCRIPTS_PATH/generate_docker.py $DOCKER_COMPOSE_TEMPLATE $DOCKER_COMPOSE_OUTPUT $DOCKER_ENV_TEMPLATE $DOCKER_ENV_OUTPUT $DOCKER_SCRIPT_TEMPLATE $DOCKER_SCRIPT_OUTPUT

# mkdir -p auto-generated/pipeline
# TODO: generate pipeline

# rm -rf temp