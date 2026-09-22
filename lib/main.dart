import 'package:flutter/material.dart';

void main() {
  runApp(const CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  const CalorieTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حاسبة السعرات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.imageUrl,
  });
}

class LoggedFood {
  final FoodItem item;
  int quantity;

  LoggedFood({required this.item, this.quantity = 1});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FoodItem> savedFoods = [
    FoodItem(
      id: '1',
      name: 'خبز بروتين',
      calories: 143,
      protein: 14,
      carbs: 19,
      fat: 2,
    ),
    FoodItem(
      id: '2',
      name: 'معمول بروتين',
      calories: 238,
      protein: 14.5,
      carbs: 20.4,
      fat: 11.2,
    ),
  ];

  List<LoggedFood> todaysLog = [];

  double get totalCalories => todaysLog.fold(0, (sum, item) => sum + (item.item.calories * item.quantity));
  double get totalProtein => todaysLog.fold(0, (sum, item) => sum + (item.item.protein * item.quantity));
  double get totalCarbs => todaysLog.fold(0, (sum, item) => sum + (item.item.carbs * item.quantity));
  double get totalFat => todaysLog.fold(0, (sum, item) => sum + (item.item.fat * item.quantity));

  void _addNewFoodDialog() {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final protController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة صنف جديد', textAlign: TextAlign.right),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الصنف *'), textAlign: TextAlign.right),
              TextField(controller: calController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعرات (حراري) *'), textAlign: TextAlign.right),
              TextField(controller: protController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'البروتين (اختياري)'), textAlign: TextAlign.right),
              TextField(controller: carbsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الكارب (اختياري)'), textAlign: TextAlign.right),
              TextField(controller: fatController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الدهون (اختياري)'), textAlign: TextAlign.right),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && calController.text.isNotEmpty) {
                setState(() {
                  savedFoods.add(
                    FoodItem(
                      id: DateTime.now().toString(),
                      name: nameController.text,
                      calories: double.tryParse(calController.text) ?? 0,
                      protein: double.tryParse(protController.text) ?? 0,
                      carbs: double.tryParse(carbsController.text) ?? 0,
                      fat: double.tryParse(fatController.text) ?? 0,
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _addFoodToLog(FoodItem food) {
    setState(() {
      int index = todaysLog.indexWhere((element) => element.item.id == food.id);
      if (index >= 0) {
        todaysLog[index].quantity++;
      } else {
        todaysLog.add(LoggedFood(item: food));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حاسبة السعرات والماكروز'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_a_photo),
              tooltip: 'إضافة صنف جديد',
              onPressed: _addNewFoodDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.teal.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _addNewFoodDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة صنف جديد'),
                  ),
                  Text(
                    'المجموع: ${totalCalories.toStringAsFixed(0)} سعرة',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('الأصناف السريعة (اضغط للإضافة):', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: savedFoods.length,
                itemBuilder: (ctx, i) {
                  final food = savedFoods[i];
                  return GestureDetector(
                    onTap: () => _addFoodToLog(food),
                    child: Container(
                      width: 110,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.shade200),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.fastfood, size: 36, color: Colors.teal),
                          const SizedBox(height: 5),
                          Text(food.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          Text('${food.calories.toInt()} سعرة', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('P: ${food.protein}g', style: const TextStyle(fontSize: 10, color: Colors.teal)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('سجل الوجبات اليومي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            Expanded(
              child: todaysLog.isEmpty
                  ? const Center(child: Text('لم يتم إضافة أي طعام اليوم'))
                  : ListView.builder(
                      itemCount: todaysLog.length,
                      itemBuilder: (ctx, i) {
                        final log = todaysLog[i];
                        return ListTile(
                          title: Text('${log.item.name} (x${log.quantity})'),
                          subtitle: Text('بروتين: ${(log.item.protein * log.quantity).toStringAsFixed(1)}g | كارب: ${(log.item.carbs * log.quantity).toStringAsFixed(1)}g | دهون: ${(log.item.fat * log.quantity).toStringAsFixed(1)}g'),
                          trailing: Text('${(log.item.calories * log.quantity).toInt()} سعرة', style: const TextStyle(fontWeight: FontWeight.bold)),
                          leading: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (log.quantity > 1) {
                                  log.quantity--;
                                } else {
                                  todaysLog.removeAt(i);
                                }
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _macroSummary('السعرات', '${totalCalories.toInt()}', 'سعرة'),
                  _macroSummary('البروتين', totalProtein.toStringAsFixed(1), 'جم'),
                  _macroSummary('الكارب', totalCarbs.toStringAsFixed(1), 'جم'),
                  _macroSummary('الدهون', totalFat.toStringAsFixed(1), 'جم'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroSummary(String title, String value, String unit) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text('$value $unit', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
