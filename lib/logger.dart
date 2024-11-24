import 'package:flutter_logs/flutter_logs.dart';

Future<void> initLogger() async {
     //Initialize Logging
     await FlutterLogs.initLogs(
     logLevelsEnabled: [
       LogLevel.INFO,
       LogLevel.WARNING,
       LogLevel.ERROR,
       LogLevel.SEVERE
     ],
     timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
     directoryStructure: DirectoryStructure.FOR_DATE,
     logTypesEnabled: ["device","network","errors"],
     logFileExtension: LogFileExtension.LOG,
     logsWriteDirectoryName: "logs",
     logsExportDirectoryName: "logs/exported",
     debugFileOperations: true,
     isDebuggable: true,
     logsRetentionPeriodInDays : 14,
     zipsRetentionPeriodInDays : 3,
     autoDeleteZipOnExport : false,
     autoClearLogs : true,
             enabled: true);
}

void logInfo(msg, {tag="MAIN", subtag="MAIN"}) {
  FlutterLogs.logInfo(tag, subtag, msg);
}

void logWarn(msg, {tag="MAIN", subtag="MAIN"}) {
  FlutterLogs.logWarn(tag, subtag, msg);
}

void logErr(msg, {tag="MAIN", subtag="MAIN"}) {
  FlutterLogs.logError(tag, subtag, msg);
}
