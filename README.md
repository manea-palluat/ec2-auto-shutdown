# EC2 Auto Shutdown

Automates the daily shutdown of specific EC2 instances and sends a detailed email report.

## Project context

This project was built during my internship, at my manager’s request.  
The team kept forgetting to stop certain EC2 instances at the end of the day, and the AWS bill was growing because of it.

To make it more technically interesting, I added an email notification that reports whether each instance was already stopped or actually just shut down (so I had to use a Lambda to get that level of precision).

## Features

- Fully managed with Terraform: SNS topic, Lambda function, and EventBridge rule
- Dockerized environment with an interactive CLI  
  (I thought it would be simpler—and more fun—to code that way)
- Parameters can be passed via terminal or `.env` file
- Email report shows whether instances were running or already stopped

## Prerequisites

- Docker
- An AWS IAM user with access key and secret

## Usage

1. Clone the repository
2. (Optional) Copy `.env.example` to `.env` and fill in the values  
   (You can also provide them later in the terminal)
3. Build the Docker image:
   ```bash
   make init
   ```
4. Deploy everything to AWS:
   ```bash
   make apply
   ```
   Make sure your AWS credentials are set correctly.

5. Confirm the email subscription (check your inbox)

The EC2 instances will be automatically stopped at the scheduled time.

## Clean up

```bash
make destroy
```

**Warning:** This command will delete **all** resources created by Terraform (SNS topic, Lambda function, EventBridge rule, etc.).  
If you’ve set up email alerts, **they will be lost**. Use with caution.

#Hope you like it!

If you have any question, feel free to ask me on GitHub or on my LinkedIn : https://www.linkedin.com/in/manea-palluat/
This code is provided as is, without any warranty. Use it at your own risk (Hoping you won't have any issue with it though! :P )