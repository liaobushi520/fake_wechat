import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const BG_COLORS = [Color.fromARGB(255, 244, 235, 219)];

class ReadPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ReadPageState();
  }
}

class ReadPageState extends State<ReadPage> {
  bool operateLayerVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GestureDetector(
            child: PageView.builder(
                itemCount: 100,
                itemBuilder: (context, index) {
                  return BookPage(
                    index: index,
                  );
                }),
            onTap: () {
              setState(() {
                operateLayerVisible = !operateLayerVisible;
              });
            },
          ),
          Opacity(
            opacity: operateLayerVisible ? 1 : 0,
            child: OperateLayer(),
          )
        ],
      ),
    );
  }
}

class BookPage extends StatefulWidget {
  final int index;

  const BookPage({Key key, this.index}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BookPageState();
  }
}

class BookPageState extends State<BookPage> with AutomaticKeepAliveClientMixin {
  GlobalKey globalKey = GlobalKey();
  FocusNode focusNode = FocusNode();

  TextEditingController controller = TextEditingController(
      text:
          "前不久听说，业内最近出了《人类简史》这么一本“奇书”，作者是个名叫尤瓦尔·赫拉利的以色列年轻人。此书在2012年以希伯来文出版，很快就被翻译成近30种文字，不仅为全球学术界所瞩目，而且引起了公众的广泛兴趣。一部世界史新著竟能“火”成这样，实在是前所未闻。所以，当中信出版社请我为本书的中文版作序时，我也就出于好奇而暂时应承了下来：“先看看吧。”而这一看，我就立刻“着道”了——拿起了就放不下，几乎是一口气读完。吸引力主要来自作者才思的旷达敏捷，还有译者文笔的生动晓畅。而书中屡屡提及中国的相关史实，也能让人感到一种说不出的亲切，好像自己也融入其中，读来欲罢不能。后来看了策划编辑舒婷的特别说明，才知道该书中文版所参照的英文版，原来是作者特地为中国读者“量身定做”的。他给各国的版本也都下过同样的功夫——作者的功力之深，由此可见一斑。");

  Future<Uint8List> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      return pngBytes;
    } catch (e) {
      print(e);
    }
    return null;
  }

  OverlayEntry overlayEntry;

  Uint8List image;

  ScrollController scrollController = ScrollController();

  final MAGNIFIER_SIZE = 150.0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      print("${scrollController.offset}");
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: Listener(
        child: RepaintBoundary(
          key: globalKey,
          child: TextField(
            //  selectionControls: ,
            expands: true,
            scrollController: scrollController,
            focusNode: focusNode,
            cursorColor: Color.fromARGB(255, 150, 118, 60),
            //  backgroundCursorColor: Colors.redAccent,
            controller: controller,
            readOnly: true,
            maxLines: null,
            minLines: null,
            style: TextStyle(color: Colors.black, fontSize: 24),
            decoration: null,
          ),
        ),
        onPointerDown: (event) async {
          if (image == null) {
            image = await _capturePng();
          }
        },
        onPointerMove: (detail) async {
          RenderBox renderObject = globalKey.currentContext.findRenderObject();
          double dx =
              -1 + (2 * detail.localPosition.dx / renderObject.size.width);
          double dy = -1 +
              (2 *
                  (detail.localPosition.dy + scrollController.offset) /
                  (scrollController.offset + renderObject.size.height));
          overlayEntry?.remove();

          double left, top;
          if (detail.localPosition.dx <= MAGNIFIER_SIZE / 2) {
            left = 0;
          } else {
            left = detail.localPosition.dx - MAGNIFIER_SIZE / 2;
          }

          if (detail.localPosition.dy + MAGNIFIER_SIZE >
              renderObject.size.height) {
            top = detail.localPosition.dy - MAGNIFIER_SIZE;
          } else {
            top = detail.localPosition.dy;
          }

          overlayEntry = OverlayEntry(builder: (context) {
            return Positioned(
                left: left,
                top: top,
                width: MAGNIFIER_SIZE,
                height: MAGNIFIER_SIZE,
                child: ClipOval(
                  child: Container(
                    color: BG_COLORS[0],
                    child: Image.memory(
                      image,
                      fit: BoxFit.none,
                      scale: 3,
                      alignment: Alignment(dx, dy),
                    ),
                  ),
                ) // Image.memory(image,width: 100,height: 100,),
                );
          });
          Overlay.of(context).insert(overlayEntry);
        },
        onPointerUp: (event) {
          overlayEntry?.remove();
          overlayEntry = null;
        },
      ),
      color: BG_COLORS[0],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class OperateLayer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OperateLayerState();
  }
}

class OperateLayerState extends State {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0,
          child: Row(
            children: <Widget>[
              Icon(Icons.book),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          child: Row(
            children: <Widget>[
              Icon(Icons.lightbulb_outline),
            ],
          ),
        ),
      ],
    );
  }
}
