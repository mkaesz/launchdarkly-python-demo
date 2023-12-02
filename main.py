import ldclient
from ldclient import Context
from ldclient.config import Config
from flask import Flask
import os

# Get the LaunchDarkly env key from the environment
sdk_key = os.getenv('LD_SDK_KEY')
ldclient.set_config(Config(sdk_key))

if ldclient.get().is_initialized():
  print("SDK successfully initialized!")
else:
  print("SDK failed to initialize")
  exit()

app = Flask(__name__)

@app.route("/")
def hello_world():
  return "<p>Hello, World!</p>"

@app.route("/user/<string:user>")
def show_user(user):
  # Only certain users are allowed to access the new feature
  context = Context.builder(f'user-key-{user}').name(user).build()
  print("The context is:", context)

  is_feature_enabled = ldclient.get().variation("new-feature", context, False)
  print("The feature flag 'new-feature' is:", is_feature_enabled)

  # Check if the new feature should be shown for the current user  
  if is_feature_enabled:
    ldclient.get().track("metric-key-user-marc", context)
    return f"<p>Welcome, {user}! Enjoy using the new cool feature.</p>"

  return f"<p>Hello, {user}!</p>"

ldclient.get().close()
