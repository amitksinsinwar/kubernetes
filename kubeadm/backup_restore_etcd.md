# Backing Up and Restoring etcd

Kubernetes stores both the declared and observed states of the cluster in the distributed key-value store. The backup process stores the `etcd` data in so called snapshot file. The snapshot file can be used to restore the `etcd` data at any given time. You can also encrypt snapshot file to protect sensitive information. The tool `etcdctl` is central to the backup and restore procedure.


## Install etcdctl

Download the lastest version from the official website and install on control plane node.

```shell
$ wget https://github.com/etcd-io/etcd/releases/download/v3.5.5/etcd-v3.5.5-linux-amd64.tar.gz

$ tar xvfz etcd-v3.5.5-linux-amd64.tar.gz
$ sudo mv etcd-v3.5.5-linux-amd64/etcdctl /usr/local/bin/

$ etcdctl version
etcdctl version: 3.5.5
API version: 3.5
```

`etcd` is deployed as pod in the `kube-system` namespace. Inspect the version by describing the pods.

```shell
kubectl get pods -n kube-system
...
etcd-kubeadm-node01                      1/1     Running   1 (97m ago)   97m
...


$ kubectl describe pods etcd-kubeadm-node01 -n kube-system
eetcd:
    Container ID:  containerd://41306bbe691a997d6345ce4885dc88f5f0dd44af23bb7913af8a6d2b592681ee
    Image:         registry.k8s.io/etcd:3.5.4-0
    Image ID:      registry.k8s.io/etcd@sha256:6f72b851544986cb0921b53ea655ec04c36131248f16d4ad110cb3ca0c369dc1
    Port:          <none>
    Host Port:     <none>
    Command:
      etcd
      --advertise-client-urls=https://192.168.122.218:2379
      --cert-file=/etc/kubernetes/pki/etcd/server.crt
      --client-cert-auth=true
      --data-dir=/var/lib/etcd
      --experimental-initial-corrupt-check=true
      --experimental-watch-progress-notify-interval=5s
      --initial-advertise-peer-urls=https://192.168.122.218:2380
      --initial-cluster=kubeadm-node01=https://192.168.122.218:2380
      --key-file=/etc/kubernetes/pki/etcd/server.key
      --listen-client-urls=https://127.0.0.1:2379,https://192.168.122.218:2379
      --listen-metrics-urls=http://127.0.0.1:2381
      --listen-peer-urls=https://192.168.122.218:2380
      --name=kubeadm-node01
      --peer-cert-file=/etc/kubernetes/pki/etcd/peer.crt
      --peer-client-cert-auth=true
      --peer-key-file=/etc/kubernetes/pki/etcd/peer.key
      --peer-trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
      --snapshot-count=10000
      --trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt
```

backup the `etcd`

```shell
$ $ sudo ETCDCTL_API=3 etcdctl --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key snapshot save /opt/etcd-backup.db
{"level":"info","ts":"2022-10-15T15:50:28.140+0530","caller":"snapshot/v3_snapshot.go:65","msg":"created temporary db file","path":"/opt/etcd-backup.db.part"}
{"level":"info","ts":"2022-10-15T15:50:28.148+0530","logger":"client","caller":"v3/maintenance.go:211","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":"2022-10-15T15:50:28.148+0530","caller":"snapshot/v3_snapshot.go:73","msg":"fetching snapshot","endpoint":"127.0.0.1:2379"}
{"level":"info","ts":"2022-10-15T15:50:28.218+0530","logger":"client","caller":"v3/maintenance.go:219","msg":"completed snapshot read; closing"}
{"level":"info","ts":"2022-10-15T15:50:28.242+0530","caller":"snapshot/v3_snapshot.go:88","msg":"fetched snapshot","endpoint":"127.0.0.1:2379","size":"6.0 MB","took":"now"}
{"level":"info","ts":"2022-10-15T15:50:28.243+0530","caller":"snapshot/v3_snapshot.go:97","msg":"saved","path":"/opt/etcd-backup.db"}
Snapshot saved at /opt/etcd-backup.db
```

## Restoring etcd

You created a backup of etcd and store it in a safe place. To restore etcd from the backup, use the `etcdctl snapshot restore` command.

```shell
sudo ETCDCTL_API=3 etcdctl snapshot restore /opt/etcd-backup.db --data-dir=/var/lib/etcd-backup1
Deprecated: Use `etcdutl snapshot restore` instead.

2022-10-15T16:20:02+05:30	info	snapshot/v3_snapshot.go:248	restoring snapshot	{"path": "/opt/etcd-backup.db", "wal-dir": "/var/lib/etcd-backup1/member/wal", "data-dir": "/var/lib/etcd-backup1", "snap-dir": "/var/lib/etcd-backup1/member/snap", "stack": "go.etcd.io/etcd/etcdutl/v3/snapshot.(*v3Manager).Restore\n\t/tmp/etcd-release-3.5.5/etcd/release/etcd/etcdutl/snapshot/v3_snapshot.go:254\ngo.etcd.io/etcd/etcdutl/v3/etcdutl.SnapshotRestoreCommandFunc\n\t/tmp/etcd-release-3.5.5/etcd/release/etcd/etcdutl/etcdutl/snapshot_command.go:147\ngo.etcd.io/etcd/etcdctl/v3/ctlv3/command.snapshotRestoreCommandFunc\n\t/tmp/etcd-release-3.5.5/etcd/release/etcd/etcdctl/ctlv3/command/snapshot_command.go:129\ngithub.com/spf13/cobra.(*Command).execute\n\t/usr/local/google/home/siarkowicz/.gvm/pkgsets/go1.16.15/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:856\ngithub.com/spf13/cobra.(*Command).ExecuteC\n\t/usr/local/google/home/siarkowicz/.gvm/pkgsets/go1.16.15/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:960\ngithub.com/spf13/cobra.(*Command).Execute\n\t/usr/local/google/home/siarkowicz/.gvm/pkgsets/go1.16.15/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:897\ngo.etcd.io/etcd/etcdctl/v3/ctlv3.Start\n\t/tmp/etcd-release-3.5.5/etcd/release/etcd/etcdctl/ctlv3/ctl.go:107\ngo.etcd.io/etcd/etcdctl/v3/ctlv3.MustStart\n\t/tmp/etcd-release-3.5.5/etcd/release/etcd/etcdctl/ctlv3/ctl.go:111\nmain.main\n\t/tmp/etcd-release-3.5.5/etcd/release/etcd/etcdctl/main.go:59\nruntime.main\n\t/usr/local/google/home/siarkowicz/.gvm/gos/go1.16.15/src/runtime/proc.go:225"}
2022-10-15T16:20:02+05:30	info	membership/store.go:141	Trimming membership information from the backend...
2022-10-15T16:20:02+05:30	info	membership/cluster.go:421	added member	{"cluster-id": "cdf818194e3a8c32", "local-member-id": "0", "added-peer-id": "8e9e05c52164694d", "added-peer-peer-urls": ["http://localhost:2380"]}
2022-10-15T16:20:02+05:30	info	snapshot/v3_snapshot.go:269	restored snapshot	{"path": "/opt/etcd-backup.db", "wal-dir": "/var/lib/etcd-backup1/member/wal", "data-dir": "/var/lib/etcd-backup1", "snap-dir": "/var/lib/etcd-backup1/member/snap"}

```

```shell
$ sudo ls /var/lib/etcd-backup1/
member
```

Now edit the YAML manifest of the etcd pod, which can be found at `/etc/kubernetes/manifests/etcd.yaml`. Change the value of `spec.volumes.hostPath` with name `etcd-data` from the original value `/var/lib/etcd/` to `/var/lib/etcd-backup`

```shell
$ sudo vim /etc/kubernetes/manifests/etcd.yaml

...
- hostPath:
      path: /var/lib/etcd-backup1
      type: DirectoryOrCreate
    name: etcd-data
...
```



