TerraformVersion = "1.1.8"

# Installing terraform in the linux agent
install_terraform_linux:
	wget https://releases.hashicorp.com/terraform/$(TerraformVersion)/terraform_$(TerraformVersion)_linux_amd64.zip
	unzip terraform_$(TerraformVersion)_linux_amd64.zip

# Installing terraform in the windows agent
install_terraform_win:
	powershell -ExecutionPolicy Bypass wget https://releases.hashicorp.com/terraform/$(TerraformVersion)/terraform_$(TerraformVersion)_windows_amd64.zip -outfile terraform_$(TerraformVersion)_windows_amd64.zip
	powershell -ExecutionPolicy Bypass expand-archive -Path terraform_$(TerraformVersion)_windows_amd64.zip -DestinationPath . -Force

# Validating the terraform	
terraform_validate:
	./terraform version 
	./terraform init 
	./terraform validate 

# Creating terraform plan
terraform_plan:
	./terraform plan

# Applying the created terraform plan
terraform_apply:
	./terraform version
	./terraform init 
	./terraform apply -auto-approve

# Destroying infrastructure using the terraform plan
terraform_destroy:
	./terraform destroy -auto-approve

# Cleaning the unused/unwanted files from the agent
terraform_clean:
	rm -rf .terraform
	rm -rf "terraform"
	rm -rf ".git"
	rm -rf ".gitignore"
	rm -rf "terraform_$(TerraformVersion)_linux_amd64.zip"