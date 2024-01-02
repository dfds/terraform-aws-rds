FROM python:slim

RUN apt update && \
    apt install -y curl libpq-dev less jq tar


# Adding  GitHub public SSH key to known hosts
RUN ssh -T -o "StrictHostKeyChecking no" -o "PubkeyAuthentication no" git@github.com || true

# Install Terraform-docs
ENV TERRAFORM_DOCS_VERSION=0.17.0

RUN curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz
RUN tar -xzf terraform-docs.tar.gz
RUN chmod +x terraform-docs
RUN mv terraform-docs /usr/local/bin/

COPY scaffolding/scripts /scripts
COPY scaffolding/templates /templates

ENTRYPOINT [ "bash", "/scripts/entrypoint.sh"]
