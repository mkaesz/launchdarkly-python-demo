# launchdarkly-python-demo

This example showcases the use of feature flags in a Python application. It uses Terraform to provision the all LaunchDarkly resources. The application uses Python with Flask and the LaunchDarkly Server SDK.

## Assumptions

1. You are using Bash. If not, the export commands must be substituted accordingly.
1. You have a LaunchDarkly account. 


## Prerequisites

1. [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 
1. [Install jq](https://jqlang.github.io/jq/download/)
1. Install Python with your preferred package manager.
1. [Create an LaunchDarkly access token](https://docs.launchdarkly.com/home/account-security/api-access-tokens#creating-api-access-tokens)

## Build and execute the demo

1. Clone the repo:
```bash
$ git clone https://github.com/mkaesz/launchdarkly-python-demo.git` && cd launchdarkly-python-demo
```

1. Export the LaunchDarkly Access Token
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

The apply step should result in the following output:
```bash
<redacted>

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + staging_env_key = (sensitive value)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

launchdarkly_project.demo-project: Creating...
launchdarkly_project.demo-project: Creation complete after 2s [id=demo-project]
launchdarkly_feature_flag.cool-new-feature: Creating...
launchdarkly_feature_flag.new-feature-kill-switch: Creating...
launchdarkly_feature_flag.cool-new-feature: Creation complete after 1s [id=demo-project/new-feature]
launchdarkly_feature_flag_environment.number_env: Creating...
launchdarkly_feature_flag.new-feature-kill-switch: Still creating... [10s elapsed]
launchdarkly_feature_flag_environment.number_env: Still creating... [10s elapsed]
launchdarkly_feature_flag.new-feature-kill-switch: Creation complete after 13s [id=demo-project/new-feature-kill-switch]
launchdarkly_feature_flag_environment.number_env: Creation complete after 13s [id=demo-project/staging/new-feature]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

staging_env_key = <sensitive>

```

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
"SDK successfully initialized" means that the LaunchDarkly environment key has been found and a connection to the LaunchDarkly servers could be established.

### Execute various API call to showcase the feature flags

1. No feature flag involved 

```bash
$ curl http://127.0.0.1:5000
<p>Hello, World!</p>
```

1. No feature flag involved, but name is being provided as part of the URL and gets printed out, but still no feature flag involved.
```bash
$ curl http://127.0.0.1:5000/user/Jim
<p>Hello, Jim!</p>
```

1. Now execute with user "Marc". 
```bash
$ curl http://127.0.0.1:5000/user/Marc
<p>Welcome, Marc! Enjoy using the new cool feature.</p>⏎
```
This uses a feature flag combined with targeting. Only the user Marc can see the new feature. Every other user will get the same output as seen with the user "Jim".

1. To disable the entire feature for everyone (other users could have been added in addition to Marc), a kill switch was implemented.
```bash
bash turn_on_kill_switch.sh
```
Another call with user "Marc" should result in the same output as for all other users now.
```bash
$ curl http://127.0.0.1:5000/user/Marc
<p>Hello, Marc!</p>
```

Disabling the kill switch:
```bash
bash turn_off_kill_switch.sh
```

Another call with user "Marc" should result in this output:
```bash
$ curl http://127.0.0.1:5000/user/Marc
<p>Welcome, Marc! Enjoy using the new cool feature.</p>⏎
```

### Destroy the all resources
```bash
$ terraform destroy
```
Confirm the action with "Yes" when asked.

The destroy step should result in the following output:
```bash

Plan: 0 to add, 0 to change, 4 to destroy.

Changes to Outputs:
  - staging_env_key = (sensitive value) -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

launchdarkly_feature_flag_environment.number_env: Destroying... [id=demo-project/staging/new-feature]
launchdarkly_feature_flag.new-feature-kill-switch: Destroying... [id=demo-project/new-feature-kill-switch]
launchdarkly_feature_flag.new-feature-kill-switch: Destruction complete after 0s
launchdarkly_feature_flag_environment.number_env: Destruction complete after 1s
launchdarkly_feature_flag.cool-new-feature: Destroying... [id=demo-project/new-feature]
launchdarkly_feature_flag.cool-new-feature: Destruction complete after 0s
launchdarkly_project.demo-project: Destroying... [id=demo-project]
launchdarkly_project.demo-project: Destruction complete after 1s

Destroy complete! Resources: 4 destroyed.
```


