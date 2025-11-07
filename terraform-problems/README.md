# Terraform Problems - Without Terragrunt

This directory demonstrates common problems when using Terraform without Terragrunt for managing multiple environments.

## Structure

```
terraform-problems/
├── dev/
│   ├── network/    # Network infrastructure for dev
│   └── app/        # Application deployment for dev
├── staging/
│   ├── network/    # Network infrastructure for staging
│   └── app/        # Application deployment for staging
└── prod/
    ├── network/    # Network infrastructure for prod
    └── app/        # Application deployment for prod
```

## Problems Demonstrated

### 1. **Backend Configuration Duplication**
Every module requires its own backend configuration block:
```hcl
terraform {
  backend "local" {
    path = "terraform-dev-network.tfstate"
  }
}
```
This is repeated in **6 different files** (3 environments × 2 modules), making it hard to maintain.

### 2. **Code Duplication**
The same Terraform code is duplicated across environments:
- `dev/network/main.tf` is almost identical to `staging/network/main.tf` and `prod/network/main.tf`
- Only the environment name changes between them
- This violates the DRY (Don't Repeat Yourself) principle

### 3. **Manual Dependency Management**
The app module depends on the network module's outputs, but:
- You must manually run `terraform apply` in the network directory first
- Values must be manually copied (e.g., network_cidr) between modules
- Risk of configuration drift if values get out of sync

### 4. **No Environment Hierarchy**
- Each environment has completely separate configuration
- No way to share common values across environments
- Changes to structure require modifying multiple files

### 5. **Difficult Multi-Module Operations**
To apply changes across all modules:
```bash
cd dev/network && terraform apply
cd ../app && terraform apply
cd ../../staging/network && terraform apply
cd ../app && terraform apply
cd ../../prod/network && terraform apply
cd ../app && terraform apply
```

## Testing the Problems

1. **Initialize and apply dev network:**
   ```bash
   cd terraform-problems/dev/network
   terraform init
   terraform apply
   ```

2. **Initialize and apply dev app:**
   ```bash
   cd ../app
   terraform init
   terraform apply
   ```

3. **Notice the manual steps required** and how network_cidr is duplicated in both modules.

4. **Try changing network_cidr** in the network module and see how you must manually update it in the app module too.

## How Terragrunt Solves These Problems

See the `terragrunt-solution/` directory to see how Terragrunt solves all of these issues.
