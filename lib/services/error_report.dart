import 'package:url_launcher/url_launcher.dart';

const _formUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSfWCee4FoaiflKNBUBrpg3GWOgOkObRyXdneK59byflraYt1w/viewform';

/// Opens the content-error report form in an external browser, with
/// [contextLabel] (e.g. "health_02 — بعد الاستيقاظ من نوم مزعج") pre-filled
/// into the form's "which item" field so the reviewer doesn't have to guess.
Future<void> reportContentError(String contextLabel) {
  final uri = Uri.parse(_formUrl).replace(queryParameters: {
    'usp': 'pp_url',
    'entry.615847691': contextLabel,
  });
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
