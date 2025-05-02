import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class RichTextEditor extends StatefulWidget {
  final List<dynamic>? initialValue;
  final void Function(List<dynamic>) onChanged;

  const RichTextEditor({super.key, this.initialValue, required this.onChanged});

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late QuillController _controller;

  @override
  void initState() {
    super.initState();
    final doc =
        widget.initialValue != null
            ? Document.fromJson(widget.initialValue!)
            : Document();
    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _controller.document.changes.listen((_) {
      widget.onChanged(_controller.document.toDelta().toJson());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillSimpleToolbar(
          controller: _controller,
          config: const QuillSimpleToolbarConfig(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: QuillEditor.basic(
              controller: _controller,
              config: QuillEditorConfig(checkBoxReadOnly: false),
            ),
          ),
        ),
      ],
    );
  }
}
