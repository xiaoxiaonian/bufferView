import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plot/bean.dart';
import 'package:plot/check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// region  ---- symbol:分包标志位  payloadLength:当前数据包携带的数据字节数，16位，无符号，小端  fixed:固定字节  head:帧头  mac:MAC地址  cmd:命令域  err:错误码  frameLength:数据域长度  data:数据域  random:随机域  cs:校验和  ----
enum BufferType { symbol, payloadLength, fixed, head, mac, cmd, err, empty, frameLength, data, random, cs, end }
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
      home: const MyHomePage(title: ''),
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
  String? buffer;
  String printResult = "";

  // region  ---- 字节是加密的吗 ----
  bool encrypted = false;

  // endregion

  // String buffer = "0F0FA50006A200000864330AFFFF000000ED03FFFFFF3F8AAA00FE00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000058ED010203040506FFFFFFFFFFFF3289EF41571C3F8A1FFE01E100000864FFFF0A0000000000000000000100000005000102612CED032359A37C44279EA5475589CABBFE164ACFAE01020304050600000000001C442937CA";
  // String? buffer = "001900aac055d1532e3503bae90a0305000100004000f3755e06e516";
  // String? buffer ="00B900AAC055D1532E3503BAE95F59FC59585959F9595656035958FB5959512B750EA6A6A6A659A6A6A6A6A666D30C5959A6A6A6A6A659595959AB5A59593D595959D3585959D1A6A6A6A6A6A6A6DEA6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A6A66BD0B6180E4566D351595A595959512B3D595959B15A595953595959535959595C59595962EE5B4E59595959595959595959595959595959D33559599D8B644E59595959599E1D706E935CEE9CF97816";
  List<RegBean> list = [];
  RegExp regExp0 = RegExp(r"^\w{6}aa\w{2}55\w{12}e9");
  List<Map<String, dynamic>> arrRegExp = [
    {"RegExp": RegExp(r"^\w{2}"), "type": BufferType.symbol.index},
    {"RegExp": RegExp(r"(?<=^\w{2})\w{4}"), "type": BufferType.payloadLength.index},
    {"RegExp": RegExp(r"(?<=^\w{6})aa"), "type": BufferType.fixed.index},
    {"RegExp": RegExp(r"(?<=^\w{8})\w{2}"), "type": BufferType.head.index},
    {"RegExp": RegExp(r"(?<=^\w{10})55"), "type": BufferType.fixed.index},
    {"RegExp": RegExp(r"(?<=^\w{12})\w{12}"), "type": BufferType.mac.index},
    {"RegExp": RegExp(r"(?<=^\w{24})e9"), "type": BufferType.fixed.index},
    {"RegExp": RegExp(r"(?<=^\w{26})\w{2}"), "type": BufferType.cmd.index},
    {"RegExp": RegExp(r"(?<=^\w{28})\w{2}"), "type": BufferType.err.index},
    {"RegExp": RegExp(r"(?<=^\w{30})\w{4}"), "type": BufferType.frameLength.index},
    {"RegExp": RegExp(r"(?<=^\w{34})\w+(?=\w{12}$)"), "type": BufferType.data.index},
    {"RegExp": RegExp(r"\w{8}(?=\w{4}$)"), "type": BufferType.random.index},
    {"RegExp": RegExp(r"\w{2}(?=\w{2}$)"), "type": BufferType.cs.index},
    {"RegExp": RegExp(r"16$"), "type": BufferType.end.index},
  ];
  List<Color> arrColor = [Colors.blue, Colors.amberAccent, Colors.cyan, Colors.pinkAccent, Colors.brown, Colors.deepOrange, const Color(0xff00ff00), const Color(0xffff0000), Colors.amberAccent, Colors.black, Colors.blueGrey, Colors.indigoAccent, Colors.purpleAccent];
  Widget? extentWidget;

  @override
  void initState() {
    super.initState();
    updateContent();
  }

  void updateContent() {
    String? source;
    buffer = buffer?.toLowerCase();
    if (buffer != null && regExp0.hasMatch(buffer!)) {
      list.clear();
      debugPrint("hasMatch");
      for (var element in arrRegExp) {
        source = element["RegExp"].stringMatch(buffer);
        debugPrint("$source");
        // region  ---- 判断字节是否加密的 ----
        if ((element["RegExp"] as RegExp).pattern == r"(?<=^\w{8})\w{2}") {
          String head = int.parse(source!, radix: 16).toRadixString(2);
          encrypted = head.startsWith("1", 1) ? true : false;
          debugPrint("$encrypted");
          setState(() {});
        }
        // endregion
        if ((element["RegExp"] as RegExp).pattern == r"(?<=^\w{28})\w{2}") {
          putBuffer(value: source ?? "", type: source == "00" ? 6 : 7);
        } else {
          if ((element["RegExp"] as RegExp).pattern == r"(?<=^\w{30})\w{4}") {
            debugPrint("数据长度");
            dataLength = int.parse(source!.substring(0, 2), radix: 16);
            if (int.parse(source.substring(2, 4), radix: 16) > 0) {
              debugPrint("字节数量超出8位了");
              dataLength += int.parse(source.substring(2, 4), radix: 16) + 255;
            }
            debugPrint("$dataLength");
          }
          putBuffer(value: source ?? "", type: element["type"]);
        }
      }
      setState(() {
        printResult = "";
      });
    } else {
      setState(() {
        printResult = "不匹配";
        Future.delayed(Duration(microseconds: 1500),(){
          debugPrint("clear");
          /*setState(() {
            printResult = "1";
          });*/
        });
      });
      debugPrint("no match");
    }

  }

  void putBuffer({required String value, required int type}) {
    for (var element in value.characters) {
      list.add(RegBean.fromParams(name: element, color: arrColor[type], type: type));
    }
    // List<String> arrayListTarget = arr.map((e) => buffer.substring(e.fixed, e.end)).toList();
    // list = arrayListTarget.map((e) => RegBean.fromParams(name: e)).toList();
  }

  void onBufferTap({required int index}) {
    debugPrint("onBufferTap :$index");
    // debugPrint("$list");
    BufferCheck? bufferCheck;
    String source = "";
    BufferType type = BufferType.values.singleWhere((element) => element.index == list[index].type);
    Iterable iterable = list.where((element) => element.type == type.index);
    for (var element in iterable) {
      source += (element as RegBean).name ?? "";
    }
    debugPrint("tap :$type");
    switch (type) {
      case BufferType.symbol:
        break;
      case BufferType.payloadLength:
        debugPrint("");
        bufferCheck = PayloadLengthChecker();
        break;
      case BufferType.fixed:
        bufferCheck = FixedChecker();
        break;
      case BufferType.head:
        bufferCheck = HeadChecker();
        break;
      case BufferType.mac:
        bufferCheck = MacChecker();
        break;
      case BufferType.cmd:
        bufferCheck = CmdChecker();
        break;
      case BufferType.err:
        bufferCheck = ErrorChecker();
        break;
      case BufferType.empty:
        bufferCheck = ErrorChecker();
        break;
      case BufferType.frameLength:
        bufferCheck = FrameLengthChecker();
        break;
      case BufferType.data:
        bufferCheck = DataChecker();
        break;
      case BufferType.random:
        bufferCheck = RandomChecker();
        break;
      case BufferType.cs:
        bufferCheck = CSChecker();
        break;
      case BufferType.end:
        bufferCheck = EndChecker();
        break;
      default:
    }
    if (source.isNotEmpty) {
      extentWidget = bufferCheck?.getWidget(source: source, index: index);
    }
    setState(() {});
  }

  // region  ---- 解密 ----
  void decrypt() {
    String? frame = buffer?.substring(6, buffer?.length);
    String? source = frame?.substring(20, frame.length - 2);
    String result = "";
    for (int index = 0; index < source!.length; index = index + 2) {
      String ch = source.substring(index, index + 2);
      var o = (int.parse(ch, radix: 16) ^ 0x59).toRadixString(16);
      // debugPrint(o);
      result += (o.length == 1 ? '0' : '') + o;
    }
    debugPrint("16进制字符串$result");
    String head = int.parse(buffer!.substring(8, 10), radix: 16).toRadixString(2);
    head = head.replaceRange(1, 2, "0");
    String headReplaced = int.parse(head, radix: 2).toRadixString(16);
    buffer = buffer!.replaceRange(8, 10, headReplaced);
    buffer = buffer!.replaceRange(26, 26 + source.length, result);
    debugPrint("$buffer");
    updateContent();
    setState(() {});
  }

  // endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 20),
        alignment: Alignment.topLeft,
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    const Spacer(),
                    Visibility(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                            onPressed: () {
                              decrypt();
                            },
                            child: const Text("解密")),
                      ),
                      visible: encrypted,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 50),
                      child: ElevatedButton(
                          onPressed: () {
                            Clipboard.getData(Clipboard.kTextPlain).then((value) {
                              debugPrint("粘贴的数据->${value?.text}");
                              buffer = value?.text;
                              if (buffer == null) {
                                debugPrint("空数据");
                                setState(() {
                                  printResult = "空数据";
                                  /*Future.delayed(Duration(microseconds: 500),(){
                                    setState(() {
                                      printResult = "1";
                                    });
                                  });*/
                                });
                              } else {
                                if (buffer!.isNotEmpty) {
                                  updateContent();
                                }
                              }
                            });
                          },
                          child: Icon(list.isEmpty ? Icons.add : Icons.refresh_outlined)),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                  children: [
                    Wrap(
                      children: list
                          .asMap()
                          .keys
                          .map((e) => FractionallySizedBox(
                                alignment: Alignment.center,
                                widthFactor: 0.06,
                                child: GestureDetector(
                                    onTap: () {
                                      onBufferTap(index: e);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 5),
                                      alignment: Alignment.center,
                                      color: list[e].color,
                                      width: MediaQuery.of(context).size.width,
                                      child: Text(
                                        list[e].name ?? "",
                                      ),
                                    )),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: extentWidget ??
                          Container(
                            child: null,
                          ),
                    )
                  ],
                )))
              ],
            ),
            Align(
              child: Text(printResult),
              alignment: Alignment.topCenter,
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
