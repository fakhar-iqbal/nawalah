import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  final String username = 'fakhareiqbal3534@gmail.com';
  final String password = 'jjlm oxho gpwt feka';

  Future<void> sendEmail(String toEmail, String subject, String body) async {
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Nawalah')
      ..recipients.add(toEmail)
      ..subject = subject
      ..text = body;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }
}
