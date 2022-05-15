# README

## 開発環境構築

* Dockerイメージをビルドして、bundle installする

```
docker-compose build
docker-compose run --rm rails bundle install
```

* データーベースを作成する

```
docker-compose run --rm rails bundle exec rails db:create db:migrate
```

* サーバーを起動する（ポート3000で起動する）

```
docker-compose run --rm --service-ports
```

## POSTMAN document

https://documenter.getpostman.com/view/107551/Uyxbq9Rf
