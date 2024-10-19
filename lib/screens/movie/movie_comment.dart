import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movies_app/controller/GetX/state_controller.dart';
import 'package:movies_app/controller/fireBase/comment_firebase_controller.dart';
import 'package:vn_badwords_filter/vn_badwords_filter.dart';

import '../../model/detail_movie.dart';

class MovieComment extends StatefulWidget {

  final Movie movieDetail;

  const MovieComment({super.key, required this.movieDetail});

  @override
  State<MovieComment> createState() => _MovieCommentState();
}

class _MovieCommentState extends State<MovieComment> {

  final _textController = TextEditingController();
  //GetX
  final stateController = Get.find<StateManager>();
  //Firebase
  final commentFirebaseController = CommentFirebaseController();

  String text1 = 'Viết bình luận của bạn!';
  String text2 = 'Đăng nhập để bình luận!';


  String formatElapsedTime(Timestamp commentTime) {
    final currentTime = DateTime.now();
    final commentDateTime = commentTime.toDate();
    final difference = currentTime.difference(commentDateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: TextField(
            readOnly: stateController.loginState.value ? false : true,
            controller: _textController,
            maxLines: 5,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
                color: Colors.white
            ),
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white24,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none
                ),
                hintText: stateController.loginState.value ? text1 : text2,
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.comment),
                prefixIconColor: Colors.white,
                suffixIcon: IconButton(
                    onPressed: stateController.loginState.value
                    ? () {
                      if(_textController.text.isNotEmpty){
                        commentFirebaseController.addComment(VNBadwordsFilter.clean(_textController.text.trim()), widget.movieDetail.name.toString(), widget.movieDetail.slug.toString(), widget.movieDetail.thumbUrl.toString(), widget.movieDetail.posterUrl.toString());
                        commentFirebaseController.addHistoryActivity(widget.movieDetail.name.toString(), widget.movieDetail.slug.toString(), 'comment');
                        _textController.clear();
                      }
                    }
                    : null,
                    icon: const Icon(Icons.send,color: Colors.white,))
            ),
          ),
        ),
        Flexible(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('movies')
                .doc(widget.movieDetail.slug.toString())
                .collection('comments')
                .orderBy('time',descending: true)
                .limit(50)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white,));
              }

              else if(snapshot.hasData && snapshot.data!.docs.isNotEmpty){
                final comments = snapshot.data!.docs; // Lấy danh sách các comment
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final commentData = comments[index].data();
                    final Timestamp commentTime = commentData['time'] ?? Timestamp.now();

                    return Container(
                      color: Colors.white12,
                      margin: const EdgeInsets.only(bottom: 5),
                      child: ListTile(
                        title: Text(commentData['user'] ?? 'Anonymous',
                          style: const TextStyle(color: Colors.white,fontSize: 13,fontWeight: FontWeight.w600),),
                        subtitle: Text(commentData['content'] ?? '',
                          style: const TextStyle(color: Colors.white,fontSize: 13,fontWeight: FontWeight.w300),),
                        trailing: Text(formatElapsedTime(commentTime)), // Hiển thị thời gian comment theo yêu cầu
                      ),
                    );
                  },
                );
              }
              return Column(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: const Image(image: AssetImage('assets/images/comment_image.png'),)),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                    child: Text('Chưa có bình luận! Hãy là người đầu tiên bình luận về bộ phim này ngay nào!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),),
                  )
                ],
              );
            },
          ),
        )

      ],
    );
  }
}
