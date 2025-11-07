# Usage Examples

This document provides detailed examples of using both the Terraform-only and Terragrunt approaches.

## Terraform Problems - Step by Step

### Scenario 1: Deploy Dev Environment

```bash
# 1. Deploy network infrastructure
cd terraform-problems/dev/network
terraform init
terraform apply -auto-approve

# 2. Deploy application (must wait for network to complete)
cd ../app
terraform init
terraform apply -auto-approve

# 3. Check outputs
terraform output
```

**Problems encountered:**
- Had to run commands in two separate directories
- Must ensure network completes before starting app
- Backend configuration is duplicated in both modules

### Scenario 2: Change Network CIDR

```bash
# 1. Update network CIDR in dev/network/terraform.tfvars
cd terraform-problems/dev/network
echo 'network_cidr = "10.0.1.0/16"' > terraform.tfvars
echo 'subnet_count = 2' >> terraform.tfvars

# 2. Apply network changes
terraform apply -auto-approve

# 3. PROBLEM: Must also update app module!
cd ../app
# Edit terraform.tfvars manually to change network_cidr to "10.0.1.0/16"
nano terraform.tfvars

# 4. Apply app changes
terraform apply -auto-approve
```

**Problems encountered:**
- Network CIDR is duplicated in two places
- Easy to forget to update the app module
- Risk of configuration drift

### Scenario 3: Deploy All Environments

```bash
# Must run 6 separate commands in sequence
cd terraform-problems

# Dev
cd dev/network && terraform init && terraform apply -auto-approve
cd ../app && terraform init && terraform apply -auto-approve

# Staging
cd ../../staging/network && terraform init && terraform apply -auto-approve
cd ../app && terraform init && terraform apply -auto-approve

# Prod
cd ../../prod/network && terraform init && terraform apply -auto-approve
cd ../app && terraform init && terraform apply -auto-approve
```

**Problems encountered:**
- 6 separate commands needed
- Easy to make mistakes in the sequence
- No way to apply all at once

## Terragrunt Solution - Step by Step

### Scenario 1: Deploy Dev Environment

```bash
# Single command deploys both modules in correct order!
cd terragrunt-solution/environments/dev
terragrunt run-all apply --terragrunt-non-interactive
```

**Benefits:**
- One command for entire environment
- Automatic dependency ordering
- Backend configuration is automatic

### Scenario 2: Change Network CIDR

```bash
# 1. Update network CIDR in dev/network/terragrunt.hcl
cd terragrunt-solution/environments/dev/network
nano terragrunt.hcl
# Change: network_cidr = "10.0.1.0/16"

# 2. Apply changes to entire environment
cd ..
terragrunt run-all apply --terragrunt-non-interactive
```

**Benefits:**
- Network CIDR only defined once
- App automatically gets updated value via dependency
- No risk of configuration drift

### Scenario 3: Deploy All Environments

```bash
# Option 1: Deploy all environments with one command
cd terragrunt-solution/environments
terragrunt run-all apply --terragrunt-non-interactive

# Option 2: Deploy environments individually
cd dev
terragrunt run-all apply --terragrunt-non-interactive
cd ../staging
terragrunt run-all apply --terragrunt-non-interactive
cd ../prod
terragrunt run-all apply --terragrunt-non-interactive
```

**Benefits:**
- Can deploy all environments at once
- Or deploy individual environments easily
- Same simple commands for any environment

## Advanced Examples

### Example 1: View Dependency Graph

```bash
cd terragrunt-solution/environments/dev/app
terragrunt graph-dependencies
```

Output:
```
digraph {
  "app" ;
  "app" -> "network";
  "network" ;
}
```

### Example 2: Plan Before Apply

```bash
# Plan all modules without applying
cd terragrunt-solution/environments/dev
terragrunt run-all plan
```

### Example 3: Apply Only Network Module

```bash
# Apply just the network module
cd terragrunt-solution/environments/dev/network
terragrunt apply
```

### Example 4: Selective Module Apply

```bash
# Apply only specific modules using wildcards
cd terragrunt-solution/environments
terragrunt run-all apply --terragrunt-include-dir "*/network"
```

### Example 5: Validate All Configurations

```bash
# Validate all Terraform configurations
cd terragrunt-solution/environments
terragrunt run-all validate
```

### Example 6: Format All Code

```bash
# Format all .tf files
cd terragrunt-solution/modules
terraform fmt -recursive
```

### Example 7: Working with Outputs

```bash
# Get outputs from network module
cd terragrunt-solution/environments/dev/network
terragrunt output

# Get outputs from app module
cd ../app
terragrunt output
```

### Example 8: Mock Outputs for Planning

The app module uses mock outputs for planning even when network doesn't exist:

```hcl
dependency "network" {
  config_path = "../network"

  mock_outputs = {
    network_cidr = "10.0.0.0/16"
    network_id   = "mock-network-id"
  }
}
```

This allows you to run `terragrunt plan` in the app directory without deploying network first.

### Example 9: Destroy in Reverse Order

```bash
# Destroy all modules in reverse dependency order
cd terragrunt-solution/environments/dev
terragrunt run-all destroy --terragrunt-non-interactive
```

Terragrunt automatically destroys app before network (reverse of apply order).

## Comparing Operations

| Operation | Terraform Commands | Terragrunt Commands |
|-----------|-------------------|---------------------|
| **Init all modules** | `cd mod1 && terraform init`<br>`cd ../mod2 && terraform init` | `terragrunt run-all init` |
| **Plan all modules** | `cd mod1 && terraform plan`<br>`cd ../mod2 && terraform plan` | `terragrunt run-all plan` |
| **Apply all modules** | `cd mod1 && terraform apply`<br>`cd ../mod2 && terraform apply` | `terragrunt run-all apply` |
| **Apply with deps** | Manual ordering required | Automatic! |
| **Pass outputs** | Manual data sources or vars | `dependency` block |
| **Destroy all** | Destroy in reverse manually | `terragrunt run-all destroy` |
| **Format code** | `terraform fmt -recursive` | `terraform fmt -recursive` |
| **Validate** | Per directory | `terragrunt run-all validate` |

## Tips and Best Practices

### Tip 1: Use Mock Outputs

Always define mock outputs for dependencies to enable planning without deploying dependencies first.

### Tip 2: Use run-all for Environment Operations

When working with an entire environment, always use `run-all` commands from the environment directory.

### Tip 3: Individual Module Changes

For small changes to a single module, you can apply just that module. Terragrunt will still check dependencies.

### Tip 4: Review Plans Before Applying

Always run `terragrunt run-all plan` before `apply` to see what will change.

### Tip 5: Use --terragrunt-non-interactive in CI/CD

For automated deployments, always use the `--terragrunt-non-interactive` flag.

### Tip 6: Leverage Environment Variables

Set environment variables for common settings:

```bash
export TERRAGRUNT_NON_INTERACTIVE=true
export TF_INPUT=false
```

### Tip 7: Parallel Execution

Terragrunt automatically parallelizes independent modules. Use `--terragrunt-parallelism` to control:

```bash
terragrunt run-all apply --terragrunt-parallelism 2
```

### Tip 8: Debug with Logging

Enable detailed logging for troubleshooting:

```bash
terragrunt run-all apply --terragrunt-log-level debug
```

## Real-World Scenarios

### Scenario: Adding a New Environment

**Terraform approach:**
1. Copy entire dev directory
2. Rename to new environment name
3. Update backend paths in all modules
4. Update environment values in all files
5. Update terraform.tfvars in all modules

**Terragrunt approach:**
1. Create new environment directory
2. Copy terragrunt.hcl files (3 small files)
3. Update environment name and values
4. Done! Modules are already shared

### Scenario: Adding a New Module

**Terraform approach:**
1. Create module in one environment
2. Copy to all other environments
3. Add backend configuration
4. Wire up dependencies manually
5. Repeat for each environment

**Terragrunt approach:**
1. Create module once in modules/
2. Create terragrunt.hcl in each environment referencing it
3. Define dependencies
4. Done! Module automatically available to all environments

### Scenario: Updating Terraform Version

**Terraform approach:**
1. Update version constraint in each module's main.tf
2. Test each environment separately
3. 18 files to update

**Terragrunt approach:**
1. Update version in root terragrunt.hcl provider generation
2. Regenerate for all modules
3. 1 file to update

## Conclusion

These examples demonstrate how Terragrunt simplifies common operations and reduces the potential for errors by:

1. Eliminating code duplication
2. Automating dependency management
3. Providing powerful multi-module commands
4. Maintaining consistency across environments
5. Reducing maintenance burden
