
import 'package:get/get.dart';

class MovieController extends GetxController{

  final RxInt _seekTime = 0.obs;

  initSeekTime(){
    _seekTime.value = 0;
  }

  setSeekTime(int newTime){
    _seekTime.value = newTime;
  }

  int getSeekTime() => _seekTime.value;

}