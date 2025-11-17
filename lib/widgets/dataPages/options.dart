import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ponit_of_sales/blocs/general/general_bloc.dart';
import 'package:ponit_of_sales/controllers/main.dart';
import 'package:ponit_of_sales/models/options.dart';
import 'package:ponit_of_sales/utils/table_permissions.dart';
import 'package:ponit_of_sales/widgets/container_head.dart';
import 'package:ponit_of_sales/widgets/craete_button.dart';
import 'package:ponit_of_sales/widgets/edits%20pages/option.dart';
import 'package:ponit_of_sales/widgets/paginated_table.dart';
import 'package:ponit_of_sales/widgets/search_anchor.dart';
import 'package:ponit_of_sales/widgets/tabs_bar.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  State<OptionsPage> createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyContainer(
          child: MyTabsBar(
            pageController: _pageController,
            tabs: const ["Option Types", "Option Values"],
            tablesName: const ['optionstype', 'optionsvalue'],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: const [_OptionTypesView(), _OptionValuesView()],
          ),
        ),
      ],
    );
  }
}

class _OptionTypesView extends StatefulWidget {
  const _OptionTypesView();

  @override
  State<_OptionTypesView> createState() => _OptionTypesViewState();
}

class _OptionTypesViewState extends State<_OptionTypesView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<OptionsType> types = [];
  late final MainController<OptionsType> controller;
  final Map<String, bool> permissions = {};

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'optionstype'));
    controller = MainController<OptionsType>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              permissions['add']!
                  ? CreateNewButton(
                      onPressed: () => showEditOptionTypeDialog(
                        context,
                        OptionsType(name: ""),
                      ),
                    )
                  : const Text("Option Types"),
              if (permissions['view']!) MySearchAnchor(searchIn: types),
            ],
          ),
        ),
        const SizedBox(height: 20),
        BlocBuilder<GeneralBloc<OptionsType>, GeneralState<OptionsType>>(
          builder: (context, state) {
            if (state is ItemsLoadSuccess<OptionsType>) {
              types.clear();
              types.addAll(state.items);
            }
            return MyPaginatedDataTable(
              datasource: MyDataSource<OptionsType>(
                types,
                (o) => o.toMap(),
                editObject: permissions['change']!
                    ? (o) => showEditOptionTypeDialog(context, o)
                    : null,
                deleteObject: permissions['delete']!
                    ? (o) => controller.deleteItem(o.id!)
                    : null,
              ),
              columnsName: OptionsType.columnsName,
            );
          },
        ),
      ],
    );
  }
}

class _OptionValuesView extends StatefulWidget {
  const _OptionValuesView();

  @override
  State<_OptionValuesView> createState() => _OptionValuesViewState();
}

class _OptionValuesViewState extends State<_OptionValuesView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final List<OptionsValue> values = [];
  late final MainController<OptionsValue> controller;
  final Map<String, bool> permissions = {};

  @override
  void initState() {
    permissions.addAll(tablePermissions(context, 'optionsvalue'));
    controller = MainController<OptionsValue>(context: context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (permissions['view']!) controller.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        MyContainer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              permissions['add']!
                  ? CreateNewButton(
                      onPressed: () => showEditOptionValueDialog(
                        context,
                        OptionsValue(name: "", typeId: 0),
                      ),
                    )
                  : const Text("Option Values"),
              if (permissions['view']!) MySearchAnchor(searchIn: values),
            ],
          ),
        ),
        const SizedBox(height: 20),
        BlocBuilder<GeneralBloc<OptionsValue>, GeneralState<OptionsValue>>(
          builder: (context, state) {
            if (state is ItemsLoadSuccess<OptionsValue>) {
              values.clear();
              values.addAll(state.items);
            }
            return MyPaginatedDataTable(
              datasource: MyDataSource<OptionsValue>(
                values,
                (o) => o.toMap(),
                editObject: permissions['change']!
                    ? (o) => showEditOptionValueDialog(context, o)
                    : null,
                deleteObject: permissions['delete']!
                    ? (o) => controller.deleteItem(o.id!)
                    : null,
              ),
              columnsName: OptionsValue.columnsName,
            );
          },
        ),
      ],
    );
  }
}
