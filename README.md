# egdevtest

This is the Terraform and Dockerfile for the devops-test homework task.

## Task 1:
* Sub-task 1 - the Dockerfile - was created as a two-step build, to keep the source and build junk out of the final image. Rocky 9 was used, the minimal version, and Python 3.12. I created an app user so as not to run the whole thing as root (security!) I also found somewhere in the docs the health check for the service, which I used.
* Sub-task 2 was done in Terraform. I broke up the code into files related to AWS services. Two outputs were created so I could see the hostnames of the ALB and DB in the end.
* Sub-task 3 was performed as described.
* Sub-task 4 was respected, with provisions (secrets manager secret for the db) that can't be used because the app can't use them yet (that I know of)

# Task 2:
* Sub-task 1: Also in Terraform, the CloudWatch log group was created.
* Sub-task 2: Same for the dashboard. The dash code is ugly. It always is.
* Sub-task 3: Also done in Terraform.

# Task 3:
I created the Lambda manually, through the AWS console, using the principle of "whatever works" :)
