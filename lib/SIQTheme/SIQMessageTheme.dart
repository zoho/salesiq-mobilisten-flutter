import 'package:salesiq_mobilisten/SIQTheme/SIQMessageCommonTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQSuggestionTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQSkipActionButtonTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQAudioPlayerTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQSelectionComponentTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQInputCardTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQSliderCardTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQInfoMessageTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQArticleMessageTheme.dart';
import 'package:salesiq_mobilisten/SIQTheme/SIQFileMessageTheme.dart';


class SIQMessageTheme {
  SIQMessageCommonTheme common;
  SIQSuggestionTheme suggestion;
  SIQSkipActionButtonTheme skipActionButton;
  SIQAudioPlayerTheme audioPlayer;
  SIQSelectionComponentTheme selection;
  SIQInputCardTheme inputCard;
  SIQSliderCardTheme slider;
  SIQInfoMessageTheme infoMessage;
  SIQArticleMessageTheme article;
  SIQFileMessageTheme file;

  SIQMessageTheme({
    SIQMessageCommonTheme? common,
    SIQSuggestionTheme? suggestion,
    SIQSkipActionButtonTheme? skipActionButton,
    SIQAudioPlayerTheme? audioPlayer,
    SIQSelectionComponentTheme? selection,
    SIQInputCardTheme? inputCard,
    SIQSliderCardTheme? slider,
    SIQInfoMessageTheme? infoMessage,
    SIQArticleMessageTheme? article,
    SIQFileMessageTheme? file,
  }):  common = common ?? SIQMessageCommonTheme(),
       suggestion = suggestion ?? SIQSuggestionTheme(),
       skipActionButton = skipActionButton ?? SIQSkipActionButtonTheme(),
       audioPlayer = audioPlayer ?? SIQAudioPlayerTheme(),
       selection = selection ?? SIQSelectionComponentTheme(),
       inputCard = inputCard ?? SIQInputCardTheme(),
       slider = slider ?? SIQSliderCardTheme(),
       infoMessage = infoMessage ?? SIQInfoMessageTheme(),
       article = article ?? SIQArticleMessageTheme(),
       file = file ?? SIQFileMessageTheme();

  Map<String, dynamic> toMap() {
    return {
      'Common': common.toMap(),
      'Suggestion': suggestion.toMap(),
      'SkipActionButton': skipActionButton.toMap(),
      'AudioPlayer': audioPlayer.toMap(),
      'Selection': selection.toMap(),
      'InputCard': inputCard.toMap(),
      'Slider': slider.toMap(),
      'InfoMessage': infoMessage.toMap(),
      'Article': article.toMap(),
      'File': file.toMap(),
    };
  }
}