enum ZoneSetUpdateStatusEnum{idle, loading, success, failure}

extension ZoneSetUpdateStatusEnumExtension on ZoneSetUpdateStatusEnum{
  String get message {
    switch(this){
      case(ZoneSetUpdateStatusEnum.idle): return '';
      case(ZoneSetUpdateStatusEnum.loading): return '';
      case(ZoneSetUpdateStatusEnum.success): return 'Zone Setting Updated Successfully!';
      case(ZoneSetUpdateStatusEnum.failure): return 'Zone Setting Updated Failed!';
    }
  }
}