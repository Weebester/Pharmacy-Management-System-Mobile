import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';
import 'custom_widgets_&_utility.dart';

class MedPage extends StatefulWidget {
  const MedPage({super.key});

  @override
  MedListState createState() => MedListState();
}

class MedListState extends State<MedPage> {
  static const int pageSize = 10;
  int cursor =0;
  final PagingController<int, Widget> pageCont =
      PagingController(firstPageKey: 0);

  String med = "";
  String manufacturer = "";
  String country = "";
  String ta = "";
  late List<Med> items;

  @override
  void initState() {
    super.initState();
    pageCont.addPageRequestListener((pageKey) {
      loadPage(pageKey);
    });
  }

  void loadPage(int pageKey) async {
    try {
      items = await fetchMed(cursor: cursor); // pass cursor for the next page
      final isLastPage = items.length < pageSize;

      if (isLastPage) {
        pageCont.appendLastPage(items.map((med) => MedView(med: med)).toList());
      } else {
        pageCont.appendPage(
            items.map((med) => MedView(med: med)).toList(), pageKey + 1);
      }
      cursor=items.last.id;
    } catch (e) {
      pageCont.error = e;
    }
  }

  void update(
      String newMed, String newManufacturer, String newCountry, String newTa) {
    setState(() {
      med = newMed;
      manufacturer = newManufacturer;
      country = newCountry;
      ta = newTa;
      cursor = 0;
    });
    pageCont.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PagedListView<int, Widget>(
          pagingController: pageCont,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) => ListTile(title: item),
          ),
        ),
        Positioned(
          bottom: 20.0,
          right: 20.0,
          child: FloatingActionButton(
            onPressed: () {
              search(context, update);
            },
            tooltip: "Search",
            child: const Icon(Icons.search),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    pageCont.dispose();
    super.dispose();
  }

  Future<List<Med>> fetchMed({int cursor = 0, int limit = pageSize}) async {
    String route =
        "$serverAddress/MedList?med=$med&manufacturer=$manufacturer&country=$country&ta=$ta&cursor=$cursor&limit=$limit";

    try {
      final apiCaller = context.read<APICaller>();
      final response = await apiCaller.get(route);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        return jsonResponse
            .map((jsonObject) => Med.fromJson(jsonObject))
            .toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}

