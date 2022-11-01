import 'package:flutter/material.dart';
import 'package:go4sheq/bloc/bloc.dart';

class AlertDialogAlert extends StatelessWidget {
  final String? title, content;
  final String btnOk, btnCancel;
  final VoidCallback? onClickedCancel, onClickedOk;

  const AlertDialogAlert({
    Key? key,
    this.title,
    this.content,
    this.btnOk = 'Ok',
    this.btnCancel = 'Cancel',
    this.onClickedCancel,
    this.onClickedOk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String tempBtnOk = btnOk;
    String tempBtnCancel = btnCancel;
    if (tempBtnOk == 'Ok') tempBtnOk = AppLocalizations.of(context)!.ok;
    if (tempBtnCancel == 'Cancel') tempBtnCancel = AppLocalizations.of(context)!.cancel;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: title != null ? Text(title!) : null,
      content: Text(content.toString()),
      actions: [
        onClickedCancel != null
            ? TextButton(
                onPressed: onClickedCancel,
                child: Text(tempBtnCancel),
              )
            : Container(),
        onClickedOk != null
            ? TextButton(
                onPressed: onClickedOk,
                child: Text(tempBtnOk),
              )
            : Container(),
      ],
    );
  }
}
