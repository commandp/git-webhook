# Git Webhook Service

這基本上是拿來當中國的跳版用的，因為 Github 在中國速度有點差，所以預先處理在這邊。

所以只要在 Repository 有設定 webhook 到這邊的話，當發生 commit 的話，就會發到 Git Webhook Service 去，只會更新 Git Repository，也就是跑 `git remote update --prune` 也可以設定跑完前面那個指令後，再去對其他的 URL 做請求。


#### 使用方式

##### 新增 git 使用者

```bash
sudo adduser git
sudo useradd -m -d /home/git git
```

將 Deploy 的 Puclic Key 加入 `/home/git/.ssh/authorized_keys`
```
sudo su git
vi /home/git/.ssh/authorized_keys # 貼上從 Deploy api Server 的 Public Key
```

##### 建立 SSH Key

```
sudo su git
ssh-keygen -t rsa -b 4096 
cat ~/.ssh/id_rsa.pub
```

##### 把 SSH Key 加入 Github

如果只有一個 Repository 要處理的話，可以加到 Deploy Key 就行了

但是如果你是要同時處理多個 Repository 的話，那就要建立一個使用者來，只開放讀取權限。

##### 安裝 Golang

```
sudo apt-get update
sudo apt-get -y upgrade
sudo su git

curl -O https://storage.googleapis.com/golang/go1.6.linux-amd64.tar.gz

tar -xvf go1.6.linux-amd64.tar.gz

"export GOROOT=$HOME/go" >> ~/.bashrc
"export PATH=$PATH:$GOROOT/bin" >> ~/.bashrc
source ~/.bashrc
```

##### 安裝 webhook

```
go get github.com/adnanh/webhook
```


##### 下載 git-webhook

```
sudo su git
cd ~/
git clone https://github.com/commandp/git-webhook.git webhook
```

##### 設定 config.yml

建立 `config.yml`，按照你的 repository 新增。

```yaml
---
<REPOSITORY NAME 1>:
  owner: "<OWNER>"
  secret: "<SECRET KEY>"
  ci_endpoins:
    master:  "http://<CI SERVER:8080/job/<JOB>/build"
<REPOSITORY NAME 2>:
  owner: "<OWNER>"
  secret: "<SECRET KEY>"
  ci_endpoins:
```

##### 產生 hook.json
這個檔案是 webhook 才能夠驗證的 json 檔

```
./gen_hooks_json.rb
```

##### 設定 init

```
# vi /etc/init/webhook.conf
author "Sammy Lin <sammylin@commandp.com>"

description "GitHub mirror Commandp Repository"

start on startup

console log

script
    exec /home/git/go/bin/webhook -hooks /home/git/webhook/hooks.json -verbose >> /var/log/webhook.log 2>&1
end script
```


##### 在 GitHub 新增 Webhook

- 在 GitHub Repository 新增 webhook ： http://<YOU SERVICE IP>:9000/hooks/<REPOSITORY NAME>
- 設定成 `Just the push event.`

##### 啟動 Service

```
initctl start webhook
```
