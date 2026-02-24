import 'dart:io';

import 'package:audiobook/dashboard/bloc/dashboard_bloc.dart';
import 'package:audiobook/dashboard/bloc/dashboard_event.dart';
import 'package:audiobook/dashboard/data/model.dart';
import 'package:audiobook/dashboard/widget/uploadLogo.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Uploader extends StatelessWidget {
  const Uploader({super.key});

  @override
  Widget build(BuildContext context) {
    pickFile() async {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'log', 'txt'],
      );

      if (picked == null || picked.files.first.path == null) return;

      final file = File(picked.files.first.path!);

      context.read<DashboardBloc>().add(
        AddFileToDashboard(
          doc: YourDocument(
            file: file,
            finalName: picked.files.first.name,
            dateTime: DateTime.now(),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        double containerWidth;
        if (maxWidth > 900) {
          containerWidth = 600; // desktop
        } else if (maxWidth > 600) {
          containerWidth = maxWidth * 0.95; // tablet
        } else {
          containerWidth = maxWidth * 0.95; // mobile
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DottedBorder(
              options: RectDottedBorderOptions(
                color: Theme.of(context).colorScheme.primary,
                dashPattern: const [6, 4],
              ),
              child: Container(
                width: containerWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const UploadLogo(),

                    const SizedBox(height: 20),

                    Text(
                      "Drop your PDF or DOC here",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "or click to browse files",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: 180,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: pickFile,
                        child: const Text("Choose File"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}