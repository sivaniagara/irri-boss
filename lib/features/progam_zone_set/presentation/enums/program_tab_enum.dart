enum ProgramTabEnum {p1, p2, p3, p4, p5, p6}

extension ProgramTabEnumExtension on ProgramTabEnum{
  String title(){
    switch (this){
      case ProgramTabEnum.p1:
        return 'P 1';
      case ProgramTabEnum.p2:
        return 'P 2';
      case ProgramTabEnum.p3:
        return 'P 3';
      case ProgramTabEnum.p4:
        return 'P 4';
      case ProgramTabEnum.p5:
        return 'P 5';
      case ProgramTabEnum.p6:
        return 'P 6';
    }
  }

  String id(){
    switch (this){
      case ProgramTabEnum.p1:
        return '1';
      case ProgramTabEnum.p2:
        return '2';
      case ProgramTabEnum.p3:
        return '3';
      case ProgramTabEnum.p4:
        return '4';
      case ProgramTabEnum.p5:
        return '5';
      case ProgramTabEnum.p6:
        return '6';
    }
  }
}
