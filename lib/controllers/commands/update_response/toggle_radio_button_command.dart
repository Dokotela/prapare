import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prapare/_internal/utils/utils.dart';
import 'package:prapare/controllers/commands/abstract_command.dart';
import 'package:prapare/models/fhir_questionnaire/survey/export.dart';

class ToggleRadioButtonCommand extends AbstractCommand {
  @override
  Future<void> execute({
    @required Rx<UserResponse> userResponse,
    @required Question question,
    @required Answer answer,
    @required String newResponse,
  }) async {
    final answerResponseList = userResponse.value.answers;

    // if toggled to off state
    if (newResponse == null) {
      responsesController.clearAllUserResponses(userResponse);
    } else {
      // decide if this will have an optional 'other' write-in option
      // First, handle ItemType.choice
      final AnswerResponse newAnswer = AnswerResponseUtil()
          .newAnswerResponseFromAnswerAndValue(
              answer: answer, newValue: newResponse);

      if (answerResponseList.isEmpty) {
        // create new response if one doesn't exist
        answerResponseList.add(newAnswer);
      } else {
        if (answerResponseList is AnswerCode ||
            answerResponseList is AnswerOther) {
          // otherwise, replace first available value with this new code
          // todo
          final AnswerResponse oldAnswer = answerResponseList.firstWhere(
              (element) => element is AnswerCode || element is AnswerOther);
          answerResponseList.remove(oldAnswer);
          answerResponseList.add(newAnswer);
        }
      }

      /// finally, collapse the 'completed survey'
      /// SubQuestions don't implement this feature
      if (validationController.isQuestionAtRoot(question) &&
          // enableWhen options also don't implement this feature
          !validationController.isAnswerAnEnableWhenOption(question, answer)) {
        validationController
            .getQuestionValidatorByUserResponse(userResponse)
            .isExpanded
            .value = false;
      }
    }

    // set enableWhen trigger, if applicable
    if (validationController.isAnswerAnEnableWhenOption(question, answer)) {
      final _bool = validationController.getEnableWhenBool(question, answer);
      if (_bool != null) {
        _bool.value = newResponse != null;
      }
    }

    // answering questions resets the 'decline to response' toggle
    validationController.setQuestionDeclined(
        userResponse.value.questionLinkId, false);

    // check validator to see if survey is complete
    validationController.validateIfQuestionAndGroupAreCompleted(userResponse);
  }
}
