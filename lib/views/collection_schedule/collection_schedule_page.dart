import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/collection_schedule_view_model.dart';

class CollectionSchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CollectionScheduleViewModel()..fetchCollectionSchedule(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Collection Schedule'),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<CollectionScheduleViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (viewModel.isError || viewModel.schedules.isEmpty) {
                return Center(child: Text('Failed to load schedule or no data available.'));
              }

              return ListView.builder(
                itemCount: viewModel.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = viewModel.schedules[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Collection',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      SizedBox(height: 8),
                      Text('Location: ${schedule.location}'),
                      Text('Date: ${schedule.collectionDate.toString()}'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Logic to view full schedule
                        },
                        child: Text('View Full Schedule'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Reminders',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      SizedBox(height: 8),
                      Text('Get notified about your upcoming waste collection dates.'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          viewModel.sendReminders();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reminders sent!')),
                          );
                        },
                        child: Text('Send Reminders'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
