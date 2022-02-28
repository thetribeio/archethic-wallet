// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:aewallet/ui/views/sheets/chart_sheet.dart';
import 'package:core/appstate_container.dart';
import 'package:core/model/ae_apps.dart';
import 'package:core/ui/widgets/components/icon_widget.dart';
import 'package:core/ui/widgets/menu/abstract_menu_widget.dart';

class MenuWidgetMail extends AbstractMenuWidget {
  List<OptionChart> optionChartList = List<OptionChart>.empty(growable: true);

  @override
  Widget buildMainMenuIcons(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSecondMenuIcons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: InkWell(
              onTap: () {
                StateContainer.of(context).currentAEApp = AEApps.bin;
                Navigator.pop(context);
              },
              child: buildIconDataWidget(context, Icons.home, 20, 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildContextMenu(BuildContext context) {
    return const SizedBox();
  }
}
