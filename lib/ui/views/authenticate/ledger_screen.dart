/// SPDX-License-Identifier: AGPL-3.0-or-later

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:archethic_lib_dart/archethic_lib_dart.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:convert/convert.dart';
import 'package:ledger_dart_lib/ledger_dart_lib.dart';

// Project imports:
import 'package:aewallet/appstate_container.dart';
import 'package:aewallet/ui/util/styles.dart';
import 'package:aewallet/ui/widgets/components/icon_widget.dart';
import 'package:aewallet/util/get_it_instance.dart';
import 'package:aewallet/util/ledger/archethic_ledger_util.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen(this.ucoTransferList, {super.key});

  final List<UCOTransfer>? ucoTransferList;

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  String response = '';
  String labelResponse = '';
  String info = '';
  String method = '';
  String originPubKey = '';

  void update() async {
    switch (method) {
      case 'getPubKey':
        String responseHex =
            hex.encode(sl.get<LedgerNanoSImpl>().response).toUpperCase();
        originPubKey = responseHex.substring(4, responseHex.length - 4);
        method = 'signTxn';
        break;
      case 'signTxn':
        print(hex.encode(sl.get<LedgerNanoSImpl>().response).toUpperCase());
        break;
      default:
    }

    setState(() {});
  }

  @override
  void initState() {
    method = 'getPubKey';

    super.initState();
    if (kIsWeb) {
      sl<LedgerNanoSImpl>().addListener(update);
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (kIsWeb) {
      sl<LedgerNanoSImpl>().removeListener(update);
      sl.get<LedgerNanoSImpl>().disconnectLedger();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  StateContainer.of(context).curTheme.backgroundDark!,
                  StateContainer.of(context).curTheme.background!
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) =>
                SafeArea(
              minimum: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.035,
                top: MediaQuery.of(context).size.height * 0.10,
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          IconWidget.build(
                              context, 'assets/icons/key-ring.png', 90, 90),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            child: AutoSizeText(
                              'Ledger',
                              style:
                                  AppStyles.textStyleSize16W400Primary(context),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              stepGranularity: 0.1,
                            ),
                          ),
                          kIsWeb
                              ? method == 'getPubKey'
                                  ? ElevatedButton(
                                      child: Text('Ledger - Get Public Key',
                                          style: AppStyles
                                              .textStyleSize16W200Primary(
                                                  context)),
                                      onPressed: () async {
                                        method = 'getPubKey';
                                        await sl
                                            .get<LedgerNanoSImpl>()
                                            .connectLedger(getPubKeyAPDU());
                                      })
                                  : method == 'signTxn'
                                      ? ElevatedButton(
                                          child: Text(
                                              'Ledger - Verify transaction',
                                              style: AppStyles
                                                  .textStyleSize16W200Primary(
                                                      context)),
                                          onPressed: () async {
                                            String addressIndex = '';
                                            // TODO: A Revoir
                                            /*String addressIndex =
                                                StateContainer.of(context)
                                                    .selectedAccount
                                                    .index!
                                                    .toRadixString(16)
                                                    .padLeft(8, '0');*/
                                            final Transaction transaction =
                                                Transaction(
                                                    type: 'transfer',
                                                    data:
                                                        Transaction.initData());
                                            for (UCOTransfer transfer
                                                in widget.ucoTransferList!) {
                                              transaction.addUCOTransfer(
                                                  transfer.to,
                                                  transfer.amount!);
                                            }
                                            final Transaction lastTransaction =
                                                await sl
                                                    .get<ApiService>()
                                                    .getLastTransaction(
                                                        StateContainer.of(
                                                                context)
                                                            .appWallet!
                                                            .appKeychain!
                                                            .getAccountSelected()!
                                                            .lastAddress!,
                                                        request: 'chainLength');
                                            final String? transactionChainSeed =
                                                await StateContainer.of(context)
                                                    .getSeed();
                                            final String originPrivateKey = sl
                                                .get<ApiService>()
                                                .getOriginKey();
                                            transaction
                                                .build(
                                                    transactionChainSeed!,
                                                    lastTransaction
                                                        .chainLength!)
                                                .originSign(originPrivateKey);
                                            OnChainWalletData
                                                onChainWalletData =
                                                walletEncoder(originPubKey);

                                            const hashType = 0;
                                            final signTxn = getSignTxnAPDU(
                                                onChainWalletData,
                                                transaction,
                                                hashType,
                                                int.tryParse(addressIndex)!);
                                            print(
                                                'signTxn:${uint8ListToHex(signTxn)}');
                                            await sl
                                                .get<LedgerNanoSImpl>()
                                                .connectLedger(signTxn);
                                          })
                                      : const SizedBox()
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
