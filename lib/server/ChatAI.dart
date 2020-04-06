


import 'dart:async';
import 'dart:isolate';

class ChatAI {


  static  listenMessage(void onData(var message)) async{
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(main2, receivePort.sendPort);
    SendPort sendPort = await receivePort.first;
    ReceivePort response = ReceivePort();
    sendPort.send(["my message", response.sendPort]);
    response.listen(onData);
  }

  static Future<void> main2(SendPort sendPort) async{
    ReceivePort port = ReceivePort();
    sendPort.send(port.sendPort);
    await for(var msg in port){
      SendPort replyTo = msg[1];
      delayedMessage(replyTo);
    }
  }


 static void delayedMessage(SendPort replyTo){
    Future.delayed(Duration(seconds: 10),(){
      replyTo.send("my reply");
      delayedMessage(replyTo);
    });
  }


  static Future<void> main(SendPort sendPort) async{
    ReceivePort port = ReceivePort();
    sendPort.send(port.sendPort);
    await for(var msg in port){
      SendPort replyTo = msg[1];
      replyTo.send("my reply");

    }
  }


  static Future<dynamic> sendMessage() async{
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(main, receivePort.sendPort);
    SendPort sendPort = await receivePort.first;
    ReceivePort response = ReceivePort();
    sendPort.send(["my message", response.sendPort]);
    return response.first;
  }


}