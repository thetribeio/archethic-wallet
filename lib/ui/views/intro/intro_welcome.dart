// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_svg/svg.dart';

// Project imports:
import 'package:archethic_wallet/appstate_container.dart';
import 'package:archethic_wallet/ui/util/dimens.dart';
import 'package:archethic_wallet/localization.dart';
import 'package:archethic_wallet/util/service_locator.dart';
import 'package:archethic_wallet/ui/util/styles.dart';
import 'package:archethic_wallet/ui/widgets/components/buttons.dart';
import 'package:archethic_wallet/util/app_util.dart';
import 'package:archethic_wallet/util/seeds.dart';
import 'package:archethic_wallet/util/vault.dart';

class IntroWelcomePage extends StatefulWidget {
  @override
  _IntroWelcomePageState createState() => _IntroWelcomePageState();
}

class _IntroWelcomePageState extends State<IntroWelcomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
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
            child: StateContainer.of(context)
                .curTheme
                .getBackgroundScreen(context)!,
          ),
          Container(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) =>
                  SafeArea(
                minimum: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.035,
                    top: MediaQuery.of(context).size.height * 0.075),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    top: 30.0,
                                  ),
                                  child: SizedBox(
                                    height: 200,
                                    child: kIsWeb
                                        ? Image.asset(
                                            StateContainer.of(context)
                                                    .curTheme
                                                    .assetsFolder! +
                                                StateContainer.of(context)
                                                    .curTheme
                                                    .logo! +
                                                '.png',
                                            height: 200,
                                          )
                                        : SvgPicture.asset(
                                            StateContainer.of(context)
                                                    .curTheme
                                                    .assetsFolder! +
                                                StateContainer.of(context)
                                                    .curTheme
                                                    .logo! +
                                                '.svg',
                                            height: 200,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 20, right: 20, left: 20),
                              child: Text(
                                AppLocalization.of(context)!.welcomeText,
                                style: AppStyles.textStyleSize14W600Primary(
                                    context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            AppButton.buildAppButton(
                                context,
                                AppButtonType.PRIMARY,
                                AppLocalization.of(context)!.newWallet,
                                Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                              Vault.getInstance().then((Vault _vault) {
                                final String _seed = AppSeeds.generateSeed();
                                _vault.setSeed(_seed);
                                AppUtil()
                                    .loginAccount(_seed, context,
                                        forceNewAccount: true)
                                    .then((_) {
                                  Navigator.of(context).pushNamed(
                                    '/intro_backup_safety',
                                  );
                                });
                              });
                            }),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            // Import Wallet Button
                            AppButton.buildAppButton(
                                context,
                                AppButtonType.PRIMARY,
                                AppLocalization.of(context)!.importWallet,
                                Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                              Navigator.of(context).pushNamed('/intro_import');
                            }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
