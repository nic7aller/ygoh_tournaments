import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FireDropdownButton<DocumentSnapshot> extends FormField<DocumentSnapshot> {
  FireDropdownButton({
    Key key,
    @required String collection,
    @required String prettyField,
    String orderField = '',
    InputDecoration decoration,
    DocumentSnapshot initialValue,
    bool autovalidate = false,
    FormFieldSetter<DocumentSnapshot> onSaved,
    FormFieldValidator<DocumentSnapshot> validator,
  }) : super(
    key: key,
    onSaved: onSaved,
    validator: validator,
    autovalidate: autovalidate,
    initialValue: initialValue,
    builder: (FormFieldState<DocumentSnapshot> field) {
      final InputDecoration effectiveDecoration = (decoration ?? const InputDecoration())
          .applyDefaults(Theme.of(field.context).inputDecorationTheme);

      return InputDecorator(
        decoration:
        effectiveDecoration.copyWith(errorText: field.hasError ? field.errorText : null),
        isEmpty: field.value == null,
        child: new StreamBuilder<QuerySnapshot>(
          stream: orderField.isEmpty
              ? Firestore.instance
              .collection(collection)
              .snapshots()
              : Firestore.instance
              .collection(collection)
              .orderBy(orderField)
              .snapshots() ,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return new Text('Loading...');
            return new DropdownButtonHideUnderline(
              child: new DropdownButton<dynamic>(
                value: field.value,
                isDense: true,
                isExpanded: true,
                items: snapshot.data.documents.map((value) {
                  return new DropdownMenuItem(
                    value: value.documentID,
                    child: new Text(value.data[prettyField]),
                  );
                }).toList(),
                onChanged: field.didChange,
              ),
            );
          }),
      );
    },
  );
}
