# launchdarkly-python-demo

This example showcases the use of feature flags in a Python application. It uses Terraform to provision the all LaunchDarkly resources. The application uses Python with Flask and the LaunchDarkly Server SDK.

## Prerequisites

1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 
1. [Install jq](https://jqlang.github.io/jq/download/)
1. Install Python with your preferred package manager.
1. [Create an LaunchDarkly access token](https://docs.launchdarkly.com/home/account-security/api-access-tokens#creating-api-access-tokens)

## Assumptions

1. You are using Bash.

## Build and execute the demo
1. Clone the repo:
```bash
$ git clone https://github.com/mkaesz/launchdarkly-python-demo.git` && cd launchdarkly-python-demo
```

1. Export the LaunchDarkly Access Token:
```bash
$ export LAUNCHDARKLY_ACCESS_TOKEN=abc123
```

1. Execute Terraform to provision the project, environments, and feature flags
```bash
$ terraform init
$ terraform plan 
$ terraform apply
```
Confirm the action with "Yes" when asked.

1. Now the LaunchDarkly environment key can be exported so that the Python application can use it. 

Terraform considers the key as sensitive. We therefore have to use JSON output and jq to extract it. 

```bash
$ export LD_SDK_KEY=$(terraform output -json | jq -r .staging_env_key.value)
```

1. Run Flask

Flask is being executed in Development mode.

```bash
$ flask --app main run
```
The output should look like that:
```bash
SDK successfully initialized!
 * Serving Flask app 'main'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://127.0.0.1:5000
Press CTRL+C to quit
```
"SDK successfully initialized" means that the access token has been found and a connection to the LaunchDarkly servers could be established.

### Execute various API call to showcase the feature flags

1. No feature flag involved 

```bash
$ curl http://127.0.0.1:5000
<p>Hello, World!</p>
```

1. No feature flag involved, but name gets printed as per URL path, but still no feature glag involved.
```bash
$ curl http://127.0.0.1:5000/user/Jim
<p>Hello, Jim!</p>
```

1. Now execute with name "Marc". 
```bash

```
```bash

```
```bash

```


### Destroy the all resources
```bash
$ terraform destroy
```
Confirm the action with "Yes" when asked.
