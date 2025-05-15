import os
import boto3

ec2 = boto3.client('ec2')
sns = boto3.client('sns')

def lambda_handler(event, context):
    topic_arn = os.environ['SNS_TOPIC_ARN']
    instance_ids = os.environ['INSTANCE_IDS'].split(',')

    stopped = []
    already_stopped = []

    statuses = ec2.describe_instance_status(InstanceIds=instance_ids, IncludeAllInstances=True)
    for inst in statuses.get('InstanceStatuses', []):
        state = inst['InstanceState']['Name']
        iid = inst['InstanceId']
        if state == 'running':
            ec2.stop_instances(InstanceIds=[iid])
            stopped.append(iid)
        else:
            already_stopped.append(iid)

    message = ""
    if stopped:
        message += f"Instances stopped: {', '.join(stopped)}.\n"
    if already_stopped:
        message += f"Instances already stopped: {', '.join(already_stopped)}."
    if not message:
        message = "No instances found."

    sns.publish(
        TopicArn=topic_arn,
        Subject='EC2 Shutdown Report',
        Message=message
    )