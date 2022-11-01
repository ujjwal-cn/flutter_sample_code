import 'package:flutter/material.dart';
import 'package:go4sheq/bloc/bloc.dart';
import 'package:go4sheq/view/component/container_screen_title.dart';
import 'package:go4sheq/view/component/container_task_status.dart';
import 'package:go4sheq/view/task/screen_task_create.dart';
import 'package:go4sheq/view/task/screen_task_list.dart';

class TabTask extends StatelessWidget {
  const TabTask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<AppBloc>().onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          margin: const EdgeInsets.only(top: 0),
          child: Column(
            children: [
              ContainerScreenTitle(
                title: AppLocalizations.of(context)!.tasks,
              ),
              const SizedBox(height: 15),
              ContainerTaskStatus(
                icon: 'icon_task_create.png',
                title: AppLocalizations.of(context)!.createTask,
                colorContainer: const Color(0xff297AC5),
                onTap: () {
                  context.read<AppBloc>().openScreenTaskCreate();
                  Navigator.pushNamed(context, ScreenTaskCreate.id);
                },
              ),
              const SizedBox(height: 8),
              ContainerTaskStatus(
                icon: 'icon_task_pending.png',
                title: AppLocalizations.of(context)!.pendingTasks,
                subTitle: '${context.watch<AppBloc>().taskPendingList.length} ${AppLocalizations.of(context)!.tasks}',
                colorContainer: const Color(0xff27B5E2),
                onTap: () {
                  Navigator.pushNamed(context, ScreenTaskList.id, arguments: {'filter': 'Pending'});
                },
              ),
              const SizedBox(height: 8),
              ContainerTaskStatus(
                icon: 'icon_task_complete.png',
                title: AppLocalizations.of(context)!.completedTasks,
                subTitle: '${context.watch<AppBloc>().taskCompletedList.length} ${AppLocalizations.of(context)!.tasks}',
                colorContainer: const Color(0xffD7F1EE),
                colorContent: const Color(0xff22718B),
                onTap: () {
                  Navigator.pushNamed(context, ScreenTaskList.id, arguments: {'filter': 'Completed'});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
