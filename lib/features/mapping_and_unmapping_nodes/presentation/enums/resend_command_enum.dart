enum ResendCommandEnum{idle, loading, resendLoading, success, failure}

extension ResendCommandEnumExtension on ResendCommandEnum{
  String getMessage(){
    switch (this){
      case (ResendCommandEnum.idle): return '';
      case (ResendCommandEnum.loading): return '';
      case (ResendCommandEnum.resendLoading): return '';
      case (ResendCommandEnum.success): return 'Resend Command Successfully.';
      case (ResendCommandEnum.failure): return 'Resend Command failed.';
    }
  }
}