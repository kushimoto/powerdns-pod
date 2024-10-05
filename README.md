# PowerDNS Pod

これは個人的に PowerDNS を Podman の Pod で構築するために作ったメモです。  
利用において私は責任を持ちません。

## 使い方

この Pod には３つのコンテナが含まれます。

- PowerDNS Auth (権威サーバー)
- PowerDNS Recursor (リゾルバ)
- PowerDNS Admin (WEBUI)

ローカルネットワークのドメインを解決する場合はリゾルバ付きで動かすといいでしょう。これがグローバル設置できるチューニングなのかはさておき、個人で管理するドメインの権威サーバーにしたい場合はリゾルバを動かさないでください。WEBUIも不要ならいりませんよ :heart:

※ すべての作業は root ユーザーで進めます。

### コンテナイメージのDL
以下のイメージを利用しておりますので、予めダウンロードしておきます。
(めんどくさいのでlatest使ってます、知らんけど)

- docker.io/powerdns/pdns-auth-master:latest
- docker.io/powerdns/pdns-recursor-master:latest
- docker.io/ngoduykhanh/powerdns-admin:v0.3.0

```shell
podman pull docker.io/powerdns/pdns-auth-master:latest
podman pull docker.io/powerdns/pdns-recursor-master:latest
podman pull docker.io/ngoduykhanh/powerdns-admin:v0.3.0
```

### インストールディレクトリの作成

/opt/powerdns を作成します。

```shell
mkdir /opt/powerdns-pod
```

ディレクトリ構成は以下のようにします。

```
/opt/powerdns-pod/
     ├─ pdns.d/
     │  └─ pdns.conf
     ├─ recursor.d/
     │  └─ recursor.conf
     └─ powerdns-pod.yaml
```

recursour.conf は local.example.com を解決したいローカルドメインに書き換えておいてください。(ホスト名+ドメイン名ではなくドメイン名です)

recursourを使わない場合は powerdns-pod.yaml から recursor に関するものをすべて消したうえで ports を以下のように書き換えてください。

```yaml
    ports:
    - containerPort: 8053
      hostPort: 53
    - containerPort: 80
      hostPort: 80
    - containerPort: 8053
      hostPort: 53
      protocol: UDP
```

ここまでできたら migration.sh を実行します。

```shell
cd /opt/powerdns-pod
bash migration.sh
```

いらないコンテナがあれば powerdns-pod.yaml をみて削っておきます。
(たぶん見ればわかる)

### systemd ファイルの設置

powerdns-pod.kube を /usr/shares/containers/systemd/ に置きます。

### 登録

以下のコマンドを実行します

```shell
/usr/libexec/podman/quadlet /usr/share/containers/systemd/powerdns-kube.kube 
systemctl daemon-reload
systemctl start powerdns-kube.service
```
