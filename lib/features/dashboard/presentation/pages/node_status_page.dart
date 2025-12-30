import 'package:flutter/material.dart';

class NodeStatusPage extends StatefulWidget {
  const NodeStatusPage({super.key});

  @override
  State<NodeStatusPage> createState() => _NodeStatusPageState();
}

class _NodeStatusPageState extends State<NodeStatusPage> {

  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Node status"),
      ),
      body: Center(
        child: Text("Node status body"),
      ),
    );
  }
}
