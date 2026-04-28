import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_listin/listins/models/listin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

part "database.g.dart";

class ListinTable extends Table {
  IntColumn get id => integer().named("id").autoIncrement()();
  TextColumn get name => text().named("name").withLength(min: 4, max: 50)();
  TextColumn get obs => text().named("obs")();
  DateTimeColumn get dateCreate => dateTime().named("dateCreate")();
  DateTimeColumn get dateUpdate => dateTime().named("dateUpdate")();
}

@DriftDatabase(tables: [ListinTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<int> insertListin(Listin listin) async {
    ListinTableCompanion novaLinha = ListinTableCompanion(
      name: Value(listin.name),
      obs: Value(listin.obs),
      dateCreate: Value(listin.dateCreate),
      dateUpdate: Value(listin.dateUpdate),
    );
    return await into(listinTable).insert(novaLinha);
  }

  Future<List<Listin>> getListins({
    bool orderByName = false,
    bool orderByDateUpdate = false,
  }) async {
    List<Listin> temp = [];
    List<ListinTableData> listData = [];

    if (orderByName) {
      listData = await (select(listinTable)
            ..orderBy([(t) => OrderingTerm(expression: t.name)]))
          .get();
    } else if (orderByDateUpdate) {
      listData = await (select(listinTable)
            ..orderBy([(t) => OrderingTerm(expression: t.dateUpdate)]))
          .get();
    } else {
      listData = await select(listinTable).get();
    }

    for (ListinTableData row in listData) {
      temp.add(
        Listin(
          id: row.id.toString(),
          name: row.name,
          obs: row.obs,
          dateCreate: row.dateCreate,
          dateUpdate: row.dateUpdate,
        ),
      );
    }

    return temp;
  }

  Future<bool> updateListin(Listin listin) async {
    return await update(listinTable).replace(ListinTableCompanion(
      id: Value(int.parse(listin.id)),
      name: Value(listin.name),
      obs: Value(listin.obs),
      dateCreate: Value(listin.dateCreate),
      dateUpdate: Value(listin.dateUpdate),
    ));
  }

  Future<int> deleteListin(int id) async {
    return await (delete(listinTable)..where((row) => row.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
