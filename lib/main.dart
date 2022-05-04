import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plot/bean.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// region  ---- symbol:分包标志位  payloadLength:当前数据包携带的数据字节数，16位，无符号，小端  start:起始位  head:帧头  mac:MAC地址  cmd:命令域  err:错误码  frameLength:数据域长度  data:数据域  random:随机域  cs:校验和  ----
enum BufferType { symbol, payloadLength, start, head, mac, cmd, err, frameLength, data, random, cs, end }
// endregion

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int dataLength = 0;

  // String? buffer;

  // String buffer = "0F0FA50006A200000864330AFFFF000000ED03FFFFFF3F8AAA00FE00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000058ED010203040506FFFFFFFFFFFF3289EF41571C3F8A1FFE01E100000864FFFF0A0000000000000000000100000005000102612CED032359A37C44279EA5475589CABBFE164ACFAE01020304050600000000001C442937CA";
  String? buffer = "001900aa0055d1532e3503bae9060005000100004000f3755e06e516";

  // String? buffer ="00B900AAC055D1532E3503BAE95F59FC59585959F9595656035958FB5959512B750EA6A6A6A659A6A6A6A6A666D30C5959A6A6A6A6A659595959AB5A59593D595959D3585959D1A6A6A6A6A6A6A6DEA6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A66BD0B6180E4566D351595A595959512B3D595959B15A595953595959535959595C59595962EE5B4E59595959595959595959595959595959D33559599D8B644E59595959599E1D706E935CEE9CF97816";
  List<RegBean> list = [];
  RegExp regExp0 = RegExp(r"^\w{6}aa\w{2}55\w{12}e9");
  List<Map<String, dynamic>> arrRegExp = [
    {"RegExp": RegExp(r"^\w{2}"), "type": BufferType.symbol.index},
    {"RegExp": RegExp(r"(?<=^\w{2})\w{4}"), "type": BufferType.payloadLength.index},
    {"RegExp": RegExp(r"(?<=^\w{6})aa"), "type": BufferType.start.index},
    {"RegExp": RegExp(r"(?<=^\w{8})\w{2}"), "type": BufferType.head.index},
    {"RegExp": RegExp(r"(?<=^\w{10})55"), "type": BufferType.start.index},
    {"RegExp": RegExp(r"(?<=^\w{12})\w{12}"), "type": BufferType.mac.index},
    {"RegExp": RegExp(r"(?<=^\w{24})e9"), "type": BufferType.start.index},
    {"RegExp": RegExp(r"(?<=^\w{26})\w{2}"), "type": BufferType.cmd.index},
    {"RegExp": RegExp(r"(?<=^\w{28})\w{2}"), "type": -1},
    {"RegExp": RegExp(r"(?<=^\w{30})\w{4}"), "type": BufferType.frameLength.index},
    {"RegExp": RegExp(r"(?<=^\w{34})\w+(?=\w{12}$)"), "type": BufferType.data.index},
    {"RegExp": RegExp(r"\w{8}(?=\w{4}$)"), "type": BufferType.random.index},
    {"RegExp": RegExp(r"\w{2}(?=\w{2}$)"), "type": BufferType.cs.index},
    {"RegExp": RegExp(r"16$"), "type": BufferType.end.index},
  ];
  List<Color> arrColor = [Colors.blue, Colors.amberAccent, Colors.cyan, Colors.pinkAccent, Colors.brown, Colors.lightGreen, const Color(0xffff0000), const Color(0xff00ff00), Colors.black, Colors.blueGrey, Colors.indigoAccent, Colors.purpleAccent];

  @override
  void initState() {
    super.initState();
    updateContent();
  }

  void updateContent() {
    String? source;
    buffer = buffer?.toLowerCase();
    if (buffer != null && regExp0.hasMatch(buffer!)) {
      debugPrint("hasMatch");
      for (var element in arrRegExp) {
        source = element["RegExp"].stringMatch(buffer);
        debugPrint("$source");
        if ((element["RegExp"] as RegExp).pattern == r"(?<=^\w{28})\w{2}") {
          putBuffer(source ?? "", source == "00" ? 7 : 6);
        }
        /*else if((element["RegExp"] as RegExp).pattern == r"(?<=^\w{34})")
          {

          }*/
        else {
          if ((element["RegExp"] as RegExp).pattern == r"(?<=^\w{30})\w{4}") {
            debugPrint("数据长度");
            dataLength = int.parse(source!.substring(0, 2), radix: 16);
            if (int.parse(source.substring(2, 4), radix: 16) > 0) {
              debugPrint("字节数量超出8位了");
              dataLength += int.parse(source.substring(2, 4), radix: 16) + 255;
            }
            debugPrint("$dataLength");
          }
          putBuffer(source ?? "", element["type"]);
        }
      }
    } else {
      debugPrint("no match");
    }
    setState(() {});
  }

  void putBuffer(String value, int type) {
    value.characters.forEach((element) {
      list.add(RegBean.fromParams(name: element, color: arrColor[type]));
    });

    // List<String> arrayListTarget = arr.map((e) => buffer.substring(e.start, e.end)).toList();
    // list = arrayListTarget.map((e) => RegBean.fromParams(name: e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        alignment: Alignment.center,
        color: Colors.blueGrey,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: [
          SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Wrap(
                children: list
                    .asMap()
                    .keys
                    .map((e) => FractionallySizedBox(
                          alignment: Alignment.center,
                          widthFactor: 0.06,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            alignment: Alignment.center,
                            color: list[e].color,
                            width: MediaQuery.of(context).size.width,
                            // height: MediaQuery.of(context).size.height,
                            child: Text(
                              list[e].name ?? "",
                            ),
                          ),
                        ))
                    .toList(),
              )
            ],
          )),
          Positioned(
            child: ElevatedButton(
                onPressed: () {
                  Clipboard.getData(Clipboard.kTextPlain).then((value) {
                    debugPrint("粘贴的数据->${value?.text}");
                    buffer = value?.text;
                    if (buffer == null) {
                      debugPrint("空数据");
                    } else {
                      if (buffer!.isNotEmpty) {
                        updateContent();
                      }
                    }
                  });
                },
                child: Icon(list.isEmpty ? Icons.add : Icons.refresh_outlined)),
            top: 5,
            right: 0,
          )
        ]),
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), */ // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
