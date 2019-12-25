import 'package:expange/colors.dart';
import 'package:expange/utils/materialbutton.dart';
import 'package:expange/utils/textstyle.dart';
import 'package:flutter/material.dart';

class Terms extends StatefulWidget {
  @override
  _Terms createState() => _Terms();
}

class _Terms extends State<Terms> {
  bool _termsCondChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: kSurfaceColor,
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              RichText(
                text: TextSpan(style: labelTextStyle(), children: <TextSpan>[
                  TextSpan(
                      text:
                          'TERMS AND CONDITION FOR FOR TICKET BOOKING AND HIRING RIDES\n\n',
                      style: smallBoldTextStyle()),
                  TextSpan(
                      text: 'CUSTOMER TERMS\n', style: smallBoldTextStyle()),
                  TextSpan(text: 'By clicking on ', style: labelTextStyle()),
                  TextSpan(
                      text: '"I ACCEPT BUTTON" ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'you acknowledge that you have read and understood the ',
                      style: labelTextStyle()),
                  TextSpan(
                      text: 'Customer Terms and Conditions ',
                      style: smallBoldTextStyle()),
                  TextSpan(text: 'of ', style: labelTextStyle()),
                  TextSpan(
                      text: 'Expange Tech Private limited.\n',
                      style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'Please ensure that you have read and understood all of these terms when you click Accept and Register. If you do not agree to the Terms and Conditions. Please do not use the service.\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text:
                          'Your acceptance will act as an agreement between you and EXPANGE TECH PVT LTD in respect of your use of the application.\n\n\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: 'COMPANY BACKGROUND\n',
                      style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'Company owns and operates the application and services. The application provides you an online platform to service for booking tickets, rides for passenger vehicle or Cabs and furthur assists you '
                          'in fare utilities and remittance. We however, do not provide any kind of associated leisures while travelling.\nThese customer terms apply to your access to and use of the application by online(Computer, mobile phone or any other electronic devices) and offline(Call and manually).\n\n\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: 'DEFINITION AND INTERPRETATION\n',
                      style: smallBoldTextStyle()),
                  TextSpan(text: '1. Account ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means the account created by you on the app for accessing the service.\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: '2. Additional Fees ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means any toll, duty, taxes, levied or any similar fees or charges that are not included in the fare but are payable by the customer.\n',
                      style: labelTextStyle()),
                  TextSpan(text: '3. Affiliate ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means in relation to the entity, another company or entity that either directly or indirectly, through any intermediaries is controlled by or is under control with that entity.\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: '4. Applicable laws ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means, the laws including including rules of common laws, principle of equity, status, regulation, rules that are statutory and mandatory code or guidelines according to Indian laws and subject to change from time to time.\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: '5. Application ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means such feature of EXPANGE TECH PVT LTD, mobile application or other program, software owned or licensed by company names.\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: '6. Area of Application ',
                      style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          "means the area in which the customer terms are accepted and abided under a region's jurisdiction.\n",
                      style: labelTextStyle()),
                  TextSpan(
                      text: '7. Booking Confirmation ',
                      style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means once the ticket or ride is confirmed, a notification will be sent to you via mail, Short Messading Service or Push Messages.\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: '8. Booking Service ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means such service provided by EXPANGE TECH PVT LTD which enables you to book rides using the application.\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: '9. Business Day ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means any day excluding Saturday, Sunday or Public holidays in the area of application.\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: '10. Cancellation Fees ',
                      style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means amount payable by you as a result of cancelling the ticket or ride and is notified to you on the application from time to time.\n',
                      style: labelTextStyle()),
                  TextSpan(text: '11. Driver ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means any person who will drive the cab/passenger vehicle and his/her credibility data is verified.\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: '12. Eligibility ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means any person above 18 years of age and booking tickets or rides.\n',
                      style: labelTextStyle()),
                  TextSpan(text: '13. Fare ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means charges per ticket/ride as per distance of travel.\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: '14. Privacy Policy ', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'means customer data protected within our system.\n',
                      style: labelTextStyle()),
                  TextSpan(text: '15. Vehicle ', style: smallBoldTextStyle()),
                  TextSpan(
                      text: 'means selected ride for travel.\n\n\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: 'REGISTRATION AND USAGE\n',
                      style: smallBoldTextStyle()),
                  TextSpan(
                      text: 'To use our services you must\n',
                      style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'a. Be competent to enter into contract under applicable laws and you must provide EXPANGE TECH PVT LTD with accurate, complete, current, valid and true details that are necessary.\n'
                          'b. Only open one account using your Registration data and not use the account of any other person.\n'
                          'c. Provide your own electronic device, which must be functioning mobile phone and ability to read text messages and push notification from the app and meet the minimum device requiring that EXPANGE TECH PVT LTD may specify from time to time. It is your responsibility to check to ensure that you download the correct version of application on your own device.\n'
                          'd. Only use the application solely in accordance with these customer terms and all applicable laws.\n'
                          'e. You are solely responsible to maintain the registration number and App login detail and will be liable for all activities and transaction and any other misuse of application that is accessed through your account (whether initiated by you or third party) except to the content caused or contributed by EXPANGE TECH PVT LTD.\n'
                          'f. If the Device is lost or stolen, you must notify EXPANGE TECH PVT LTD\n'
                          'g. If you cannot access your account, you must notify us and we will provide you details to access to your account. If your account has been compromised you must notify us to prevent unknown misconduct.\n'
                          'h. EXPANGE TECH PVT LTD has the right to terminate the service of your app anytime if it has reason to believe so fit.\nHowever, you may terminate these T&C at any time provided you are not using our services.\n\n\n',
                      style: labelTextStyle()),
                  TextSpan(text: 'PRIVACY \n', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'EXPANGE TECH PVT LTD will collect, store, process and transfer user data in compliance with the privacy policy. For providing services on real-time basis we need user’s permission in Android or IOS device to access their contacts, GPS, camera, Gallery etc. \n\n\n',
                      style: labelTextStyle()),
                  TextSpan(text: 'PAYMENT\n', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          '1. You will be charged and must pay entire fare including GST. Driver on behalf of the EXPANGE TECH PVT LTD collect the fare.\n'
                          '2. You will be required to share certain details of Debit card, Credit Card with payment processor in order for EXPANGE TECH PVT LTD to process payment of fare.\n\n\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: 'YOUR AUTHORIZATION \n',
                      style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          '1. Permits the payment processor to debit or credit the bank account or debit/credit account associated with your payment details.\n'
                          '2. Permits the payment processor to use your card to initiate the transaction.\n'
                          '3. Your payment information is protected by 128 bit encryption.\n'
                          '4. EXPANGE TECH PVT LTD will be solely responsible for settling any payment issue between you and Driver.\n'
                          '5. If any amount paid by you is fully or partially refundable for any reason such amount will be credited to your account.\n'
                          '6. Any payment processing related issue not caused by an error or fault with the application must be resolved by you and the relevant payment processor.\n\n\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: 'CANCELLATION FEE\n', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'You may cancel your ride after booking, provided you cancel within 5 min with no charges. In cancellation after 5 min, you will be charged 30% of the ticket.\n\n\n',
                      style: labelTextStyle()),
                  TextSpan(text: 'TAX\n', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'Total fare will include fare plus service tax as per government norms.\n\n\n',
                      style: labelTextStyle()),
                  TextSpan(text: 'BEHAVIOUR\n', style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'Improper behavior with our cab drivers, fellow passengers, smoking or drinking inside cab is not allowed and any breach of code of conducts will led to legal consequences upon you. For passenger vehicle services, user must follow the reporting and departure timing diligently.\n\n\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: 'INTELLECTUAL PROPERTY RIGHTS\n',
                      style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'Application is originally and wholly developed and owned by EXPANGE TECH PVT LTD and imitation of application or its feature may result in legal and financial consequences.\n\n\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: 'THIRD PARTY LIABILITY\n',
                      style: smallBoldTextStyle()),
                  TextSpan(
                      text:
                          'The database we use is sole property of Google and EXPANGE TECH PVT LTD will not be liable of any breach. Google services used within our application, viz. Google maps, Google cloud database, Google mobile framework etc are sole property of Google and we shall not be held responsible for any disruption of services or any possible consequences.\n\n\n\n',
                      style: labelTextStyle()),
                  TextSpan(
                      text: 'App Version v1.0.0\n', style: labelTextStyle()),
                  TextSpan(
                      text: 'Expange Tech Private Limited, Dibrugarh\n',
                      style: smallBoldTextStyle()),
                ]),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Checkbox(
                    activeColor: kGreenColor,
                    value: _termsCondChecked,
                    onChanged: (bool value) {
                      setState(() {
                        _termsCondChecked = value;
                      });
                    },
                  ),
                  Text(
                    'I Accept the terms and conditions',
                    style: labelTextStyle(),
                  ),
                ],
              ),
              MaterialedButton(Icons.arrow_forward, 'Continue', () {
                Navigator.of(context).pop();
              })
            ],
          )),
        ),
      ),
    );
  }
}
