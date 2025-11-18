import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/provider/parties.dart';
import 'package:ponit_of_sales/models/groups.dart';
import 'package:ponit_of_sales/models/party.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
// import 'package:ponit_of_sales/widgets/data_table.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  @override
  void initState() {
    super.initState();
    context.read<GeneralBloc<Groups>>().add(LoadItems());
    context.read<AppParties>().fetchPermissions();
    context.read<AppParties>().fetchCT();
  }

  void _showEditGroupDialog(BuildContext context, Groups group) {
    final nameController = TextEditingController(text: group.name);
    final selectedPermissions = group.permissions.toSet();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final appParties = context.watch<AppParties>();
            final allPermissions = appParties.permissions;
            final contentTypes = appParties.contentTypes;

            // Group permissions by content type
            final Map<String, List<ViewParty<Permissions>>> groupedPermissions =
                {};
            for (var p in allPermissions) {
              final parts = p.name.split(' | ');
              if (parts.length >= 2) {
                final modelName = parts[1];
                if (!groupedPermissions.containsKey(modelName)) {
                  groupedPermissions[modelName] = [];
                }
                groupedPermissions[modelName]!.add(p);
              }
            }

            return AlertDialog(
              title: Text(group.id == 0 ? 'Create Group' : 'Edit Group'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Permissions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      if (allPermissions.isEmpty || contentTypes.isEmpty)
                        const Center(child: CircularProgressIndicator())
                      else
                        ...groupedPermissions.entries.map((entry) {
                          final modelName = entry.key;
                          final permissions = entry.value;
                          return ExpansionTile(
                            title: Text(
                              modelName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            children: permissions.map((p) {
                              final isSelected = selectedPermissions.contains(
                                p.id,
                              );
                              final permissionDescription = p.name
                                  .split(' | ')
                                  .last;
                              return CheckboxListTile(
                                title: Text(permissionDescription),
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedPermissions.add(p.id);
                                    } else {
                                      selectedPermissions.remove(p.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newGroup = Groups(
                      id: group.id,
                      name: nameController.text,
                      permissions: selectedPermissions.toList(),
                    );
                    if (group.id == 0) {
                      context.read<GeneralBloc<Groups>>().add(
                        AddItem(newGroup),
                      );
                    } else {
                      context.read<GeneralBloc<Groups>>().add(
                        UpdateItem(itemId: newGroup.id, item: newGroup),
                      );
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeneralBloc<Groups>, GeneralState<Groups>>(
      builder: (context, state) {
        List<Groups> groups = [];
        if (state is GeneralLoadInProgress<Groups>) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ItemLoadFailure<Groups>) {
          return Center(child: Text('Failed to load groups: ${state.error}'));
        } else if (state is ItemsLoadSuccess<Groups>) {
          groups = state.items;
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Group'),
                    onPressed: () {
                      _showEditGroupDialog(
                        context,
                        Groups(id: 0, name: '', permissions: []),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<GeneralBloc<Groups>>().add(LoadItems());
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              MyPaginatedDataTable(
                columnsName: const ['ID', 'Name', 'permissions'],
                datasource: MyDataSource<Groups>(
                  groups,
                  (o) => o.toJson(),
                  editObject: (o) {
                    _showEditGroupDialog(context, o);
                  },
                  deleteObject: (o) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: Text(
                          'Are you sure you want to delete the group "${o.name}"?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              context.read<GeneralBloc<Groups>>().add(
                                DeleteItem(o.id),
                              );
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  extraActions: {},
                ),
              ),
            ],
          ),
        );

        // return const Center(child: Text('Something went wrong.'));
      },
    );
  }
}
