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
$ oc project acrobot
```

## Sync the Pod Data with the Git Repo

Use `oc rsync` to sync the latest updates between the repo and the data directory in the pod. Make sure you get the current pod name and swap it for the example shown here. You can use `oc get pods` to get the pod name.

~~~
$ oc get pods
NAME                   READY     STATUS      RESTARTS   AGE
acrobot-app-17-cfj85   1/1       Running     0          3m
~~~


```
$ oc rsync <podname>:/opt/acrobot/data /path/to/local/AcroBot/data
```

The first `oc rsync` argument is the source directory. The second argument is the destination (in the example, the directory `/opt/acrobot/data` in the pod named `<podname>`).

Then you can commit them to git.


## Build and Deploy the New Image

```
$ oc start-build acrobot-app
```


