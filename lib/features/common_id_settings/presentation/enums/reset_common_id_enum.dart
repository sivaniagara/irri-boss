enum ResetCommonIdEnum{idle, loading, success, failure}

extension  ResetCommonIdEnumExtension on ResetCommonIdEnum{
  String getMessage(){
    switch (this){
      case (ResetCommonIdEnum.idle): return '';
      case (ResetCommonIdEnum.loading): return '';
      case (ResetCommonIdEnum.success): return 'Reset Command Send Successfully.';
      case (ResetCommonIdEnum.failure): return 'Reset Command Send failed.';
    }
  }
}