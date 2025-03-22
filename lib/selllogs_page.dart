import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mypharmacy/log_card.dart';
import 'package:mypharmacy/user_state.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';
import 'custom_widgets_&_utility.dart';

class SellLogsPage extends StatefulWidget {
  const SellLogsPage({super.key});

  @override
  SellLogsListState createState() => SellLogsListState();
}

class SellLogsListState extends State<SellLogsPage> {
  static const int pageSize = 10;
  String cursor = "2200-01-01";
  final PagingController<int, LogEntry> pageCont =
      PagingController(firstPageKey: 0);

  String from = "";
  String to = "";

  @override
  void initState() {
    super.initState();
    pageCont.addPageRequestListener((pageKey) {
      loadPage(pageKey);
    });
  }

  void loadPage(int pageKey) async {
    try {
      final userState = context.read<UserState>();
      final pharmaIndex = userState.pharmaIndex;

      List<LogEntry> items = await fetchLogs(pharmaIndex: pharmaIndex);
      final isLastPage = items.length < pageSize;

      if (isLastPage) {
        pageCont.appendLastPage(items);
      } else {
        cursor = items.last.date.split("+").first;
        pageCont.appendPage(items, pageKey + 1);
      }
    } catch (e) {
      pageCont.error = e;
    }
  }

  void update(String newFrom, String newTo) {
    setState(() {
      from = newFrom;
      to = newTo;
      cursor = "2200-01-01";
    });
    pageCont.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sells Logs"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Stack(
        children: [
          PagedListView<int, LogEntry>(
            pagingController: pageCont,
            builderDelegate: PagedChildBuilderDelegate<LogEntry>(
              itemBuilder: (context, item, index) =>
                  LogEntryCard(logEntry: item),
            ),
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                showDateFilterDialog(context, from, to, update);
              },
              tooltip: "Filter Logs by Date",
              heroTag: null,
              child: const Icon(Icons.date_range),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pageCont.dispose();
    super.dispose();
  }

  Future<List<LogEntry>> fetchLogs({required int pharmaIndex}) async {
    List<String> queryParams = [
      "pharma_index=$pharmaIndex",
      if (from.isNotEmpty) "from_date=$from",
      if (to.isNotEmpty) "to_date=$to",
      "cursor=$cursor",
      "limit=$pageSize"
    ];

    String route = "$serverAddress/sell_logs?${queryParams.join('&')}";
    try {
      final apiCaller = context.read<APICaller>();
      final response = await apiCaller.get(route);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        return jsonResponse
            .map((jsonObject) => LogEntry.fromJson(jsonObject))
            .toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error fetching logs: $e');
    }
  }
}
