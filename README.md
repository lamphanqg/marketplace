# README

## 開発環境構築

* Dockerイメージをビルドして、bundle installする

```
docker-compose build
docker-compose run --rm rails bundle install
```

* サーバーを起動する（ポート3000で起動する）

```
docker-compose run --rm --service-ports
```

## POSTMAN document

https://documenter.getpostman.com/view/107551/Uyxbq9Rf
