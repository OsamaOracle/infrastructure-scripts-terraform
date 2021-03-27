# Infra

The idea of this terraform is to have some shared tooling for most (if not all) of our projects.

## Structure

### modules
Contains shared Terraform modules.
Be careful when updating this as it will affect all projects using the module. It's a good practice to start a new version of the module first, if you're doing breaking changes and then eventually migrate individual projects to this new version.

### projects
Contains directories for all projects. You can define per-project modules, variables, etc.

## Running Terraform
At the moment, running Terraform is a manual task, eventually it might be added to a pipeline.

### Prerequisities
- `terraform`
- `terragrunt` - used mainly to avoid code duplication inside the terraform code
- `tfenv` - easy way to manage terraform client versions
- access to AWS

For your convenience you can use the terraform-runner Docker image from https://github.com/OsamaOracle/infrastructure-scripts-terraform
which contains all of the above dependencies. 


### Usage
Get latest terraform version:
```
tfenv install latest
tfenv use latest
```

Switch to a project you want to provision:
```
cd projects/echo
```

Run plan:
```
terragrunt plan
```

Run apply:
```
terragrunt apply
```
