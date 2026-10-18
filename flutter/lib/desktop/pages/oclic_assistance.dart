import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common.dart';
import 'package:flutter_hbb/models/platform_model.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:window_manager/window_manager.dart';
import 'server_page.dart' show checkClickTime;

const oclicInk = Color(0xff1c1445);
const oclicMint = Color(0xffc1f4e1);
const oclicCoral = Color(0xffff5a36);
const oclicSun = Color(0xffffd33f);

bool get isOclic => bind.mainGetAppNameSync() == 'OclicAssistance';

class OclicLogo extends StatelessWidget {
  const OclicLogo({super.key});
  @override
  Widget build(BuildContext context) {
    const scale = 124 / 316;
    return SizedBox(width: 124, height: 84, child: Stack(clipBehavior: Clip.hardEdge, children: [
      Positioned(left: -106 * scale, top: -142 * scale, width: 512 * scale, height: 512 * scale,
        child: Image.asset('assets/oclic-logo.png')),
    ]));
  }
}

class OclicFrame extends StatelessWidget {
  final String status;
  final Widget child;
  final Widget actions;
  final VoidCallback onClose;
  const OclicFrame({super.key, required this.status, required this.child, required this.actions, required this.onClose});
  @override
  Widget build(BuildContext context) => Theme(
    data: ThemeData(brightness: Brightness.light, fontFamily: 'OclicNunito',
      scaffoldBackgroundColor: Colors.white, colorScheme: const ColorScheme.light(primary: oclicInk, onPrimary: Colors.white,
        secondary: oclicMint, onSecondary: oclicInk, surface: Colors.white, onSurface: oclicInk, error: oclicCoral, onError: oclicInk),
      textTheme: Theme.of(context).textTheme.apply(fontFamily: 'OclicNunito', bodyColor: oclicInk, displayColor: oclicInk),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        foregroundColor: oclicInk, backgroundColor: oclicCoral, elevation: 0,
        minimumSize: const Size(double.infinity, 46),
        side: const BorderSide(color: oclicInk), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: oclicInk)),
    ),
    child: Builder(builder: (context) => Scaffold(body: Column(children: [
      SizedBox(height: 38, child: Row(children: [
        Expanded(child: GestureDetector(onPanStart: (_) => windowManager.startDragging(),
          behavior: HitTestBehavior.opaque, child: const Padding(padding: EdgeInsets.only(left: 16),
            child: Text('Oclic Assistance', style: TextStyle(color: oclicInk, fontSize: 12))))),
        IconButton(tooltip: 'Fermer l’outil', icon: const Icon(Icons.close, size: 18, color: oclicInk), onPressed: onClose),
      ])),
      const Divider(height: 1, color: oclicInk),
      Expanded(child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.fromLTRB(28, 18, 28, 12), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const OclicLogo(),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: oclicMint, borderRadius: BorderRadius.circular(30)),
            child: Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: oclicInk))),
        ]),
        const SizedBox(height: 24), child,
      ])))),
      Padding(padding: const EdgeInsets.fromLTRB(28, 12, 28, 0), child: actions),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: Column(children: [
        const Divider(color: oclicInk),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('BAOU TECHNOLOGIE', style: TextStyle(fontSize: 10, color: oclicInk)),
          TextButton(onPressed: () => showDialog<void>(context: context, builder: (context) => AlertDialog(
            title: const Text('Oclic Assistance'),
            content: const Text('Version 0.1.0 · RustDesk 1.5.0\nLogiciel libre, licence AGPL-3.0.\nSources : github.com/Jun-cod/oclic-assistance'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer'))])),
            child: const Text('À propos', style: TextStyle(fontSize: 12))),
        ]),
      ])),
    ]))),
  );
}

Widget oclicTitle(String text) => Text(text, textAlign: TextAlign.center,
  style: const TextStyle(fontFamily: 'OclicFredoka', fontSize: 28, fontWeight: FontWeight.w600, color: oclicInk));

Widget oclicIdentity(String label, String id) => Container(
  width: double.infinity, padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(color: oclicMint, borderRadius: BorderRadius.circular(12)),
  child: Column(children: [Text(label, style: const TextStyle(fontSize: 12, color: oclicInk)),
    const SizedBox(height: 8), SelectableText(id.isEmpty ? '…' : id, textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 2, color: oclicInk))]));

class OclicMainWindow extends StatefulWidget {
  const OclicMainWindow({super.key});
  @override
  State<OclicMainWindow> createState() => _OclicMainWindowState();
}

class _OclicMainWindowState extends State<OclicMainWindow> with WindowListener {
  Timer? timer;
  String id = '', error = '';
  bool online = false, closing = false, fetching = false;
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.setPreventClose(true);
    windowManager.setMinimumSize(const Size(360, 540));
    windowManager.setSize(const Size(480, 640));
    bind.mainCheckConnectStatus();
    refresh();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
  }
  Future<void> refresh() async {
    if (fetching || closing) return;
    fetching = true;
    try {
      final nextId = await bind.mainGetMyId();
      final data = jsonDecode(await bind.mainGetConnectStatus()) as Map<String, dynamic>;
      final nextOnline = (data['status_num'] as num? ?? 0) > 0;
      final nextError = await bind.mainGetError();
      if (mounted && (id != nextId || online != nextOnline || error != nextError)) {
        setState(() { id = nextId; online = nextOnline; error = nextError; });
      }
    } catch (_) {
      if (mounted) setState(() { online = false; error = 'Connexion indisponible.'; });
    } finally { fetching = false; }
  }
  Future<void> quit() async {
    if (closing) return;
    setState(() { closing = true; });
    final stopped = await bind.mainOclicShutdown();
    if (!mounted) return;
    if (!stopped) { setState(() { closing = false; error = 'Arrêt non confirmé. Réessayez.'; }); return; }
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
    exit(0);
  }
  @override
  void onWindowClose() { quit(); }
  @override
  void dispose() { timer?.cancel(); windowManager.removeListener(this); super.dispose(); }
  @override
  Widget build(BuildContext context) => OclicFrame(status: closing ? 'Arrêt en cours' : online ? 'Prêt' : 'Connexion…', onClose: quit,
    actions: ElevatedButton(onPressed: closing ? null : quit, child: Text(closing ? 'Déconnexion…' : 'Arrêter l’assistance')),
    child: Column(children: [
      const Icon(Icons.desktop_windows_outlined, size: 48, color: oclicInk), const SizedBox(height: 20),
      oclicTitle('Votre identifiant'), const SizedBox(height: 12),
      const Text('Transmettez-le au technicien.', style: TextStyle(fontSize: 14, color: oclicInk)),
      const SizedBox(height: 24), oclicIdentity('ID Oclic', id),
      TextButton.icon(onPressed: id.isEmpty ? null : () async { await Clipboard.setData(ClipboardData(text: id)); },
        icon: const Icon(Icons.copy_outlined, size: 16), label: const Text('Copier l’identifiant')),
      if (error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: oclicInk))),
    ]));
}

class OclicConnectionPanel extends StatefulWidget {
  final ServerModel model;
  const OclicConnectionPanel({super.key, required this.model});
  @override
  State<OclicConnectionPanel> createState() => _OclicConnectionPanelState();
}

class _OclicConnectionPanelState extends State<OclicConnectionPanel> {
  int? approving;
  bool closing = false;
  String error = '';
  @override
  void initState() {
    super.initState();
    windowManager.setSize(const Size(480, 640));
    windowManager.setMinimumSize(const Size(360, 540));
  }
  Future<void> stop() async {
    if (closing) return;
    setState(() { closing = true; });
    final stopped = await bind.mainOclicShutdown();
    if (!mounted) return;
    if (!stopped) { setState(() { closing = false; error = 'Arrêt non confirmé. Réessayez.'; }); return; }
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }
  @override
  Widget build(BuildContext context) {
    final clients = widget.model.clients.where((client) => !client.disconnected).toList();
    final Client? client = clients.isEmpty ? null : clients.first;
    final active = client?.authorized ?? false;
    return OclicFrame(status: closing ? 'Arrêt en cours' : active ? 'En cours' : 'Demande reçue', onClose: stop,
      actions: Column(children: [
        if (error.isNotEmpty) Text(error, style: const TextStyle(color: oclicInk)),
        if (!active && client != null) ...[
          ElevatedButton(onPressed: approving == client.id || closing ? null : () => checkClickTime(client.id, () async {
            setState(() { approving = client.id; });
            // The native Login event, not this click, changes the authorized state.
            await bind.cmLoginRes(connId: client.id, res: true);
          }), child: Text(approving == client.id ? 'Connexion…' : 'Autoriser')),
          TextButton(onPressed: closing ? null : () async { await bind.cmLoginRes(connId: client.id, res: false); }, child: const Text('Refuser')),
        ] else ElevatedButton(onPressed: closing ? null : stop, child: Text(closing ? 'Déconnexion…' : 'Arrêter la session')),
        if (active && client != null && widget.model.showElevation)
          TextButton(onPressed: () => checkClickTime(client.id, () async {
            await bind.cmElevatePortable(connId: client.id);
          }), child: const Text('Autoriser les actions administrateur')),
      ]),
      child: Column(children: [
        Icon(active ? Icons.check_circle_outline : Icons.desktop_access_disabled_outlined, size: 48, color: oclicInk),
        const SizedBox(height: 20), oclicTitle(active ? 'Le technicien intervient' : 'Autoriser l’assistance ?'),
        const SizedBox(height: 12),
        Text(active ? 'Écran, clavier et souris partagés.' : 'Vérifiez cet identifiant avec Oclic.', textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: oclicInk)),
        const SizedBox(height: 24), oclicIdentity('Identifiant du poste distant', client?.peerId ?? ''),
      ]));
  }
}
