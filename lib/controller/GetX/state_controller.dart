
import 'package:get/get.dart';


class StateManager extends GetxController {


  // Trạng thái đăng nhập
  RxBool loginState = false.obs;
  updateLoginState(bool newValue){
      loginState.value = newValue;
  }

  // Carousel State
  RxInt currentCarouselIndex = 0.obs;
  void initCarouselIndex(){
    currentCarouselIndex.value = 0;
  }
  void updateCarouselIndex(int newValue) {
    currentCarouselIndex.value = newValue;
  }

  RxBool autoPlayState = true.obs;
  enableAutoPlay(){
    if(autoPlayState.value == false){
      autoPlayState.value = true;
    }
  }
  disableAutoPlay(){
    if(autoPlayState.value == true){
      autoPlayState.value = false;
    }
  }

  // Trạng thái hiển thị nút xóa hay nút V
  RxBool isRemovingItem = false.obs;
  void initRemovingStatus() {
    isRemovingItem.value = false;
  }
  void updateRemovingStatus() {
    isRemovingItem.value = !isRemovingItem.value;
  }

  //
  RxBool showMoreTitle = false.obs;
  void initShowTitleStatus() {
    showMoreTitle.value = false;
  }
  void updateShowTitleStatus() {
    showMoreTitle.value = !showMoreTitle.value;
  }

//
  RxBool showMoreDescription = false.obs;
  void initShowDescriptionStatus() {
    showMoreDescription.value = false;
  }
  void updateShowDescriptionStatus() {
    showMoreDescription.value = !showMoreDescription.value;
  }

  //

  RxBool isLoadData = false.obs;

  void updateLoadDataState() {
    isLoadData.value = true;
  }


}