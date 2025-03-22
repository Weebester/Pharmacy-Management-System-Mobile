import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mypharmacy/selllogs_page.dart';
import 'package:mypharmacy/user_state.dart';
import 'package:provider/provider.dart';
import 'Bill.dart';
import 'api_call_manager.dart';

class SellPage extends StatelessWidget {
  const SellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final apiCaller = context.read<APICaller>();
    final userState = Provider.of<UserState>(context);
    return Consumer<BillState>(
      builder: (context, currentBill, child) {
        return
          Stack(
              children: [
          Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Bill",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: currentBill.doc,
                      decoration: InputDecoration(
                        labelText: 'Prescriber',
                        hintText: 'Enter name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the Prescriber name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 6),
                    const Divider(),

                    Column(
                      children:
                          List.generate(currentBill.cartItems.length, (index) {
                        final item = currentBill.cartItems[index];
                        String p = "OTC";
                        if (item.pom == "Yes") {
                          p = "POM";
                        }
                        return ListTile(
                          title: Text("${item.name}($p)"),
                          subtitle: Text("Price:${item.price} IQD"),
                          onTap: () {
                            currentBill.removeItem(index);
                          },
                        );
                      }),
                    ),

                    const Divider(),
                    const SizedBox(height: 10),

                    // Total Price Calculation
                    Text(
                      "Total Price: ${currentBill.totalPrice} IQD",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            currentBill.clearBill(); // Clear cart on cancel
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            'Cancel',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              ////temp sell place holder
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirm Sale"),
                                  content:Text("press confirm to finalize sell operation"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Close"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        var result = await currentBill.sell(
                                            apiCaller, userState.pharmaIndex);
                                        bool success = result["success"];
                                        String message = result["message"];

                                        SchedulerBinding.instance
                                            .addPostFrameCallback((_) {
                                          if (success) {
                                            currentBill.clearBill();
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(content: Text("sold successfully")),
                                            );
                                          } else {
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(content: Text(message)),
                                            );
                                          }
                                        });
                                      },
                                      child: Text("Confirm"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            'Sell',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
                Positioned(
                  bottom: 20.0,
                  right: 20.0,
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellLogsPage(),
                        ),
                      );
                    },
                    tooltip: "Logs",
                    heroTag: null,
                    child: const Icon(Icons.history_edu),
                  ),
                ),
              ],
          );
      },
    );
  }
}
