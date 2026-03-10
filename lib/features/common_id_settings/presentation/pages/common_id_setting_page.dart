import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_app_bar.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/custom_list_tile.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/presentation/bloc/common_id_settings_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/presentation/bloc/common_id_settings_state.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/presentation/enums/common_id_settings_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/presentation/widgets/node_list.dart';

import '../../../../core/widgets/alert_dialog.dart';
import '../../../../core/widgets/app_alerts.dart';
import '../../../../core/widgets/gradiant_background.dart';
import '../enums/reset_common_id_enum.dart';
import '../enums/view_common_id_enum.dart';

class CommonIdSettingPage extends StatelessWidget {
  const CommonIdSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Common Id Settings'),
      body: BlocListener<CommonIdSettingsBloc, CommonIdSettingsState>(
        listener: (context, state){
          if(state is CommonIdSettingsLoaded && state.commonIdSettingsUpdateStatus == CommonIdSettingsUpdateStatus.loading){
            showGradientLoadingDialog(context);
          }else if(state is CommonIdSettingsLoaded && state.commonIdSettingsUpdateStatus == CommonIdSettingsUpdateStatus.failure){
            context.pop();
            showErrorAlert(context: context, message: CommonIdSettingsUpdateStatus.failure.getMessage());
          }else if(state is CommonIdSettingsLoaded && state.commonIdSettingsUpdateStatus == CommonIdSettingsUpdateStatus.success){
            context.pop();
            showSuccessAlert(
                context: context,
                message: CommonIdSettingsUpdateStatus.success.getMessage(),
                onPressed: (){
                  context.pop();
                }
            );
          }else if(state is CommonIdSettingsLoaded && state.viewCommonIdEnum == ViewCommonIdEnum.loading){
            showGradientLoadingDialog(context);
          }else if(state is CommonIdSettingsLoaded && state.viewCommonIdEnum == ViewCommonIdEnum.failure){
            context.pop();
            showErrorAlert(context: context, message: ViewCommonIdEnum.failure.getMessage());
          }else if(state is CommonIdSettingsLoaded && state.viewCommonIdEnum == ViewCommonIdEnum.success){
            context.pop();
            showSuccessAlert(
                context: context,
                message: ViewCommonIdEnum.success.getMessage(),
                onPressed: (){
                  context.pop();
                }
            );
          }else if(state is CommonIdSettingsLoaded && state.resetCommonIdEnum == ResetCommonIdEnum.loading){
            showGradientLoadingDialog(context);
          }else if(state is CommonIdSettingsLoaded && state.resetCommonIdEnum == ResetCommonIdEnum.failure){
            context.pop();
            showErrorAlert(context: context, message: ResetCommonIdEnum.failure.getMessage());
          }else if(state is CommonIdSettingsLoaded && state.resetCommonIdEnum == ResetCommonIdEnum.success){
            context.pop();
            showSuccessAlert(
                context: context,
                message: ResetCommonIdEnum.success.getMessage(),
                onPressed: (){
                  context.pop();
                }
            );
          }
        },
        child: BlocBuilder<CommonIdSettingsBloc, CommonIdSettingsState>(
            builder: (context, state){
              if(state is CommonIdSettingsLoading){
                return const Center(child: CircularProgressIndicator());
              }else if (state is CommonIdSettingsError) {
                return Material(child: Center(child: Text(state.message, style: TextStyle(color: Colors.black),)));
              }else if(state is CommonIdSettingsLoaded){
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(height: 10,),
                      Expanded(
                        child: ListView.builder(
                            itemCount: state.listOfCategoryEntity.length,
                            itemBuilder: (context, index){
                              return CustomListTile(
                                  onTap: (){
                                    showNodeSheet(context, index);
                                  },
                                  title: state.listOfCategoryEntity[index].categoryName
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Placeholder();
            }
        ),
      ),
    );
  }

  void showNodeSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider.value(
            value: context.read<CommonIdSettingsBloc>(),
          child: NodeList(categoryIndex: index,),
        );
      },
    );
  }
}
