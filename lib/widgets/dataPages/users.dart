import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/core/main.dart';
import 'package:ponit_of_sales/models/user.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/permission_guard.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';

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
  late final MainController<User> controller;
  @override
  void initState() {
    controller = MainController<User>(
      context: context,
      service: AppService.usersService,
    );
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fethAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        MyContainer(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PermissionGuard(
                requiredPermissions: ['add_user'],
                child: CreateNewButton(onPressed: () {}),
              ),
              PermissionGuard(
                requiredPermissions: ['view_user'],
                child: MySearchAnchor<User>(searchIn: users),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        PermissionGuard(
          requiredPermissions: ['view_user'],
          fallback: Center(
            child: Text("You haven't requierd permission to view this table"),
          ),
          child: BlocBuilder<GeneralBloc<User>, GeneralState>(
            builder: (context, state) {
              if (state is GeneralLoadInProgress<User>) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ItemLoadFailure<User>) {
                return Center(child: Text(state.error));
              } else if (state is ItemsLoadSuccess<User>) {
                users.clear();
                users.addAll(state.items);
              }
              return MyPaginatedDataTable(
                datasource: MyDataSource<User>(
                  users,
                  (o) => o.toMap(),
                  editObject: (o) {
                    // TODO: Here handle edit action
                  },
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
