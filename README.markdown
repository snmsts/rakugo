# rakugo.ros

Provides a command for retrieving 定席 and 落語会 which the given 落語家 appears and held in a month.

## Usage

```
$ rakugo 柳家三三 三遊亭金馬 柳亭左龍
柳家  三三, 三遊亭 金馬, 柳亭  左龍が出演する定席・落語会

2016/08/21
鈴本演芸場 8月下席
URL: http://rakugo-kyokai.jp/jyoseki/index.php?pid=1&eid=537
主な出演者: 柳家  三三

2016/08/21
池袋演芸場 8月下席
URL: http://rakugo-kyokai.jp/jyoseki/index.php?pid=4&eid=535
主な出演者: 柳家  三三, 三遊亭 金馬

2016/08/31
池袋余一会　噺坂　～其の11～
URL: http://rakugo-kyokai.jp/rakugokai/detail.php?id=1787
主な出演者: 柳家  三三, 柳亭  左龍

2016/09/01
浅草演芸ホール 9月上席
URL: http://rakugo-kyokai.jp/jyoseki/index.php?pid=3&eid=558
主な出演者: 柳亭  左龍

2016/09/10
第100回傳通院寄席
URL: http://rakugo-kyokai.jp/rakugokai/detail.php?id=1047
主な出演者: 三遊亭 金馬

2016/09/11
池袋演芸場 9月中席
URL: http://rakugo-kyokai.jp/jyoseki/index.php?pid=4&eid=562
主な出演者: 柳亭  左龍

2016/09/19
第81回　三三・左龍の会
URL: http://rakugo-kyokai.jp/rakugokai/detail.php?id=455
主な出演者: 柳家  三三, 柳亭  左龍
```

## Restriction

The given 落語家 must belong to 落語協会 or 落語芸術協会 for now.

Sometimes it cannot find some 落語家 because of a bug of those organizations' websites. For example, there's "台所おさん" at "落語協会", however, their website doesn't show him with his fullname. This bug is already reported so I hope it would be resolved soon.

## Installation

```
$ cd ~/.roswell/
$ git clone https://github.com/fukamachi/rakugo ~/.roswell/local-projects/rakugo
$ ros install rakugo
```

## Author

* Eitaro Fukamachi (e.arrows@gmail.com)

## Copyright

Copyright (c) 2016 Eitaro Fukamachi (e.arrows@gmail.com)

## License

Licensed under the BSD 2-Clause License.
