import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class RichTextViewer extends StatelessWidget {
  final List<dynamic> content;

  const RichTextViewer({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final doc = Document.fromJson(content);
    final controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    return QuillEditor.basic(
      controller: controller,
      config: QuillEditorConfig(checkBoxReadOnly: true),
    );
  }
}
