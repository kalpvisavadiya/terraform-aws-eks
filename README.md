# Terraform AWS EKS

Terraform starter project for provisioning an AWS VPC and an Amazon EKS cluster with a managed node group.

## Resources created

- VPC across two Availability Zones
- Public and private subnets
- One NAT Gateway
- Amazon EKS cluster
- EKS managed worker node group
- S3 remote Terraform state bucket, bootstrapped by the workflow with public access blocked, encryption, and versioning enabled

## 1. GitHub repository setup

Create a repository named `terraform-aws-eks` and push this project to its `main` branch.

In **Settings → Secrets and variables → Actions**, create these repository secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Create this repository variable:

- `AWS_REGION` = `ap-south-1`

Do not put real credentials in source files, commit history, workflow YAML, or `.tfvars` files.

## 2. AWS permissions

The IAM user behind the access keys needs permission to manage the resources in this project, including VPC/EC2 networking, EKS, IAM roles and policies used by the EKS modules, and the S3 state bucket. For a real environment, prefer a dedicated deployment identity with reviewed least-privilege permissions. Do not use root-account access keys.

The workflow bootstraps the state bucket named `<AWS_ACCOUNT_ID>-<github-owner-lowercase>-terraform-state`. The bucket name must be globally unique. If the name is already owned by another AWS account, change the `STATE_BUCKET` expression in the workflow before running it.

## 3. Run the workflow

1. Push the files to GitHub.
2. Open **Actions → Terraform AWS EKS → Run workflow**.
3. Select `plan` first. Review the plan and estimated cost.
4. Run the workflow again and select `apply` only when ready to create resources.

The workflow only runs a plan/apply from manual dispatch. Pull requests run formatting and validation checks.

## 4. Connect kubectl

After a successful apply, use the cluster name shown in Terraform outputs. The default name is `devops-eks-dev-cluster`.

On a computer with AWS CLI and kubectl installed, and AWS credentials configured for the same account, run:

```bash
aws eks update-kubeconfig --region ap-south-1 --name devops-eks-dev-cluster
kubectl get nodes
```

## Cost and cleanup

This creates chargeable AWS resources, including EKS, EC2 worker nodes, and a NAT Gateway. Review current AWS pricing for your region before applying.

There is intentionally no automatic destroy job. To remove the cluster, review the Terraform plan carefully and run `terraform destroy` from a trusted environment using the same remote state and permissions. Delete the S3 state bucket only after infrastructure cleanup and after confirming you no longer need its state history.

## Notes

- `cluster_version` is set to `1.32` as a starting default. Before applying, confirm that this Kubernetes version is supported by EKS in your selected region and update it if needed.
- Keep `.terraform.lock.hcl` committed after the first successful `terraform init` for reproducible provider selections.
- GitHub repository secrets are separate per repository; the application repository must be configured separately if it needs to use the same AWS credentials.
