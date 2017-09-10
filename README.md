# docker-git
Basic git server in a docker container

# Run
Use two volume containers, one to store the authorized ssh keys for the `git` user, and another to store the actual git repository contents. This way, the data will persist beyond the life of the sshd server that serves the data.

```
$ docker volume create git_pubkeys
$ docker volume create git_repos
```

Use a disposable container to modify the `authorized_keys` file on the `git_pubkeys` volume to include the public SSH keys you want to grant access to.

```
$ docker run --rm -it --mount source=git_pubkeys,destination=/keys ubuntu:16.04 /bin/bash
root@0c4026d9c291:/# echo "YOUR PUBLIC KEY" >> /keys/authorized_keys
root@0c4026d9c291:/# exit
```

Finally, build the docker-git container and run it as a daemonized process, mounting the volumes appropriately and mapping the desired host port:

```
$ docker build . -t docker-git
$ docker run --rm -d -p 44444:22 --mount source=git_pubkeys,destination=/home/git/.ssh,readonly -v git_repos:/home/git docker-git
```

For now, you'll need to manually enter the container to add a new repository:

```
root@fabf5b5dd931:/# mkdir /home/git/myrepo.git
root@fabf5b5dd931:/# git -C /home/git/myrepo.git init --bare
root@fabf5b5dd931:/# chown -R git /home/git/myrepo.git
```

But I'd like to add a `~git/git-shell-commands` directory with repo creation and maintenance scripts.

Then you can check out your new repo via:

```
git clone ssh://git@localhost:44444/home/git/myrepo.git
```
