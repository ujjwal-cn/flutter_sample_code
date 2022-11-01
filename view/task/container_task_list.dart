import 'package:flutter/material.dart';
import 'package:go4sheq/bloc/bloc.dart';
import 'package:go4sheq/model/task_priority_details.dart';
import 'package:go4sheq/model/task_status_details.dart';
import 'package:go4sheq/util/app_util.dart';
import 'package:go4sheq/view/component/button_icon.dart';

class ContainerTaskList extends StatelessWidget {
  final String? name, details;
  final TaskStatusDetails? taskStatusDetails;
  final DateTime? deadline;
  final TaskPriorityDetails? taskPriorityDetails;
  final VoidCallback? onClicked;

  const ContainerTaskList({
    Key? key,
    this.name,
    this.details,
    this.taskStatusDetails,
    this.deadline,
    this.taskPriorityDetails,
    this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Status
    String? status = taskStatusDetails?.name;
    if (status == 'Pending') status = AppLocalizations.of(context)!.pending;
    if (status == 'Completed') status = AppLocalizations.of(context)!.completed;
    Color? statusColor = taskStatusDetails?.color;
    // Priority
    String? priority = taskPriorityDetails?.name;
    if (priority == 'Critical') priority = AppLocalizations.of(context)!.critical;
    if (priority == 'High') priority = AppLocalizations.of(context)!.high;
    if (priority == 'Medium') priority = AppLocalizations.of(context)!.medium;
    if (priority == 'Low') priority = AppLocalizations.of(context)!.low;
    String? priorityIcon = taskPriorityDetails?.icon;
    Color? priorityColor = taskPriorityDetails?.color;
    // Overdue
    bool isTaskOverdue = false;
    if (taskStatusDetails?.name == 'Pending' && deadline != null && deadline!.add(const Duration(hours: 24)).isBefore(DateTime.now())) {
      isTaskOverdue = true;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            width: 0.2,
            color: Color(0xffC1C1C1),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onClicked,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          '$name',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$status',
                        style: TextStyle(
                          fontSize: 16,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  details != null
                      ? Text(
                          '$details',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox(),
                  const SizedBox(height: 15),
                  deadline != null ? _buildTimeWidget(title: AppLocalizations.of(context)!.deadline, body: deadline!.getString(separator: '.'), isTaskOverdue: isTaskOverdue) : _buildTimeWidget(title: '', body: ''),
                  Row(
                    children: [
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: _buildTimeWidget(title: AppLocalizations.of(context)!.priority, body: priority ?? '-', icon: priorityIcon, color: priorityColor),
                      ),
                      onClicked != null
                          ? const Align(
                              alignment: Alignment.centerRight,
                              child: ButtonIcon(
                                icon: Image(
                                  image: AssetImage('images/icon_arrow_right.png'),
                                ),
                                splashRadius: 20,
                              ),
                            )
                          : const SizedBox(height: 15),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeWidget({required String title, required String body, String? icon, Color? color, bool isTaskOverdue = false}) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 10),
        if (icon != null) ...[
          Image(
            image: AssetImage('images/$icon'),
            width: 18,
            height: 18,
            color: color,
          ),
          const SizedBox(width: 5),
        ],
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Text(
            body,
            style: TextStyle(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
              fontWeight: isTaskOverdue ? FontWeight.bold : null,
              color: isTaskOverdue ? Colors.red : null,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
