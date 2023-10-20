import 'package:flutter/material.dart';
import 'package:instagram_flutter/resources/firestore_methods.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final snap;
  final postId;
  const CommentCard({super.key, required this.snap, required this.postId});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(widget.snap['profilePic']),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.snap['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: " ${widget.snap['caption']}",
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(
                        widget.snap['datePublished'].toDate(),
                      ),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w400),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () async {
                if (widget.snap['likes'].contains(widget.snap['uid'])) {
                  await FirestoreMethods().unlikeComment(widget.postId,
                      widget.snap['commentId'], widget.snap['uid']);
                } else {
                  await FirestoreMethods().likeComment(widget.postId,
                      widget.snap['commentId'], widget.snap['uid']);
                }
              },
              child: widget.snap['likes'].contains(widget.snap['uid'])
                  ? const Icon(Icons.favorite,
                      color: Colors.redAccent, size: 16)
                  : const Icon(Icons.favorite_border, size: 16),
            ),
          )
        ],
      ),
    );
  }
}
