// ignore_for_file: cancel_subscriptions, prefer_const_constructors

// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:event_taxi/event_taxi.dart';

// Project imports:
import 'package:aewallet/appstate_container.dart';
import 'package:aewallet/bus/account_changed_event.dart';
import 'package:aewallet/bus/disable_lock_timeout_event.dart';
import 'package:aewallet/bus/notifications_event.dart';
import 'package:aewallet/localization.dart';
import 'package:aewallet/ui/menu/settings_drawer_wallet_mobile.dart';
import 'package:aewallet/ui/util/dimens.dart';
import 'package:aewallet/ui/util/responsive.dart';
import 'package:aewallet/ui/util/routes.dart';
import 'package:aewallet/ui/util/styles.dart';
import 'package:aewallet/ui/views/main/account_tab.dart';
import 'package:aewallet/ui/views/main/accounts_list_tab.dart';
import 'package:aewallet/ui/views/main/main_appbar.dart';
import 'package:aewallet/ui/views/main/main_bottombar.dart';
import 'package:aewallet/ui/views/main/nft_tab.dart';
import 'package:aewallet/ui/views/tokens_fungibles/add_token.dart';
import 'package:aewallet/ui/widgets/components/buttons.dart';
import 'package:aewallet/ui/widgets/components/sheet_util.dart';
import 'package:aewallet/ui/widgets/dialogs/network_dialog.dart';
import 'package:aewallet/util/notifications_util.dart';
import 'package:aewallet/util/preferences.dart';

class AppHomePageUniverse extends StatefulWidget {
  const AppHomePageUniverse({super.key});

  @override
  State<AppHomePageUniverse> createState() => _AppHomePageUniverseState();
}

class _AppHomePageUniverseState extends State<AppHomePageUniverse>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  AnimationController? _placeholderCardAnimationController;
  Animation<double>? _opacityAnimation;
  bool? _animationDisposed;

  bool _lockDisabled = false; // whether we should avoid locking the app

  bool? accountIsPressed;

  AnimationController? animationController;
  ColorTween? colorTween;
  CurvedAnimation? curvedAnimation;

  TabController? tabController;

  @override
  void initState() {
    super.initState();

    accountIsPressed = false;
    tabController = TabController(length: 2, vsync: this);

    _registerBus();
    WidgetsBinding.instance.addObserver(this);

    NotificationsUtil.init();
    listenNotifications();

    // Setup placeholder animation and start
    _animationDisposed = false;
    _placeholderCardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _placeholderCardAnimationController!
        .addListener(_animationControllerListener);
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _placeholderCardAnimationController!,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    _opacityAnimation!.addStatusListener(_animationStatusListener);
    _placeholderCardAnimationController!.forward();
  }

  listenNotifications() =>
      NotificationsUtil.onNotifications.stream.listen(onClickedNotification);

  void onClickedNotification(String? payload) {
    EventTaxiImpl.singleton().fire(NotificationsEvent(payload: payload));
  }

  void _animationStatusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        _placeholderCardAnimationController!.forward();
        break;
      case AnimationStatus.completed:
        _placeholderCardAnimationController!.reverse();
        break;
      default:
        break;
    }
  }

  void _animationControllerListener() {
    setState(() {});
  }

  void _startAnimation() {
    if (_animationDisposed!) {
      _animationDisposed = false;
      _placeholderCardAnimationController!
          .addListener(_animationControllerListener);
      _opacityAnimation!.addStatusListener(_animationStatusListener);
      _placeholderCardAnimationController!.forward();
    }
  }

  void _disposeAnimation() {
    if (!_animationDisposed!) {
      _animationDisposed = true;
      _opacityAnimation!.removeStatusListener(_animationStatusListener);
      _placeholderCardAnimationController!
          .removeListener(_animationControllerListener);
      _placeholderCardAnimationController!.stop();
    }
  }

  StreamSubscription<DisableLockTimeoutEvent>? _disableLockSub;
  StreamSubscription<AccountChangedEvent>? _switchAccountSub;
  StreamSubscription<NotificationsEvent>? _notificationsSub;

  void _registerBus() {
    // Hackish event to block auto-lock functionality
    _disableLockSub = EventTaxiImpl.singleton()
        .registerTo<DisableLockTimeoutEvent>()
        .listen((DisableLockTimeoutEvent event) {
      if (event.disable!) {
        cancelLockEvent();
      }
      _lockDisabled = event.disable!;
    });
    // User changed account
    _switchAccountSub = EventTaxiImpl.singleton()
        .registerTo<AccountChangedEvent>()
        .listen((AccountChangedEvent event) {
      setState(() {
        StateContainer.of(context).recentTransactionsLoading = true;

        _startAnimation();

        StateContainer.of(context).requestUpdate();
        _disposeAnimation();

        StateContainer.of(context).recentTransactionsLoading = false;
      });

      if (event.delayPop) {
        Future<void>.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
        });
      } else if (!event.noPop) {
        Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      }
    });

    _notificationsSub = EventTaxiImpl.singleton()
        .registerTo<NotificationsEvent>()
        .listen((NotificationsEvent event) async {
      StateContainer.of(context).recentTransactionsLoading = true;

      await StateContainer.of(context).requestUpdate();

      StateContainer.of(context).recentTransactionsLoading = false;
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
    });
  }

  @override
  void dispose() {
    _destroyBus();
    WidgetsBinding.instance.removeObserver(this);
    tabController!.dispose();
    _placeholderCardAnimationController!.dispose();
    super.dispose();
  }

  void _destroyBus() {
    if (_disableLockSub != null) {
      _disableLockSub!.cancel();
    }
    if (_switchAccountSub != null) {
      _switchAccountSub!.cancel();
    }
    if (_notificationsSub != null) {
      _notificationsSub!.cancel();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle websocket connection when app is in background
    // terminate it to be eco-friendly
    switch (state) {
      case AppLifecycleState.paused:
        setAppLockEvent();
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        cancelLockEvent();
        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  // To lock and unlock the app
  StreamSubscription<dynamic>? lockStreamListener;

  Future<void> setAppLockEvent() async {
    final Preferences preferences = await Preferences.getInstance();
    if ((preferences.getLock()) && !_lockDisabled) {
      if (lockStreamListener != null) {
        lockStreamListener!.cancel();
      }
      final Future<dynamic> delayed =
          Future<void>.delayed((preferences.getLockTimeout()).getDuration());
      delayed.then((_) {
        return true;
      });
      lockStreamListener = delayed.asStream().listen((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      });
    }
  }

  Future<void> cancelLockEvent() async {
    if (lockStreamListener != null) {
      lockStreamListener!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: MainAppBar(),
      bottomNavigationBar: MainBottomBar(),
      drawerEdgeDragWidth: 0,
      resizeToAvoidBottomInset: false,
      backgroundColor: StateContainer.of(context).curTheme.background,
      drawer: SizedBox(
        width: Responsive.drawerWidth(context),
        child: const Drawer(
          child: SettingsSheetWalletMobile(),
        ),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: StateContainer.of(context).bottomBarPageController,
        //children: const [AccountsListTab(), AccountTab(), NFTTab()],
        children: const [AccountsListTab(), AccountTab()],
        onPageChanged: (index) {
          setState(
              () => StateContainer.of(context).bottomBarCurrentPage = index);
        },
      ),
    );
  }

  Future<void> _networkDialog() async {
    StateContainer.of(context).curNetwork = (await NetworkDialog.getDialog(
        context, StateContainer.of(context).curNetwork))!;
    await StateContainer.of(context).requestUpdate();
    setState(() {});
  }
}

class ExpandablePageView extends StatefulWidget {
  final List<Widget>? children;

  const ExpandablePageView({
    super.key,
    @required this.children,
  });

  @override
  State<ExpandablePageView> createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView>
    with TickerProviderStateMixin {
  PageController? _pageController;
  List<double>? _heights;
  int _currentPage = 0;

  double get _currentHeight => _heights![_currentPage];

  @override
  void initState() {
    _heights = widget.children!.map((e) => 0.0).toList();
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        final newPage = _pageController!.page!.round();
        if (_currentPage != newPage) {
          setState(() => _currentPage = newPage);
        }
      });
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: 80,
          child: ContainedTabBarView(
            tabBarProperties: TabBarProperties(
                indicatorColor:
                    StateContainer.of(context).curTheme.backgroundDarkest),
            tabs: [
              Text(
                AppLocalization.of(context)!.recentTransactionsHeader,
                style: AppStyles.textStyleSize14W600EquinoxPrimary(context),
                textAlign: TextAlign.center,
              ),
              Text(
                AppLocalization.of(context)!.tokensHeader,
                style: AppStyles.textStyleSize14W600EquinoxPrimary(context),
                textAlign: TextAlign.center,
              ),
            ],
            // ignore: prefer_const_literals_to_create_immutables
            views: [
              const SizedBox(
                height: 0,
              ),
              const SizedBox(
                height: 0,
              )
            ],
            onChange: (index) {
              _pageController!.jumpToPage(index);
            },
          ),
        ),
        TweenAnimationBuilder<double>(
          curve: Curves.easeInOutCubic,
          duration: const Duration(milliseconds: 100),
          tween: Tween<double>(begin: _heights![0], end: _currentHeight),
          builder: (context, value, child) =>
              SizedBox(height: value, child: child),
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: _sizeReportingChildren
                .asMap() //
                .map((index, child) => MapEntry(index, child))
                .values
                .toList(),
          ),
        ),
        if (_currentPage == 1)
          Padding(
            padding:
                const EdgeInsets.only(top: 10.0, bottom: 10, left: 0, right: 0),
            child: Row(
              children: <Widget>[
                AppButton.buildAppButtonTiny(
                    const Key('createTokenFungible'),
                    context,
                    AppButtonType.primary,
                    AppLocalization.of(context)!.createFungibleToken,
                    Dimens.buttonBottomDimens, onPressed: () {
                  Sheets.showAppHeightNineSheet(
                      context: context,
                      widget: AddTokenSheet(
                        primaryCurrency:
                            StateContainer.of(context).curPrimaryCurrency,
                      ));
                }),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> get _sizeReportingChildren => widget.children!
      .asMap() //
      .map(
        (index, child) => MapEntry(
          index,
          OverflowBox(
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: SizeReportingWidget(
              onSizeChange: (size) =>
                  setState(() => _heights![index] = size.height),
              child: Align(child: child),
            ),
          ),
        ),
      )
      .values
      .toList();
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    key,
    required this.child,
    required this.onSizeChange,
  }) : super(key: key);

  @override
  State<SizeReportingWidget> createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  final _widgetKey = GlobalKey();
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(
          key: _widgetKey,
          child: widget.child,
        ),
      ),
    );
  }

  void _notifySize() {
    final context = _widgetKey.currentContext;
    if (context == null) return;
    final size = context.size;
    if (_oldSize != size) {
      _oldSize = size;
      widget.onSizeChange(size!);
    }
  }
}
