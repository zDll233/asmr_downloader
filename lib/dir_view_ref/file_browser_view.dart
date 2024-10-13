import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class FileBrowserView extends StatefulWidget {
  const FileBrowserView({super.key});

  @override
  FileBrowserViewState createState() => FileBrowserViewState();
}

class FileBrowserViewState extends State<FileBrowserView> {
  final Map<String, bool> _selectedFiles = {}; // 记录选中的状态
  List<FileItem> _fileItems = []; // 存储文件和目录的层次结构

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  // 递归加载文件夹内容
  Future<void> _loadFiles() async {
    final selectedDirPath =
        await FilePicker.platform.getDirectoryPath(dialogTitle: '');
    Directory appDocDir = Directory(selectedDirPath!);
    String dirPath = appDocDir.path;
    Directory rootDir = Directory(dirPath);

    // 递归获取文件夹结构
    List<FileItem> files = _listDirectory(rootDir, 0); // 从根目录开始，深度为0
    setState(() {
      _fileItems = files;
    });
  }

  // 递归获取文件/目录结构
  List<FileItem> _listDirectory(Directory dir, int depth) {
    List<FileItem> items = [];
    List<FileSystemEntity> entities = dir.listSync();

    for (var entity in entities) {
      bool isDir = FileSystemEntity.isDirectorySync(entity.path);
      items.add(FileItem(
        name: p.basename(entity.path), // 只显示名称
        path: entity.path,
        isDirectory: isDir,
        depth: depth,
      ));

      // 如果是目录，递归获取其子文件/目录
      if (isDir) {
        items.addAll(_listDirectory(Directory(entity.path), depth + 1));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文件浏览器'),
      ),
      body: _fileItems.isNotEmpty
          ? ListView.builder(
              itemCount: _fileItems.length,
              itemBuilder: (context, index) {
                final fileItem = _fileItems[index];
                bool isSelected = _selectedFiles[fileItem.path] ?? false;

                return Padding(
                  padding:
                      EdgeInsets.only(left: 16.0 * fileItem.depth), // 根据深度缩进
                  child: CheckboxListTile(
                    title: Row(
                      children: [
                        Icon(fileItem.isDirectory
                            ? Icons.folder // 目录图标
                            : Icons.insert_drive_file), // 文件图标
                        SizedBox(width: 10),
                        Text(fileItem.name), // 文件或目录名称
                      ],
                    ),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedFiles[fileItem.path] = value ?? false;
                      });
                    },
                  ),
                );
              },
            )
          : Center(child: CircularProgressIndicator()), // 加载时显示的进度条
    );
  }
}

// 文件/目录结构体
class FileItem {
  final String name; // 文件或目录名称
  final String path; // 文件或目录路径
  final bool isDirectory; // 是否是目录
  final int depth; // 文件或目录的层级深度

  FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.depth,
  });
}
