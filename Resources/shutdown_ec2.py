#!/usr/bin/env python
# Written by: Robert J.

import boto3
import os
import json

#######################################
### Global Vars #######################
#######################################

region      = os.environ.get('region', 'us-west-2')
environment = os.environ.get('environment', 'Development')
account     = os.environ.get('account')
sns_arn     = os.environ.get('sns_arn')

ec2         = boto3.client('ec2', region_name=region)
ec2_asg     = boto3.client('autoscaling')
sns         = boto3.client('sns')

#######################################
### Main Function #####################
#######################################

def main():
    asgs = check_ec2_asg()

    filters = [
        {
            'Name': 'instance-state-name',
            'Values': [
                'running'
            ]
        },
        {
            'Name': 'tag:Environment',
            'Values': [
                environment
            ]
        }
    ]

    ec2_ids = check_ec2(filters)

    if asgs or ec2_ids:
        sns_message = "Auto Scaling Groups affected =\n" + \
                      str(asgs) + \
                      "\nEC2 Instances Affected =\n" + \
                      str(ec2_ids)
        sns_push(account, sns_arn, sns_message)

    return None


#######################################
### Program Specific Functions ########
#######################################

def check_ec2_asg():
    print('Getting ASG List...')
    tags = ec2_asg.describe_tags()['Tags']

    asgs = [
        asg['ResourceId'] for asg in tags if asg['Value'] == 'Development'
    ]

    print(
        json.dumps(
            asgs,
            sort_keys=True,
            indent=4
        )
    )

    if asgs:
        print('Scaling down ASGs...')
        scale_down_asgs(asgs)

        print('ASGs Scaled')
        return asgs
    else:
        print('No ASGs found.')
        return None


def check_ec2(filters):
    print('Getting instance list...')
    instances   = lookup_instance_data(filters)
    ids         = get_ids(instances)

    print(
        json.dumps(
            ids,
            sort_keys=True,
            indent=4
        )
    )

    if instances:
        print('Stopping instances...')
        stop_instances(ids)

        print('Instances stopped.')
        return ids
    else:
        print('No instances found.')
        return None

def scale_down_asgs(asgs):
    for asg in asgs:
        ec2_asg.update_auto_scaling_group(
            AutoScalingGroupName=asg,
            MinSize=0,
            MaxSize=0,
            DesiredCapacity=0
        )


def lookup_instance_data(filters):
    data        = ec2.describe_instances(Filters=filters)
    flat_data   = [
        instances for reservation in [
            reservations['Instances'] for reservations in data['Reservations']
        ] for instances in reservation
    ]

    return flat_data


def get_ids(instances):
    ids = [
        i['InstanceId'] for i in instances if 'InstanceLifecycle' not in i.keys()
    ]

    return ids


def stop_instances(ids):
    ec2.stop_instances(InstanceIds=ids)


def sns_push(account, sns_arn, sns_message):
    print("Pushing to SNS...")
    sns_subject = 'Lambda Infrastructure Control Enacted - ' + account
    response    = sns.publish(
        TopicArn=sns_arn,
        Message=sns_message,
        Subject=sns_subject,
        MessageStructure='string'
    )

    return response


#######################################
### Execution #########################
#######################################

if __name__ == "__main__":
    main()

def execute_me_lambda(event, context):
    out = main()
    return out
