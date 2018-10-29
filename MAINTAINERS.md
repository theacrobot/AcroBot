# Maintainers Notes

The basic process for rebuilding and pushing a new image using the latest updates.

## Log in so you can do stuff (Red Hat internal only)

```
sudo docker login -p $(oc whoami -t) -e unused -u unused docker-registry.engineering.redhat.com
sudo oc login --server=https://internal-registry.host.prod.eng.rdu2.redhat.com:8443
```

## Make sure you are in the correct project.

```
oc project acrobot
```

Use rsync to sync the latest updates between the repo and the data directory in the pod. Make sure you get the current pod name and swap it for the example shown here.
The first parameter is the source directory (in this example, it would be . - the current directory). The second parameter is the destination (in the example, the directory /opt/acrobot/data in the pod named acrobot-4-v4cpn).

This command copies the contents of the current working directory into /opt/acrobot/data in the container (a persistent volume).

You can get the pod names via `oc get pods` or just browsing the web ui.

Use `oc rsync` to back up or restore the acrobot data files. Whenever you want to commit those data files to your git repo, use:

```
oc rsync <podname>:/opt/acrobot/data /path/to/local/AcroBot/data
```

Then you can commit them to git.


## Build the new image

```
sudo docker build -t docker-registry.engineering.redhat.com/acrobot/acrobot:latest .
```

## Tag and push the new image
```
sudo docker tag 8bd157fff7a0 docker-registry.engineering.redhat.com/daobrien/acrobot:latest
sudo docker push docker-registry.engineering.redhat.com/acrobot/acrobot
```

## Redeploy the image.
Probably easiest to do this from the web UI.

