import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class RichTextViewer extends StatelessWidget {
  final List<dynamic> content;

  const RichTextViewer({super.key, required this.content});

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
