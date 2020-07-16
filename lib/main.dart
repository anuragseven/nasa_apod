import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';



void main() => runApp(NasaApod());



class NasaApod extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(

      title: "NASA APOD",
      theme: ThemeData(

        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,

      ),

      initialRoute: '/',
      routes: {
        '/':(BuildContext ctx)=> ShowPic()


      },

    );
  }
}


class ShowPic extends StatefulWidget {

  @override
  _ShowPicState createState()=> _ShowPicState();

}

class _ShowPicState extends State<ShowPic>{
  String imageUrl;
  String imageInfo="Image Information";
  String imageTitle='Image Title';
  String mediaType ="mediaType";
  String year;
  String month;
  String day;
  DateTime dateTime;

  Future<void> datePickerDialog(BuildContext context) async{

    DateTime dateTime=await showDatePicker(context:context,initialDate: DateTime.now(),firstDate: DateTime(1995,6,16,0,0), lastDate: DateTime.now(),cancelText: "Cancel",confirmText: "OK");
    if(dateTime!=null){

      setState(() {
        year=dateTime.year.toString();
        month=dateTime.month.toString();
        day=dateTime.day.toString();

      });
      getApodResponse(year:year, month:month, day:day).then(displayApod).catchError((error)=>print(error));
    }


  }

  Future<Response> getApodResponse({String year ,String month , String day}){
    String date=year+"-"+month+"-"+day;
    String url =Uri.encodeFull("https://api.nasa.gov/planetary/apod?date=$date&hd=true&api_key=DEMO_KEY");

    Future <Response> response = get(url);

    return response;


  }

  displayApod(Response response){
    Map<String,dynamic> apoddetails=json.decode(response.body);


    setState(() {

      imageInfo=apoddetails['explanation']==null?"data is not available":apoddetails["explanation"];
      imageTitle=apoddetails['title']==null?"data is not available":apoddetails['title'];

    });
    mediaType=apoddetails['media_type'];
    if(mediaType=="image"){  imageUrl=apoddetails['hdurl'];}
    else {imageUrl=null;}

  }



  @override
  initState(){
    super.initState();
    dateTime=DateTime.now();
    year=dateTime.year.toString();
    month=dateTime.month.toString();
    day=dateTime.day.toString();
    getApodResponse(year:year,month:month,day:day).then((response) => displayApod(response)).catchError((error)=>print(error));



  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child : Scaffold(

          appBar: AppBar(
            title: Text("NASA APOD"),

          ),

          body: Padding(
            padding:EdgeInsets.only(top:20,left:30,right:30),
            child:ListView(


              children: <Widget>[
                GestureDetector( child: Row(
                  children: <Widget>[
                    Container(
                      child: Text(day+"-"+month+"-"+year),
                      decoration: BoxDecoration(border: Border.all(color: Colors.red,width: 1.5)),
                    ),
                    Padding(padding: EdgeInsets.only(left: 10),),
                    Icon(Icons.calendar_today,color: Colors.red,)

                  ],
                ),
                  onTap: ()async=>await datePickerDialog(context),
                ),
                Text(imageTitle,
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                Padding(padding: EdgeInsets.only(bottom: 20),
                ),
                Container(

                  child: imageUrl!=null?Image.network(imageUrl):mediaType=="video"?Text("image is not available"):Text("Waiting For the picture"),


                ),

                Padding(padding: EdgeInsets.only(bottom: 20),
                ),

                Text(imageInfo,
                  style: TextStyle(
                      fontStyle: FontStyle.italic
                  ),


                ),
              ],
            ),

          )
      ),
    );

  }


}

