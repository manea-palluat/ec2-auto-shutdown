#This Lambda function stops EC2 instances and sends a notification via SNS.

import boto3, os #if you see an error here, don't worry, this code is not executed in this environment but in AWS Lambda which has boto3 installed

ec2 = boto3.client('ec2') #this client allows us to interact with EC2 instances
sns = boto3.client('sns') #and this one with SNS

SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN'] #this is the ARN of the SNS topic where we will send notifications
INSTANCE_IDS  = os.environ['INSTANCE_IDS'].split(',') #this is a list of instance IDs that we want to stop, passed as a comma-separated string in the environment variable

#this function is the entry point for the Lambda function

def lambda_handler(event, context):
    stopped = []
    already = []
    resp = ec2.describe_instance_status(InstanceIds=INSTANCE_IDS, IncludeAllInstances=True)
    for inst in resp['InstanceStatuses']:
        iid   = inst['InstanceId']
        st    = inst['InstanceState']['Name']
        if st == 'running': #if the instance is running...
            ec2.stop_instances(InstanceIds=[iid]) #... we stop it
            stopped.append(iid) #and we add it to the stopped list
        else:
            already.append(iid) #... otherwise we add it to the already stopped list

    #and we send these information to the selected mail
    parts = []
    if stopped:
        parts.append(f"✅ Instances arrêtées : {', '.join(stopped)}") #cool pretty green check :)
    if already:
        parts.append(f"ℹ️ Instances déjà arrêtées : {', '.join(already)}") #info pretty blue info ;)
    if not parts:
        parts = ["ℹ️ Aucune instance trouvée."] #if no instance found, we send a message to the SNS topic
    sns.publish(TopicArn=SNS_TOPIC_ARN, Subject="Alerte EC2 arrêt automatique", Message="\n".join(parts)) #email subject and attached message

#Made by @manea-palluat (GitHub) - 2025
#Hope you like it! If you have any question, feel free to ask me on GitHub or on my LinkedIn : https://www.linkedin.com/in/manea-palluat/
#This code is provided as is, without any warranty. Use it at your own risk (Hoping you won't have any issue with it :P )
