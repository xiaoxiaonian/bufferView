import 'package:flutter/material.dart';

abstract class BufferCheck {
  Widget? widget;

  Widget? getWidget({required String source, required int index});
}

class PayloadLengthChecker extends BufferCheck {
  @override
  Widget? getWidget({required String source, required int index}) {
    int length;
    length = int.parse(source.substring(0, 2), radix: 16);
    if (int.parse(source.substring(2, 4), radix: 16) > 0) {
      debugPrint("字节数量超出8位了");
      length += int.parse(source.substring(2, 4), radix: 16) + 255;
    }
    length *= 2;
    debugPrint(source);
    widget = Row(
      children: [
        const Text(
          "(Payload)字节数:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text("$length", style: const TextStyle(fontSize: 16)),
          flex: 1,
        )
      ],
    );
    return widget;
  }
}

class FrameLengthChecker extends BufferCheck {
  @override
  Widget? getWidget({required String source, required int index}) {
    int length;
    length = int.parse(source.substring(0, 2), radix: 16);
    if (int.parse(source.substring(2, 4), radix: 16) > 0) {
      debugPrint("字节数量超出8位了");
      length += int.parse(source.substring(2, 4), radix: 16) + 255;
    }
    length *= 2;
    debugPrint(source);
    widget = Row(
      children: [
        const Text(
          "数据域长度:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text("$length", style: const TextStyle(fontSize: 16)),
          flex: 1,
        )
      ],
    );
    return widget;
  }
}

class FixedChecker extends BufferCheck {
  @override
  Widget? getWidget({required String source, required int index}) {
    widget = Row(
      children: [
        const Text(
          "固定字节:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(source, style: const TextStyle(fontSize: 16)),
          flex: 1,
        )
      ],
    );
    return widget;
  }
}

class MacChecker extends BufferCheck {
  @override
  Widget? getWidget({required String source, required int index}) {
    String value = "";
    for (int main = 10, sub = main + 2; main >= 0; main -= 2, sub -= 2) {
      value += source.substring(main, sub);
    }
    widget = Row(
      children: [
        const Text(
          "设备物理地址:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16)),
          flex: 1,
        )
      ],
    );
    return widget;
  }
}

class HeadChecker extends BufferCheck {
  @override
  Widget? getWidget({required String source, required int index}) {
    String head = int.parse(source, radix: 16).toRadixString(2);
    String type = head.startsWith("0") ? "命令帧" : "应答帧";
    String isEncrypt = head.startsWith("1", 1) ? "已加密" : "未加密";
    widget = Row(
      children: [
        const Text(
          "帧头:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text("$head  $type  $isEncrypt", style: const TextStyle(fontSize: 16)),
          flex: 1,
        )
      ],
    );
    return widget;
  }
}

//section 命令
class CmdChecker extends BufferCheck {
  @override
  Widget? getWidget({required String source, required int index}) {
    int cmd = int.parse(source, radix: 16);
    List<String> arrTitle = ["", "配置帧加密", "读取蓝牙卡信息", "写入蓝牙卡信息", "读取用户信息", "写入用户信息", "读取IC卡数据", "写入IC卡数据", "擦除IC卡数据", "获取IC卡密码错误计数器", "获取IC卡密码", "验证IC卡密码", "修改IC卡密码", "获取当前MTU"];
    List<String> arrDescription = ["",
      """
          命令帧 DATA[0]：
                  0x59 - 允许回应非加密帧
                  0x00 - 不允许回应非加密帧
                  特别要求：该命令帧必须加密
          回应帧 无       
      """,
      """
          命令帧 读取蓝牙卡信息，该信息保存在蓝牙芯片上，不在IC卡中
          回应帧 读取蓝牙卡信息回应
                    DATA[0~3]: 蓝牙卡ID，32位BCD编码，如{0x78,0x56,0x34,0x12}代表ID为
                    12345678
                    DATA[4]: IC卡类型
                     0x01 – 记忆卡
                     0x02 – 逻辑加密卡
                     0x03 – CPU卡
                     0x04 – 射频卡
                    DATA[5]: IC卡型号:
                     0x01 – SLE4442_3V3
                     0x02 – AT88SC102_3V3
                    DATA[6]: 蓝牙卡状态:
                     0xFF – 初始化
                     0xAA – 已发行
                     0x55 – 已报废
                    DATA[7]:电池电量百分比(0~100)
                    DATA[8~11]:发行日期，32位BCD编码，格式YYYYMMDD，如
                    {0x30,0x08,0x19,0x20}代表2019年8月30日
                    DATA[12~13]: IC卡容量
                    DATA[14~15]:Reserved
                    DATA[16~47]: 版本信息
      """,
      """
          命令帧 写入蓝牙卡信息，该信息保存在蓝牙芯片上，不在IC卡中
                    DATA[0~3]: 蓝牙卡ID，32位BCD编码，如
                    {0x78,0x56,0x34,0x12}代表ID为12345678
                    DATA[4]: IC卡类型
                     0x01 – 记忆卡
                     0x02 – 逻辑加密卡
                     0x03 – CPU卡
                     0x04 – 射频卡
                    DATA[5]: IC卡型号:
                     0x01 – SLE4442_3V3
                     0x02 – AT88SC102_3V3
                    DATA[6]: 蓝牙卡状态:
                     0xFF – 初始化
                     0xAA – 已发行
                     0x55 – 已报废
                    DATA[7]:Reserved
                    DATA[8~11]:发行日期，32位BCD编码，格式YYYYMMDD， 如{0x30,0x08,0x19,0x20}代表2019年8月30日
                    DATA[12~13]: IC卡容量
                    DATA[14~15]:Reserved
                    DATA[16~47]: 版本信息
          回应帧 无 
      """,
      """
          命令帧 读取用户信息，该信息保存在蓝牙芯片上，不在IC
                 卡中
          回应帧 读取用户信息回应
                DATA[0~31]: 用户信息
      """,
      """
          命令帧 写入用户信息，该信息保存在蓝牙芯片上，不在IC
                卡中
          回应帧 写入蓝牙卡信息回应
                DATA[0~31]: 用户信息
      """,
      """
          命令帧 读取IC卡数据
                    DATA[0]:读取区域类型
                     0x01:主数据区
                     0x02:保护位区
                    DATA[1 ~ 2]:读取地址
                    DATA[3 ~ 4]:读取长度N，N>0
                    4442卡这两个区域均支持，主数据区共256字节，保护位
                    区共4 字节
                    102卡仅有主数据区，共178字节
          回应帧 读取IC卡数据回应
                    DATA[0]:读取区域类型
                     0x01:主数据区
                     0x02:保护位区
                    DATA[1 ~ 2]:读取地址
                    DATA[3 ~ 4]:读取长度N，N>0
                    DATA[5 ~ 4+N]:读取的数据
      """,
      """
         命令帧 写入IC卡数据
                   DATA[0]:写入区域类型
                    0x01:主数据区
                    0x02:保护位区
                   DATA[1 ~ 2]:写入地址
                   DATA[3 ~ 4]:写入长度N，N>0
                   DATA[5 ~ 4+N]:写入数据
                   4442卡这两个区域均支持，主数据区共256字节，保护
                   位区共4字节
                   102卡仅有主数据区，共178字节
         回应帧 写入IC卡数据回应
                   DATA[0]:写入区域类型
                    0x01:主数据区
                    0x02:保护位区
                   DATA[1 ~ 2]:写入地址
                   DATA[3 ~ 4]:写入长度N，N>0
      """,
      """
         命令帧 擦除IC卡数据
                   DATA[0]:擦除区域类型
                    0x01:主数据区
                    0x02:保护位区
                   DATA[1 ~ 2]:擦除地址
                   DATA[3 ~ 4]:擦除长度N，N>0
                   4442卡这两个区域均支持，主数据区共256字节，保护位区
                   共4字节
                   102卡仅有主数据区，共178字节
         回应帧 擦除IC卡数据回应
                   DATA[0]:擦除区域类型
                    0x01:主数据区
                    0x02:保护位区
                   DATA[1 ~ 2]:擦除地址
                   DATA[3 ~ 4]:擦除长度N，N>0
      """,
      """
         命令帧 读取IC卡密码错误计数器
         回应帧 读取IC卡密码错误计数器
                   回应
                   DATA[0]: 计数值，8位无符号数，如0x03代表
                   错误计数为3
      """,
      """
         命令帧 无
         回应帧 4442卡：4 byte
                DATA[0]：密钥
                DATA[1~3]：加密后密码
                102卡：3byte
                DATA[0]：密钥
                DATA[1~2]：加密后密码
      """,
      """
         命令帧 4442卡：4 byte
               DATA[0]：加密参数
               DATA[1~3]：加密后密码
               102卡：3byte
               DATA[0]：加密参数
               DATA[1~2]：加密后密码
         回应帧 无
      """,
      """
         命令帧 4442卡：8 byte
               DATA[0]：原密码加密参数
               DATA[1~3]：加密后原密码
               DATA[4]：新密码加密参数
               DATA[5~7]：加密后新密码
               102卡：6 byte
               DATA[0]：原密码加密参数
               DATA[1~2]：加密后原密码
               DATA[3]：新密码加密参数
               DATA[4~5]：加密后新密码
         回应帧 无
      """,
      """
         命令帧 无
         回应帧 DATA[0~1]：
               当前MTU，16位，无符号数，小端
      """
    ];
    widget = Column(
      children: [
        Row(
          children: [
            const Text(
              "命令:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(arrTitle[cmd], style: const TextStyle(fontSize: 16)),
              flex: 1,
            )
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "说明:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(arrDescription[cmd], style: const TextStyle(fontSize: 16)),
              flex: 1,
            )
          ],
        )
      ],
    );
    return widget;
  }
}

class ErrorChecker extends BufferCheck {
  @override
  Widget? getWidget({required String source, required int index}) {
    int error = int.parse(source, radix: 16);
    List<String> arr = ["无错,操作成功", "未知错误", "未知命令。即该协议不支持的命令", "DATA域错误。未按命令格式传输正确的DATA", "不支持的命令。如4442与102卡均不支持写入蓝牙卡信息", "密码错误。验证、修改密码时传入的密码有误", "卡片已熔断", "电池电量过低，不允许对IC卡进行操作"];
    widget = Row(
      children: [
        const Text(
          "错误码说明:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        //section arr error
        Expanded(
          child: Text(arr[error], style: const TextStyle(fontSize: 16)),
          flex: 1,
        )
      ],
    );
    return widget;
  }
}

class DataChecker extends BufferCheck {
  @override
  Widget? getWidget({required String source, required int index}) {
    widget = Row(
      children: [
        const Text(
          "数据域:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(source, style: const TextStyle(fontSize: 16)),
          flex: 1,
        )
      ],
    );
    return widget;
  }
}

class RandomChecker extends BufferCheck {
  @override
  Widget? getWidget({required String source, required int index}) {
    widget = Row(
      children: [
        const Text(
          "随机域:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(source, style: const TextStyle(fontSize: 16)),
          flex: 1,
        )
      ],
    );
    return widget;
  }
}

class CSChecker extends BufferCheck {
  @override
  Widget? getWidget({required String source, required int index}) {
    widget = Row(
      children: [
        const Text(
          "校验和:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(source, style: const TextStyle(fontSize: 16)),
          flex: 1,
        )
      ],
    );
    return widget;
  }
}

class EndChecker extends BufferCheck {
  @override
  Widget? getWidget({required String source, required int index}) {
    widget = Row(
      children: [
        const Text(
          "结束位:",
          //section arr dsds
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(source, style: const TextStyle(fontSize: 16)),
          flex: 1,
        )
      ],
    );
    return widget;
  }
}
