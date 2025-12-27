enum DeleteMappedNodeEnum{idle, loading, success, failure}

extension DeleteMappedNodeEnumExtension on DeleteMappedNodeEnum{
  String getMessage(){
    switch (this){
      case (DeleteMappedNodeEnum.idle): return '';
      case (DeleteMappedNodeEnum.loading): return '';
      case (DeleteMappedNodeEnum.success): return 'Node Deleted Successfully.';
      case (DeleteMappedNodeEnum.failure): return 'Node Deleted failed.';
    }
  }
}