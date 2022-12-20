# Maintainer's Notes

The basic process for rebuilding and pushing a new image using the latest updates.

## Log in (Red Hat internal only)

As best as I can tell, this is the latest URL to use to connect to this
platform:

https://console-openshift-console.apps.mpp-e1-preprod.syvu.p1.openshiftapps.com/

Notice the *preprod* in the URL. This differentiates this instance from the
*prod* instance; I'm still working out the differences between these two as they
relate to Acrobot.

1. In the OpenShift Container Platform web UI, click your profile name and then click `Copy Login Command` to copy the entire log-in command, including your token, to the clipboard.
1. Open a terminal and paste the log-in command:

```
$ oc login https://open.paas.redhat.com --token=BigLongStringOfCharactersHere
```

## Change to the Acrobot Project

```
$ oc projects | grep acrobot
acrobot--config
acrobot--pipeline
acrobot--runtime-int

$ oc project acrobot--runtime-int
Now using project "acrobot--runtime-int" on server "https://api.mpp-e1-preprod.syvu.p1.openshiftapps.com:6443".
```

## Sync the Pod Data with the Git Repo

Use `oc rsync` to sync the latest updates between the repo and the data directory in the pod. Make sure you get the current pod name and swap it for the example shown here. You can use `oc get pods` to get the pod name.

~~~
$ oc get pods
NAME                   READY     STATUS      RESTARTS   AGE
acrobot-app-17-cfj85   1/1       Running     0          3m
~~~


```
[user@host AcroBot] (master) $ oc rsync <podname>:/opt/acrobot/data .
receiving incremental file list
data/abbrev.yaml

sent 766 bytes  received 1,440 bytes  259.53 bytes/sec
total size is 84,036  speedup is 38.09
```

The first `oc rsync` argument is the source directory (in the example, the directory `/opt/acrobot/data` in the pod named `<podname>`). The second argument is the destination.

Repeat this for the internal version.

## Clean Up the Databases

If you want or need to review the databases, do any cleanup, whatever, now is
the time. Review the `data/abbrev.yaml` file and make whatever changes are
required.

Run `verify_yaml.rb` over the database file to make sure it's valid, and then commit and push your changes to Git.

~~~
$ ruby verify_yaml.rb
YAML file './acrobot.yaml' valid!
YAML file './data/abbrev.yaml' valid!
YAML file './data/draft.yaml' valid!

$ git commit data/abbrev.yaml
 1 file changed, 7 insertions(+), 8 deletions(-)
~~~

## Sync the Databases

To make sure the two instances are using the same data, sync the repo with the pods.

~~~
[user@host AcroBot] (master) $ oc rsync data/ <external-podname>:/opt/acrobot/data
sending incremental file list
abbrev.yaml
...output omitted...

[user@host AcroBot] (master) $ oc rsync data/ <internal-podname>:/opt/acrobot/data
sending incremental file list
abbrev.yaml
...output omitted...
~~~

## Changes to the Source Code

Acrobot uses a build config that pulls straight from the repo so if you make changes locally and push them to the repo you just need to build and deploy a new image. All the changes are picked up automatically.

## Build and Deploy the New Image

```
$ oc start-build acrobot-app
```

You can monitor the new deployment if you're into that sort of thing:
```
$ oc get pods -w
```
It should only take a few minutes to deploy.

## Editing the ConfigMap for the Internal Bot

If you need to change the channels where the bot lives or make other minor changes, use the `oc login` command and manually edit the ConfigMap:

- Use the `oc edit configmaps acrobot-internal` command to open the ConfigMap in an editor.
- Make the required changes and then save and close the file.
- Use the `oc rollout latest acrobot-internal-app` command to deploy the new version.

That should be all you need.
