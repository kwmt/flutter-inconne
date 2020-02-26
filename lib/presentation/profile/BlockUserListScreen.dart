import 'package:flutter/material.dart';
import 'package:instantonnection/application/AppConfig.dart';
import 'package:instantonnection/domain/model/BlockUser.dart';
import 'package:instantonnection/domain/model/Room.dart';
import 'package:instantonnection/l10n/strings.dart';
import 'package:instantonnection/presentation/common/BaseScreenState.dart';
import 'package:instantonnection/presentation/common/ExceptionUtil.dart';
import 'package:instantonnection/presentation/common/ImageUtils.dart';
import 'package:instantonnection/presentation/common/Screen.dart';
import 'package:instantonnection/presentation/common/navigator/AppNavigator.dart';
import 'package:instantonnection/presentation/profile/BlockUserListViewModel.dart';

class BlockUserListScreen extends StatefulWidget implements Screen {
  final AppNavigator appNavigator;
  final BlockUserListViewModel viewModel;

  BlockUserListScreen({this.appNavigator, this.viewModel});

  @override
  _BlockUserListScreenState createState() => _BlockUserListScreenState();

  @override
  String get name => "/profile/blockUsers";
}

class _BlockUserListScreenState extends BaseScreenState<BlockUserListScreen> {
  @override
  void initState() {
    super.initState();

    widget.viewModel.fetchUsers();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = StreamBuilder(
        stream: widget.viewModel.blockUser,
        builder: (BuildContext context, AsyncSnapshot<BlockUserList> snapshot) {
          if (snapshot.hasError) {
            ExceptionUtil.showErrorMessageIfNeeded(
                widget.appNavigator, context, snapshot.error);
            print(snapshot.error);
          }

          if (!snapshot.hasData || snapshot.data.blockUsers.length == 0) {
            return Center(child: Text(Strings.of(context).noUsersAreBlocking));
          }
          return ListView.builder(
            itemCount: snapshot.data.count,
            itemBuilder: (BuildContext context, int position) {
              return _buildBlockUserItem(
                  context, snapshot.data.blockUser(position));
            },
          );
        });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConfig.kTheme.primaryColor,
        title: Text(Strings.of(context).blockedUserTitle),
        elevation: 4.0,
      ),
      body: body,
    );
  }


  Container _buildBlockUserItem(BuildContext context, RoomUser blockUser) {
    final ThemeData themeData = Theme.of(context);
    return Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: themeData.dividerColor))),
        child: ListTile(
          leading: ImageUtils.circle(blockUser.photoUrl),
          title: Text(blockUser.name),
          trailing: RaisedButton(
            onPressed: () => _onTapRemoveBlockUserButton(blockUser, context),
            child: Text(Strings.of(context).unblockUser),
          ),
        ));
  }

  void _onTapRemoveBlockUserButton(
      RoomUser blockUser, BuildContext context)  {
    widget.viewModel.remove(blockUser);
  }
}
