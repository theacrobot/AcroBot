# Maintainer's Notes

The basic process for rebuilding and pushing a new image using the latest updates.

## Log in (Red Hat internal only)

1. In the OpenShift Container Platform web UI, click your profile name and then click `Copy Login Command` to copy the entire log-in command, including your token, to the clipboard.
1. Open a terminal and paste the log-in command:

```
$ oc login https://open.paas.redhat.com --token=BigLongStringOfCharactersHere
```

## Change to the Acrobot Project

```
oc project acrobot
```

## Sync the Pod Data with the Git Repo

Use `rsync` to sync the latest updates between the repo and the data directory in the pod. Make sure you get the current pod name and swap it for the example shown here.
The first parameter is the source directory (in this example, it would be . - the current directory). The second parameter is the destination (in the example, the directory `/opt/acrobot/data` in the pod named `<podname>`).

This command copies the contents of the current working directory into `/opt/acrobot/data` in the container (a persistent volume).

You can get the pod names via `oc get pods` or just browsing the web ui.

Use `oc rsync` to back up or restore the acrobot data files. Whenever you want to commit those data files to your git repo, use:

```
oc rsync <podname>:/opt/acrobot/data /path/to/local/AcroBot/data
```

Then you can commit them to git.


## Build and Deploy the New Image

```
$ oc start-build acrobot-app
```


