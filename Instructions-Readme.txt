#  Note/.  Deploying in China is restrictive and therefore different steps need to be taken.


STEP1.  Ensure you have access to Chinese subscription and set ENV variable for Azure China API Endpoint


(a) az cloud set -n AzureChinaCloud


CHECK:
az cloud show -o table
IsActive    Name             Profile
----------  ---------------  ---------
True        AzureChinaCloud  latest



(b) az login --use-device-code 
(Authenticate)
https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli-interactively

(c) az account set --subscription <subscription_id>

CHECK:
az account list -o table
Name        CloudName        SubscriptionId                        State    IsDefault
----------  ---------------  ------------------------------------  -------  -----------
Some-One   AzureChinaCloud  <subnet_idxxxxxxxxxxxxxxxxxxxxxxxxxx>  Enabled  True


(d) Set Azure API ENV variables
export ARM_ENDPOINT=https://management.chinacloudapi.cn
export ARM_ENVIRONMENT=china


(e)  For CI/CD - Pipeline, you would set up Service Principle (SP) with appropriate permissions and scope

export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"


STEP2.  Run the TF code 



NOTES/.

1. Copilot Security Group Management workflow errors on 'China North' deployed location -    "Provided region_name * doesn't match supported format"
2. Note.  above works fine for "China North 3" deployed
3. Copilot link to controller requires  https inbounc rule on controller NSG (public ip flow, not private ip)
