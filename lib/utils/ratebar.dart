import 'package:expange/colors.dart';
import 'package:flutter/material.dart';

typedef void RatingChangeCallback(int rating);

class RateBar extends StatelessWidget {
  final int starCount;
  final int rating;
  final RatingChangeCallback onRatingChanged;

  RateBar({
    this.starCount = 5,
    @required this.rating,
    @required this.onRatingChanged,
  });

  Widget buildStar(BuildContext context, int index) {
    Icon icon = (index > rating)
        ? new Icon(Icons.star_border, color: kGreenColor, size: 30.0)
        : new Icon(Icons.star, color: kGreenColor, size: 30.0);

    return new InkResponse(
      onTap: onRatingChanged == null ? null : () => onRatingChanged(index),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children:
          new List.generate(starCount, (index) => buildStar(context, index)),
    );
  }
}
