# できたこと

* 各APIの実装
    * ユーザー作成
    * ログイン（モバイルアプリから使う前提で、クッキーが使えないから認証はJWTを使います）
    * ユーザー情報確認
    * ユーザー一覧
    * 商品一覧（ページングあり、価格の安い順）
    * 商品情報変更（在庫個数以外）
    * 商品の在庫個数変更（商品レコードに対して悲観的ロックを適用）
    * 商品情報確認
    * 購入（商品、購入者、販売者レコードに対して悲観的ロックを適用）
    * 購入履歴
* 各model、form、requestのrspecテスト

# できていないこと

* ログイントークン（JWT）の無効化する仕組みができていません。ログアウト機能を実装する際にブラックリストなどを実装すべきです。 devise_token_authのgemを使ったら良いが、Rails7のAPIモードでは現在使えません： https://github.com/heartcombo/devise/issues/5443 （クッキーとセッションのミドルウェアを入れたら使えますが、モバイルアプリはクッキーがないのでモバイルアプリ向けのAPIなら使えません）
* 商品の在庫個数変更API、購入APIに対してロックをかけているが、rspecでテストが書けていません。いろいろ試しましたが、ロックがなくても通ったのでダメでした。無理やりsleepを挟んで手動でのテストは行いました。

# パフォーマンスを改善できそうなこと

* トップページにいくつかの流行っている商品を常に見せるなら、その商品の情報をredisに保存して、リクエストが来たらDBから取得せずにredisから情報を返して良いです。さらに、JSONファイルを事前に作ってCDNにおいて、トップページはCDNからJSONデータを使うようにしたらもっと速くなります。
* 大量の購入リクエストに対応するには現在の購入処理を分けて、即時処理はredisのデータを更新するのとキューにメッセージを追加するだけで、DBデータの更新はsidekiqなどの非同期処理に移管すべきです。
    * redisサーバーを立てて、各商品の在庫個数とユーザーのポイントをredisキャッシュに入れる
    * SQSのFIFOキューを作る
    * 購入リクエストを受けたら、redisにある在庫個数とユーザーのポイントを更新し、購入の情報（購入者、商品、数量）をキューメッセージにして送る
    * sidekiqワーカーでキューからメッセージをプルして、今purchase_form.rbにある処理を行ってDBにデータを登録・更新し、変更後の在庫個数とポイントをまたredisのキャッシュに反映させる
* DBサーバーを読み込み専用と書き込み専用に分けて、database.ymlとapplication_record.rbでそれぞれの向き先を設定したら、読み込み専用ＤＢに対してauto scalingが適用できます。
    * https://guides.rubyonrails.org/active_record_multiple_databases.html
    * https://aws.amazon.com/jp/blogs/database/scaling-your-amazon-rds-instance-vertically-and-horizontally/
