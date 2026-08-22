export 'web_downloader_stub.dart'
    if (dart.library.html) 'web_downloader_web.dart'
    if (dart.library.io) 'web_downloader_mobile.dart';
