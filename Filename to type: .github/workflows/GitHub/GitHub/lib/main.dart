import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_helper;
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB.init();
  runApp(const XtremeApp());
}

class XtremeApp extends StatelessWidget {
  const XtremeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xtreme DSR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
          primary: const Color(0xFFD32F2F),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}class DB {
  static late Database _db;

  static Future<void> init() async {
    _db = await openDatabase(
      path_helper.join(
        await getDatabasesPath(),
        'xtreme_v3.db',
      ),
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE routes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          )
        ''');
        await db.execute('''
          CREATE TABLE outlets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            outletName TEXT NOT NULL,
            ownerName TEXT NOT NULL,
            contactNo TEXT,
            panNo TEXT,
            channel TEXT,
            outletType TEXT,
            volume TEXT,
            address TEXT,
            wsTieUp TEXT,
            display TEXT,
            dps TEXT,
            indoorBrand TEXT,
            otherBoard TEXT,
            mbq TEXT,
            routeName TEXT NOT NULL,
            photoPath TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE visits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            outletId INTEGER NOT NULL,
            visitDate TEXT NOT NULL,
            photoPath TEXT,
            s_mt250 INTEGER DEFAULT 0,
            s_mt330 INTEGER DEFAULT 0,
            s_mt330c INTEGER DEFAULT 0,
            s_xt330 INTEGER DEFAULT 0,
            s_jj200 INTEGER DEFAULT 0,
            s_jj320 INTEGER DEFAULT 0,
            s_bb250 INTEGER DEFAULT 0,
            s_bb500 INTEGER DEFAULT 0,
            s_bb1500 INTEGER DEFAULT 0,
            s_bb2500 INTEGER DEFAULT 0,
            s_bbh500 INTEGER DEFAULT 0,
            s_csd INTEGER DEFAULT 0,
            s_liquor INTEGER DEFAULT 0,
            o_mt250 INTEGER DEFAULT 0,
            o_mt330 INTEGER DEFAULT 0,
            o_mt330c INTEGER DEFAULT 0,
            o_xt330 INTEGER DEFAULT 0,
            o_jj200 INTEGER DEFAULT 0,
            o_jj320 INTEGER DEFAULT 0,
            o_bb250 INTEGER DEFAULT 0,
            o_bb500 INTEGER DEFAULT 0,
            o_bb1500 INTEGER DEFAULT 0,
            o_bb2500 INTEGER DEFAULT 0,
            o_bbh500 INTEGER DEFAULT 0,
            o_csd INTEGER DEFAULT 0,
            o_liquor INTEGER DEFAULT 0,
            ob_rb250 INTEGER DEFAULT 0,
            ob_rb330 INTEGER DEFAULT 0,
            remarks TEXT DEFAULT '',
            createdAt TEXT NOT NULL
          )
        ''');
        await db.insert('routes', {'name': 'Tulsipur'});
        await db.insert('routes', {'name': 'Ghorahi'});
        await db.insert('routes', {'name': 'Lamahi'});
      },
    );
  }

  static Future<List<String>> getRoutes() async {
    final r = await _db.query(
      'routes', orderBy: 'name ASC',
    );
    return r.map((e) => e['name'] as String).toList();
  }

  static Future<void> addRoute(String name) async {
    await _db.insert('routes', {'name': name},
      conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> deleteRoute(String name) async {
    await _db.delete('routes',
      where: 'name = ?', whereArgs: [name]);
  }

  static Future<void> updateRoute(
    String old, String neu) async {
    await _db.update('routes', {'name': neu},
      where: 'name = ?', whereArgs: [old]);
  }

  static Future<int> insertOutlet(
    Map<String, dynamic> d) async {
    return await _db.insert('outlets', d);
  }

  static Future<List<Map<String, dynamic>>>
    getOutletsByRoute(String r) async {
    return await _db.query('outlets',
      where: 'routeName = ?',
      whereArgs: [r],
      orderBy: 'outletName ASC');
  }

  static Future<List<Map<String, dynamic>>>
    getAllOutlets() async {
    return await _db.query('outlets',
      orderBy: 'outletName ASC');
  }

  static Future<void> updateOutlet(
    int id, Map<String, dynamic> d) async {
    await _db.update('outlets', d,
      where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteOutlet(int id) async {
    await _db.delete('visits',
      where: 'outletId = ?', whereArgs: [id]);
    await _db.delete('outlets',
      where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> insertVisit(
    Map<String, dynamic> d) async {
    return await _db.insert('visits', d);
  }

  static Future<List<Map<String, dynamic>>>
    getVisitsByOutlet(int id) async {
    return await _db.query('visits',
      where: 'outletId = ?',
      whereArgs: [id],
      orderBy: 'visitDate DESC');
  }

  static Future<Map<String, dynamic>?> getLastVisit(
    int id) async {
    final r = await _db.query('visits',
      where: 'outletId = ?',
      whereArgs: [id],
      orderBy: 'visitDate DESC',
      limit: 1);
    return r.isNotEmpty ? r.first : null;
  }

  static Future<List<Map<String, dynamic>>>
    getTodayVisits() async {
    final t =
      DateTime.now().toIso8601String().split('T')[0];
    return await _db.query('visits',
      where: 'visitDate = ?', whereArgs: [t]);
  }

  static Future<List<Map<String, dynamic>>>
    getVisitsByDate(String date) async {
    return await _db.query('visits',
      where: 'visitDate = ?',
      whereArgs: [date],
      orderBy: 'createdAt DESC');
  }

  static int totalCases(Map<String, dynamic> v) =>
    (v['o_mt250']??0)+(v['o_mt330']??0)+
    (v['o_mt330c']??0)+(v['o_xt330']??0)+
    (v['o_jj200']??0)+(v['o_jj320']??0)+
    (v['o_bb250']??0)+(v['o_bb500']??0)+
    (v['o_bb1500']??0)+(v['o_bb2500']??0)+
    (v['o_bbh500']??0)+(v['o_csd']??0)+
    (v['o_liquor']??0);

  static Future<Map<String,int>> getTodayStats() async {
    final visits = await getTodayVisits();
    int cases = 0; int ordered = 0;
    for (var v in visits) {
      final c = totalCases(v);
      cases += c;
      if (c > 0) ordered++;
    }
    return {
      'visits': visits.length,
      'ordered': ordered,
      'cases': cases,
    };
  }class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() =>
    _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _routes = [];
  String? _route;
  Map<String,int> _stats = {
    'visits':0,'ordered':0,'cases':0
  };
  int _outlets = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final routes = await DB.getRoutes();
    final outlets = await DB.getAllOutlets();
    final stats = await DB.getTodayStats();
    setState(() {
      _routes = routes;
      _outlets = outlets.length;
      _stats = stats;
      if (_routes.isNotEmpty) {
        _route ??= _routes.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: SingleChildScrollView(
            physics:
              const AlwaysScrollableScrollPhysics(),
            child: Column(children: [
              _header(),
              const SizedBox(height: 16),
              _stats2(),
              const SizedBox(height: 20),
              _actions(),
              const SizedBox(height: 30),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFD32F2F),
            Color(0xFFB71C1C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        20,20,20,24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt,
                color: Colors.yellow, size: 28),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment:
                CrossAxisAlignment.start,
              children: [
                Text('XTREME DSR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  )),
                Text('Agro Thai Foods Pvt. Ltd.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  )),
              ],
            ),
          ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person,
                  color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment:
                  CrossAxisAlignment.start,
                children: [
                  const Text('Sujal Gupta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )),
                  const Text(
                    'HQ: Dang  •  R.B Enterprises',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    )),
                ],
              )),
              Text(
                DateFormat('dd MMM').format(
                  DateTime.now()),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                )),
            ]),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.location_on,
                color: Color(0xFFD32F2F), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _route,
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: const Text('Select Route'),
                  items: _routes.map((r) =>
                    DropdownMenuItem(
                      value: r,
                      child: Text(r,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        )),
                    )).toList(),
                  onChanged: (v) =>
                    setState(() => _route = v),
                ),
              ),
              IconButton(
                tooltip: 'Manage Routes',
                icon: const Icon(Icons.tune,
                  color: Color(0xFFD32F2F)),
                onPressed: () async {
                  await Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                      const RouteManagerScreen()));
                  _load();
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _stats2() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16),
      child: Row(children: [
        _sc('Visits\nToday',
          '${_stats['visits']}',
          Icons.directions_walk, Colors.blue),
        const SizedBox(width: 10),
        _sc('Total\nOutlets',
          '$_outlets',
          Icons.store, Colors.green),
        const SizedBox(width: 10),
        _sc('Cases\nToday',
          '${_stats['cases']}',
          Icons.inventory_2, Colors.orange),
      ]),
    );
  }

  Widget _sc(String t, String v,
    IconData i, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: c.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0,3),
          )],
        ),
        child: Column(children: [
          Icon(i, color: c, size: 22),
          const SizedBox(height: 6),
          Text(v, style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: c,
          )),
          Text(t, style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            height: 1.2,
          ), textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            )),
          const SizedBox(height: 12),
          _bigBtn(
            icon: Icons.add_location_alt,
            label: 'Start New Visit',
            sub: 'Select outlet → Fill → WhatsApp',
            color: const Color(0xFFD32F2F),
            onTap: () async {
              if (_route == null) {
                ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(
                    content: Text(
                      'Select a route first!')));
                return;
              }
              await Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                  OutletListScreen(
                    route: _route!,
                    selectionMode: true)));
              _load();
            },
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _sb(
              Icons.add_business,
              'Add Outlet', Colors.green,
              () async {
                await Navigator.push(context,
                  MaterialPageRoute(builder: (_) =>
                    AddOutletScreen(
                      defaultRoute:
                        _route ?? 'Tulsipur')));
                _load();
              },
            )),
            const SizedBox(width: 10),
            Expanded(child: _sb(
              Icons.store,
              'All Outlets', Colors.blue,
              () => Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                  const OutletListScreen())),
            )),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _sb(
              Icons.history,
              'History', Colors.orange,
              () => Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                  const HistoryScreen())),
            )),
            const SizedBox(width: 10),
            Expanded(child: _sb(
              Icons.bar_chart,
              'Daily Summary', Colors.purple,
              () => Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                  const SummaryScreen())),
            )),
          ]),
        ],
      ),
    );
  }

  Widget _bigBtn({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Icon(icon, color: Colors.white, size: 36),
            const SizedBox(width: 14),
            Expanded(child: Column(
              crossAxisAlignment:
                CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                )),
                Text(sub, style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                )),
              ],
            )),
            const Icon(Icons.arrow_forward_ios,
              color: Colors.white70, size: 16),
          ]),
        ),
      ),
    );
  }

  Widget _sb(IconData icon, String label,
    Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius:
                  BorderRadius.circular(10),
              ),
              child: Icon(icon,
                color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            )),
          ]),
        ),
      ),
    );
  }class RouteManagerScreen extends StatefulWidget {
  const RouteManagerScreen({super.key});
  @override
  State<RouteManagerScreen> createState() =>
    _RouteManagerScreenState();
}

class _RouteManagerScreenState
  extends State<RouteManagerScreen> {
  List<String> _routes = [];
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final r = await DB.getRoutes();
    setState(() => _routes = r);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Routes'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                  labelText: 'New Route Point',
                  hintText: 'e.g. Ghorahi',
                  prefixIcon:
                    Icon(Icons.add_location),
                ),
                textCapitalization:
                  TextCapitalization.words,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(70,50)),
              onPressed: () async {
                final n = _ctrl.text.trim();
                if (n.isEmpty) return;
                await DB.addRoute(n);
                _ctrl.clear();
                _load();
              },
              child: const Text('Add'),
            ),
          ]),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
          child: Row(children: [
            Icon(Icons.info_outline,
              color: Colors.grey.shade500,
              size: 16),
            const SizedBox(width: 8),
            Text('${_routes.length} route points',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              )),
          ]),
        ),
        Expanded(
          child: _routes.isEmpty
            ? const Center(
                child: Text('No routes yet'))
            : ListView.builder(
                itemCount: _routes.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16),
                itemBuilder: (ctx, i) {
                  final r = _routes[i];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(
                          0xFFD32F2F).withOpacity(0.1),
                        child: Text('${i+1}',
                          style: const TextStyle(
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.bold,
                          )),
                      ),
                      title: Text(r,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blue),
                            onPressed: () =>
                              _edit(r),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red),
                            onPressed: () =>
                              _delete(r),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ]),
    );
  }

  void _edit(String old) {
    final c = TextEditingController(text: old);
    showDialog(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Route'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Route Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (c.text.trim().isEmpty) return;
              await DB.updateRoute(
                old, c.text.trim());
              Navigator.pop(ctx);
              _load();
            },
            child: const Text('Save')),
        ],
      ),
    );
  }

  void _delete(String name) {
    showDialog(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Route?'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red),
            onPressed: () async {
              await DB.deleteRoute(name);
              Navigator.pop(ctx);
              _load();
            },
            child: const Text('Delete')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }class AddOutletScreen extends StatefulWidget {
  final String defaultRoute;
  final Map<String, dynamic>? existing;
  const AddOutletScreen({
    super.key,
    this.defaultRoute = 'Tulsipur',
    this.existing,
  });
  @override
  State<AddOutletScreen> createState() =>
    _AddOutletScreenState();
}

class _AddOutletScreenState
  extends State<AddOutletScreen> {
  final _fk = GlobalKey<FormState>();
  List<String> _routes = [];
  String? _route;
  String _type = '';
  String _channel = '';
  String? _photo;
  bool _saving = false;

  late final TextEditingController _nameC,
    _ownerC, _contactC, _panC, _volumeC,
    _addressC, _wsC, _displayC, _dpsC,
    _indoorC, _boardC, _mbqC;

  final _types = ['Hotel','Dairy','Kirana',
    'Liquor Store','Restaurant','Grocery',
    'General Store','Wholesale','Other'];

  final _channels = ['On Trade','Off Trade',
    'Modern Trade','General Trade',
    'HORECA','CSD','Other'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameC = TextEditingController(
      text: e?['outletName']??'');
    _ownerC = TextEditingController(
      text: e?['ownerName']??'');
    _contactC = TextEditingController(
      text: e?['contactNo']??'');
    _panC = TextEditingController(
      text: e?['panNo']??'');
    _volumeC = TextEditingController(
      text: e?['volume']??'');
    _addressC = TextEditingController(
      text: e?['address']??'');
    _wsC = TextEditingController(
      text: e?['wsTieUp']??'');
    _displayC = TextEditingController(
      text: e?['display']??'');
    _dpsC = TextEditingController(
      text: e?['dps']??'');
    _indoorC = TextEditingController(
      text: e?['indoorBrand']??'');
    _boardC = TextEditingController(
      text: e?['otherBoard']??'');
    _mbqC = TextEditingController(
      text: e?['mbq']??'');
    _type = e?['outletType']??'';
    _channel = e?['channel']??'';
    _route = e?['routeName']??widget.defaultRoute;
    _photo = e?['photoPath'];
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final r = await DB.getRoutes();
    setState(() {
      _routes = r;
      if (!_routes.contains(_route) &&
        _routes.isNotEmpty) {
        _route = _routes.first;
      }
    });
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1024, imageQuality: 80);
    if (img != null) {
      setState(() => _photo = img.path);
    }
  }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _saving = true);
    final d = {
      'outletName': _nameC.text.trim(),
      'ownerName': _ownerC.text.trim(),
      'contactNo': _contactC.text.trim(),
      'panNo': _panC.text.trim(),
      'channel': _channel,
      'outletType': _type,
      'volume': _volumeC.text.trim(),
      'address': _addressC.text.trim(),
      'wsTieUp': _wsC.text.trim(),
      'display': _displayC.text.trim(),
      'dps': _dpsC.text.trim(),
      'indoorBrand': _indoorC.text.trim(),
      'otherBoard': _boardC.text.trim(),
      'mbq': _mbqC.text.trim(),
      'routeName': _route??'Tulsipur',
      'photoPath': _photo,
      'createdAt':
        DateTime.now().toIso8601String(),
    };
    if (widget.existing != null) {
      await DB.updateOutlet(
        widget.existing!['id'], d);
    } else {
      await DB.insertOutlet(d);
    }
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Outlet saved! ✅'),
          backgroundColor: Colors.green));
      Navigator.pop(context, true);
    }
  }

  Widget _sec(String t) => Padding(
    padding: const EdgeInsets.only(
      top: 16, bottom: 8),
    child: Text(t, style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: Color(0xFFD32F2F),
    )),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null
          ? 'Edit Outlet' : 'Add Outlet')),
      body: Form(
        key: _fk,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                    BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.grey.shade300),
                  image: _photo != null
                    ? DecorationImage(
                        image: FileImage(File(_photo!)),
                        fit: BoxFit.cover)
                    : null,
                ),
                child: _photo == null
                  ? Column(
                      mainAxisAlignment:
                        MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt,
                          size: 40,
                          color: Colors.grey.shade400),
                        Text('Take outlet photo',
                          style: TextStyle(
                            color: Colors.grey.shade500)),
                      ])
                  : null,
              ),
            ),
            _sec('📍 Basic Info'),
            TextFormField(controller: _nameC,
              decoration: const InputDecoration(
                labelText: 'Outlet Name *',
                prefixIcon: Icon(Icons.store)),
              validator: (v) =>
                v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _ownerC,
              decoration: const InputDecoration(
                labelText: 'Owner Name *',
                prefixIcon: Icon(Icons.person)),
              validator: (v) =>
                v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _contactC,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Contact No',
                prefixIcon: Icon(Icons.phone))),
            const SizedBox(height: 12),
            TextFormField(controller: _addressC,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on))),
            _sec('🏷️ Classification'),
            DropdownButtonFormField<String>(
              value: _routes.contains(_route)
                ? _route : null,
              decoration: const InputDecoration(
                labelText: 'Route Point *',
                prefixIcon: Icon(Icons.route)),
              items: _routes.map((r) =>
                DropdownMenuItem(
                  value: r, child: Text(r))).toList(),
              onChanged: (v) =>
                setState(() => _route = v),
              validator: (v) =>
                v == null ? 'Select route' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type.isEmpty ? null : _type,
              decoration: const InputDecoration(
                labelText: 'Outlet Type',
                prefixIcon: Icon(Icons.category)),
              items: _types.map((t) =>
                DropdownMenuItem(
                  value: t, child: Text(t))).toList(),
              onChanged: (v) =>
                setState(() => _type = v??'')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _channel.isEmpty
                ? null : _channel,
              decoration: const InputDecoration(
                labelText: 'Channel',
                prefixIcon:
                  Icon(Icons.account_tree)),
              items: _channels.map((c) =>
                DropdownMenuItem(
                  value: c, child: Text(c))).toList(),
              onChanged: (v) =>
                setState(() => _channel = v??'')),
            _sec('📋 Additional Details'),
            TextFormField(controller: _panC,
              decoration: const InputDecoration(
                labelText: 'PAN No',
                prefixIcon: Icon(Icons.badge))),
            const SizedBox(height: 10),
            TextFormField(controller: _volumeC,
              decoration: const InputDecoration(
                labelText: 'Volume',
                prefixIcon: Icon(Icons.bar_chart))),
            const SizedBox(height: 10),
            TextFormField(controller: _wsC,
              decoration: const InputDecoration(
                labelText: 'W/S Tie-Up',
                prefixIcon: Icon(Icons.handshake))),
            const SizedBox(height: 10),
            TextFormField(controller: _displayC,
              decoration: const InputDecoration(
                labelText: 'Display',
                prefixIcon: Icon(Icons.visibility))),
            const SizedBox(height: 10),
            TextFormField(controller: _dpsC,
              decoration: const InputDecoration(
                labelText: 'DPS',
                prefixIcon: Icon(Icons.analytics))),
            const SizedBox(height: 10),
            TextFormField(controller: _indoorC,
              decoration: const InputDecoration(
                labelText: 'Indoor Branding',
                prefixIcon:
                  Icon(Icons.branding_watermark))),
            const SizedBox(height: 10),
            TextFormField(controller: _boardC,
              decoration: const InputDecoration(
                labelText: 'Other Brand Board',
                prefixIcon: Icon(Icons.dashboard))),
            const SizedBox(height: 10),
            TextFormField(controller: _mbqC,
              decoration: const InputDecoration(
                labelText: 'MBQ',
                prefixIcon: Icon(Icons.inventory))),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                ? const SizedBox(width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white))
                : const Icon(Icons.save),
              label: Text(widget.existing != null
                ? 'Update Outlet' : 'Save Outlet')),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameC.dispose(); _ownerC.dispose();
    _contactC.dispose(); _panC.dispose();
    _volumeC.dispose(); _addressC.dispose();
    _wsC.dispose(); _displayC.dispose();
    _dpsC.dispose(); _indoorC.dispose();
    _boardC.dispose(); _mbqC.dispose();
    super.dispose();
  }class OutletListScreen extends StatefulWidget {
  final String? route;
  final bool selectionMode;
  const OutletListScreen({
    super.key,
    this.route,
    this.selectionMode = false,
  });
  @override
  State<OutletListScreen> createState() =>
    _OutletListScreenState();
}

class _OutletListScreenState
  extends State<OutletListScreen> {
  List<Map<String,dynamic>> _all = [];
  List<Map<String,dynamic>> _filtered = [];
  final _sc = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final o = widget.route != null
      ? await DB.getOutletsByRoute(widget.route!)
      : await DB.getAllOutlets();
    setState(() {
      _all = o; _filtered = o; _loading = false;
    });
  }

  void _search(String q) {
    setState(() {
      _filtered = _all.where((o) =>
        o['outletName'].toString().toLowerCase()
          .contains(q.toLowerCase()) ||
        o['ownerName'].toString().toLowerCase()
          .contains(q.toLowerCase())).toList();
    });
  }

  Color _color(String? t) {
    switch ((t??'').toLowerCase()) {
      case 'hotel': return Colors.blue;
      case 'dairy': return Colors.teal;
      case 'kirana': return Colors.green;
      case 'liquor store': return Colors.purple;
      case 'restaurant': return Colors.orange;
      default: return Colors.grey;
    }
  }

  void _del(Map<String,dynamic> o) {
    showDialog(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Outlet?'),
        content: Text(
          'Delete "${o['outletName']}"?\n'
          'History also deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red),
            onPressed: () async {
              await DB.deleteOutlet(o['id']);
              Navigator.pop(ctx);
              _load();
            },
            child: const Text('Delete')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectionMode
          ? 'Select Outlet'
          : widget.route != null
            ? '${widget.route} Outlets'
            : 'All Outlets'),
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _sc,
            onChanged: _search,
            decoration: InputDecoration(
              hintText: 'Search outlet or owner...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _sc.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _sc.clear(); _search('');
                    })
                : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 4),
          child: Row(children: [
            Text('${_filtered.length} outlets',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13)),
          ]),
        ),
        Expanded(
          child: _loading
            ? const Center(
                child: CircularProgressIndicator())
            : _filtered.isEmpty
              ? Center(child: Text(
                  _all.isEmpty
                    ? 'No outlets.\nTap + to add!'
                    : 'No results',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500)))
              : ListView.builder(
                  itemCount: _filtered.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                  itemBuilder: (ctx, i) {
                    final o = _filtered[i];
                    final c = _color(o['outletType']);
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                            c.withOpacity(0.1),
                          child: Text(
                            o['outletName']
                              .toString()
                              .substring(0,1)
                              .toUpperCase(),
                            style: TextStyle(
                              color: c,
                              fontWeight:
                                FontWeight.bold)),
                        ),
                        title: Text(o['outletName'],
                          style: const TextStyle(
                            fontWeight:
                              FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment:
                            CrossAxisAlignment.start,
                          children: [
                            Text('👤 ${o['ownerName']}'),
                            Text(
                              '🏷️ ${o['outletType']??''}  •  📍 ${o['routeName']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: c)),
                          ],
                        ),
                        trailing: widget.selectionMode
                          ? const Icon(
                              Icons.arrow_forward_ios,
                              size: 16)
                          : PopupMenuButton(
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'visit',
                                  child: Row(children: [
                                    Icon(Icons.add_location,
                                      color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Start Visit'),
                                  ])),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(children: [
                                    Icon(Icons.edit,
                                      color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ])),
                                const PopupMenuItem(
                                  value: 'history',
                                  child: Row(children: [
                                    Icon(Icons.history,
                                      color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text('History'),
                                  ])),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(children: [
                                    Icon(Icons.delete,
                                      color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                      style: TextStyle(
                                        color: Colors.red)),
                                  ])),
                              ],
                              onSelected: (v) async {
                                if (v=='visit') {
                                  await Navigator.push(ctx,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                        VisitScreen(outlet: o)));
                                  _load();
                                } else if (v=='edit') {
                                  await Navigator.push(ctx,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                        AddOutletScreen(
                                          existing: o)));
                                  _load();
                                } else if (v=='history') {
                                  Navigator.push(ctx,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                        OutletHistoryScreen(
                                          outlet: o)));
                                } else if (v=='delete') {
                                  _del(o);
                                }
                              }),
                        onTap: widget.selectionMode
                          ? () => Navigator.push(ctx,
                              MaterialPageRoute(
                                builder: (_) =>
                                  VisitScreen(outlet: o)))
                          : null,
                      ),
                    );
                  }),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD32F2F),
        onPressed: () async {
          await Navigator.push(context,
            MaterialPageRoute(builder: (_) =>
              AddOutletScreen(
                defaultRoute:
                  widget.route ?? 'Tulsipur')));
          _load();
        },
        child: const Icon(Icons.add,
          color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }class VisitScreen extends StatefulWidget {
  final Map<String,dynamic> outlet;
  const VisitScreen({super.key, required this.outlet});
  @override
  State<VisitScreen> createState() =>
    _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen> {
  String? _photo;
  final _remC = TextEditingController();
  bool _saving = false;
  Map<String,dynamic>? _last;

  final _s = <String,TextEditingController>{
    'mt250': TextEditingController(),
    'mt330': TextEditingController(),
    'mt330c': TextEditingController(),
    'xt330': TextEditingController(),
    'jj200': TextEditingController(),
    'jj320': TextEditingController(),
    'bb250': TextEditingController(),
    'bb500': TextEditingController(),
    'bb1500': TextEditingController(),
    'bb2500': TextEditingController(),
    'bbh500': TextEditingController(),
    'csd': TextEditingController(),
    'liquor': TextEditingController(),
  };

  final _o = <String,TextEditingController>{
    'mt250': TextEditingController(),
    'mt330': TextEditingController(),
    'mt330c': TextEditingController(),
    'xt330': TextEditingController(),
    'jj200': TextEditingController(),
    'jj320': TextEditingController(),
    'bb250': TextEditingController(),
    'bb500': TextEditingController(),
    'bb1500': TextEditingController(),
    'bb2500': TextEditingController(),
    'bbh500': TextEditingController(),
    'csd': TextEditingController(),
    'liquor': TextEditingController(),
  };

  final _ob = <String,TextEditingController>{
    'rb250': TextEditingController(),
    'rb330': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadLast();
  }

  Future<void> _loadLast() async {
    final l = await DB.getLastVisit(
      widget.outlet['id']);
    setState(() => _last = l);
  }

  int _v(Map<String,TextEditingController> m,
    String k) =>
    int.tryParse(m[k]?.text??'0')??0;

  int get _total =>
    _v(_o,'mt250')+_v(_o,'mt330')+
    _v(_o,'mt330c')+_v(_o,'xt330')+
    _v(_o,'jj200')+_v(_o,'jj320')+
    _v(_o,'bb250')+_v(_o,'bb500')+
    _v(_o,'bb1500')+_v(_o,'bb2500')+
    _v(_o,'bbh500')+_v(_o,'csd')+
    _v(_o,'liquor');

  Future<void> _takePhoto() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1024, imageQuality: 80);
    if (img!=null) {
      setState(() => _photo = img.path);
    }
  }

  Map<String,dynamic> _data() {
    final t = DateTime.now()
      .toIso8601String().split('T')[0];
    return {
      'outletId': widget.outlet['id'],
      'visitDate': t,
      'photoPath': _photo,
      's_mt250': _v(_s,'mt250'),
      's_mt330': _v(_s,'mt330'),
      's_mt330c': _v(_s,'mt330c'),
      's_xt330': _v(_s,'xt330'),
      's_jj200': _v(_s,'jj200'),
      's_jj320': _v(_s,'jj320'),
      's_bb250': _v(_s,'bb250'),
      's_bb500': _v(_s,'bb500'),
      's_bb1500': _v(_s,'bb1500'),
      's_bb2500': _v(_s,'bb2500'),
      's_bbh500': _v(_s,'bbh500'),
      's_csd': _v(_s,'csd'),
      's_liquor': _v(_s,'liquor'),
      'o_mt250': _v(_o,'mt250'),
      'o_mt330': _v(_o,'mt330'),
      'o_mt330c': _v(_o,'mt330c'),
      'o_xt330': _v(_o,'xt330'),
      'o_jj200': _v(_o,'jj200'),
      'o_jj320': _v(_o,'jj320'),
      'o_bb250': _v(_o,'bb250'),
      'o_bb500': _v(_o,'bb500'),
      'o_bb1500': _v(_o,'bb1500'),
      'o_bb2500': _v(_o,'bb2500'),
      'o_bbh500': _v(_o,'bbh500'),
      'o_csd': _v(_o,'csd'),
      'o_liquor': _v(_o,'liquor'),
      'ob_rb250': _v(_ob,'rb250'),
      'ob_rb330': _v(_ob,'rb330'),
      'remarks': _remC.text.trim(),
      'createdAt':
        DateTime.now().toIso8601String(),
    };
  }

  String _msg() {
    final o = widget.outlet;
    final d = DateFormat('dd-MMM-yyyy')
      .format(DateTime.now());
    final b = StringBuffer();
    b.writeln('━━━━━━━━━━━━━━━━━━━━');
    b.writeln('📊 *XTREME DSR REPORT*');
    b.writeln('━━━━━━━━━━━━━━━━━━━━');
    b.writeln('📅 *Date:* $d');
    b.writeln('🏢 *HEADQUARTER:* Dang');
    b.writeln('📍 *ROUTE(POINT):* ${o['routeName']}');
    b.writeln('👤 *INCHARGE NAME:* Sujal Gupta');
    b.writeln('🏪 *DEALER NAME:* R.B Enterprises');
    b.writeln('');
    b.writeln('━━ *OUTLET INFO* ━━');
    b.writeln('🏪 *OUTLET NAME:* ${o['outletName']}');
    if((o['panNo']??'').isNotEmpty)
      b.writeln('📋 *PAN No:* ${o['panNo']}');
    if((o['channel']??'').isNotEmpty)
      b.writeln('📡 *CHANNEL:* ${o['channel']}');
    if((o['outletType']??'').isNotEmpty)
      b.writeln('🏷️ *OUTLET TYPE:* ${o['outletType']}');
    if((o['volume']??'').isNotEmpty)
      b.writeln('📦 *VOLUME:* ${o['volume']}');
    if((o['address']??'').isNotEmpty)
      b.writeln('📍 *ADDRESS:* ${o['address']}');
    b.writeln('👤 *OWNER NAME:* ${o['ownerName']}');
    b.writeln('📞 *CONTACT NO:* ${o['contactNo']}');
    if((o['wsTieUp']??'').isNotEmpty)
      b.writeln('🤝 *W/S TIE-UP:* ${o['wsTieUp']}');
    if((o['display']??'').isNotEmpty)
      b.writeln('🖼️ *DISPLAY:* ${o['display']}');
    if((o['dps']??'').isNotEmpty)
      b.writeln('📊 *DPS:* ${o['dps']}');
    if((o['indoorBrand']??'').isNotEmpty)
      b.writeln('🏪 *INDOOR BRANDING:* ${o['indoorBrand']}');
    if((o['otherBoard']??'').isNotEmpty)
      b.writeln('🪧 *OTHER BRAND BOARD:* ${o['otherBoard']}');
    if((o['mbq']??'').isNotEmpty)
      b.writeln('📦 *MBQ:* ${o['mbq']}');
    b.writeln('');
    b.writeln('━━ *PHYSICAL STOCK* ━━');
    b.writeln('MT 250: *${_v(_s,'mt250')}*');
    b.writeln('MT 330: *${_v(_s,'mt330')}*');
    b.writeln('MT 330 CLASSIC: *${_v(_s,'mt330c')}*');
    b.writeln('XT 330: *${_v(_s,'xt330')}*');
    b.writeln('JUICE JELLY 200ML: *${_v(_s,'jj200')}*');
    b.writeln('JUICE JELLY 320ML: *${_v(_s,'jj320')}*');
    b.writeln('BAM BAM CSD 250ML: *${_v(_s,'bb250')}*');
    b.writeln('BAM BAM CSD 500ML: *${_v(_s,'bb500')}*');
    b.writeln('BAM BAM CSD 1.5L: *${_v(_s,'bb1500')}*');
    b.writeln('BAM BAM CSD 2.5L: *${_v(_s,'bb2500')}*');
    b.writeln('BAM BAM HYDRATION 500ML: *${_v(_s,'bbh500')}*');
    b.writeln('CSD: *${_v(_s,'csd')}*');
    b.writeln('LIQUOR: *${_v(_s,'liquor')}*');
    b.writeln('');
    b.writeln('━━ *ORDER IN CASES* ━━');
    b.writeln('MT 250: *${_v(_o,'mt250')}*');
    b.writeln('MT 330: *${_v(_o,'mt330')}*');
    b.writeln('MT 330 CLASSIC: *${_v(_o,'mt330c')}*');
    b.writeln('XT 330: *${_v(_o,'xt330')}*');
    b.writeln('JUICE JELLY 200ML: *${_v(_o,'jj200')}*');
    b.writeln('JUICE JELLY 320ML: *${_v(_o,'jj320')}*');
    b.writeln('BAM BAM CSD 250ML: *${_v(_o,'bb250')}*');
    b.writeln('BAM BAM CSD 500ML: *${_v(_o,'bb500')}*');
    b.writeln('BAM BAM CSD 1.5L: *${_v(_o,'bb1500')}*');
    b.writeln('BAM BAM CSD 2.5L: *${_v(_o,'bb2500')}*');
    b.writeln('BAM BAM HYDRATION 500ML: *${_v(_o,'bbh500')}*');
    b.writeln('CSD: *${_v(_o,'csd')}*');
    b.writeln('LIQUOR: *${_v(_o,'liquor')}*');
    b.writeln('');
    b.writeln('━━ *OTHER BRANDS STOCK* ━━');
    b.writeln('RB 250: *${_v(_ob,'rb250')}*');
    b.writeln('RB 330: *${_v(_ob,'rb330')}*');
    if(_remC.text.trim().isNotEmpty)
      b.writeln('\n📝 *Remarks:* ${_remC.text.trim()}');
    b.writeln('');
    b.writeln('📦 *TOTAL CASES:* $_total');
    b.writeln('━━━━━━━━━━━━━━━━━━━━');
    return b.toString();
  }

  Future<void> _send() async {
    setState(() => _saving = true);
    await DB.insertVisit(_data());
    final msg = _msg();
    if (_photo!=null && File(_photo!).existsSync()) {
      await Share.shareXFiles(
        [XFile(_photo!)], text: msg);
    } else {
      final uri = Uri.parse(
        'whatsapp://send?text=${Uri.encodeComponent(msg)}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri,
          mode: LaunchMode.externalApplication);
      }
    }
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved & Sent! ✅'),
          backgroundColor: Colors.green));
      Navigator.pop(context, true);
    }
  }

  Future<void> _saveOnly() async {
    setState(() => _saving = true);
    await DB.insertVisit(_data());
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Visit Saved! ✅'),
          backgroundColor: Colors.green));
      Navigator.pop(context, true);
    }
  }  @override
  Widget build(BuildContext context) {
    final o = widget.outlet;
    return Scaffold(
      appBar: AppBar(
        title: Text(o['outletName'],
          style: const TextStyle(fontSize: 16)),
        actions: [
          if (_last != null)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _showLast),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                  CrossAxisAlignment.start,
                children: [
                  Text(o['outletName'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('👤 ${o['ownerName']}'),
                  if((o['contactNo']??'').isNotEmpty)
                    Text('📞 ${o['contactNo']}'),
                  if((o['outletType']??'').isNotEmpty)
                    Text('🏷️ ${o['outletType']}'),
                  Text('📍 ${o['routeName']}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _takePhoto,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                  BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300),
                image: _photo != null
                  ? DecorationImage(
                      image: FileImage(File(_photo!)),
                      fit: BoxFit.cover)
                  : null,
              ),
              child: _photo == null
                ? Column(
                    mainAxisAlignment:
                      MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.camera_alt,
                        size: 32,
                        color: Colors.grey),
                      Text('Tap to take photo 📸',
                        style: TextStyle(
                          color: Colors.grey)),
                    ])
                : null,
            ),
          ),
          const SizedBox(height: 20),
          _hdr('📦 PHYSICAL STOCK', Colors.blue),
          const SizedBox(height: 8),
          _box(_s, Colors.blue),
          const SizedBox(height: 20),
          _hdr('🛒 ORDER IN CASES', Colors.green),
          const SizedBox(height: 8),
          _box(_o, Colors.green),
          const SizedBox(height: 20),
          _hdr('🏷️ OTHER BRANDS STOCK',
            Colors.orange),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.2)),
            ),
            child: Column(children: [
              _row('RB 250',
                _ob['rb250']!, Colors.orange),
              _row('RB 330',
                _ob['rb330']!, Colors.orange),
            ]),
          ),
          const SizedBox(height: 20),
          _hdr('📝 REMARKS', Colors.grey),
          const SizedBox(height: 8),
          TextField(
            controller: _remC,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Any special remarks...',
              border: OutlineInputBorder(
                borderRadius:
                  BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                const Color(0xFF25D366),
              minimumSize:
                const Size(double.infinity, 54)),
            onPressed: _saving ? null : _send,
            icon: _saving
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white))
              : const Icon(Icons.send),
            label: const Text(
              'SAVE & SEND TO WHATSAPP',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _saving ? null : _saveOnly,
            icon: const Icon(Icons.save),
            label: const Text(
              'Save Only (Send Later)')),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _hdr(String t, Color c) => Row(children: [
    Container(width: 4, height: 22,
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(t, style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: c)),
  ]);

  Widget _box(
    Map<String,TextEditingController> ctrls,
    Color c) {
    final labels = {
      'mt250':'MT 250',
      'mt330':'MT 330',
      'mt330c':'MT 330 CLASSIC',
      'xt330':'XT 330',
      'jj200':'JUICE JELLY 200ML',
      'jj320':'JUICE JELLY 320ML',
      'bb250':'BAM BAM CSD 250ML',
      'bb500':'BAM BAM CSD 500ML',
      'bb1500':'BAM BAM CSD 1.5L',
      'bb2500':'BAM BAM CSD 2.5L',
      'bbh500':'BAM BAM HYDRATION 500ML',
      'csd':'CSD',
      'liquor':'LIQUOR',
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: c.withOpacity(0.2))),
      child: Column(
        children: labels.entries
          .map((e) => _row(
              e.value, ctrls[e.key]!, c))
          .toList()),
    );
  }

  Widget _row(String label,
    TextEditingController ctrl, Color c) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(flex: 4,
          child: Text(label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500))),
        SizedBox(width: 75, height: 38,
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 6),
              border: OutlineInputBorder(
                borderRadius:
                  BorderRadius.circular(8)),
              filled: true,
              fillColor: c.withOpacity(0.05),
              hintText: '0',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13)),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold))),
      ]),
    );
  }

  void _showLast() {
    if (_last == null) return;
    showDialog(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Last Visit'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
              CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📅 ${_last!['visitDate']}'),
              const Divider(),
              const Text('Last Order:',
                style: TextStyle(
                  fontWeight: FontWeight.bold)),
              if((_last!['o_mt250']??0)>0)
                Text('MT 250: ${_last!['o_mt250']}'),
              if((_last!['o_mt330']??0)>0)
                Text('MT 330: ${_last!['o_mt330']}'),
              if((_last!['o_xt330']??0)>0)
                Text('XT 330: ${_last!['o_xt330']}'),
              if((_last!['remarks']??'').isNotEmpty)
                Text('📝 ${_last!['remarks']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _remC.dispose();
    for (var c in _s.values) c.dispose();
    for (var c in _o.values) c.dispose();
    for (var c in _ob.values) c.dispose();
    super.dispose();
  }class OutletHistoryScreen extends StatelessWidget {
  final Map<String,dynamic> outlet;
  const OutletHistoryScreen({
    super.key, required this.outlet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${outlet['outletName']} History')),
      body: FutureBuilder<List<Map<String,dynamic>>>(
        future: DB.getVisitsByOutlet(outlet['id']),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(
            child: CircularProgressIndicator());
          final visits = snap.data!;
          if (visits.isEmpty) return const Center(
            child: Text('No visits yet'));
          return ListView.builder(
            itemCount: visits.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (ctx, i) {
              final v = visits[i];
              final c = DB.totalCases(v);
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: c>0
                      ? Colors.green.shade50
                      : Colors.grey.shade100,
                    child: Icon(
                      c>0
                        ? Icons.shopping_cart
                        : Icons.store,
                      color: c>0
                        ? Colors.green
                        : Colors.grey)),
                  title: Text(v['visitDate'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold)),
                  subtitle: Text(c>0
                    ? 'Ordered: $c cases'
                    : 'No order'),
                  trailing: Text('$c',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: c>0
                        ? Colors.green
                        : Colors.grey)),
                ),
              );
            });
        },
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() =>
    _HistoryScreenState();
}

class _HistoryScreenState
  extends State<HistoryScreen> {
  DateTime _date = DateTime.now();
  List<Map<String,dynamic>> _visits = [];
  Map<int,Map<String,dynamic>> _oMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final ds = DateFormat('yyyy-MM-dd')
      .format(_date);
    final visits = await DB.getVisitsByDate(ds);
    final outlets = await DB.getAllOutlets();
    final map = <int,Map<String,dynamic>>{};
    for (var o in outlets) { map[o['id']] = o; }
    setState(() {
      _visits = visits;
      _oMap = map;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit History')),
      body: Column(children: [
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2024),
              lastDate: DateTime.now());
            if (d != null) {
              setState(() => _date = d);
              _load();
            }
          },
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius:
                BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.calendar_today,
                color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(child: Text(
                DateFormat('dd MMM yyyy, EEEE')
                  .format(_date),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold))),
              Text('${_visits.length} visits',
                style: const TextStyle(
                  color: Colors.blue)),
              const Icon(Icons.arrow_drop_down),
            ]),
          ),
        ),
        Expanded(
          child: _loading
            ? const Center(
                child: CircularProgressIndicator())
            : _visits.isEmpty
              ? const Center(
                  child: Text(
                    'No visits on this date'))
              : ListView.builder(
                  itemCount: _visits.length,
                  padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12),
                  itemBuilder: (ctx, i) {
                    final v = _visits[i];
                    final o = _oMap[v['outletId']];
                    final c = DB.totalCases(v);
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: c>0
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                          child: Icon(Icons.store,
                            color: c>0
                              ? Colors.green
                              : Colors.grey)),
                        title: Text(
                          o?['outletName']??'Unknown',
                          style: const TextStyle(
                            fontWeight:
                              FontWeight.bold)),
                        subtitle: Text(c>0
                          ? '$c cases ordered'
                          : 'No order'),
                        trailing: Text('$c',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                              FontWeight.bold,
                            color: c>0
                              ? Colors.green
                              : Colors.grey)),
                      ),
                    );
                  }),
        ),
      ]),
    );class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});
  @override
  State<SummaryScreen> createState() =>
    _SummaryScreenState();
}

class _SummaryScreenState
  extends State<SummaryScreen> {
  List<Map<String,dynamic>> _visits = [];
  Map<int,Map<String,dynamic>> _oMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final visits = await DB.getTodayVisits();
    final outlets = await DB.getAllOutlets();
    final map = <int,Map<String,dynamic>>{};
    for (var o in outlets) { map[o['id']] = o; }
    setState(() {
      _visits = visits;
      _oMap = map;
      _loading = false;
    });
  }

  String _summaryMsg() {
    final d = DateFormat('dd-MMM-yyyy')
      .format(DateTime.now());
    int total = 0; int ordered = 0;
    for (var v in _visits) {
      final c = DB.totalCases(v);
      total += c;
      if (c>0) ordered++;
    }
    final b = StringBuffer();
    b.writeln('━━━━━━━━━━━━━━━━━━━━');
    b.writeln('📊 *DAILY SUMMARY REPORT*');
    b.writeln('━━━━━━━━━━━━━━━━━━━━');
    b.writeln('📅 Date: $d');
    b.writeln('👤 Incharge: Sujal Gupta');
    b.writeln('🏢 HQ: Dang');
    b.writeln('🏪 Dealer: R.B Enterprises');
    b.writeln('');
    b.writeln('✅ Outlets Visited: ${_visits.length}');
    b.writeln('🛒 Outlets Ordered: $ordered');
    b.writeln('📦 Total Cases: $total');
    b.writeln('');
    b.writeln('━━ OUTLET WISE ━━');
    for (var v in _visits) {
      final o = _oMap[v['outletId']];
      if (o==null) continue;
      final c = DB.totalCases(v);
      b.writeln('• ${o['outletName']} → *$c cases*');
    }
    b.writeln('━━━━━━━━━━━━━━━━━━━━');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    int total = 0; int ordered = 0;
    for (var v in _visits) {
      final c = DB.totalCases(v);
      total += c;
      if (c>0) ordered++;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Summary')),
      body: _loading
        ? const Center(
            child: CircularProgressIndicator())
        : Column(children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.purple.shade400,
                  Colors.purple.shade700,
                ]),
                borderRadius:
                  BorderRadius.circular(16)),
              child: Column(children: [
                Text(
                  DateFormat('dd MMM yyyy')
                    .format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white70)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                  children: [
                    _item('Visited',
                      '${_visits.length}',
                      Icons.directions_walk),
                    _item('Ordered',
                      '$ordered',
                      Icons.shopping_cart),
                    _item('Cases',
                      '$total',
                      Icons.inventory_2),
                  ],
                ),
              ]),
            ),
            Expanded(
              child: _visits.isEmpty
                ? const Center(
                    child: Text(
                      'No visits today yet'))
                : ListView.builder(
                    itemCount: _visits.length,
                    padding:
                      const EdgeInsets.symmetric(
                        horizontal: 16),
                    itemBuilder: (ctx, i) {
                      final v = _visits[i];
                      final o = _oMap[v['outletId']];
                      final c = DB.totalCases(v);
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                              Colors.purple.shade50,
                            child: Text('${i+1}',
                              style: const TextStyle(
                                fontWeight:
                                  FontWeight.bold,
                                color:
                                  Colors.purple))),
                          title: Text(
                            o?['outletName']??'-',
                            style: const TextStyle(
                              fontWeight:
                                FontWeight.bold)),
                          subtitle: Text(
                            o?['outletType']??''),
                          trailing: Text(
                            '$c cases',
                            style: TextStyle(
                              fontWeight:
                                FontWeight.bold,
                              color: c>0
                                ? Colors.green
                                : Colors.grey)),
                        ),
                      );
                    }),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                    const Color(0xFF25D366)),
                onPressed: _visits.isEmpty
                  ? null
                  : () async {
                      final msg = _summaryMsg();
                      final uri = Uri.parse(
                        'whatsapp://send?text='
                        '${Uri.encodeComponent(msg)}');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                          mode: LaunchMode
                            .externalApplication);
                      }
                    },
                icon: const Icon(Icons.send),
                label: const Text(
                  'Send Summary to WhatsApp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold))),
            ),
          ]),
    );
  }

  Widget _item(String l, String v, IconData i) {
    return Column(children: [
      Icon(i, color: Colors.white, size: 26),
      const SizedBox(height: 8),
      Text(v, style: const TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.bold)),
      Text(l, style: const TextStyle(
        color: Colors.white70,
        fontSize: 12)),
    ]);
  }
}
  }
}
}
}
}
}
}
}
