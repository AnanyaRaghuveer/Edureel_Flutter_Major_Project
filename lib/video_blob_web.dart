import 'dart:html' as html;

String createBlobUrl(List<int> bytes) {
  final blob = html.Blob([bytes], 'video/mp4');
  return html.Url.createObjectUrlFromBlob(blob);
}