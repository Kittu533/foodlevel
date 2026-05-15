import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../scan/domain/food_prediction.dart';

class PredictionConfidenceList extends StatelessWidget {
  const PredictionConfidenceList({required this.predictions, super.key});

  final List<FoodPrediction> predictions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final prediction in predictions)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    prediction.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: prediction.confidence,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 44,
                  child: Text(
                    Formatters.percent(prediction.confidence),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
