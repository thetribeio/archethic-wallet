/// SPDX-License-Identifier: AGPL-3.0-or-later

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

// Project imports:
import 'package:aewallet/appstate_container.dart';
import 'package:aewallet/bus/authenticated_event.dart';
import 'package:aewallet/localization.dart';
import 'package:aewallet/model/authentication_method.dart';
import 'package:aewallet/model/data/account.dart';
import 'package:aewallet/model/data/app_wallet.dart';
import 'package:aewallet/model/data/appdb.dart';
import 'package:aewallet/model/data/price.dart';
import 'package:aewallet/ui/util/dimens.dart';
import 'package:aewallet/ui/util/styles.dart';
import 'package:aewallet/ui/util/ui_util.dart';
import 'package:aewallet/ui/views/intro/intro_configure_security.dart';
import 'package:aewallet/ui/widgets/components/buttons.dart';
import 'package:aewallet/ui/widgets/components/dialog.dart';
import 'package:aewallet/ui/widgets/components/picker_item.dart';
import 'package:aewallet/util/biometrics_util.dart';
import 'package:aewallet/util/get_it_instance.dart';
import 'package:aewallet/util/haptic_util.dart';
import 'package:aewallet/util/keychain_util.dart';
import 'package:aewallet/util/mnemonics.dart';
import 'package:aewallet/util/preferences.dart';
import 'package:aewallet/util/vault.dart';

class IntroImportSeedPage extends StatefulWidget {
  const IntroImportSeedPage({super.key});

  @override
  State<IntroImportSeedPage> createState() => _IntroImportSeedState();
}

class _IntroImportSeedState extends State<IntroImportSeedPage> {
  bool _mnemonicIsValid = false;
  String _mnemonicError = '';
  bool? isPressed;
  String language = 'en';
  List<String> phrase = List<String>.filled(24, '');

  StreamSubscription<AuthenticatedEvent>? _authSub;

  @override
  void initState() {
    isPressed = false;
    _registerBus();
    Preferences.getInstance()
        .then((Preferences preferences) => preferences.setLanguageSeed('en'));
    super.initState();
  }

  void _registerBus() {
    _authSub = EventTaxiImpl.singleton()
        .registerTo<AuthenticatedEvent>()
        .listen((AuthenticatedEvent event) async {
      await StateContainer.of(context).requestUpdate();

      StateContainer.of(context).checkTransactionInputs(
          AppLocalization.of(context)!.transactionInputNotification);
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (Route<dynamic> route) => false,
      );
    });
  }

  void _destroyBus() {
    if (_authSub != null) {
      _authSub!.cancel();
    }
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  StateContainer.of(context).curTheme.background2Small!),
              fit: BoxFit.fitHeight),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              StateContainer.of(context).curTheme.backgroundDark!,
              StateContainer.of(context).curTheme.background!
            ],
          ),
        ),
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
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsetsDirectional.only(
                                  start: smallScreen(context) ? 15 : 20),
                              height: 50,
                              width: 50,
                              child: BackButton(
                                key: const Key('back'),
                                color: StateContainer.of(context).curTheme.text,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  margin: const EdgeInsetsDirectional.only(
                                      start: 15),
                                  height: 50,
                                  width: 50,
                                  child: TextButton(
                                    onPressed: () async {
                                      sl.get<HapticUtil>().feedback(
                                          FeedbackType.light,
                                          StateContainer.of(context)
                                              .activeVibrations);

                                      Preferences preferences =
                                          await Preferences.getInstance();
                                      preferences.setLanguageSeed('en');
                                      setState(() {
                                        language = 'en';
                                      });
                                    },
                                    child: language == 'en'
                                        ? Image.asset(
                                            'assets/icons/languages/united-states.png')
                                        : Opacity(
                                            opacity: 0.3,
                                            child: Image.asset(
                                                'assets/icons/languages/united-states.png'),
                                          ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsetsDirectional.only(
                                      start: 15),
                                  height: 50,
                                  width: 50,
                                  child: TextButton(
                                    onPressed: () async {
                                      sl.get<HapticUtil>().feedback(
                                          FeedbackType.light,
                                          StateContainer.of(context)
                                              .activeVibrations);

                                      Preferences preferences =
                                          await Preferences.getInstance();
                                      preferences.setLanguageSeed('fr');
                                      setState(() {
                                        language = 'fr';
                                      });
                                    },
                                    child: language == 'fr'
                                        ? Image.asset(
                                            'assets/icons/languages/france.png')
                                        : Opacity(
                                            opacity: 0.3,
                                            child: Image.asset(
                                                'assets/icons/languages/france.png'),
                                          ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsetsDirectional.only(
                            start: smallScreen(context) ? 30 : 40,
                            end: smallScreen(context) ? 30 : 40,
                            top: 10,
                          ),
                          alignment: const AlignmentDirectional(-1, 0),
                          child: AutoSizeText(
                            AppLocalization.of(context)!.importSecretPhrase,
                            style:
                                AppStyles.textStyleSize28W700Primary(context),
                            maxLines: 1,
                            minFontSize: 12,
                            stepGranularity: 0.1,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: smallScreen(context) ? 30 : 40,
                              right: smallScreen(context) ? 30 : 40,
                              top: 15.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalization.of(context)!.importSecretPhraseHint,
                            style:
                                AppStyles.textStyleSize16W600Primary(context),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        if (_mnemonicError != '')
                          SizedBox(
                            height: 40,
                            child: Text(_mnemonicError,
                                style: AppStyles.textStyleSize14W200Primary(
                                    context)),
                          )
                        else
                          const SizedBox(
                            height: 40,
                          ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(height: 10),
                              GridView.count(
                                  physics: const NeverScrollableScrollPhysics(),
                                  childAspectRatio: 1.2,
                                  padding:
                                      const EdgeInsets.only(top: 0, bottom: 0),
                                  shrinkWrap: true,
                                  crossAxisCount: 4,
                                  children: List.generate(24, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Column(
                                        children: [
                                          Text((index + 1).toString(),
                                              style: AppStyles
                                                  .textStyleSize12W100Primary(
                                                      context)),
                                          Autocomplete<String>(
                                            optionsBuilder: (TextEditingValue
                                                textEditingValue) {
                                              if (textEditingValue.text == '') {
                                                return const Iterable<
                                                    String>.empty();
                                              }
                                              return AppMnemomics.getLanguage(
                                                      language)
                                                  .list
                                                  .where((String option) {
                                                return option.contains(unorm
                                                    .nfkd(textEditingValue.text
                                                        .toLowerCase()));
                                              });
                                            },
                                            onSelected: (String selection) {
                                              if (!AppMnemomics.isValidWord(
                                                  selection,
                                                  languageCode: language)) {
                                                setState(() {
                                                  _mnemonicIsValid = false;
                                                  _mnemonicError =
                                                      AppLocalization.of(
                                                              context)!
                                                          .mnemonicInvalidWord
                                                          .replaceAll(
                                                              '%1', selection);
                                                });
                                              } else {
                                                phrase[index] = selection;
                                                setState(() {
                                                  _mnemonicError = '';
                                                  _mnemonicIsValid = true;
                                                });
                                              }
                                              ;
                                            },
                                            fieldViewBuilder: ((context,
                                                textEditingController,
                                                focusNode,
                                                onFieldSubmitted) {
                                              return Stack(
                                                alignment:
                                                    AlignmentDirectional.center,
                                                children: <Widget>[
                                                  TextFormField(
                                                    controller:
                                                        textEditingController,
                                                    focusNode: focusNode,
                                                    style: AppStyles
                                                        .textStyleSize12W400Primary(
                                                            context),
                                                    autocorrect: false,
                                                    onChanged: (value) {
                                                      if (!AppMnemomics
                                                          .isValidWord(value,
                                                              languageCode:
                                                                  language)) {
                                                        setState(() {
                                                          _mnemonicIsValid =
                                                              false;
                                                          _mnemonicError =
                                                              AppLocalization.of(
                                                                      context)!
                                                                  .mnemonicInvalidWord
                                                                  .replaceAll(
                                                                      '%1',
                                                                      value);
                                                        });
                                                      } else {
                                                        phrase[index] = value;
                                                        setState(() {
                                                          _mnemonicError = '';
                                                          _mnemonicIsValid =
                                                              true;
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  Positioned(
                                                    bottom: 1,
                                                    child: Container(
                                                      height: 1,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            StateContainer.of(
                                                                    context)
                                                                .curTheme
                                                                .gradient!,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    );
                                  })),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    isPressed == true || phrase.contains('')
                        ? AppButton.buildAppButton(
                            const Key('ok'),
                            context,
                            AppButtonType.primaryOutline,
                            AppLocalization.of(context)!.ok,
                            Dimens.buttonTopDimens,
                            onPressed: () {},
                          )
                        : AppButton.buildAppButton(
                            const Key('ok'),
                            context,
                            AppButtonType.primary,
                            AppLocalization.of(context)!.ok,
                            Dimens.buttonTopDimens,
                            onPressed: () async {
                              _showSendingAnimation(context);
                              setState(() {
                                _mnemonicError = '';
                                isPressed = true;
                              });

                              _mnemonicIsValid = true;
                              for (var word in phrase) {
                                if (word.trim() == '') {
                                  _mnemonicIsValid = false;
                                  _mnemonicError = AppLocalization.of(context)!
                                      .mnemonicSizeError;
                                } else {
                                  if (AppMnemomics.isValidWord(word,
                                          languageCode: language) ==
                                      false) {
                                    _mnemonicIsValid = false;
                                    _mnemonicError =
                                        AppLocalization.of(context)!
                                            .mnemonicInvalidWord
                                            .replaceAll('%1', word);
                                  }
                                }
                              }
                              if (_mnemonicIsValid == true) {
                                await sl.get<DBHelper>().clearAppWallet();
                                StateContainer.of(context).appWallet = null;
                                String seed = AppMnemomics.mnemonicListToSeed(
                                    phrase,
                                    languageCode: language);
                                final Vault vault = await Vault.getInstance();
                                vault.setSeed(seed);
                                Price tokenPrice = await Price.getCurrency(
                                    StateContainer.of(context)
                                        .curCurrency
                                        .currency
                                        .name);

                                try {
                                  AppWallet? appWallet = await KeychainUtil()
                                      .getListAccountsFromKeychain(
                                          StateContainer.of(context).appWallet,
                                          seed,
                                          StateContainer.of(context)
                                              .curCurrency
                                              .currency
                                              .name,
                                          StateContainer.of(context)
                                              .curNetwork
                                              .getNetworkCryptoCurrencyLabel(),
                                          tokenPrice,
                                          loadBalance: true,
                                          loadRecentTransactions: true);

                                  StateContainer.of(context).appWallet =
                                      appWallet;
                                  List<Account>? accounts =
                                      appWallet!.appKeychain!.accounts;

                                  if (accounts == null ||
                                      accounts.length == 0) {
                                    setState(() {
                                      _mnemonicIsValid = false;
                                    });
                                    UIUtil.showSnackbar(
                                        AppLocalization.of(context)!.noKeychain,
                                        context,
                                        StateContainer.of(context)
                                            .curTheme
                                            .text!,
                                        StateContainer.of(context)
                                            .curTheme
                                            .snackBarShadow!);
                                    Navigator.of(context).pop();
                                  } else {
                                    accounts.sort(
                                        (a, b) => a.name!.compareTo(b.name!));
                                    await _accountsDialog(accounts);
                                    await _launchSecurityConfiguration(
                                        StateContainer.of(context)
                                            .appWallet!
                                            .appKeychain!
                                            .getAccountSelected()!
                                            .name!,
                                        seed);
                                  }
                                } catch (e) {
                                  setState(() {
                                    _mnemonicIsValid = false;
                                  });
                                  UIUtil.showSnackbar(
                                      AppLocalization.of(context)!.noKeychain,
                                      context,
                                      StateContainer.of(context).curTheme.text!,
                                      StateContainer.of(context)
                                          .curTheme
                                          .snackBarShadow!);
                                  Navigator.of(context).pop();
                                }
                              }

                              setState(() {
                                isPressed = false;
                              });
                            },
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _launchSecurityConfiguration(String name, String seed) async {
    bool biometricsAvalaible = await sl.get<BiometricUtil>().hasBiometrics();
    List<PickerItem> accessModes = [];
    accessModes.add(PickerItem(
        AuthenticationMethod(AuthMethod.pin).getDisplayName(context),
        AuthenticationMethod(AuthMethod.pin).getDescription(context),
        AuthenticationMethod.getIcon(AuthMethod.pin),
        StateContainer.of(context).curTheme.pickerItemIconEnabled,
        AuthMethod.pin,
        true));
    accessModes.add(PickerItem(
        AuthenticationMethod(AuthMethod.password).getDisplayName(context),
        AuthenticationMethod(AuthMethod.password).getDescription(context),
        AuthenticationMethod.getIcon(AuthMethod.password),
        StateContainer.of(context).curTheme.pickerItemIconEnabled,
        AuthMethod.password,
        true));
    if (biometricsAvalaible) {
      accessModes.add(PickerItem(
          AuthenticationMethod(AuthMethod.biometrics).getDisplayName(context),
          AuthenticationMethod(AuthMethod.biometrics).getDescription(context),
          AuthenticationMethod.getIcon(AuthMethod.biometrics),
          StateContainer.of(context).curTheme.pickerItemIconEnabled,
          AuthMethod.biometrics,
          true));
    }
    accessModes.add(PickerItem(
        AuthenticationMethod(AuthMethod.biometricsUniris)
            .getDisplayName(context),
        AuthenticationMethod(AuthMethod.biometricsUniris)
            .getDescription(context),
        AuthenticationMethod.getIcon(AuthMethod.biometricsUniris),
        StateContainer.of(context).curTheme.pickerItemIconEnabled,
        AuthMethod.biometricsUniris,
        false));
    accessModes.add(PickerItem(
        AuthenticationMethod(AuthMethod.yubikeyWithYubicloud)
            .getDisplayName(context),
        AuthenticationMethod(AuthMethod.yubikeyWithYubicloud)
            .getDescription(context),
        AuthenticationMethod.getIcon(AuthMethod.yubikeyWithYubicloud),
        StateContainer.of(context).curTheme.pickerItemIconEnabled,
        AuthMethod.yubikeyWithYubicloud,
        true));

    bool securityConfiguration = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return IntroConfigureSecurity(
        accessModes: accessModes,
        name: name,
        seed: seed,
      );
    }));

    return securityConfiguration;
  }

  Future<void> _accountsDialog(List<Account> accounts) async {
    final List<PickerItem> pickerItemsList =
        List<PickerItem>.empty(growable: true);
    for (Account account in accounts) {
      pickerItemsList
          .add(PickerItem(account.name!, null, null, null, account, true));
    }

    final Account? selection = await showDialog<Account>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalization.of(context)!.keychainHeader,
                    style: AppStyles.textStyleSize24W700EquinoxPrimary(context),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  accounts.length > 1
                      ? Text(
                          AppLocalization.of(context)!.selectAccountDescSeveral,
                          style: AppStyles.textStyleSize12W100Primary(context),
                        )
                      : Text(
                          AppLocalization.of(context)!.selectAccountDescOne,
                          style: AppStyles.textStyleSize12W100Primary(context),
                        ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                side: BorderSide(
                    color: StateContainer.of(context).curTheme.text45!)),
            content: SingleChildScrollView(
              child: PickerWidget(
                pickerItems: pickerItemsList,
                selectedIndex: 0,
                onSelected: (value) {
                  Navigator.pop(context, value.value);
                },
              ),
            ),
          );
        });
    if (selection != null) {
      await StateContainer.of(context)
          .appWallet!
          .appKeychain!
          .setAccountSelected(selection);
    }
  }

  void _showSendingAnimation(BuildContext context) {
    Navigator.of(context).push(AnimationLoadingOverlay(
      AnimationType.send,
      StateContainer.of(context).curTheme.animationOverlayStrong!,
      StateContainer.of(context).curTheme.animationOverlayMedium!,
    ));
  }
}
