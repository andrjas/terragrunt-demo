# Terragrunt Solution

This directory demonstrates how Terragrunt solves common Terraform problems by keeping your code DRY (Don't Repeat Yourself).

## Structure

```
terragrunt-solution/
├── terragrunt.hcl              # Root config: backend & provider generation
├── modules/
│   ├── network/                # Shared network module (used by all envs)
│   └── app/                    # Shared app module (used by all envs)
└── environments/
    ├── dev/
    │   ├── terragrunt.hcl      # Dev environment config
    │   ├── network/
    │   │   └── terragrunt.hcl  # Dev network config
    │   └── app/
    │       └── terragrunt.hcl  # Dev app config (depends on network)
    ├── staging/
    │   ├── terragrunt.hcl      # Staging environment config
    │   ├── network/
    │   │   └── terragrunt.hcl  # Staging network config
    │   └── app/
    │       └── terragrunt.hcl  # Staging app config (depends on network)
    └── prod/
        ├── terragrunt.hcl      # Production environment config
        ├── network/
        │   └── terragrunt.hcl  # Production network config
        └── app/
            └── terragrunt.hcl  # Production app config (depends on network)
```

## How Terragrunt Solves the Problems

### 1. **DRY Backend Configuration**
Instead of repeating backend config in every module, it's defined once in the root `terragrunt.hcl`:
```hcl
remote_state {
  backend = "local"
  config = {
    path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}
```
Terragrunt automatically generates the backend configuration for each module.

### 2. **DRY Module Code**
Only **one copy** of each module exists in `modules/`:
- `modules/network/` - Used by all environments
- `modules/app/` - Used by all environments

Each environment's `terragrunt.hcl` points to the shared module:
```hcl
terraform {
  source = "../../../modules/network"
}
```

### 3. **Automatic Dependency Management**
Dependencies are declared in `terragrunt.hcl`:
```hcl
dependency "network" {
  config_path = "../network"
}

inputs = {
  network_cidr = dependency.network.outputs.network_cidr
}
```
Terragrunt automatically:
- Runs network before app
- Passes outputs from network to app
- No manual copying of values!

### 4. **Environment Hierarchy**
Configuration inherits from parent directories:
- Root `terragrunt.hcl` - Backend & provider config
- Environment `terragrunt.hcl` - Environment name
- Module `terragrunt.hcl` - Module-specific values

### 5. **Easy Multi-Module Operations**
Apply all modules in an environment with proper dependency order:
```bash
cd environments/dev
terragrunt run-all apply
```

Or apply across ALL environments:
```bash
cd environments
terragrunt run-all apply
```

## Quick Start

### Prerequisites
- Terraform 1.0+
- Terragrunt

### Apply Dev Environment

1. **Apply everything in dev with one command:**
   ```bash
   cd environments/dev
   terragrunt run-all apply
   ```

2. **Or apply modules individually:**
   ```bash
   cd environments/dev/network
   terragrunt apply

   cd ../app
   terragrunt apply  # Network will be applied automatically if needed!
   ```

### Apply Staging Environment

```bash
cd environments/staging
terragrunt run-all apply
```

### Apply Production Environment

```bash
cd environments/prod
terragrunt run-all apply
```

### Apply Everything

```bash
cd environments
terragrunt run-all apply
```

### View Plan for All Modules

```bash
cd environments/dev
terragrunt run-all plan
```

### Destroy Everything in an Environment

```bash
cd environments/dev
terragrunt run-all destroy
```

## Key Terragrunt Features Demonstrated

1. **Remote State Management** - Automatic backend configuration
2. **DRY Configuration** - Shared modules and configuration
3. **Dependency Management** - Automatic module dependencies
4. **Configuration Inheritance** - Hierarchical configuration
5. **Multi-Module Commands** - `run-all` to operate on multiple modules
6. **Output Passing** - Automatic output passing between modules
7. **Mock Outputs** - For planning without dependencies
8. **Provider Generation** - Automatic provider configuration

## Comparison with Terraform-Only Approach

| Problem | Terraform-Only | Terragrunt Solution |
|---------|---------------|---------------------|
| Backend config | Duplicated 6 times | Defined once |
| Module code | Duplicated 6 times | Defined once (2 modules) |
| Dependencies | Manual coordination | Automatic |
| Running multiple modules | 6 separate commands | One `run-all` command |
| Updating network CIDR | Update 2 files per env | Automatic output passing |
| Adding new environment | Copy all files | Create 3 small config files |
