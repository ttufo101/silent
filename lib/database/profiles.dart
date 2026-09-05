part of 'database.dart';

@DataClassName('RawProfile')
class Profiles extends Table {
  @override
  String get tableName => 'profiles';

  IntColumn get id => integer()();

  TextColumn get label => text()();

  TextColumn get currentGroupName => text().nullable()();

  TextColumn get overwriteType => textEnum<OverwriteType>()();

  IntColumn get scriptId => integer().nullable()();

  TextColumn get selectedMap => text().map(const StringMapConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [Profiles])
class ProfilesDao extends DatabaseAccessor<Database> with _$ProfilesDaoMixin {
  ProfilesDao(super.attachedDatabase);

  Selectable<Profile> query() {
    final stmt = profiles.select();
    stmt.orderBy([(t) => OrderingTerm.asc(t.id)]);
    return stmt.map((item) => item.toProfile());
  }

  Future<void> setAll(Iterable<Profile> profiles) async {
    await batch((b) async {
      setAllWithBatch(b, profiles);
    });
  }

  Future<void> putAll<T extends Table, D extends DataClass>(
    Iterable<Insertable<D>> items,
  ) async {
    await batch((b) async {
      putAllWithBatch(b, items);
    });
  }

  void putAllWithBatch<T extends Table, D extends DataClass>(
    Batch batch,
    Iterable<Insertable<D>> items,
  ) {
    batch.insertAllOnConflictUpdate(profiles, items);
  }

  Selectable<String> fileNames() {
    final query = profiles.selectOnly()..addColumns([profiles.id]);
    return query.map((row) => '${row.read(profiles.id)}.yaml');
  }

  void setAllWithBatch(Batch batch, Iterable<Profile> profiles) {
    final List<ProfilesCompanion> items = [];
    final List<int> ids = [];
    for (final profile in profiles) {
      ids.add(profile.id);
      items.add(profile.toCompanion());
    }

    this.profiles.setAll(batch, items, deleteFilter: (t) => t.id.isNotIn(ids));
  }
}

extension RawProfilExt on RawProfile {
  Profile toProfile() {
    return Profile(
      id: id,
      label: label,
      currentGroupName: currentGroupName,
      selectedMap: selectedMap,
      overwriteType: overwriteType,
      scriptId: scriptId,
    );
  }
}

extension ProfilesCompanionExt on Profile {
  ProfilesCompanion toCompanion() {
    return ProfilesCompanion.insert(
      id: Value(id),
      label: label,
      currentGroupName: Value(currentGroupName),
      selectedMap: selectedMap,
      overwriteType: overwriteType,
      scriptId: Value(scriptId),
    );
  }
}
