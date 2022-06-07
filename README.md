# Clark-DevOps_Task
## Task & Case:
- Automate the deployment and management of a Consul cluster
- Choose a concept/tool to automate the deployment and provisioning of the needed AWS resources and servers
- Implement and test your solution
- Provide us with a git repository showing not only the result, but also the way you’ve taken to implement your solution
- The setup and maintenance should be fully automated
- We use AWS for hosting our solution
- For operating our infrastructure we need a HA Consul cluster distributed over at least 3 availability zones
- Consul instances should discover themselves using DNS
# Solution :

## Steps:

- created the vpc , gateway , routing tables and subnets for the cluster network
- Implemented the tags for Consul instances to discover themselves using DNS
- created the ec2 instances and installed consul agent and added the tags to each server 
- create load balancer for the cluster services
- created ssh key-value pair for ec2 access
- Registrator service which is a utility which will automatically register any new services we run to Consul.

## Test:

- To run terraform successfully :
- you should first configure AWS Cli:
```sh
 aws configure
 ```
- then in "variables.tf":
- enter values for : AWS_ACCESS_KEY_ID , AWS_SECRET_ACCESS_KEY , you can configure a terraform.tfvars file for all the values or provide them via prompt once you try to run "terrafom apply"
- you should have ssh keys prepared to be deployed on AWS , and provide thier location in "variables.tf" file :
> - variable "key_name" 
> - variable "public_key_path"
> - variable "priv_key_path" 
- then run :
```sh
terraform init
```
- then run:
```sh
terraform apply -auto-approve
```

- run a sample microservice _which registrator will register for us_

![image](https://user-images.githubusercontent.com/22475831/172407567-e14df33c-e673-4a95-b964-a3525664afa0.png)


## Result:

- Terraform modules applied successfully 

![image](https://user-images.githubusercontent.com/22475831/172407134-829bb75e-edc9-4b5b-840b-ec9c7b137ab4.png)

- Consul is accessible via elb frontend: 

![Capture2](https://user-images.githubusercontent.com/22475831/172406911-6ad2b63a-861c-4b51-959c-1222f7820bee.PNG)

- Consul UI -> Nodes:

![Capture3](https://user-images.githubusercontent.com/22475831/172407396-2319c3cb-a948-471b-9b87-d3f4cf437324.PNG)

- Service is automatically discovered by consul and registrator:

![Capture1](https://user-images.githubusercontent.com/22475831/172406495-597b8377-930d-493a-a815-f9728dce980a.PNG)

