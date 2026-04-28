import 'package:flutter/material.dart';
import 'package:flutter_listin/authentication/models/mock_user.dart';
import 'package:flutter_listin/listins/data/database.dart';
import 'package:flutter_listin/listins/screens/widgets/home_drawer.dart';
import 'package:flutter_listin/listins/screens/widgets/home_listin_item.dart';
import '../models/listin.dart';
import 'widgets/listin_add_edit_modal.dart';
import 'widgets/listin_options_modal.dart';

class HomeScreen extends StatefulWidget {
  final MockUser user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AppDatabase _appdatabase;
  List<Listin> listListins = [];

  @override
  void initState() {
    _appdatabase = AppDatabase();
    getData();
    super.initState();
  }

  @override
  void dispose() {
    _appdatabase.close();
    super.dispose();
  }

  Widget _popMenuButtonBuilder(List<PopupMenuItem> listPopMenuItem) {
    return PopupMenuButton(
        itemBuilder: (BuildContext context) => listPopMenuItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HomeDrawer(user: widget.user),
      appBar: AppBar(
        title: const Text("Minhas listas"),
        actions: [
          _popMenuButtonBuilder([
            PopupMenuItem(
              child: const Text("Ordenar por nome"),
              onTap: () async {
                getData(orderByName: true);
              },
            ),
            PopupMenuItem(
              child: const Text("Ordenar por data de alteração"),
              onTap: () async {
                getData(orderByDateUpdate: true);
              },
            ),
          ]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (listListins.isEmpty)
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/bag.png"),
                  const SizedBox(height: 32),
                  const Text(
                    "Nenhuma lista ainda.\nVamos criar a primeira?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                return getData();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: ListView(
                  children: List.generate(
                    listListins.length,
                    (index) {
                      Listin listin = listListins[index];
                      return HomeListinItem(
                        listin: listin,
                        showOptionModal: showOptionModal,
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }

  showAddModal({Listin? listin}) {
    showAddEditListinModal(
        context: context,
        onRefresh: getData,
        model: listin,
        appDataBase: _appdatabase);
  }

  showOptionModal(Listin listin) {
    showListinOptionsModal(
      context: context,
      listin: listin,
      onRemove: remove,
    ).then((value) {
      if (value != null && value) {
        showAddModal(listin: listin);
      }
    });
  }

  getData({
    bool orderByName = false,
    bool orderByDateUpdate = false,
  }) async {
    List<Listin> listaListins = await _appdatabase.getListins(
      orderByDateUpdate: orderByDateUpdate,
      orderByName: orderByName,
    );

    setState(() {
      listListins = listaListins;
    });
  }

  void remove(Listin model) async {
    await _appdatabase.deleteListin(int.parse(model.id));
    getData();
  }
}
