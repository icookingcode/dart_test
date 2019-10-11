import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:english_words/english_words.dart';

import 'base/log.dart' as log; //指定库前缀
import 'base/metadata.dart';

/// 使用 typedef(保留了类型信息), 或者 function-type alias 来为方法类型命名
typedef int Compare(int a, int b);

int sort(int a, int b) => a - b;

void main() {
  assert(sort is Compare); //true  判断任意function的类型的方法
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
//      home: MyHomePage('Flutter Demo Home Page'),
      home: RandomWords(),
    );
  }
}

class MyScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Material 是UI呈现的“一张纸”
    return Material(
      // Column is 垂直方向的线性布局.
      child: Column(
        children: <Widget>[
          MyAppBar(
            title: Text(
              'Example title',
              style: Theme.of(context).primaryTextTheme.title,
            ),
          ),
          Expanded(
            child: Center(
              child: Text('Hello, world!'),
            ),
          ),
        ],
      ),
    );
  }
}
///封装的appbar
class MyAppBar extends StatelessWidget {
  MyAppBar({this.title});

  // Widget子类中的字段往往都会定义为"final"

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Container(
        height: 56.0, // 单位是逻辑上的像素（并非真实的像素，类似于浏览器中的像素）
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(color: Colors.blue[500]),
        // Row 是水平方向的线性布局（linear layout）
        child: Row(
          //列表项的类型是 <Widget>
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              tooltip: 'Navigation menu',
              onPressed: null, // null 会禁用 button
            ),
            // Expanded expands its child to fill the available space.
            Expanded(
              child: title,
            ),
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'Search',
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}

///随机英文字符串
class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  /// 对于每个建议的单词对都会调用一次itemBuilder，然后将单词对添加到ListTile行中
  /// 在偶数行，该函数会为单词对添加一个ListTile row.
  /// 在奇数行，该函数会添加一个分割线widget，来分隔相邻的词对。
  /// 注意，在小屏幕上，分割线看起来可能比较吃力。
  Widget _buildItem(context, i) {
    // 在每一列之前，添加一个1像素高的分隔线widget
    if (i.isOdd) return Divider();
    // 语法 "i ~/ 2" 表示i除以2，但返回值是整形（向下取整），比如i为：1, 2, 3, 4, 5
    // 时，结果为0, 1, 1, 2, 2， 这可以计算出ListView中减去分隔线后的实际单词对数量
    final index = i ~/ 2;
    // 如果是建议列表中最后一个单词对
    if (index >= _suggestions.length) {
      // ...接着再生成10个单词对，然后添加到建议列表
      _suggestions.addAll(generateWordPairs().take(10));
    }
    return _buildRow(_suggestions[index]);
  }

  ///构建行
  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return new ListTile(
      leading: CircleAvatar(
        child: Text(pair.asPascalCase.substring(0,1)),
      ),
      title: new Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  ///导航 跳转
  void _pushSaved() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      final tiles = _saved.map(
        (pair) {
          return ListTile(
            title: Text(
              pair.asPascalCase,
              style: _biggerFont,
            ),
          );
        },
      );
      final divided = ListTile.divideTiles(
        context: context,
        tiles: tiles,
      ).toList();
      return Scaffold(
        appBar: AppBar(
          title: Text('Saved Suggestions'),
        ),
        body: ListView(children: divided),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('welcome to Flutter'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: _pushSaved,
          )
        ],
      ),
      body: ListView.builder(itemBuilder: _buildItem),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @required
  final String title;

  MyHomePage(this.title);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String mVersion;

  @override
  void initState() {
    super.initState();
    var list = ['apples', 'oranges', 'grapes', 'bananas', 'plums'];
    //匿名方法
    list.forEach((i) {
      print("initState" + list.indexOf(i).toString() + ': ' + i);
    });
    for (var x in list) {
      print("initState_for in " + x.toString());
    }
    var jsonData = json.decode('{"x":1, "y":2}');
    print(jsonData is Map);
    jsonData['z'] = 10;
    Point point = Point.fromJson(jsonData);
    print('x:${point.x} y:${point.y} z:${point.z}');
    Point point2 = Point.alongXAxis(5);
    print('x:${point2.x} y:${point2.y} z:${point2.z}');
    Point4 point4 = Point4(110, json: jsonData);
    log.Logger("ERROR")
        .log('x:${point4.x} y:${point4.y} z:${point4.z} w:${point4.w}');
    _getVersion();
    testCollection();
    testRegExp();
    testUri();
    testDateTime();
    requestPermission();
    httpTest();
    testConvert();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('1',
                  style: TextStyle(
                      color: Colors.greenAccent,
                      backgroundColor: Colors.yellowAccent,
                      fontSize: 26)),
              Text('2\u{1f600}'),
              Text(
                  '3\u2665  \u{1f605}  \u{1f60e}  \u{1f47b}  \u{1f596}  \u{1f44d}'),
              Text(_getName(
                firstName: 'Gu',
                lastName: 'Chao',
              )),
              Text(_say(
                'Guc',
                '你好啊',
                'Phone',
                "happy",
              )),
              Text('$mVersion'),
            ],
          ),
        ));
  }

  ///可选命名参数
  String _getName({String firstName, String lastName = '暂无'}) {
    return '$firstName $lastName';
  }

  ///可选位置参数
  String _say(String from, String msg,
      [String device = "carrier pigeon", String mood]) {
    var result = '$from says $msg';
    if (device != null) {
      result = '$result with a $device';
    }
    if (mood != null) {
      result = '$result (in a $mood mood)';
    }
    return result;
  }

  @TODO('Gu', 'get app version')
  _getVersion() async {
    var version = await log.Application().lookUpVersion();
    setState(() {
      mVersion = version.toString();
    });
  }

  ///测试集合
  testCollection() {
    var points = <Point>[];
    points.add(Point(1, 1));
    points.add(Point(2, 2));
    var addresses = <String, Address>{};
    addresses['home'] = Address("沁阳市崇义镇", lat: 35.0958, lng: 112.9486);
    addresses['work'] = Address("郑东新区", lat: 34.7736, lng: 113.7411);
    log.Logger('colloction').log(
        'points isEmpty: ${points.isEmpty} addresses isEmpty: ${addresses.isEmpty}');
    //使用高阶（higher-order）函数来转换集合数据
    var addressesDesc = addresses
        .map<String, String>((key, value) => MapEntry(key, value.toString()));
    addressesDesc.forEach(_printAddress);
    //如果需要遍历一个集合，通常使用循环语句
    for (Point point in points) {
      log.Logger('colloction').log('point:${point.x},${point.y}');
    }
  }

  ///测试正则表达式
  testRegExp() {
    var numbers = RegExp(r'\d+');
    var someDigits = 'llamas live 15 to 20 years';
    var exedOut = someDigits.replaceAll(numbers, 'XX');
    log.Logger('regexp').log(exedOut);
    // Check whether the reg exp has a match in a string.
    var hasMatch = numbers.hasMatch(someDigits);
    log.Logger('regexp').log('$hasMatch');
  }

  ///测试URI
  testUri() {
    var uri = Uri(
        scheme: 'http',
        host: 'example.org',
        port: 8080,
        path: '/foo/bar',
        fragment: 'frag');
    log.Logger('uri').log('$uri');
  }

  ///测试datetime
  testDateTime() {
    var now = DateTime.now();
    var mills = now.millisecondsSinceEpoch;
    log.Logger('datetime').log('now: $mills');
  }

  ///打印map集合内容
  void _printAddress(String key, String value) {
    log.Logger('colloction').log('$key $value');
  }

  ///申请权限
  Future requestPermission() async {
    // 申请权限
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);

    // 申请结果
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);

    if (permission == PermissionStatus.granted) {
      print("权限申请通过");
      readFileAwaitFor();
      writeFile();
      directoryOperation();
    } else {
      print("权限申请未通过");
    }
  }

  readFileAwaitFor() async {
    log.Logger("readFileAwaitFor").log('${Directory.current}');
    var config = new File('/sdcard/config.txt');
    Stream<List<int>> inputStream = config.openRead();

    inputStream.transform(Utf8Decoder()).transform(new LineSplitter()).listen(
        (line) {
      log.Logger('readFileAwaitFor')
          .log('Got ${line.length} characters from stream');
      log.Logger('readFileAwaitFor').log('$line');
    }, onDone: () {
      log.Logger('readFileAwaitFor').log('file is now closed');
    }, onError: (e) {
      log.Logger('readFileAwaitFor').log(e.toString());
    });

    var contents = await config.readAsString();
    log.Logger('readFileAwaitFor')
        .log('The entire file is ${contents.length} characters long.');
    var contents2 = await config.readAsBytes();
    log.Logger('readFileAwaitFor')
        .log('The entire file is ${contents2.length} bytes long');
    /*   try {
      await for (var line in lines) {
        log.Logger('readFileAwaitFor').log('Got ${line.length} characters from stream');
        log.Logger('readFileAwaitFor').log('$line');
      }
      log.Logger('readFileAwaitFor').log('file is now closed');
    } catch (e) {
      log.Logger('readFileAwaitFor').log(e.toString());
    }
    */
  }

  writeFile() {
    var logFile = new File('/sdcard/log.txt');
    var sink = logFile.openWrite(mode: FileMode.append);
    sink.write('FILE ACCESSED ${new DateTime.now()}\n');
    sink.close();
    log.Logger('writeFile').log('write success');
  }

  directoryOperation() async {
    var dir = new Directory('/sdcard');
    try {
      var dirList = dir.list();
      await for (FileSystemEntity f in dirList) {
        if (f is File) {
          log.Logger('directoryOperation').log('Found file ${f.path}');
        } else if (f is Directory) {
          log.Logger('directoryOperation').log('Found dir ${f.path}');
        }
      }
    } catch (e) {
      log.Logger('directoryOperation').log(e.toString());
    }
  }

  dartHandler(HttpRequest request) {
    request.response.headers.contentType = ContentType('text', 'plain');
    request.response.write('Dart is optionally typed');
    request.response.close();
  }

  httpTest() async {
    var url = Uri.parse('http://192.168.20.158:80/php_hello.php');
    var httpClient = new HttpClient();
    var request = await httpClient.getUrl(url);
    var response = await request.close();
    log.Logger('httpTest')
        .log('${response.statusCode} ${response.reasonPhrase}');
    response.transform(Utf8Decoder()).transform(new LineSplitter()).listen(
      (line) {
        log.Logger('httpTest').log('Got ${line.length} characters from stream');
        log.Logger('httpTest').log('$line');
      },
      onDone: () {
        log.Logger('httpTest').log('file is now closed');
      },
      onError: (e) {
        log.Logger('httpTest').log(e.toString());
      },
    );

    httpClient.close();
    /*
    var req = 'http://localhost/php_hello.php';
    var requests = await HttpServer.bind('127.0.0.1', 8888);
    await for (var request in requests) {
      log.Logger('httpTest').log('Got request for ${request.uri.path}');
      if (request.uri.path == '/sdcard') {
        dartHandler(request);
      } else {
        request.response.write('Not found');
        request.response.close();
      }
    }
    */
  }

  ///转换相关  JSON   UTF-8
  void testConvert() {
    var jsonString = '''
  [
    {"score": 40},
    {"score": 80}
  ]
  ''';
    var scores = json.decode(jsonString);
    log.Logger('testJSON').log('scores is List :${scores is List}');
    for (var score in scores) {
      log.Logger('testJSON').log('score:${score['score']}');
    }

    var string = Utf8Decoder().convert([
      0xc3,
      0x8e,
      0xc3,
      0xb1,
      0xc5,
      0xa3,
      0xc3,
      0xa9,
      0x72,
      0xc3,
      0xb1,
      0xc3,
      0xa5,
      0xc5,
      0xa3,
      0xc3,
      0xae,
      0xc3,
      0xb6,
      0xc3,
      0xb1,
      0xc3,
      0xa5,
      0xc4,
      0xbc,
      0xc3,
      0xae,
      0xc5,
      0xbe,
      0xc3,
      0xa5,
      0xc5,
      0xa3,
      0xc3,
      0xae,
      0xe1,
      0xbb,
      0x9d,
      0xc3,
      0xb1
    ]);
    log.Logger('testUtf-8').log('$string');
  }
}

class Point {
  num x;
  num y;
  num z = 0;

  Point(this.x, this.y);

  //初始化列表构造函数
  Point.fromJson(Map json)
      : x = json['x'],
        y = json['y'],
        z = json['z'] ?? 0 {
    print('初始化完成');
  }

  //重定向构造函数
  Point.alongXAxis(num x) : this(x, 0);

  ///计算两点间的距离
  num distanceTo(Point other) {
    var dx = x - other.x;
    var dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  static num distanceBetween(Point a, Point b) {
    var dx = a.x - b.x;
    var dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }
}

class Point4 extends Point with ColorMixin {
  num w;

  Point4(this.w, {@required Map json}) : super.fromJson(json) {
    bgColor = Colors.white;
    color = Colors.black;
  }
}

///Mixins 是一种在多类继承中重用 一个类代码的方法
abstract class ColorMixin {
  Color bgColor;
  Color color;
}

enum Sex { MALE, FEMALE }

///使用泛型来减少重复代码
abstract class Cache<T> {
  T getByKey(String key);

  setByKey(String key, T value);
}

class Address {
  ///地址
  String address;

  ///纬度
  num lat;

  ///经度
  num lng;

  Address(this.address, {this.lat = 0, this.lng = 0});

  @override
  String toString() => '地址：$address 纬度：$lat 经度：$lng';
}
