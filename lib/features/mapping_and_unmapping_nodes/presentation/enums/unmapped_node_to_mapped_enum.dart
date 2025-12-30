enum UnmappedNodeToMappedEnum{idle, loading, success, failure}

extension UnmappedNodeToMappedEnumExtension on UnmappedNodeToMappedEnum{
  String get message {
    switch(this){
      case (UnmappedNodeToMappedEnum.idle): return '';
      case (UnmappedNodeToMappedEnum.loading): return '';
      case (UnmappedNodeToMappedEnum.success): return 'Node Successfully Mapped!';
      case (UnmappedNodeToMappedEnum.failure): return 'Mapping nodes failed!';
    }
  }
}