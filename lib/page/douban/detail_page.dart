
import 'package:flutter/material.dart';

class MovieDetailPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {

    return MovieDetailPageState();
  }


}




class MovieDetailPageState extends State<MovieDetailPage>{



  @override
  Widget build(BuildContext context) {
   return Column(
     children: <Widget>[
       DecoratedBox(
         decoration: BoxDecoration(image: DecorationImage(
           image: NetworkImage("https://movie.douban.com/subject/26348103/photos?type=R"),
         )),
       ),
       Row(
         children: <Widget>[
           Text("小妇人"),
           Text("little woman"),
           Text("美国/剧情"),

           Column(

             children: <Widget>[


             ],
           )


         ],
       ),


     ],
   );

  }
}