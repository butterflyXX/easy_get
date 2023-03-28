import 'package:flutter/material.dart';

class _DataListener extends Listenable {
  final List<VoidCallback> onData = [];
  @override
  void addListener(VoidCallback listener) {
    onData.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    onData.remove(listener);
  }
}

typedef EasyGetControllerBuilder = Widget Function(BuildContext context);

class EasyGetBuilder<T extends EasyGetController> extends StatefulWidget {
  final EasyGetControllerBuilder builder;
  final String? tag;
  const EasyGetBuilder({Key? key, required this.builder, this.tag,}) : super(key: key);

  @override
  State<EasyGetBuilder<T>> createState() => _EasyGetBuilderState<T>();
}

class _EasyGetBuilderState<T extends EasyGetController> extends State<EasyGetBuilder<T>> {
  EasyGetControllerItem<T>? controllerItem;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controllerItem = EasyGet._findItem<T>(tag: widget.tag)!;
    controllerItem!.addCount();
    controllerItem!.controller.listener.addListener(() {
      setState(() {
      });
    });
  }
  @override
  Widget build(BuildContext context) => widget.builder(context);

  @override
  void dispose() {
    controllerItem!.subCount();
    if (controllerItem!.canBeRemoved()) {
      EasyGet.delete(controllerItem!);
    }
    super.dispose();
  }
}

class EasyGetController {
  final bool isGlobal;
  final listener = _DataListener();
  EasyGetController({this.isGlobal = false});
  update() {
    for (var e in listener.onData) {
      e();
    }
  }
}

class EasyGet {
  static final Map<String,EasyGetControllerItem> controllers = {};
  static T put<T extends EasyGetController>(T controller,{String? tag}) {
    String key = _getKey<T>(tag: tag);
    if (!controllers.containsKey(key)) {
      controllers[key] = EasyGetControllerItem<T>(controller);
    }
    return getController<T>(tag: tag)!;
  }

  static delete<T extends EasyGetController>(EasyGetControllerItem<T> controllerItem,{String? tag}) {
    print("${controllerItem.controller}controller被移除了");
    controllers.remove(_getKey<T>(tag: tag));
  }

  static T? find<T extends EasyGetController>({String? tag}) {
    return getController(tag: tag);
  }

  static EasyGetControllerItem<T>? _findItem<T extends EasyGetController>({String? tag}) {
    return controllers[_getKey<T>(tag: tag)] as EasyGetControllerItem<T>?;
  }

  static String _getKey<T extends EasyGetController>({String? tag}) {
    String key = T.toString()+(tag??"");
    return key;
  }

  static T? getController<T extends EasyGetController>({String? tag}) {
    return controllers[_getKey<T>(tag: tag)]?.controller as T?;
  }
}

class EasyGetControllerItem<T extends EasyGetController> {
  final T controller;
  int count = 0;
  EasyGetControllerItem(this.controller);
  addCount() {
    count++;
  }

  subCount() {
    count--;
  }

  bool canBeRemoved() {
    if (controller.isGlobal) return false;
    return count == 0;
  }
}
