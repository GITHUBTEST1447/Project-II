## Project Title

Containerized Application

## Overview

Wrote a module for deploying a containerized application architecture on AWS  
Made use of the following services:  

- AWS ECS (ASG, ECS Service, ECS Cluster, ECS Task Definition)
- AWS ELB (Target Group, Listener, ALB)
- AWS VPC (Public/Private Subnets, NAT Gateway, Route Tables, Internet Gateways, Security Groups)  
- AWS RDS (Tables, snapshots)
- AWS Route53 (Setup ALIAS record to point to the ELB)  

## General Requirements

- An AWS account
- Terraform
- ~$3/month
- Creating your own root module to call

## Terraform Requirements

- An already created VPC. Easy to use AWS' official VPC module to deploy this. Supply the VPC ID in the module call.  
- A Route 53 Hosted Zone. Supply the hosted zone's FQDN in the module call.  
- A SSL/TLS certificate from AWS ACM. Supply in the module call.  
- A AWS region. Supply in the module call.  
- An RDS snapshot with the people table created. Very simple.
- A secret in AWS secrets manager that contains the RDS snapshots credentials.
