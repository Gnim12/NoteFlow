import 'dart:io';

import 'package:flutter/material.dart';

import '../models/attachment_model.dart';

class AttachmentList extends StatelessWidget {
  final List<Attachment> attachments;
  final ValueChanged<Attachment> onDelete;
  final ValueChanged<Attachment> onTap;

  const AttachmentList({
    super.key,
    required this.attachments,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: attachments.map((attachment) {
        return GestureDetector(
          onTap: () => onTap(attachment),
          child: Container(
            width: 90,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: attachment.type == AttachmentType.image
                          ? Image.file(
                              File(attachment.localPath),
                              width: 78,
                              height: 78,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _FileIcon(theme),
                            )
                          : SizedBox(
                              width: 78,
                              height: 78,
                              child: _FileIcon(theme),
                            ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: InkWell(
                        onTap: () => onDelete(attachment),
                        child: CircleAvatar(
                          radius: 11,
                          backgroundColor: theme.colorScheme.error,
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (!attachment.isUploaded)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Icon(
                          Icons.cloud_off_rounded,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  attachment.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FileIcon extends StatelessWidget {
  final ThemeData theme;

  const _FileIcon(this.theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.insert_drive_file,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
