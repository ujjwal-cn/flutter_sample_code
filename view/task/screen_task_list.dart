import 'package:flutter/material.dart';
import 'package:go4sheq/bloc/bloc.dart';
import 'package:go4sheq/model/task_details.dart';
import 'package:go4sheq/util/app_constant.dart';
import 'package:go4sheq/view/component/button_icon.dart';
import 'package:go4sheq/view/component/button_icon_back.dart';
import 'package:go4sheq/view/component/container_screen_title.dart';
import 'package:go4sheq/view/task/container_task_list.dart';
import 'package:go4sheq/view/task/screen_task_create.dart';

class ScreenTaskList extends StatefulWidget {
  static const String id = 'screen_task_list';

  const ScreenTaskList({
    Key? key,
  }) : super(key: key);

  @override
  State<ScreenTaskList> createState() => _ScreenTaskListState();
}

class _ScreenTaskListState extends State<ScreenTaskList> {
  String _taskStatus = '';
  List<String> _filterList = [];
  int _filterIndex = -1;
  List<TaskDetails> _taskList = [];

  _getTaskList(String status) async {
    _taskStatus = status;
    switch (status) {
      case 'Pending':
        _taskList = context.read<AppBloc>().taskPendingList;
        break;
      case 'Completed':
        _taskList = context.read<AppBloc>().taskCompletedList;
        break;
      default:
        _taskList = context.read<AppBloc>().taskList;
    }
    setState(() {});
  }

  _popupMenuItemClicked(int? index) async {
    switch (index) {
      case 0: // Sort by due date
        _filterIndex = 0;
        _taskList.sort((a, b) => (a.taskEndDate ?? DateTime(3000)).compareTo(b.taskEndDate ?? DateTime(3000)));
        break;
      case 1: // Sort by priority
        _filterIndex = 1;
        _taskList.sort((a, b) => (a.taskPriorityDetails?.id ?? 100) - (b.taskPriorityDetails?.id ?? 100));
        break;
      case 2: // Sort alphabetically
        _filterIndex = 2;
        _taskList.sort((a, b) => (a.name?.toLowerCase() ?? '').compareTo(b.name?.toLowerCase() ?? ''));
        break;
      default:
        _filterIndex = -1;
    }
    setState(() {});
  }

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _filterList = [
        AppLocalizations.of(context)!.sortByDueDate,
        AppLocalizations.of(context)!.sortByPriority,
        AppLocalizations.of(context)!.sortAlphabetically,
      ];

      final Map<String, dynamic> tempArgument = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final String filter = tempArgument['filter'] ?? ''; // Pending, Completed
      _getTaskList(filter);
      _popupMenuItemClicked(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kColorBackground,
      body: Stack(
        children: [
          // const ContainerScreenBackgroundHome(),
          Container(
            margin: const EdgeInsets.only(top: 13.5), // 100
            child: Column(
              children: [
                ContainerScreenTitle(
                  title: AppLocalizations.of(context)!.taskList,
                  leftWidget: const ButtonIconBack(),
                  rightWidget: PopupMenuButton<String>(
                    onSelected: (value) {
                      _popupMenuItemClicked(_filterList.indexOf(value));
                    },
                    itemBuilder: (BuildContext context) {
                      return _filterList.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              choice,
                              style: TextStyle(
                                fontSize: 16,
                                color: (_filterIndex != -1 && _filterList[_filterIndex] == choice) ? const Color(0xff297AC5) : null,
                              ),
                            ),
                          ),
                        );
                      }).toList();
                    },
                    offset: const Offset(-10, 46),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    tooltip: AppLocalizations.of(context)!.filter,
                    child: const ButtonIcon(
                      icon: Image(
                        image: AssetImage('images/icon_filter.png'),
                        width: 25,
                        height: 25,
                      ),
                      onPressed: null,
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: _taskList.isEmpty
                      ? Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Text(
                            (_taskStatus == 'Pending')
                                ? AppLocalizations.of(context)!.thereAreNoPendingTasks
                                : (_taskStatus == 'Completed')
                                    ? AppLocalizations.of(context)!.thereAreNoCompletedTasks
                                    : AppLocalizations.of(context)!.noItemsAvailable,
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _taskList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final task = _taskList[index];
                            final taskStatus = task.taskStatusDetails?.name;
                            return ContainerTaskList(
                              name: task.name,
                              // details: task.description,
                              taskStatusDetails: task.taskStatusDetails,
                              deadline: task.taskEndDate,
                              taskPriorityDetails: task.taskPriorityDetails,
                              onClicked: () async {
                                context.read<AppBloc>().openScreenTaskUpdate(taskDetails: task);
                                await Navigator.pushNamed(context, ScreenTaskCreate.id, arguments: {'viewTask': taskStatus == 'Completed'});
                                _getTaskList(_taskStatus);
                                _popupMenuItemClicked(_filterIndex);
                              },
                            );
                          },
                          padding: const EdgeInsets.only(bottom: 15),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
