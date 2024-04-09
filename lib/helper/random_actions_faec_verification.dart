import 'dart:math';

import 'package:poc_face_detection_by_mlkit/face_detector/face_actions_constant.dart';


class RandomActionsFaceVerificationHelper{
  static List<FaceActionsConstant> toActionsType(int countAction){
    final Random _random = Random();
    final List<FaceActionsConstant> _listActions = [
      FaceActionsConstant.MOUTH_OPEN,
      FaceActionsConstant.EYES_CLOSED,
      FaceActionsConstant.HEAD_DOWN,
      FaceActionsConstant.HEAD_UP,
      FaceActionsConstant.TURN_LEFT,
      FaceActionsConstant.TURN_RIGHT,
      FaceActionsConstant.TILT_FACE_LEFT,
      FaceActionsConstant.TILT_FACE_RIGHT
    ];
    final List<FaceActionsConstant> listActionsRes = [
      FaceActionsConstant.LOOK_STRAIGHT,
    ];

    for(int i=1;i<=countAction;i++){
      var element = _listActions[_random.nextInt(_listActions.length)];
      listActionsRes.add(element);
      for(int j=0;j<_listActions.length;j++){
        if(element.name == _listActions[j].name){
          _listActions.removeAt(j);
        }
      }
    }
    return listActionsRes;
  }

}