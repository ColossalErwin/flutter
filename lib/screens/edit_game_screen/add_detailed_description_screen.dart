//packages
import 'package:flutter/material.dart';

class AddDetailedDescriptionScreen extends StatelessWidget {
  final void Function(String? detailedDescription) addDetailedDescription;
  final String? title;
  final String? detailedDescription;

  const AddDetailedDescriptionScreen({
    Key? key,
    required this.addDetailedDescription,
    this.title,
    this.detailedDescription,
  }) : super(key: key);

  void _saveForm(GlobalKey<FormState> formKey) {
    formKey.currentState?.save();
  }

  Future<void> _makeChanges(BuildContext context, GlobalKey<FormState> form) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: const Text("Click confirm to finish editing."),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text("Keep editing"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () {
                _saveForm(form);
                //no need to await since we wouldn't modify and need detailed description after going back
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: (title != null)
            ? FittedBox(child: Text(title!))
            : const FittedBox(child: Text("Add a detailed description")),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _makeChanges(context, form);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: form,
          onChanged: () {},
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  initialValue: detailedDescription,
                  keyboardType: TextInputType.multiline,
                  maxLines: 35,
                  decoration: InputDecoration(
                    labelText: (title != null)
                        ? "Add a detailed description for $title"
                        : "Add a detailed description for this game",
                  ),
                  textInputAction: TextInputAction.next,
                  //go to the next input after we confirm/Enter
                  //go to a focus node if we use the below code
                  onFieldSubmitted: (inputValue) {
                    //we don't really need inputValue, so just use _ instead of inputValue is OK
                    //FocusScope.of(context).requestFocus(_msrpFocusNode);
                    //if we click next, it will jump to the field with the requestFocusNode
                    //which is _msrpFocusNode for msrp field
                  },
                  onSaved: (inputValue) {
                    addDetailedDescription(inputValue);
                    print("input value is: ");
                    print(inputValue);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
