
import 'package:flutter/material.dart';
import 'data/game_content.dart';
import 'services/game_state.dart';
import 'widgets/kibi_pet.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state=GameState();
  await state.load();
  runApp(KibiApp(state:state));
}

class KibiApp extends StatelessWidget {
  final GameState state;
  const KibiApp({super.key,required this.state});
  @override Widget build(BuildContext context)=>AnimatedBuilder(
    animation:state,
    builder:(_,__)=>MaterialApp(
      debugShowCheckedModeBanner:false,
      title:'Киби',
      theme:ThemeData(
        useMaterial3:true,
        colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xFF7C6FD0),brightness:Brightness.light),
        scaffoldBackgroundColor:const Color(0xFFF8F6FC),
        fontFamily:'sans',
        textTheme:const TextTheme(bodyLarge:TextStyle(fontSize:16),bodyMedium:TextStyle(fontSize:16)),
        filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(minimumSize:const Size(48,52),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)))),
        cardTheme:CardThemeData(elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(24)),color:Colors.white),
      ),
      home: state.hasProfile?HomeScreen(state:state):WelcomeScreen(state:state),
    )
  );
}

class WelcomeScreen extends StatefulWidget {
  final GameState state; const WelcomeScreen({super.key,required this.state});
  @override State<WelcomeScreen> createState()=>_WelcomeState();
}
class _WelcomeState extends State<WelcomeScreen> {
  int page=0;
  @override Widget build(BuildContext context)=>KibiBackground(child:SafeArea(child:Padding(
    padding:const EdgeInsets.all(24),
    child:Column(children:[
      const Spacer(),
      KibiPet(style:0,stage:1,mood:90,size:220),
      const SizedBox(height:16),
      Text(page==0?'Киби':page==1?'Три простых решения':'Учись на выборе',style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w800)),
      const SizedBox(height:12),
      Text(page==0?'Игра о деньгах, целях и заботе о питомце.':page==1?'Нужное • Желаемое • Накопления':'Планируй, пробуй, исправляй ошибки без штрафов.',textAlign:TextAlign.center,style:const TextStyle(fontSize:18,height:1.4)),
      const Spacer(),
      Row(children:[
        if(page>0) Expanded(child:OutlinedButton(onPressed:()=>setState(()=>page--),child:const Text('Назад'))),
        if(page>0) const SizedBox(width:12),
        Expanded(child:FilledButton(onPressed:(){
          if(page<2){setState(()=>page++);}else{Navigator.push(context,MaterialPageRoute(builder:(_)=>ProfileScreen(state:widget.state)));}
        },child:Text(page<2?'Дальше':'Создать Киби'))),
      ]),
      const SizedBox(height:10),
      TextButton(onPressed:()async{await widget.state.reset(demo:true);},child:const Text('Демонстрационный режим'))
    ])
  )));
}

class ProfileScreen extends StatefulWidget {
  final GameState state; const ProfileScreen({super.key,required this.state});
  @override State<ProfileScreen> createState()=>_ProfileState();
}
class _ProfileState extends State<ProfileScreen>{
  final player=TextEditingController(), pet=TextEditingController(text:'Киби'); int style=0;
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Создай питомца')),body:ListView(padding:const EdgeInsets.all(20),children:[
    Center(child:KibiPet(style:style,stage:1,mood:90,size:190)),
    const SizedBox(height:8),
    const Text('Выбери внешний вид',textAlign:TextAlign.center,style:TextStyle(fontSize:18,fontWeight:FontWeight.w700)),
    const SizedBox(height:12),
    Wrap(spacing:8,runSpacing:8,alignment:WrapAlignment.center,children:List.generate(9,(i)=>InkWell(
      onTap:()=>setState(()=>style=i),
      borderRadius:BorderRadius.circular(14),
      child:Container(width:52,height:52,decoration:BoxDecoration(border:Border.all(color:style==i?Theme.of(context).colorScheme.primary:Colors.transparent,width:3),borderRadius:BorderRadius.circular(14)),child:KibiPet(style:i,stage:1,mood:90,size:48))
    ))),
    const SizedBox(height:20),
    TextField(controller:player,decoration:const InputDecoration(labelText:'Твоё игровое имя',border:OutlineInputBorder())),
    const SizedBox(height:12),
    TextField(controller:pet,decoration:const InputDecoration(labelText:'Имя питомца',border:OutlineInputBorder())),
    const SizedBox(height:20),
    FilledButton(onPressed:()async{await widget.state.createProfile(player.text,pet.text,style);if(context.mounted)Navigator.popUntil(context,(r)=>r.isFirst);},child:const Text('Начать игру'))
  ]));
}

class HomeScreen extends StatefulWidget {
  final GameState state; const HomeScreen({super.key,required this.state});
  @override State<HomeScreen> createState()=>_HomeState();
}
class _HomeState extends State<HomeScreen>{
  int tab=0;
  @override Widget build(BuildContext context){
    final pages=[Dashboard(state:widget.state),TasksScreen(state:widget.state),BudgetScreen(state:widget.state),GoalsScreen(state:widget.state),ProgressScreen(state:widget.state)];
    return Scaffold(
      body:pages[tab],
      bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const[
        NavigationDestination(icon:Icon(Icons.home_rounded),label:'Главная'),
        NavigationDestination(icon:Icon(Icons.task_alt_rounded),label:'Задания'),
        NavigationDestination(icon:Icon(Icons.pie_chart_rounded),label:'Бюджет'),
        NavigationDestination(icon:Icon(Icons.savings_rounded),label:'Цель'),
        NavigationDestination(icon:Icon(Icons.emoji_events_rounded),label:'Прогресс'),
      ])
    );
  }
}

class Dashboard extends StatelessWidget {
  final GameState state; const Dashboard({super.key,required this.state});
  @override Widget build(BuildContext context){
    final goal=goals.firstWhere((g)=>g.id==state.goalId);
    final active=tasks.firstWhere((t)=>!state.completedTasks.contains(t.id),orElse:()=>tasks.last);
    return KibiBackground(garden:state.savings>=300,child:SafeArea(child:ListView(padding:const EdgeInsets.fromLTRB(18,12,18,24),children:[
      Row(children:[
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('Привет, ${state.playerName}!',style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800)),
          Text('Период ${state.period} · ${state.demoMode?'демо':'обычная игра'}')
        ])),
        IconButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>SettingsScreen(state:state))),icon:const Icon(Icons.settings_rounded),tooltip:'Настройки')
      ]),
      const SizedBox(height:8),
      Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
          _Pill(Icons.monetization_on_rounded,'${state.balance}','Баланс'),
          _Pill(Icons.savings_rounded,'${state.savings}','Накоплено'),
          _Pill(Icons.workspace_premium_rounded,'${state.badges}/15','Значки'),
        ]),
        KibiPet(style:state.petStyle,stage:state.stage,mood:state.mood,size:210),
        Text(state.petName,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800)),
        Text(state.mood>=70?'Киби в хорошем настроении':state.mood>=50?'Киби спокоен':'Киби немного грустит — можно всё исправить',textAlign:TextAlign.center),
        const SizedBox(height:12),
        Row(children:[Expanded(child:_meter('Настроение',state.mood,Icons.sentiment_satisfied_rounded)),const SizedBox(width:8),Expanded(child:_meter('Сытость',state.satiety,Icons.restaurant_rounded)),const SizedBox(width:8),Expanded(child:_meter('Уход',state.care,Icons.favorite_rounded))])
      ]))),
      const SizedBox(height:12),
      _sectionTitle('Текущая цель',Icons.flag_rounded),
      Card(child:ListTile(minVerticalPadding:14,leading:CircleAvatar(child:Icon(goal.icon)),title:Text(goal.title,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        const SizedBox(height:8),LinearProgressIndicator(value:(state.savings/goal.cost).clamp(0,1)),const SizedBox(height:6),Text('${state.savings} из ${goal.cost} монет')
      ]))),
      const SizedBox(height:12),
      _sectionTitle('Активное задание',Icons.bolt_rounded),
      Card(child:ListTile(minVerticalPadding:14,leading:CircleAvatar(child:Icon(active.icon)),title:Text(active.title,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${active.type} · награда +${active.reward}'),trailing:const Icon(Icons.chevron_right_rounded),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>TaskPlayScreen(state:state,task:active))))),
      const SizedBox(height:12),
      Row(children:[
        Expanded(child:_quick(context,Icons.shopping_bag_rounded,'Покупки',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ShopScreen(state:state))))),
        const SizedBox(width:10),
        Expanded(child:_quick(context,Icons.menu_book_rounded,'История денег',()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>HistoryQuiz(state:state))))),
        const SizedBox(width:10),
        Expanded(child:_quick(context,Icons.help_outline_rounded,'Подсказка',()=>_help(context))),
      ])
    ])));
  }
  Widget _meter(String name,int value,IconData icon)=>Column(children:[Icon(icon,size:20),const SizedBox(height:4),LinearProgressIndicator(value:value/100),const SizedBox(height:4),Text(name,style:const TextStyle(fontSize:12))]);
  Widget _quick(BuildContext c,IconData i,String t,VoidCallback f)=>InkWell(onTap:f,borderRadius:BorderRadius.circular(20),child:Container(height:86,padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(i),const SizedBox(height:6),Text(t,textAlign:TextAlign.center,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w600))])));
  void _help(BuildContext c)=>showModalBottomSheet(context:c,showDragHandle:true,builder:(_)=>const Padding(padding:EdgeInsets.all(24),child:Text('Три решения Киби:\\n\\n1. Нужное — то, без чего питомцу трудно.\\n2. Желаемое — приятное, но его можно отложить.\\n3. Накопления — монеты для будущей цели.',style:TextStyle(fontSize:18,height:1.5))));
}

class _Pill extends StatelessWidget{
  final IconData icon;final String value,label;const _Pill(this.icon,this.value,this.label);
  @override Widget build(BuildContext context)=>Column(children:[Icon(icon),Text(value,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800)),Text(label,style:const TextStyle(fontSize:12))]);
}
Widget _sectionTitle(String t,IconData i)=>Row(children:[Icon(i,size:20),const SizedBox(width:7),Text(t,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w800))]);

class TasksScreen extends StatelessWidget{
  final GameState state;const TasksScreen({super.key,required this.state});
  @override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.all(18),children:[
    const Text('Задания',style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),
    const Text('15 уровней: заработок, траты, накопления и безопасность.'),
    const SizedBox(height:14),
    ...tasks.map((t){
      final done=state.completedTasks.contains(t.id);
      final unlocked=state.demoMode||t.id<=state.completedTasks.length+1;
      return Card(child:ListTile(enabled:unlocked,minVerticalPadding:12,leading:CircleAvatar(child:done?const Icon(Icons.check_rounded):Text('${t.id}')),title:Text(t.title,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${t.type} · +${t.reward} монет'),trailing:Icon(unlocked?Icons.chevron_right_rounded:Icons.lock_rounded),onTap:unlocked?()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>TaskPlayScreen(state:state,task:t))):null));
    })
  ]));
}

class TaskPlayScreen extends StatefulWidget{
  final GameState state;final TaskData task;const TaskPlayScreen({super.key,required this.state,required this.task});
  @override State<TaskPlayScreen> createState()=>_TaskPlayState();
}
class _TaskPlayState extends State<TaskPlayScreen>{
  int taps=0; int exam=0; int q=0; bool finished=false;
  List<String> get options{
    switch(widget.task.id){
      case 2:return ['Быстрая: +5','Долгая: +15'];
      case 4:return ['Ручка + тетрадь + ластик','Игрушка + наклейки','Только пенал'];
      case 5:return ['Сок за 15','Сок за 10'];
      case 6:return ['5 монет','10 монет','15 монет'];
      case 7:return ['Корм для Киби','Новая игрушка'];
      case 8:return ['250','350','450'];
      case 9:return ['Снять 50','Подождать ради цели'];
      case 10:return ['20 / 15 / 15','50 / 0 / 0','0 / 0 / 50'];
      case 11:return ['Доп. уровень +20','Отдохнуть'];
      case 12:return ['Отказать и позвать взрослого','Сказать код'];
      case 13:return ['Удалить сообщение','Открыть ссылку'];
      case 15:return ['Откладывать понемногу регулярно','Потратить всё сейчас','Ждать случайного подарка'];
      default:return ['Готово'];
    }
  }
  int get correct{
    switch(widget.task.id){case 2:return 1;case 4:return 0;case 5:return 1;case 6:return 1;case 7:return 0;case 8:return 1;case 9:return 1;case 10:return 0;case 11:return 0;case 12:return 0;case 13:return 0;case 15:return 0;default:return 0;}
  }
  Future<void> choose(int i)async{
    if(i==correct){await finish();}else{await widget.state.wrongChoice();if(mounted)_msg('Пока не так','${taskExplanations[widget.task.id-1]} Попробуй ещё раз.');}
  }
  Future<void> finish()async{
    if(finished)return;finished=true;
    await widget.state.completeTask(widget.task.id,widget.task.reward);
    if(mounted)_msg('Получилось!','${taskExplanations[widget.task.id-1]}\\n\\n+${widget.task.reward} монет · значок «${badgeNames[widget.task.id-1]}»',pop:true);
  }
  void _msg(String title,String text,{bool pop=false})=>showDialog(context:context,builder:(c)=>AlertDialog(title:Text(title),content:Text(text),actions:[FilledButton(onPressed:(){Navigator.pop(c);if(pop)Navigator.pop(context);},child:const Text('Понятно'))]));
  @override Widget build(BuildContext context){
    final t=widget.task;
    if(t.id==1)return _watering();
    if(t.id==3)return _savingWeek();
    if(t.id==14)return _exam();
    return Scaffold(appBar:AppBar(title:Text('Уровень ${t.id}')),body:ListView(padding:const EdgeInsets.all(20),children:[
      Icon(t.icon,size:72,color:Theme.of(context).colorScheme.primary),
      const SizedBox(height:16),Text(t.title,textAlign:TextAlign.center,style:const TextStyle(fontSize:26,fontWeight:FontWeight.w800)),
      const SizedBox(height:8),Text(t.description,textAlign:TextAlign.center,style:const TextStyle(fontSize:18,height:1.4)),
      const SizedBox(height:24),...options.asMap().entries.map((e)=>Padding(padding:const EdgeInsets.only(bottom:10),child:FilledButton.tonal(onPressed:()=>choose(e.key),child:Padding(padding:const EdgeInsets.symmetric(vertical:8),child:Text(e.value,textAlign:TextAlign.center))))),
      const SizedBox(height:12),Text('Награда: +${t.reward} монет',textAlign:TextAlign.center)
    ]));
  }
  Widget _watering()=>Scaffold(appBar:AppBar(title:const Text('Полей цветы')),body:Padding(padding:const EdgeInsets.all(24),child:Column(children:[
    const Text('Нажми на каждый сухой цветок',style:TextStyle(fontSize:20,fontWeight:FontWeight.w700)),const Spacer(),
    Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:List.generate(3,(i)=>IconButton(iconSize:70,onPressed:taps>i?null:()async{setState(()=>taps++);if(taps>=3)await finish();},icon:Icon(taps>i?Icons.local_florist_rounded:Icons.local_florist_outlined,color:taps>i?Colors.green:Colors.brown)))),
    const Spacer(),Text('$taps / 3',style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800))
  ])));
  Widget _savingWeek()=>Scaffold(appBar:AppBar(title:const Text('Копилка за неделю')),body:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const Icon(Icons.savings_rounded,size:110),Text('$taps / 7',style:const TextStyle(fontSize:32,fontWeight:FontWeight.w800)),const SizedBox(height:16),
    FilledButton(onPressed:taps>=7?null:()async{if(widget.state.balance<5){_msg('Не хватает монет','Сначала выполни другое задание.');return;}await widget.state.deposit(5);setState(()=>taps++);if(taps>=7)await finish();},child:const Text('Отложить 5 монет'))
  ])));
  Widget _exam(){
    const qs=[['Что такое накопления?','Монеты для будущей цели','Монеты, которые надо сразу потратить'],['500 − 150 = ?','350','250'],['Что важнее сначала?','Нужная покупка','Любая игрушка'],['Если снять накопления?','Цель станет дальше','Цель станет дешевле'],['Странная ссылка обещает монеты. Что делать?','Не открывать','Ввести пароль']];
    if(q>=5){if(!finished){Future.microtask(finish);}return const Scaffold(body:Center(child:CircularProgressIndicator()));}
    return Scaffold(appBar:AppBar(title:Text('Экзамен ${q+1}/5')),body:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      Text(qs[q][0],textAlign:TextAlign.center,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w800)),const SizedBox(height:24),
      FilledButton.tonal(onPressed:(){exam++;setState(()=>q++);},child:Text(qs[q][1])),const SizedBox(height:12),
      FilledButton.tonal(onPressed:()async{await widget.state.wrongChoice();_msg('Подумай ещё','${taskExplanations[13]}');},child:Text(qs[q][2]))
    ])));
  }
}

class BudgetScreen extends StatefulWidget{final GameState state;const BudgetScreen({super.key,required this.state});@override State<BudgetScreen> createState()=>_BudgetState();}
class _BudgetState extends State<BudgetScreen>{
  late int need=widget.state.planNeed,want=widget.state.planWant,save=widget.state.planSave;
  @override Widget build(BuildContext context){
    final total=need+want+save, ok=total<=widget.state.balance;
    return SafeArea(child:ListView(padding:const EdgeInsets.all(18),children:[
      const Text('План бюджета',style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),Text('Доступно: ${widget.state.balance} монет. Распредели сумму до начала периода.'),const SizedBox(height:16),
      _slider('Нужное',need,Icons.shopping_basket_rounded,(v)=>setState(()=>need=v)),
      _slider('Желаемое',want,Icons.toys_rounded,(v)=>setState(()=>want=v)),
      _slider('Накопления',save,Icons.savings_rounded,(v)=>setState(()=>save=v)),
      Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Распределено'),Text('$total',style:const TextStyle(fontWeight:FontWeight.w800))]),
        Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('Остаток'),Text('${widget.state.balance-total}',style:TextStyle(fontWeight:FontWeight.w800,color:ok?Colors.green:Colors.red))]),
      ]))),
      const SizedBox(height:12),
      FilledButton(onPressed:ok?()async{await widget.state.setPlan(need,want,save);if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('План сохранён. Теперь сравним его с фактом.')));}:null,child:Text(widget.state.planConfirmed?'Обновить план':'Подтвердить план')),
      const SizedBox(height:20),
      _sectionTitle('План и факт',Icons.bar_chart_rounded),const SizedBox(height:8),
      _compare('Нужное',widget.state.planNeed,widget.state.spentNeed),
      _compare('Желаемое',widget.state.planWant,widget.state.spentWant),
      _compare('Накопления',widget.state.planSave,widget.state.savedThisPeriod),
      const SizedBox(height:16),
      FilledButton.tonal(onPressed:()async{await widget.state.nextPeriod();},child:const Text('Завершить период и получить +120'))
    ]));
  }
  Widget _slider(String t,int v,IconData i,ValueChanged<int> f)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[Row(children:[Icon(i),const SizedBox(width:8),Expanded(child:Text(t,style:const TextStyle(fontWeight:FontWeight.w700))),Text('$v')]),Slider(value:v.toDouble(),min:0,max:300,divisions:30,onChanged:(x)=>f(x.round()))])));
  Widget _compare(String t,int p,int f)=>Padding(padding:const EdgeInsets.symmetric(vertical:7),child:Row(children:[Expanded(child:Text(t)),Text('план $p  •  факт $f')]));
}

class GoalsScreen extends StatelessWidget{
  final GameState state;const GoalsScreen({super.key,required this.state});
  @override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.all(18),children:[
    const Text('Накопления',style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),Text('В копилке ${state.savings} монет · на руках ${state.balance}'),const SizedBox(height:14),
    ...goals.map((g)=>Card(child:ListTile(minVerticalPadding:14,leading:CircleAvatar(child:Icon(g.icon)),title:Text(g.title,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${g.cost} монет · ${g.description}'),trailing:state.goalId==g.id?const Icon(Icons.check_circle_rounded):null,onTap:()async{state.goalId=g.id;await state.save();state.notifyListeners();}))),
    const SizedBox(height:12),
    FilledButton(onPressed:()=>_deposit(context),child:const Text('Пополнить накопления'))
  ]));
  void _deposit(BuildContext context){
    int amount=20;
    showDialog(context:context,builder:(c)=>StatefulBuilder(builder:(c,set)=>AlertDialog(title:const Text('Отложить монеты'),content:Column(mainAxisSize:MainAxisSize.min,children:[Text('$amount монет',style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800)),Slider(value:amount.toDouble(),min:5,max:100,divisions:19,onChanged:(v)=>set(()=>amount=v.round()))]),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Отмена')),FilledButton(onPressed:()async{final ok=await state.deposit(amount);if(c.mounted)Navigator.pop(c);if(context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(ok?'Отложено $amount монет':'Не хватает монет')));},child:const Text('Отложить'))])));
  }
}

class ShopScreen extends StatelessWidget{
  final GameState state;const ShopScreen({super.key,required this.state});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Покупки')),body:ListView(padding:const EdgeInsets.all(18),children:[
    Text('Баланс: ${state.balance} монет',style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:12),
    ...shopItems.map((x)=>Card(child:ListTile(minVerticalPadding:14,leading:CircleAvatar(child:Icon(x.icon)),title:Text(x.title,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${x.category} · ${x.effect}'),trailing:Text('${x.price} 🪙'),onTap:()=>_confirm(context,x))))
  ]));
  void _confirm(BuildContext context,ShopItem x)=>showDialog(context:context,builder:(c)=>AlertDialog(title:Text(x.title),content:Text('Цена: ${x.price} монет\\nКатегория: ${x.category}\\nВлияние: ${x.effect}'),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Не сейчас')),FilledButton(onPressed:()async{final ok=await state.buy(x.id,x.title,x.category,x.price);if(c.mounted)Navigator.pop(c);if(context.mounted)showDialog(context:context,builder:(d)=>AlertDialog(title:Text(ok?'Покупка готова':'Монет не хватает'),content:Text(ok?'Баланс уменьшился на ${x.price}. ${x.effect}.':'Не хватает ${x.price-state.balance} монет. Выполни задание, отложи покупку или выбери более дешёвую.'),actions:[FilledButton(onPressed:()=>Navigator.pop(d),child:const Text('Понятно'))]));},child:const Text('Купить'))]));
}

class ProgressScreen extends StatelessWidget{
  final GameState state;const ProgressScreen({super.key,required this.state});
  @override Widget build(BuildContext context)=>SafeArea(child:ListView(padding:const EdgeInsets.all(18),children:[
    const Text('Прогресс Киби',style:TextStyle(fontSize:28,fontWeight:FontWeight.w800)),
    Text('Стадия ${state.stage}/3 · ${state.stage==1?'Малыш Киби':state.stage==2?'Подросток Киби':'Взрослый Киби'}'),const SizedBox(height:10),
    Center(child:KibiPet(style:state.petStyle,stage:state.stage,mood:state.mood,size:190)),
    Card(child:Padding(padding:const EdgeInsets.all(16),child:Text(state.stage==1?'Собери 7 значков, чтобы Киби подрос.':state.stage==2?'Собери все 15 значков — Киби станет взрослым.':'Все стадии развития открыты!',textAlign:TextAlign.center))),
    const SizedBox(height:12),_sectionTitle('Значки',Icons.workspace_premium_rounded),const SizedBox(height:8),
    GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),itemCount:15,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:8,mainAxisSpacing:8,childAspectRatio:.88),itemBuilder:(_,i){final got=state.completedTasks.contains(i+1);return Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:got?const Color(0xFFF1EDFF):Colors.white,borderRadius:BorderRadius.circular(18)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(got?Icons.workspace_premium_rounded:Icons.lock_outline_rounded,size:30),const SizedBox(height:5),Text(badgeNames[i],textAlign:TextAlign.center,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w600))]));}),
    const SizedBox(height:16),_sectionTitle('Последние события',Icons.history_rounded),...state.events.take(8).map((e)=>ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.circle,size:9),title:Text(e)))
  ]));
}

class HistoryQuiz extends StatefulWidget{final GameState state;const HistoryQuiz({super.key,required this.state});@override State<HistoryQuiz> createState()=>_HistoryQuizState();}
class _HistoryQuizState extends State<HistoryQuiz>{int q=0,score=0;bool answered=false;
  @override Widget build(BuildContext context){final item=historyQuestions[q];return Scaffold(appBar:AppBar(title:Text('История денег ${q+1}/${historyQuestions.length}')),body:Padding(padding:const EdgeInsets.all(22),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
    const Icon(Icons.menu_book_rounded,size:70),const SizedBox(height:16),Text(item[0],textAlign:TextAlign.center,style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800)),const SizedBox(height:20),
    ...item.skip(1).map((a)=>Padding(padding:const EdgeInsets.only(bottom:10),child:FilledButton.tonal(onPressed:answered?null:()async{final ok=a==item[1];setState(()=>answered=true);if(ok){score++;widget.state.balance+=10;await widget.state.save();widget.state.notifyListeners();}if(context.mounted)showDialog(context:context,builder:(c)=>AlertDialog(title:Text(ok?'Верно! +10':'Попробуй запомнить'),content:Text(ok?'Отлично. Ты узнал ещё один факт о деньгах.':'Правильный ответ: ${item[1]}'),actions:[FilledButton(onPressed:(){Navigator.pop(c);if(q<historyQuestions.length-1){setState((){q++;answered=false;});}else{Navigator.pop(context);}},child:Text(q<historyQuestions.length-1?'Дальше':'Готово'))]));},child:Text(a)))) 
  ])));}}

class SettingsScreen extends StatelessWidget{
  final GameState state;const SettingsScreen({super.key,required this.state});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Настройки')),body:ListView(padding:const EdgeInsets.all(18),children:[
    SwitchListTile(title:const Text('Звуки'),subtitle:const Text('Можно отключить'),value:state.sound,onChanged:(v)async{state.sound=v;await state.save();state.notifyListeners();}),
    SwitchListTile(title:const Text('Анимации'),subtitle:const Text('Можно отключить'),value:state.animations,onChanged:(v)async{state.animations=v;await state.save();state.notifyListeners();}),
    ListTile(leading:const Icon(Icons.admin_panel_settings_rounded),title:const Text('Раздел для взрослого'),subtitle:const Text('Нужно решить простой пример'),onTap:()=>_adultGate(context)),
    ListTile(leading:const Icon(Icons.refresh_rounded),title:const Text('Сбросить демо-профиль'),onTap:()=>_reset(context,true)),
    ListTile(leading:const Icon(Icons.delete_outline_rounded),title:const Text('Удалить локальный профиль'),onTap:()=>_reset(context,false)),
  ]));
  void _adultGate(BuildContext context){final c=TextEditingController();showDialog(context:context,builder:(d)=>AlertDialog(title:const Text('Для взрослого'),content:TextField(controller:c,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Сколько будет 7 × 8?')),actions:[FilledButton(onPressed:(){if(c.text=='56'){Navigator.pop(d);Navigator.push(context,MaterialPageRoute(builder:(_)=>AdultScreen(state:state)));}},child:const Text('Открыть'))]));}
  void _reset(BuildContext context,bool demo)=>showDialog(context:context,builder:(d)=>AlertDialog(title:Text(demo?'Сбросить демо?':'Удалить профиль?'),content:const Text('Это заметно изменит прогресс. Действие нужно подтвердить.'),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Отмена')),FilledButton(onPressed:()async{await state.reset(demo:demo);if(d.mounted)Navigator.pop(d);if(context.mounted)Navigator.popUntil(context,(r)=>r.isFirst);},child:const Text('Подтвердить'))]));
}

class AdultScreen extends StatelessWidget{
  final GameState state;const AdultScreen({super.key,required this.state});
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Для взрослого')),body:ListView(padding:const EdgeInsets.all(20),children:[
    const Text('Цель приложения',style:TextStyle(fontSize:22,fontWeight:FontWeight.w800)),const Text('Помочь ребёнку тренировать планирование бюджета, различать нужное и желаемое, формировать накопления и безопасно относиться к цифровым платежам.'),
    const SizedBox(height:18),Text('Пройдено заданий: ${state.badges} из 15',style:const TextStyle(fontSize:18,fontWeight:FontWeight.w700)),Text('Игровых периодов: ${state.period}'),Text('Накоплено: ${state.savings} монет'),
    const SizedBox(height:18),const Text('Оценок ребёнку нет: приложение показывает только общий прогресс и изученные темы.')
  ]));
}
