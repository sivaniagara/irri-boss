enum ViewCommandEnum{idle, loading, success, failure}

extension ViewCommandEnumExtension on ViewCommandEnum{
  String getMessage(){
    switch (this){
      case (ViewCommandEnum.idle): return '';
      case (ViewCommandEnum.loading): return '';
      case (ViewCommandEnum.success): return 'View Command Successfully.';
      case (ViewCommandEnum.failure): return 'View Command failed.';
    }
  }
}