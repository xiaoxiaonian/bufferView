import 'dart:convert' show json;

import 'package:flutter/material.dart';

class RegBean {

  int? type;
  Color? color;
  String? name;

  RegBean.fromParams({this.type, this.color, this.name});

  factory RegBean(Object jsonStr) => jsonStr is String ? RegBean.fromJson(json.decode(jsonStr)) : RegBean.fromJson(jsonStr);

  static RegBean? parse(jsonStr) => ['null', '', null].contains(jsonStr) ? null : RegBean(jsonStr);

  RegBean.fromJson(jsonRes) {
    type = jsonRes['type'];
    color = jsonRes['color'];
    name = jsonRes['name'];
  }

  @override
  String toString() {
    return '{"type": $type, "color": ${color != null?'$color':'null'}, "name": ${name != null?'${json.encode(name)}':'null'}}';
  }

  String toJson() => this.toString();
}