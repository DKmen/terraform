# Terraform Project

This project contains Terraform configurations for setting up infrastructure on AWS.

## Project Structure

### Files and Directories
  
- **learning-pdf/**: Directory for learning materials in PDF format.

- **terraform/**: Main directory for Terraform configurations.
  - `.terraform.lock.hcl`: Lock file for Terraform.
  - `main.tf`: Main Terraform configuration file.
  - **modules/**: Directory for custom Terraform modules.
    - **server/**: Server module.
      - `main.tf`: Main configuration for the server module.
      - `outputs.tf`: Outputs for the server module.
      - `variables.tf`: Variables for the server module.
    - **vpc/**: VPC module.
      - `main.tf`: Main configuration for the VPC module.
      - `output.tf`: Outputs for the VPC module.
      - `variables.tf`: Variables for the VPC module.
  - `outputs.tf`: Outputs for the main Terraform configuration.
  - `terraform.tf`: Main Terraform configuration file.
  - `terraform.tfstate`: Current state of the Terraform-managed infrastructure.
  - `terraform.tfstate.backup`: Backup of the Terraform state file.
  - **terraform.tfstate.d/**: Directory for Terraform state files.
    - `devlopment/`: State files for the development environment.
  - `variables.tf`: Variables for the main Terraform configuration.

## Usage

1. **Initialize Terraform**:
    ```sh
   terraform init
    ```

2. **Plan Terraform Configuration**:
    ```sh
   terraform plan
    ```

3. **Apply Terraform Configuration**:
    ```sh
    terraform apply
     ```
    
4. **Destroy Terraform Configuration**:
    ```sh
    terraform destroy
    ```
    