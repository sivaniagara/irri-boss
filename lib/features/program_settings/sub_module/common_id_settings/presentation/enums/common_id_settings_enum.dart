enum CommonIdSettingsUpdateStatus{idle, loading, success, failure}

extension  CommonIdSettingsUpdateStatusX on CommonIdSettingsUpdateStatus{
  String getMessage(){
    switch (this){
      case (CommonIdSettingsUpdateStatus.idle): return '';
      case (CommonIdSettingsUpdateStatus.loading): return '';
      case (CommonIdSettingsUpdateStatus.success): return 'Ordering Update Successfully.';
      case (CommonIdSettingsUpdateStatus.failure): return 'Ordering Update failed.';
    }
  }
}