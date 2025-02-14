/// SPDX-License-Identifier: AGPL-3.0-or-later

// Dart imports:
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_vibrate/flutter_vibrate.dart';

// Project imports:
import 'package:aewallet/appstate_container.dart';
import 'package:aewallet/model/data/nft_infos_off_chain.dart';
import 'package:aewallet/model/data/token_informations.dart';
import 'package:aewallet/ui/util/styles.dart';
import 'package:aewallet/util/get_it_instance.dart';
import 'package:aewallet/util/haptic_util.dart';
import 'package:aewallet/util/mime_util.dart';
import 'package:aewallet/util/token_util.dart';

class NFTCard extends StatelessWidget {
  const NFTCard({
    Key? key,
    required this.onTap,
    required this.tokenInformations,
  }) : super(key: key);

  final VoidCallback onTap;

  final TokenInformations tokenInformations;

  @override
  Widget build(BuildContext context) {
    String typeMime =
        TokenUtil.getPropertyValue(tokenInformations, 'type/mime');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  tokenInformations.name!,
                  style: AppStyles.textStyleSize12W400Primary(context),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 5,
            shadowColor: Colors.black,
            margin: const EdgeInsets.only(left: 8, right: 8),
            color: StateContainer.of(context).curTheme.backgroundDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: Colors.white10, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                if (MimeUtil.isImage(typeMime) == true ||
                    MimeUtil.isPdf(typeMime) == true)
                  FutureBuilder<Uint8List?>(
                      future: TokenUtil.getImageFromTokenAddress(
                          tokenInformations.address!, typeMime),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .text,
                                    border: Border.all(
                                      width: 1,
                                    ),
                                  ),
                                  child: Image.memory(
                                    snapshot.data!,
                                    height: 130,
                                    fit: BoxFit.fitHeight,
                                  )));
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      })
              ],
            ),
          ),
        ),
        NFTCardBottom(tokenInformations: tokenInformations),
      ],
    );
  }
}

class NFTCardBottom extends StatefulWidget {
  const NFTCardBottom({
    Key? key,
    required this.tokenInformations,
  }) : super(key: key);

  final TokenInformations tokenInformations;

  @override
  State<NFTCardBottom> createState() => _NFTCardBottomState();
}

class _NFTCardBottomState extends State<NFTCardBottom> {
  @override
  Widget build(BuildContext context) {
    NftInfosOffChain? nftInfosOffChain = StateContainer.of(context)
        .appWallet!
        .appKeychain!
        .getAccountSelected()!
        .getftInfosOffChain(widget.tokenInformations.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 5),
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /*InkWell(
                  onTap: (() async {
                    sl.get<HapticUtil>().feedback(FeedbackType.light,
                        StateContainer.of(context).activeVibrations);
                    await StateContainer.of(context)
                        .appWallet!
                        .appKeychain!
                        .getAccountSelected()!
                        .updateNftInfosOffChain(
                            tokenAddress: widget.tokenInformations.address,
                            favorite: false);
                  }),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),*/
                InkWell(
                  onTap: (() async {
                    sl.get<HapticUtil>().feedback(FeedbackType.light,
                        StateContainer.of(context).activeVibrations);

                    StateContainer.of(context)
                        .appWallet!
                        .appKeychain!
                        .getAccountSelected()!
                        .updateNftInfosOffChainFavorite(
                            widget.tokenInformations.id);
                    setState(() {});
                  }),
                  child: nftInfosOffChain == null ||
                          nftInfosOffChain.favorite == false
                      ? Icon(
                          Icons.favorite_border,
                          color: Colors.yellow[800],
                          size: 18,
                        )
                      : Icon(
                          Icons.favorite,
                          color: Colors.yellow[800],
                          size: 18,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
