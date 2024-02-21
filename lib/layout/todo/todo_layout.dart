import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/layout/todo/cubit/cubit.dart';
import 'package:todo_app/layout/todo/cubit/states.dart';
import 'package:todo_app/shared/components/components.dart';

class ToDoLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        return ToDoCubit()..createDatabase();
      },
      child: BlocConsumer<ToDoCubit, ToDoStates>(
        listener: (BuildContext context, ToDoStates state) {
          if (state is ToDoInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, ToDoStates state) {
          ToDoCubit cubit = ToDoCubit.get(context);

          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(
                cubit.titles[cubit.currentIndex],
              ),
            ),
            body: (state is! ToDoGetDatabaseLoadingState)
                ? cubit.screens[cubit.currentIndex]
                : Center(child: CircularProgressIndicator()),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState!.validate()){
                  cubit.insertToDatabase(
                    title: titleController.text,
                    time: timeController.text,
                    date: dateController.text,
                  );
                  formKey.currentState!.reset();
                  }
                }
                else {
                  scaffoldKey.currentState!
                      .showBottomSheet(
                        (context) {
                          return SingleChildScrollView(
                            child: Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(
                                20.0,
                              ),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    defaultFormField(
                                      label: 'Task Title',
                                      prefix: Icons.title,
                                      controller: titleController,
                                      type: TextInputType.text,
                                      validate: (String? value) {
                                        if (value == null) return '';
                                        if (value.isEmpty) {
                                          return 'title must not be empty';
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    defaultFormField(
                                      controller: timeController,
                                      type: TextInputType.datetime,
                                      onTap: () {
                                        showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        ).then((value) {
                                          timeController.text =
                                              value!.format(context).toString();
                                          print(value.format(context));
                                        });
                                      },
                                      validate: (String? value) {
                                        if (value == null) return '';
                                        if (value.isEmpty) {
                                          return 'time must not be empty';
                                        }
                                      },
                                      label: 'Task Time',
                                      prefix: Icons.watch_later_outlined,
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    defaultFormField(
                                      controller: dateController,
                                      type: TextInputType.datetime,
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.parse('2025-05-03'),
                                        ).then((value) {
                                          dateController.text =
                                              DateFormat.yMMMd().format(value!);
                                        });
                                      },
                                      validate: (String? value) {
                                        if (value == null) return '';
                                        if (value.isEmpty) {
                                          return 'date must not be empty';
                                        }
                                      },
                                      label: 'Task Date',
                                      prefix: Icons.calendar_today,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                        cubit.changeBottomSheetState(
                          isShow: false,
                          icon: Icons.edit,
                        );
                      });

                  cubit.changeBottomSheetState(
                    isShow: true,
                    icon: Icons.add,
                  );
                }
              },
              child: Icon(
                cubit.fabIcon,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.menu,
                  ),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check_circle_outline,
                  ),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.archive_outlined,
                  ),
                  label: 'Archived',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
