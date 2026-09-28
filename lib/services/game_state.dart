
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameState extends ChangeNotifier {
  String playerName = '';
  String petName = 'Киби';
  int petStyle = 0;
  int balance = 300;
  int savings = 0;
  int mood = 80;
  int satiety = 80;
  int care = 80;
  int period = 1;
  String goalId = 'home';
  int planNeed = 100, planWant = 80, planSave = 70;
  int spentNeed = 0, spentWant = 0, savedThisPeriod = 0;
  bool planConfirmed = false;
  bool demoMode = false;
  bool sound = true, animations = true;
  Set<int> completedTasks = {};
  List<String> purchases = [];
  List<String> events = [];

  int get badges => completedTasks.length;
  int get stage => badges >= 15 ? 3 : badges >= 7 ? 2 : 1;
  bool get hasProfile => playerName.trim().isNotEmpty;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('kibi_state');
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      playerName = j['playerName'] ?? '';
      petName = j['petName'] ?? 'Киби';
      petStyle = j['petStyle'] ?? 0;
      balance = j['balance'] ?? 300;
      savings = j['savings'] ?? 0;
      mood = j['mood'] ?? 80;
      satiety = j['satiety'] ?? 80;
      care = j['care'] ?? 80;
      period = j['period'] ?? 1;
      goalId = j['goalId'] ?? 'home';
      planNeed = j['planNeed'] ?? 100;
      planWant = j['planWant'] ?? 80;
      planSave = j['planSave'] ?? 70;
      spentNeed = j['spentNeed'] ?? 0;
      spentWant = j['spentWant'] ?? 0;
      savedThisPeriod = j['savedThisPeriod'] ?? 0;
      planConfirmed = j['planConfirmed'] ?? false;
      demoMode = j['demoMode'] ?? false;
      sound = j['sound'] ?? true;
      animations = j['animations'] ?? true;
      completedTasks = Set<int>.from(j['completedTasks'] ?? []);
      purchases = List<String>.from(j['purchases'] ?? []);
      events = List<String>.from(j['events'] ?? []);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('kibi_state', jsonEncode({
      'playerName': playerName, 'petName': petName, 'petStyle': petStyle,
      'balance': balance, 'savings': savings, 'mood': mood, 'satiety': satiety,
      'care': care, 'period': period, 'goalId': goalId,
      'planNeed': planNeed, 'planWant': planWant, 'planSave': planSave,
      'spentNeed': spentNeed, 'spentWant': spentWant, 'savedThisPeriod': savedThisPeriod,
      'planConfirmed': planConfirmed, 'demoMode': demoMode, 'sound': sound,
      'animations': animations, 'completedTasks': completedTasks.toList(),
      'purchases': purchases, 'events': events,
    }));
  }

  void _event(String text) {
    events.insert(0, text);
    if (events.length > 30) events.removeLast();
  }

  Future<void> createProfile(String player, String pet, int style) async {
    playerName = player.trim().isEmpty ? 'Игрок' : player.trim();
    petName = pet.trim().isEmpty ? 'Киби' : pet.trim();
    petStyle = style;
    _event('Профиль создан. Стартовый бюджет: 300 монет.');
    await save(); notifyListeners();
  }

  Future<void> setPlan(int need, int want, int saveAmount) async {
    planNeed=need; planWant=want; planSave=saveAmount; planConfirmed=true;
    _event('План бюджета подтверждён.');
    await save(); notifyListeners();
  }

  Future<bool> buy(String id, String title, String category, int price) async {
    if (balance < price) return false;
    balance -= price;
    if (category == 'Обязательное') {
      spentNeed += price; satiety = (satiety + 10).clamp(0,100); care=(care+8).clamp(0,100);
    } else {
      spentWant += price; mood=(mood+12).clamp(0,100);
    }
    purchases.insert(0, '$title · $price монет');
    _event('Покупка: $title, −$price монет.');
    await save(); notifyListeners(); return true;
  }

  Future<bool> deposit(int amount) async {
    if (amount <= 0 || balance < amount) return false;
    balance -= amount; savings += amount; savedThisPeriod += amount;
    mood=(mood+2).clamp(0,100);
    _event('В накопления отложено $amount монет.');
    await save(); notifyListeners(); return true;
  }

  Future<void> completeTask(int id, int reward) async {
    if (completedTasks.contains(id)) return;
    completedTasks.add(id); balance += reward; mood=(mood+5).clamp(0,100);
    _event('Задание №$id выполнено: +$reward монет и новый значок.');
    await save(); notifyListeners();
  }

  Future<void> wrongChoice() async {
    mood=(mood-7).clamp(35,100);
    _event('Киби немного загрустил. Ошибку можно исправить — попробуй ещё раз.');
    await save(); notifyListeners();
  }

  Future<void> nextPeriod() async {
    final needOk = spentNeed >= (planNeed * .6);
    final saveOk = savedThisPeriod >= (planSave * .6);
    final wantOk = spentWant <= planWant + 20;
    if (needOk) { satiety=(satiety+5).clamp(0,100); care=(care+5).clamp(0,100); }
    else { satiety=(satiety-8).clamp(35,100); }
    if (saveOk && wantOk) mood=(mood+8).clamp(0,100); else mood=(mood-4).clamp(35,100);
    period++;
    balance += 120;
    spentNeed=0; spentWant=0; savedThisPeriod=0; planConfirmed=false;
    _event('Начался период $period. Понятный доход: +120 монет.');
    await save(); notifyListeners();
  }

  Future<void> reset({bool demo=false}) async {
    playerName=demo?'Эксперт':'';
    petName='Киби'; petStyle=0; balance=300; savings=0; mood=80; satiety=80; care=80;
    period=1; goalId='home'; planNeed=100; planWant=80; planSave=70;
    spentNeed=0; spentWant=0; savedThisPeriod=0; planConfirmed=false;
    demoMode=demo; completedTasks={}; purchases=[]; events=[];
    if (demo) _event('Демонстрационный профиль готов.');
    await save(); notifyListeners();
  }
}
