// Flutter imports:
import 'package:archethic_wallet/dimens.dart';
import 'package:archethic_wallet/ui/widgets/buttons.dart';
import 'package:archethic_wallet/util/caseconverter.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

// Project imports:
import 'package:archethic_wallet/appstate_container.dart';
import 'package:archethic_wallet/localization.dart';
import 'package:archethic_wallet/styles.dart';
import 'package:archethic_wallet/ui/util/ui_util.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveSheet extends StatefulWidget {
  ReceiveSheet() : super();

  _ReceiveSheetState createState() => _ReceiveSheetState();
}

class _ReceiveSheetState extends State<ReceiveSheet> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
      child: Column(
        children: <Widget>[
          // A row for the address text and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //Empty SizedBox
              SizedBox(
                width: 60,
                height: 0,
              ),
              Column(
                children: <Widget>[
                  // Sheet handle
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: 5,
                    width: MediaQuery.of(context).size.width * 0.15,
                    decoration: BoxDecoration(
                      color: StateContainer.of(context).curTheme.primary10,
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 15.0),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width - 140),
                    child: Column(
                      children: <Widget>[
                        // Header
                        AutoSizeText(
                          AppLocalization.of(context)!.receive,
                          style: AppStyles.textStyleSize24W700Primary(context),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          stepGranularity: 0.1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //Empty SizedBox
              SizedBox(
                width: 60,
                height: 0,
              ),
            ],
          ),

          Expanded(
            child: Container(
                margin: const EdgeInsets.only(top: 0, bottom: 10),
                child: SafeArea(
                  minimum: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.035,
                  ),
                  child: Column(
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text:
                                  StateContainer.of(context).wallet!.address));
                          UIUtil.showSnackbar('Address copied', context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Material(
                            color: StateContainer.of(context)
                                .curTheme
                                .backgroundDarkest,
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 200,
                                        margin: const EdgeInsets.all(8),
                                        child: AutoSizeText(
                                          AppLocalization.of(context)!
                                              .addressInfos,
                                          style: AppStyles
                                              .textStyleSize16W700Primary(
                                                  context),
                                        ),
                                      ),
                                      Container(
                                        width: 150,
                                        height: 150,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .backgroundDarkest,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: QrImage(
                                          foregroundColor: Colors.white,
                                          data: StateContainer.of(context)
                                              .selectedAccount
                                              .lastAddress!,
                                          version: QrVersions.auto,
                                          size: 150.0,
                                          gapless: false,
                                        ),
                                      ),
                                      Container(
                                        width: 200,
                                        alignment: Alignment.center,
                                        margin: const EdgeInsets.all(8),
                                        child: Column(
                                          children: <Widget>[
                                            AutoSizeText(
                                                CaseChange.toUpperCase(
                                                    StateContainer.of(context)
                                                        .selectedAccount
                                                        .lastAddress!
                                                        .substring(0, 16),
                                                    context),
                                                style: AppStyles
                                                    .textStyleSize12W100Primary(
                                                        context)),
                                            AutoSizeText(
                                                CaseChange.toUpperCase(
                                                    StateContainer.of(context)
                                                        .selectedAccount
                                                        .lastAddress!
                                                        .substring(16, 32),
                                                    context),
                                                style: AppStyles
                                                    .textStyleSize12W100Primary(
                                                        context)),
                                            AutoSizeText(
                                                CaseChange.toUpperCase(
                                                    StateContainer.of(context)
                                                        .selectedAccount
                                                        .lastAddress!
                                                        .substring(32, 48),
                                                    context),
                                                style: AppStyles
                                                    .textStyleSize12W100Primary(
                                                        context)),
                                            AutoSizeText(
                                                CaseChange.toUpperCase(
                                                    StateContainer.of(context)
                                                        .selectedAccount
                                                        .lastAddress!
                                                        .substring(48),
                                                    context),
                                                style: AppStyles
                                                    .textStyleSize12W100Primary(
                                                        context)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
          Container(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        AppLocalization.of(context)!.copy,
                        Dimens.BUTTON_TOP_DIMENS,
                        icon: Icon(Icons.copy), onPressed: () async {
                      Clipboard.setData(ClipboardData(
                          text: StateContainer.of(context).wallet!.address));
                      UIUtil.showSnackbar('Address copied', context);
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        AppLocalization.of(context)!.share,
                        Dimens.BUTTON_BOTTOM_DIMENS,
                        icon: Icon(Icons.share), onPressed: () {
                      final box = context.findRenderObject() as RenderBox?;
                      Share.share(
                          '${StateContainer.of(context).selectedAccount.lastAddress!} ',
                          sharePositionOrigin:
                              box!.localToGlobal(Offset.zero) & box.size);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
