import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';
import 'custom_widgets_&_utility.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({super.key});

  @override
  ItemListState createState() => ItemListState();
}

class ItemListState extends State<ItemPage> {
  static const int pageSize = 10;
  final PagingController<int, Widget> pageCont =
      PagingController(firstPageKey: 0);

  String med = "";
  String manufacturer = "";
  String country = "";
  String ta = "";
  late List<StockItem> items = [];

  @override
  void initState() {
    super.initState();
    pageCont.addPageRequestListener((pageKey) {
      loadPage(pageKey);
    });
    fetchItem().then((meds) {
      items = meds;
      pageCont.refresh();
    });
  }

  void loadPage(int pageKey) async {
    final cursor = items.isEmpty ? "000000000000000000000000" : items.last.id;

    try {
      items = await fetchItem(cursor: cursor); // pass cursor for the next page
      final isLastPage = items.length < pageSize;

      if (isLastPage) {
        pageCont
            .appendLastPage(items.map((med) => ItemView(item: med)).toList());
      } else {
        pageCont.appendPage(
            items.map((med) => ItemView(item: med)).toList(), pageKey + 1);
      }
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
      items = [];
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

  Future<List<StockItem>> fetchItem(
      {String cursor = "000000000000000000000000",
      int limit = pageSize}) async {
    String route =
        "$serverAddress/Stock?med=$med&manufacturer=$manufacturer&country=$country&ta=$ta&cursor=$cursor&limit=$limit";

    try {
      final apiCaller = context.read<APICaller>();
      final response = await apiCaller.get(route);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = response.data;
        return jsonResponse
            .map((jsonObject) => StockItem.fromJson(jsonObject))
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
