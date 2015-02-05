# unbound with filter-aaaa-on-v4

## What?

- 内部の名前解決はunboundの`local-data`で済ませたい
- IPv6を使うクライアント対策として`filter-aaaa-on-v4`は必要
- unboundにはbindの`filter-aaaa-on-v4`相当の機能がない

という問題を解決するコンテナです。

`filter-aaaa-on-v4`を有効にしたbindと、そこにforwardするunboundをまとめただけ。

## How to use

`local.conf`を格納したディレクトリを、コンテナの`/etc/unbound/conf.d`としてマウントして起動します。

```
sudo docker run -d -p 53:53/udp -v /path/to:/etc/unbound/conf.d --name unbound nekoya/unbound-ipv6-filter
```

とりあえず試してみるには、このリポジトリの`conf.d`をマウントしてみるとよいでしょう。

### 内部の名前解決

`conf.d/local.conf`に以下のように書いておくと、その情報がコンテナ内のunboundに取り込まれます。

```
local-data: "myhost.dev.local    A 10.1.1.10"
```

`local.conf`の更新を反映するにはコンテナを再起動すればOK。

```
sudo docker restart unbound
```

### `filter-aaaa-on-v4`の仕事

`www.cisco.com`などにIPv6で問い合わせてみると、

```
dig @localhost www.cisco.com AAAA
```

裏のbindがAAAAレコードをフィルタしてくれます。`8.8.8.8`に同じクエリを投げた時の結果と比べてみると分かりやすいでしょう。

社内のネットワークがIPv6非対応なのに、頑なにAAAAで名前解決しようとするWindowsクライアントがいても安心ですね。
