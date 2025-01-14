import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';

class MultiBoardListExample extends StatefulWidget {
  const MultiBoardListExample({Key? key}) : super(key: key);

  @override
  State<MultiBoardListExample> createState() => _MultiBoardListExampleState();
}

class _MultiBoardListExampleState extends State<MultiBoardListExample> {
  final AppFlowyBoardController controller = AppFlowyBoardController(
    onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      debugPrint('Move item from $fromIndex to $toIndex');
    },
    onMoveGroupItem: (groupId, fromIndex, toIndex) {
      debugPrint('Move $groupId:$fromIndex to $groupId:$toIndex');
    },
    onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      debugPrint('Move $fromGroupId:$fromIndex to $toGroupId:$toIndex');
    },
  );

  late AppFlowyBoardScrollController boardController;

  @override
  void initState() {
    boardController = AppFlowyBoardScrollController();
    final group1 = AppFlowyGroupData(id: "To Do", name: "To Do", items: [
      TextItem("Card 1", 1),
      TextItem("Card 2", 0),
      TextItem("Card 4", 3),
      TextItem("Card 5", 2),
    ]);

    final group2 = AppFlowyGroupData(
      id: "In Progress",
      name: "In Progress",
      items: <AppFlowyGroupItem>[
        TextItem("Card 6", 12),
        RichTextItem(title: "Card 7", subtitle: 'Aug 1, 2020 4:05 PM'),
        RichTextItem(title: "Card 8", subtitle: 'Aug 1, 2020 4:05 PM'),
      ],
    );

    final group3 = AppFlowyGroupData(id: "Pending", name: "Pending", items: <AppFlowyGroupItem>[
      TextItem("Card 9", 12),
      RichTextItem(title: "Card 10", subtitle: 'Aug 1, 2020 4:05 PM'),
      TextItem("Card 11", 12),
      TextItem("Card 12", 12),
      TextItem("Card 11", 12),
      TextItem("Card 11", 12),
      TextItem("Card 11", 12),
      TextItem("Card 11", 12),
      TextItem("Card 11", 12),
      TextItem("Card 11", 12),
      TextItem("Card 11", 12),
    ]);
    final group4 = AppFlowyGroupData(id: "Canceled", name: "Canceled", items: <AppFlowyGroupItem>[
      TextItem("Card 13", 12),
      TextItem("Card 14", 12),
      TextItem("Card 15", 12),
    ]);
    final group5 = AppFlowyGroupData(id: "Urgent", name: "Urgent", items: <AppFlowyGroupItem>[
      TextItem("Card 14", 12),
      TextItem("Card 15", 12),
    ]);

    controller.addGroup(group1);
    controller.addGroup(group2);
    controller.addGroup(group3);
    controller.addGroup(group4);
    controller.addGroup(group5);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var config = const AppFlowyBoardConfig(
        boardCornerRadius: 4,
        groupBackgroundColor: Colors.white,
        cardMargin: EdgeInsets.symmetric(horizontal: 5),
        groupBodyPadding: EdgeInsets.symmetric(horizontal: 10),
        stretchGroupHeight: true,
        edgeInsets: EdgeInsets.all(5),
        boxShadow: [BoxShadow(color: Colors.red, spreadRadius: 1)]);
    return AppFlowyBoard(
        controller: controller,
        cardBuilder: (context, group, groupItem) {
          return AppFlowyGroupCard(
            key: ValueKey(groupItem.id),
            child: _buildCard(groupItem),
          );
        },
        boardScrollController: boardController,
        footerBuilder: (context, columnData) {
          return AppFlowyGroupFooter(
            icon: const Icon(Icons.add, size: 20),
            title: const Text('New'),
            height: 50,
            margin: config.groupBodyPadding,
            onAddButtonClick: () {
              boardController.scrollToBottom(columnData.id);
            },
          );
        },
        headerBuilder: (context, columnData) {
          return AppFlowyGroupHeader(
            icon: const Icon(Icons.lightbulb_circle),
            title: SizedBox(
              width: 60,
              child: TextField(
                controller: TextEditingController()..text = columnData.headerData.groupName,
                onSubmitted: (val) {
                  controller.getGroupController(columnData.headerData.groupId)!.updateGroupName(val);
                },
              ),
            ),
            addIcon: const Icon(Icons.add, size: 20),
            moreIcon: const Icon(Icons.more_horiz, size: 20),
            height: 50,
            margin: config.groupBodyPadding,
          );
        },
        groupConstraints: const BoxConstraints.tightFor(width: 240),
        config: config);
  }

  Widget _buildCard(AppFlowyGroupItem item) {
    if (item is TextItem) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Text(item.s),
        ),
      );
    }

    if (item is RichTextItem) {
      return RichTextCard(item: item);
    }

    throw UnimplementedError();
  }
}

class RichTextCard extends StatefulWidget {
  final RichTextItem item;
  const RichTextCard({
    required this.item,
    Key? key,
  }) : super(key: key);

  @override
  State<RichTextCard> createState() => _RichTextCardState();
}

class _RichTextCardState extends State<RichTextCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
            Text(
              widget.item.subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}

class TextItem extends AppFlowyGroupItem {
  final String s;
  final int pos;

  TextItem(this.s, this.pos);

  @override
  int get position => pos;

  @override
  String get id => s;
}

class RichTextItem extends AppFlowyGroupItem {
  final String title;
  final String subtitle;

  RichTextItem({required this.title, required this.subtitle});

  @override
  String get id => title;
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
