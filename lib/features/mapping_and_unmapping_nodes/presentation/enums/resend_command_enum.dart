enum ResendCommandEnum{idle, loading, success, failure}

extension ResendCommandEnumExtension on ResendCommandEnum{
  String getMessage(){
    switch (this){
      case (ResendCommandEnum.idle): return '';
      case (ResendCommandEnum.loading): return '';
      case (ResendCommandEnum.success): return 'Resend Command Successfully.';
      case (ResendCommandEnum.failure): return 'Resend Command failed.';
    }
  }
}