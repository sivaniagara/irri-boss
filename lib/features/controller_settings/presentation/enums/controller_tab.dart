enum ControllerTab {details, nodes, programs}

extension ControllerTabExtension on ControllerTab{
  String title(){
    switch (this){
      case ControllerTab.details:
        return 'Controller';
      case ControllerTab.nodes:
        return 'Nodes';
      case ControllerTab.programs:
        return 'Programs';
    }
  }
}
