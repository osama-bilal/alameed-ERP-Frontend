import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/general/general_bloc.dart';
import '/controllers/main.dart';
import '/l10n/app_localizations.dart';
import '/models/user.dart';
import '/utils/table_permissions.dart';
import '/widgets/container_head.dart';
import '/widgets/craete_button.dart';
import '/widgets/edits%20pages/user.dart';
import '/widgets/paginated_table.dart';
import '/widgets/permission_guard.dart';
import '/widgets/search_anchor.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<User> users = [];
  List<User> filteredUsers = [];
  late final MainController<User> controller;
  final Map<String, bool> permissions = {};
  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'user'));
    controller = MainController<User>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
      filteredUsers = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              permissions['add']!
                  ? CreateNewButton(
                      onPressed: () {
                        showEditUserDialog(
                          context,
                          User(username: "", isActive: true),
                        );
                      },
                    )
                  : Text(l10n.users),
              if (permissions['view']!)
                MySearchAnchor(
                  searchIn: users,
                  onSubmitted: (res) => setState(() => filteredUsers = res),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_user'],
          child: BlocBuilder<GeneralBloc<User>, GeneralState<User>>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<User>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<User>) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error)));
              } else if (state is ItemOperationSuccess<User>) {
                controller.fetchAll();
              } else if (state is ItemsLoadSuccess<User>) {
                users.clear();
                users.addAll(state.items);
              }
              if (filteredUsers.isEmpty) {
                filteredUsers = users;
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<User>(
                  excludeFields: ['user_permissions'],
                  filteredUsers,
                  (o) => o.toMap(),
                  editObject: permissions['change']!
                      ? (o) {
                          showEditUserDialog(context, o);
                        }
                      : null,
                  deleteObject: permissions['delete']!
                      ? (o) {
                          users.remove(o);
                          controller.deleteItem(o.id!);
                        }
                      : null,
                ),
                columnsName: User.columnsName,
              );
            },
          ),
        ),
      ],
    );
  }
}
