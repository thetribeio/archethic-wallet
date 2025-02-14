/// SPDX-License-Identifier: AGPL-3.0-or-later

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:aewallet/localization.dart';
import 'package:aewallet/model/setting_item.dart';

enum AuthMethod {
  pin,
  biometrics,
  biometricsUniris,
  yubikeyWithYubicloud,
  ledger,
  password
}

/// Represent the available authentication methods our app supports
class AuthenticationMethod extends SettingSelectionItem {
  AuthenticationMethod(this.method);

  AuthMethod method;

  @override
  String getDisplayName(BuildContext context) {
    switch (method) {
      case AuthMethod.biometrics:
        return AppLocalization.of(context)!.biometricsMethod;
      case AuthMethod.biometricsUniris:
        return AppLocalization.of(context)!.biometricsUnirisMethod;
      case AuthMethod.pin:
        return AppLocalization.of(context)!.pinMethod;
      case AuthMethod.yubikeyWithYubicloud:
        return AppLocalization.of(context)!.yubikeyWithYubiCloudMethod;
      case AuthMethod.ledger:
        return AppLocalization.of(context)!.ledgerMethod;
      case AuthMethod.password:
        return AppLocalization.of(context)!.passwordMethod;
      default:
        return AppLocalization.of(context)!.pinMethod;
    }
  }

  String getDescription(BuildContext context) {
    switch (method) {
      case AuthMethod.biometrics:
        return AppLocalization.of(context)!
            .configureSecurityExplanationBiometrics;
      case AuthMethod.biometricsUniris:
        return AppLocalization.of(context)!
            .configureSecurityExplanationUnirisBiometrics;
      case AuthMethod.pin:
        return AppLocalization.of(context)!.configureSecurityExplanationPIN;
      case AuthMethod.yubikeyWithYubicloud:
        return AppLocalization.of(context)!.configureSecurityExplanationYubikey;
      case AuthMethod.ledger:
        return '';
      case AuthMethod.password:
        return AppLocalization.of(context)!
            .configureSecurityExplanationPassword;
      default:
        return AppLocalization.of(context)!.configureSecurityExplanationPIN;
    }
  }

  static String getIcon(AuthMethod method) {
    switch (method) {
      case AuthMethod.biometrics:
        return 'assets/icons/biometrics.png';
      case AuthMethod.biometricsUniris:
        return 'assets/icons/biometrics-uniris.png';
      case AuthMethod.pin:
        return 'assets/icons/pin-code.png';
      case AuthMethod.yubikeyWithYubicloud:
        return 'assets/icons/digital-key.png';
      case AuthMethod.password:
        return 'assets/icons/password.png';
      default:
        return 'assets/icons/password.png';
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return method.index;
  }
}
