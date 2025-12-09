import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/retry.dart';

import '../../../../../core/di/injection.dart' as di;
import '../../../../../core/widgets/action_button.dart';
import '../../../../../core/widgets/alert_dialog.dart';
import '../../groups_barrel.dart';

class GroupsPage extends StatelessWidget {
  final int userId;
  const GroupsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext dialogContext) {
    final groupFetchingUseCase = di.sl<GroupFetchingUsecase>();
    final addGroupUseCase = di.sl<GroupAddingUsecase>();
    final editGroupUsecase = di.sl<EditGroupUsecase>();
    final deleteGroupUsecase = di.sl<DeleteGroupUsecase>();
    return BlocProvider(
      create: (context) => GroupBloc(
        groupFetchingUsecase: groupFetchingUseCase,
        groupAddingUsecase: addGroupUseCase,
        editGroupUsecase: editGroupUsecase,
        deleteGroupUsecase: deleteGroupUsecase,
      )..add(FetchGroupsEvent(userId)),
      child: _GroupsView(userId: userId),
    );
  }
}

class _GroupsView extends StatelessWidget {
  final int userId;
  const _GroupsView({required this.userId});

  @override
  Widget build(BuildContext dialogContext) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          if (state is GroupLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GroupLoaded) {
            return _buildGroupList(context, state, userId);
          } else if (state is GroupFetchingError) {
            return Retry(
              message: state.message,
              onPressed: () => context.read<GroupBloc>().add(FetchGroupsEvent(userId)),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGroupDialog(dialogContext, userId, isEdit: false, isDelete: false),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupList(BuildContext context, GroupLoaded state, int userId) {
    if (state.groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No groups yet. Tap the + button to create one.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final completer = Completer<void>();
        late StreamSubscription subscription;
        subscription = context.read<GroupBloc>().stream.listen((s) {
          if (s is GroupLoaded || s is GroupFetchingError) {
            completer.complete();
            subscription.cancel();
          }
        });
        context.read<GroupBloc>().add(FetchGroupsEvent(userId));
        await completer.future;
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.groups.length,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemBuilder: (context, index) {
          final group = state.groups[index];
          final isFirst = index == 0;
          final isLast = index == state.groups.length - 1;
          final borderRadius = BorderRadius.only(
            topLeft: isFirst ? const Radius.circular(16) : Radius.zero,
            topRight: isFirst ? const Radius.circular(16) : Radius.zero,
            bottomLeft: isLast ? const Radius.circular(16) : Radius.zero,
            bottomRight: isLast ? const Radius.circular(16) : Radius.zero,
          );

          return Column(
            children: [
              GlassCard(
                padding: EdgeInsets.zero,
                borderRadius: borderRadius,
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 10, right: 5),
                  title: Text(group.groupName),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showGroupDialog(
                          context,
                          userId,
                          isEdit: true,
                          isDelete: false,
                          groupId: group.userGroupId,
                          groupName: group.groupName,
                        ),
                        icon: Icon(Icons.edit, color: Theme.of(context).primaryColorLight),
                        tooltip: 'Edit group',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _showGroupDialog(
                          context,
                          userId,
                          isEdit: false,
                          isDelete: true,
                          groupId: group.userGroupId,
                          groupName: group.groupName,
                        ),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete group',
                      ),
                    ],
                  ),
                ),
              ),
              if(isLast)
                SizedBox(height: 50,)
            ],
          );
        },
      ),
    );
  }

  void _showGroupDialog(
      BuildContext context,
      int userId, {
        required bool isEdit,
        required bool isDelete,
        int groupId = 0,
        String groupName = '',
      }) {
    final bloc = context.read<GroupBloc>();
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: bloc,
        child: GroupDialog(
          userId: userId,
          isEdit: isEdit,
          isDelete: isDelete,
          groupId: groupId,
          groupName: groupName,
        ),
      ),
    );
  }
}

class GroupDialog extends StatefulWidget {
  final int userId;
  final bool isEdit;
  final bool isDelete;
  final int groupId;
  final String groupName;

  const GroupDialog({
    super.key,
    required this.userId,
    required this.isEdit,
    required this.isDelete,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDialog> createState() => _GroupDialogState();
}

class _GroupDialogState extends State<GroupDialog> {
  late final TextEditingController _controller;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.isEdit ? widget.groupName : 'New Group');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (widget.isDelete) {
      context.read<GroupBloc>().add(GroupDeleteEvent(userId: widget.userId, groupId: widget.groupId));
      return;
    }

    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final bloc = context.read<GroupBloc>();
    final event = widget.isEdit
        ? GroupEditEvent(userId: widget.userId, groupId: widget.groupId, groupName: name)
        : GroupAddEvent(userId: widget.userId, groupName: name);

    bloc.add(event);
  }

  void _handleStateChange(GroupState state) {
    if (mounted) {
      if (state is GroupAddingStarted || state is EditGroupInitial || state is GroupDeletingStarted) {
        setState(() => _isLoading = true);
      } else if (state is GroupAddingLoaded || state is EditGroupSuccess || state is GroupDeleteSuccess) {
        setState(() => _isLoading = false);
        if (context.mounted) Navigator.of(context).pop();
      } else if (state is GroupAddingError || state is EditGroupError || state is GroupDeleteError) {
        setState(() => _isLoading = false);
        if (context.mounted && state is GroupDeleteError) Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) => _handleStateChange(state),
      child: GlassyAlertDialog(
        title: widget.isEdit ? 'Edit Group' : widget.isDelete ? 'Delete Group' : 'New Group',
        content: widget.isDelete
            ? Text('Are you sure you want to delete "${widget.groupName}"? This action cannot be undone.')
            : TextFormField(
          controller: _controller,
          autofocus: true,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: 'Enter group name',
            hintStyle: const TextStyle(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: _buildClearButton(),
          ),
        ),
        actions: [
          ActionButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            isPrimary: false,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          ActionButton(
            onPressed: _isLoading ? null : _handleSave,
            isPrimary: true,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : Text(widget.isDelete ? 'Delete' : 'Save'),
          ),
        ],
        barrierDismissible: false,
      ),
    );
  }

  Widget _buildClearButton() => IconButton(
    icon: Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.clear_rounded, color: Colors.white),
    ),
    onPressed: _controller.clear,
  );
}