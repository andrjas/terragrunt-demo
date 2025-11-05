# Terragrunt Demo Project

A comprehensive demonstration of Terragrunt features and how it solves common Terraform problems.

## Overview

This repository demonstrates the benefits of using Terragrunt by showing two approaches side-by-side:

1. **`terraform-problems/`** - Traditional Terraform approach with common pain points
2. **`terragrunt-solution/`** - Terragrunt approach that solves those problems

## Quick Links

- [Terraform Problems Documentation](./terraform-problems/README.md)
- [Terragrunt Solution Documentation](./terragrunt-solution/README.md)

## What's Inside

### Terraform Problems (`terraform-problems/`)

A traditional Terraform setup demonstrating common issues:

- **Backend duplication** - Same backend config repeated 6 times
- **Code duplication** - Identical module code copied across environments
- **Manual dependency management** - No automatic ordering of resource creation
- **Manual output passing** - Values must be manually copied between modules
- **Complex multi-module operations** - Need to run multiple commands

### Terragrunt Solution (`terragrunt-solution/`)

An improved setup using Terragrunt that solves all the above problems:

- **DRY backend config** - Backend defined once and reused
- **Shared modules** - Single module code reused across all environments
- **Automatic dependencies** - Modules run in correct order automatically
- **Automatic output passing** - Outputs automatically flow between modules
- **Simple multi-module operations** - Single command to apply all modules

## Features Demonstrated

### 1. DRY Backend Configuration

**Problem (Terraform):**
```hcl
# Repeated in every module
terraform {
  backend "local" {
    path = "terraform-dev-network.tfstate"
  }
}
```

**Solution (Terragrunt):**
```hcl
# Defined once in root terragrunt.hcl
remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }
}
```

### 2. Code Reusability

**Problem:** 18 Terraform files across 6 module instances

**Solution:** 2 shared modules referenced by 7 Terragrunt config files

### 3. Dependency Management

**Problem (Terraform):**
```bash
# Must manually run in order
cd dev/network && terraform apply
cd ../app && terraform apply
```

**Solution (Terragrunt):**
```hcl
# In app/terragrunt.hcl
dependency "network" {
  config_path = "../network"
}

inputs = {
  network_cidr = dependency.network.outputs.network_cidr
}
```

```bash
# Runs in correct order automatically
terragrunt run-all apply
```

### 4. Environment Hierarchy

**Problem:** No shared configuration between environments

**Solution:**
```
Root terragrunt.hcl          → Backend & provider config
  └── Environment terragrunt.hcl   → Environment name
      └── Module terragrunt.hcl    → Module-specific values
```

### 5. Multi-Module Commands

**Problem (Terraform):**
```bash
# 6 separate commands needed
cd dev/network && terraform apply
cd ../app && terraform apply
cd ../../staging/network && terraform apply
cd ../app && terraform apply
cd ../../prod/network && terraform apply
cd ../app && terraform apply
```

**Solution (Terragrunt):**
```bash
# Single command
cd environments && terragrunt run-all apply
```

## Prerequisites

- **Terraform** 1.0 or later
- **Terragrunt** 0.54.0 or later (for terragrunt-solution only)

### Install Terraform

```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### Install Terragrunt

```bash
# macOS
brew install terragrunt

# Linux
wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.0/terragrunt_linux_amd64
chmod +x terragrunt_linux_amd64
sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
```

## Getting Started

### Try the Terraform Problems

See the issues firsthand:

```bash
cd terraform-problems/dev/network
terraform init
terraform apply

cd ../app
terraform init
terraform apply
```

Notice:
- You must run commands in the correct order
- Backend config is duplicated
- network_cidr is hardcoded in both modules

### Try the Terragrunt Solution

Experience the improvements:

```bash
cd terragrunt-solution/environments/dev
terragrunt run-all apply
```

Notice:
- Single command applies both modules in correct order
- No backend configuration in modules
- Outputs automatically passed between modules

## Project Structure

```
.
├── README.md                          # This file
├── terraform-problems/                # Traditional Terraform approach
│   ├── README.md
│   ├── dev/
│   │   ├── network/                   # Dev network (duplicated code)
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   ├── outputs.tf
│   │   │   └── terraform.tfvars
│   │   └── app/                       # Dev app (duplicated code)
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── terraform.tfvars
│   ├── staging/                       # Same structure (more duplication!)
│   └── prod/                          # Same structure (even more duplication!)
│
├── terragrunt-solution/               # Terragrunt approach
│   ├── README.md
│   ├── terragrunt.hcl                 # Root config (backend & provider)
│   ├── modules/
│   │   ├── network/                   # Shared network module (single copy!)
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── app/                       # Shared app module (single copy!)
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── environments/
│       ├── dev/
│       │   ├── terragrunt.hcl         # Dev environment config
│       │   ├── network/
│       │   │   └── terragrunt.hcl     # Points to shared module
│       │   └── app/
│       │       └── terragrunt.hcl     # Points to shared module + dependencies
│       ├── staging/
│       │   └── ...                    # Similar structure
│       └── prod/
│           └── ...                    # Similar structure
│
└── .github/
    └── workflows/
        └── test.yml                   # CI/CD tests for both approaches
```

## Running Tests

### Local Testing

Test Terraform problems:
```bash
cd terraform-problems/dev/network
terraform init && terraform apply -auto-approve

cd ../app
terraform init && terraform apply -auto-approve
```

Test Terragrunt solution:
```bash
cd terragrunt-solution/environments/dev
terragrunt run-all apply --terragrunt-non-interactive
```

### GitHub Actions

The repository includes a comprehensive GitHub Actions workflow that:

1. Tests the Terraform approach across all environments
2. Tests the Terragrunt approach across all environments
3. Compares file counts between approaches
4. Runs integration tests
5. Verifies dependency ordering

The workflow runs automatically on push and pull requests.

## Common Commands

### Terraform Approach

```bash
# Initialize
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy
```

### Terragrunt Approach

```bash
# Initialize all modules
terragrunt run-all init

# Plan all modules
terragrunt run-all plan

# Apply all modules (in dependency order)
terragrunt run-all apply

# Apply specific module
terragrunt apply

# Destroy all modules (in reverse dependency order)
terragrunt run-all destroy

# Show dependency graph
terragrunt graph-dependencies
```

## Key Takeaways

| Aspect | Terraform Only | Terragrunt |
|--------|---------------|------------|
| **Backend Config** | Duplicated in every module | Defined once, reused everywhere |
| **Module Code** | Duplicated per environment | Single shared module |
| **Dependencies** | Manual ordering required | Automatic dependency resolution |
| **Output Passing** | Manual copying of values | Automatic output injection |
| **Multi-Module Ops** | Multiple commands | Single `run-all` command |
| **Lines of Code** | ~300 lines | ~200 lines |
| **Files** | 24 files | 13 files |
| **Maintainability** | Update multiple files | Update once, apply everywhere |
| **Learning Curve** | Moderate | Moderate (+ Terragrunt syntax) |

## Benefits of Terragrunt

1. **DRY (Don't Repeat Yourself)** - Write configuration once, use everywhere
2. **Reduced Maintenance** - Update shared modules, not individual environments
3. **Automatic Dependencies** - No manual coordination needed
4. **Consistent Structure** - Enforced patterns across all environments
5. **Powerful Commands** - `run-all` operations across multiple modules
6. **Safe Defaults** - Mock outputs for planning, proper dependency order
7. **Flexible Backends** - Easy to switch backend configuration
8. **Better Organization** - Clear separation between code and configuration

## When to Use Terragrunt

Terragrunt is particularly valuable when you have:

- Multiple environments (dev, staging, prod)
- Multiple modules with dependencies
- Repeated configuration across environments
- Complex infrastructure with many components
- Need for consistent structure across teams
- Desire to follow DRY principles

## Learn More

- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Terragrunt Best Practices](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/)

## Contributing

This is a demo project, but suggestions and improvements are welcome! Feel free to:

- Open issues for questions or problems
- Submit pull requests with improvements
- Share how you've adapted this for your needs

## License

MIT License - See [LICENSE](LICENSE) file for details

## Additional Resources

- **Blog posts**: Compare approaches and explain Terragrunt benefits
- **Video tutorials**: Walk through both approaches
- **Real-world examples**: Scale this pattern to production use cases

---

**Star this repository** if you found it helpful! ⭐
