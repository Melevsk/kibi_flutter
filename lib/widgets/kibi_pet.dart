import 'package:flutter/material.dart';
class KibiPet extends StatelessWidget {
  final int style, stage, mood; final double size;
  const KibiPet({super.key,required this.style,required this.stage,required this.mood,this.size=220});
  @override Widget build(BuildContext context){final s=style.clamp(0,8);final g=stage.clamp(1,3);return SizedBox.square(dimension:size,child:Image.asset('assets/kibi/kibi_${s}_stage_$g.png',fit:BoxFit.contain,filterQuality:FilterQuality.high));}
}
class KibiBackground extends StatelessWidget {final Widget child;final bool garden;const KibiBackground({super.key,required this.child,this.garden=false});@override Widget build(BuildContext context)=>Container(decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:garden?[const Color(0xFFE8F7F0),const Color(0xFFCDE8D6)]:[const Color(0xFFFFFAF4),const Color(0xFFFFEFE3)])),child:Stack(children:[Positioned(top:45,right:-45,child:_blob(const Color(0x337FC8E8),185)),Positioned(bottom:65,left:-55,child:_blob(const Color(0x33A9D98E),205)),child]));Widget _blob(Color c,double s)=>Container(width:s,height:s,decoration:BoxDecoration(color:c,shape:BoxShape.circle));}
