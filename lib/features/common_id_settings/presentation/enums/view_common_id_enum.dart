enum ViewCommonIdEnum{idle, loading, success, failure}

extension  ViewCommonIdEnumExtension on ViewCommonIdEnum{
  String getMessage(){
    switch (this){
      case (ViewCommonIdEnum.idle): return '';
      case (ViewCommonIdEnum.loading): return '';
      case (ViewCommonIdEnum.success): return 'View Command Send Successfully.';
      case (ViewCommonIdEnum.failure): return 'View Command Send failed.';
    }
  }
}