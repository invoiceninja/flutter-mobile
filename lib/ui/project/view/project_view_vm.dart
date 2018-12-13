import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/redux/project/project_actions.dart';
import 'package:invoiceninja_flutter/data/models/project_model.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/ui/project/view/project_view.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/ui/app/icon_message.dart';

class ProjectViewScreen extends StatelessWidget {
  static const String route = '/project/view';
  const ProjectViewScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ProjectViewVM>(
      converter: (Store<AppState> store) {
        return ProjectViewVM.fromStore(store);
      },
      builder: (context, vm) {
        return ProjectView(
          viewModel: vm,
        );
      },
    );
  }
}

class ProjectViewVM {
  final ProjectEntity project;
  final CompanyEntity company;
  final Function(BuildContext, EntityAction) onActionSelected;
  final Function(BuildContext) onEditPressed;
  final bool isSaving;
  final bool isLoading;
  final bool isDirty;

  ProjectViewVM({
    @required this.project,
    @required this.company,
    @required this.onActionSelected,
    @required this.onEditPressed,
    @required this.isSaving,
    @required this.isLoading,
    @required this.isDirty,
  });

  factory ProjectViewVM.fromStore(Store<AppState> store) {
    final state = store.state;
    final payment = state.projectState.map[state.projectUIState.selectedId];

    return ProjectViewVM(
        isLoading: store.state.isLoading,
        project: project,
        onEditPressed: (BuildContext context) {
          store.dispatch(EditProject(project: project, context: context));
        },
        onActionSelected: (BuildContext context, EntityAction action) {
          final localization = AppLocalization.of(context);
          switch (action) {
            case EntityAction.archive:
              store.dispatch(ArchiveProjectRequest(
                  popCompleter(context, localization.archivedProject),
                  project.id));
              break;
            case EntityAction.delete:
              store.dispatch(DeleteProjectRequest(
                  popCompleter(context, localization.deletedProject),
                  project.id));
              break;
            case EntityAction.restore:
              store.dispatch(RestoreProjectRequest(
                  snackBarCompleter(context, localization.restoredProject),
                  project.id));
              break;
          }
        });
  }
}
