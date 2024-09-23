import 'package:salesiq_mobilisten/siqtheme/siqmessagecommontheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqsuggestiontheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqskipactionbuttontheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqaudioplayertheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqselectioncomponenttheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqinputcardtheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqslidercardtheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqinfomessagetheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqarticlemessagetheme.dart';
import 'package:salesiq_mobilisten/siqtheme/siqfilemessagetheme.dart';

class SIQMessageTheme {
  // ignore_for_file: public_member_api_docs

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
  })  : common = common ?? SIQMessageCommonTheme(),
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
