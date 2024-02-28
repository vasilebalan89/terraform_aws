# terraform_aws

main.tf file containing the main definitions for resources necessary; 
the first blocks specifies the versioning and provider, and specifies a region, which is not hardcoded, but called from the vars.tf file 
with a VPC and a subnet, with a specific CIDR block; 
also after that we define an internet gateway, which is associated with a routing table, and then the routing table associated with the subnet to have the possibility to ssh into the virtual machines from outside; 
then we have the defitions of the virtaul machines - with values taken mainly from the vars file - AMI type, instance type in terms of available resources, and counting of VMs;  - also a bunch of the default values in vars are overwritten from the tfvars file, a file for centralizing more important parameter in a simpler format - the counting of vms and the type of AWS instance used 

