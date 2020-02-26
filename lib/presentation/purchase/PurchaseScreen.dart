import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/model/PaidPlan.dart';
import 'package:instantonnection/domain/model/PurchaseItem.dart';
import 'package:instantonnection/domain/model/User.dart';
import 'package:instantonnection/domain/model/util/EnumUtil.dart';
import 'package:instantonnection/domain/usecase/PurchaseUseCase.dart';
import 'package:instantonnection/domain/usecase/UpdateUserProfileUseCase.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/ExceptionUtil.dart';
import 'package:instantonnection/presentation/common/LinkTextSpan.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';

class PurchaseScreen extends StatefulWidget implements Screen {
  final User user;

  final PurchaseUseCase purchaseUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  final AppNavigator appNavigator;

  /// サブスクリプションページかどうか。
  /// サブスクリプションページならtrue
  /// 非消耗品(広告削除プラン)ページならfalse
  final bool isForSubscription;

  const PurchaseScreen({
    Key key,
    this.user,
    this.isForSubscription,
    this.purchaseUseCase,
    this.updateUserProfileUseCase,
    this.appNavigator,
  }) : super(key: key);

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();

  @override
  String get name => "/purchase";
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  List<ListItem> _items = [];

  User _updatedUser;

  @override
  void initState() {
    super.initState();
    _updatedUser = widget.user;
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      await widget.purchaseUseCase.init();

      List<PurchaseItem> items;
      if (widget.isForSubscription) {
        // ProductやSubscriptionを購入していたら、Productプランを表示しないようにしたいため、Subscriptionのみ取得する。
        items = await widget.purchaseUseCase.fetchSubscriptions();
      } else {
        items = await widget.purchaseUseCase.fetchProducts();
      }

      // mapで変換したあと、別のListItemのサブクラスをaddできないので、for文で実装している。
      for (int i = 0; i < items.length; i++) {
        this._items.add(PlanItem(PurchaseItemViewModel._(context, items[i])));
      }
      this._items..add(SubscriptionInformationItem());
      setState(() {});
    } catch (error) {
      ExceptionUtil.showErrorMessageIfNeeded(
          widget.appNavigator, context, error);
    }
  }

  Future<Null> _showConfirmThenBuy(
      BuildContext context, PurchaseItem item) async {
    // Androidの場合、定期購入を買っている状態で別の定期購入を買うと、二重課金されてしまう。
    // Androidの仕組みとしては、アップグレード・ダウングレードに対応したAPIはあるが
    // (https://developer.android.com/google/play/billing/billing_reference?hl=ja#upgrade-getBuyIntentToReplaceSkus)
    // Flutterプラグインは対応していなさそう。
    // そのため、すでに購入済みの場合は、注意を促すことで対応する。

    bool isOk = true;
    if (Platform.isAndroid && _updatedUser.paidPlan.paidType != PaidType.Free) {
      isOk = await widget.appNavigator.showDialogMessage(context,
          title: Strings.of(context).beCareful,
          message:
              "${EnumUtil.getValueString(_updatedUser.paidPlan.paidType)} ${Strings.of(context).changePaidPlan}",
          isOkOnly: false);
    }
    if (isOk) {
      this._buy(context, item);
    }
  }

  Future<Null> _buy(BuildContext context, PurchaseItem item) async {
    if (item.productId == AppConfig.of(context).freePlan) {
      PaidPlan paidPlan = PaidPlan();
      await widget.updateUserProfileUseCase.execute(_updatedUser);
      setState(() {
        _updatedUser.paidPlan = paidPlan;
      });
      return;
    }

    User user = _updatedUser;
    try {
      if (item.productId == AppConfig.of(context).productAdPlan) {
        user = await widget.purchaseUseCase.buyAdPlan(_updatedUser, item);
      } else if (item.productId == AppConfig.of(context).litePlan) {
        user = await widget.purchaseUseCase.buyLitePlan(_updatedUser, item);
      } else if (item.productId == AppConfig.of(context).proPlan) {
        user = await widget.purchaseUseCase.buyProPlan(_updatedUser, item);
      } else if (item.productId == AppConfig.of(context).unlimitedPlan) {
        user =
            await widget.purchaseUseCase.buyUnlimitedPlan(_updatedUser, item);
      } else {
        user = await widget.purchaseUseCase.buyAdPlan(_updatedUser, item);
      }
      if (user != null) {
        setState(() {
          _updatedUser = user;
        });
      }
    } catch (error) {
      ExceptionUtil.showErrorMessageIfNeeded(
          widget.appNavigator, context, error);
    }
  }

  Widget _purchaseTitleWidget(PurchaseItemViewModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      child: Text(
        item.title,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _purchasePriceWidget(PurchaseItemViewModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      child: Text(
        item.price,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _purchaseDescriptionWidget(PurchaseItemViewModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      child: Text(
        item.description,
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _purchaseButtonWidget(PurchaseItemViewModel item) {
    bool alreadyPurchased = _updatedUser.paidPlan.itemId == item.productId;
    return FlatButton(
      disabledColor: Colors.grey,
      color: Colors.orange,
      onPressed: alreadyPurchased
          ? null
          : () {
              this._showConfirmThenBuy(context, item.item);
            },
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 48.0,
              alignment: Alignment(-1.0, 0.0),
              child: Center(
                  child: Text(
                alreadyPurchased
                    ? Strings.of(context).purchased
                    : Strings.of(context).buyNow,
                style: TextStyle(color: Colors.white),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _purchaseItemWidget(PurchaseItemViewModel item) {
    return Container(
      child: Column(
        children: <Widget>[
          _purchaseTitleWidget(item),
          _purchasePriceWidget(item),
          _purchaseDescriptionWidget(item),
          _purchaseButtonWidget(item),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, _updatedUser);
        return Future.value(false);
      },
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppConfig.kTheme.primaryColor,
            title: Text(Strings.of(context).pricing),
          ),
          body: Container(
              margin: EdgeInsets.all(16.0),
              child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    ListItem item = _items[index];
                    if (item is PlanItem) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: _purchaseItemWidget(item.viewModel),
                      );
                    }
                    if (item is SubscriptionInformationItem) {
                      return item.create(context);
                    }
                  })),
        ),
      ),
    );
  }
}

class PurchaseItemViewModel {
  final BuildContext _context;
  final PurchaseItem item;

  PurchaseItemViewModel(this._context, this.item);

  factory PurchaseItemViewModel._(BuildContext context, PurchaseItem item) {
    return PurchaseItemViewModel(context, item);
  }

  String get productId => item.productId;

  // appleのApp内課金からタイトルやdescriptionを取得していたが、なぜかProductionのみTitleとDescriptionが取得できなくなっていた。（金額は取得できている）

  String get title {
    AppConfig appConfig = AppConfig.of(_context);
    if (item.productId == appConfig.litePlan) {
      return Strings.of(_context).litePlanTitle;
    } else if (item.productId == appConfig.proPlan) {
      return Strings.of(_context).proPlanTitle;
    } else if (item.productId == appConfig.unlimitedPlan) {
      return Strings.of(_context).unlimitedPlanTitle;
    } else {
      return "";
    }
  } // "${item.title}";

  String get price => "${item.localizedPrice}/${Strings.of(_context).month}";

//  String get description => "${item.description}";
  String get description {
    AppConfig appConfig = AppConfig.of(_context);
    if (item.productId == appConfig.litePlan) {
      return Strings.of(_context).litePlanDescription;
    } else if (item.productId == appConfig.proPlan) {
      return Strings.of(_context).proPlanDescription;
    } else if (item.productId == appConfig.unlimitedPlan) {
      return Strings.of(_context).unlimitedPlanDescription;
    } else {
      return "";
    }
  } // "${item.title}";
}

abstract class ListItem {}

class PlanItem implements ListItem {
  final PurchaseItemViewModel viewModel;

  PlanItem(this.viewModel);
}

class SubscriptionInformationItem implements ListItem {
  TextStyle textStyle = TextStyle(color: Colors.black54, fontSize: 11.0);

  Widget create(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 16.0, right: 8.0),
      child: Column(
        children: <Widget>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Strings.of(context).aboutSubscription,
                  style: TextStyle(color: Colors.black87, fontSize: 12.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Text(
                    Platform.isIOS
                        ? Strings.of(context).aboutSubscriptionDetailForIOS
                        : Strings.of(context).aboutSubscriptionDetailForAndroid,
                    style: textStyle,
                  ),
                ),
              ]),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 11.0),
              children: _createTermsAndPrivacyLink(context),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _createTermsAndPrivacyLink(BuildContext context) {
    return <TextSpan>[
      LinkTextSpan(
          text: Strings.of(context).terms,
          url: AppConfig.of(context).termsUrl,
          inAppWebView: true),
      TextSpan(text: " "),
      LinkTextSpan(
          text: Strings.of(context).privacy,
          url: AppConfig.of(context).privacyPolicyUrl,
          inAppWebView: true),
    ];
  }
}
