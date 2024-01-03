FROM python:slim

RUN apt update && \
    apt install -y curl libpq-dev less jq tar unzip


# Adding  GitHub public SSH key to known hosts
RUN ssh -T -o "StrictHostKeyChecking no" -o "PubkeyAuthentication no" git@github.com || true

# ========================================
# TERRAFORM DOCS
# ========================================
ENV TERRAFORM_DOCS_VERSION=0.17.0

RUN curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz
RUN tar -xzf terraform-docs.tar.gz
RUN chmod +x terraform-docs
RUN mv terraform-docs /usr/local/bin/

# ========================================
# TERRAFORM
# ========================================
ENV TERRAFORM_VERSION=1.4.6

RUN curl -L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && rm terraform.zip \
    && mv terraform /usr/local/bin/


COPY scaffolding/scripts /scripts
COPY scaffolding/templates /templates

ENTRYPOINT [ "bash", "/scripts/entrypoint.sh"]
