# terraform-nsxt
very simple, and single flat tf file to get NSX-T configured with a sample T1 router and associated logical segments and DFW policy

Step1: 
install terraform on your chosen linux box

TER_VER=`curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'`
wget https://releases.hashicorp.com/terraform/${TER_VER}/terraform_${TER_VER}_linux_amd64.zip
unzip terraform_${TER_VER}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
which terraform
terraform -v

Step2:
In the same dir as the main.tf file
Initialise the requried NSX-T provider
  "terraform init"

Step3:
Validate the plan
  "terraform plan"
  
Step4:
Execute the plan
  "terraform apply"
  
Step5:
Delete the plan (if necessary)
  "terraform destroy"
  
NOTE:
Be sure to check in the Manager portion of the NSX-T UI, as pre NSX-T 3.2, TF uses the management API (not the policy API).
In time, Policy API (and UI) will show the TF created objects
