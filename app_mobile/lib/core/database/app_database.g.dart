// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta('lastAttemptAt');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt = GeneratedColumn<DateTime>(
    'last_attempt_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    entityType,
    entityId,
    operation,
    payloadJson,
    createdAt,
    retryCount,
    lastAttemptAt,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(data['payload_json']!, _payloadJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(data['last_attempt_at']!, _lastAttemptAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  /// The `clientOpId` (UUID v4) — see `MED100_DATABASE_DESIGN.md` §0 on
  /// idempotency. Using it directly as the primary key means a retried
  /// enqueue is naturally a no-op rather than a duplicate row.
  final String id;

  /// See §0a (local per-user table scoping) — required on every per-user
  /// local table so a shared/re-logged-in device can't cross-contaminate
  /// two users' pending writes.
  final String userId;

  /// `quiz_attempt | flashcard_grade | bookmark | settings |
  /// achievement_seen | note | note_folder`
  final String entityType;
  final String entityId;

  /// `create | update | delete` — `delete` added for `features/notes`
  /// (the first real drainer of this table, see `NotesSyncWorker`):
  /// unlike every entity type above, a note or folder can actually be
  /// deleted, not just created/edited, so the vocabulary needed a third
  /// value to tell the sync worker to remove the remote document rather
  /// than upsert it.
  final String operation;
  final String payloadJson;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? lastAttemptAt;

  /// `pending | in_flight | failed | synced`
  final String status;
  const OutboxData({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payloadJson,
    required this.createdAt,
    required this.retryCount,
    this.lastAttemptAt,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      userId: Value(userId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      status: Value(status),
    );
  }

  factory OutboxData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'status': serializer.toJson<String>(status),
    };
  }

  OutboxData copyWith({
    String? id,
    String? userId,
    String? entityType,
    String? entityId,
    String? operation,
    String? payloadJson,
    DateTime? createdAt,
    int? retryCount,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    String? status,
  }) => OutboxData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    lastAttemptAt: lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
    status: status ?? this.status,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      entityType: data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payloadJson: data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastAttemptAt: data.lastAttemptAt.present ? data.lastAttemptAt.value : this.lastAttemptAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    entityType,
    entityId,
    operation,
    payloadJson,
    createdAt,
    retryCount,
    lastAttemptAt,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.status == this.status);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<DateTime?> lastAttemptAt;
  final Value<String> status;
  final Value<int> rowid;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String id,
    required String userId,
    required String entityType,
    required String entityId,
    required String operation,
    required String payloadJson,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
    Value<DateTime?>? lastAttemptAt,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return OutboxCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPulledAtMeta = const VerificationMeta('lastPulledAt');
  @override
  late final GeneratedColumn<DateTime> lastPulledAt = GeneratedColumn<DateTime>(
    'last_pulled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPushedAtMeta = const VerificationMeta('lastPushedAt');
  @override
  late final GeneratedColumn<DateTime> lastPushedAt = GeneratedColumn<DateTime>(
    'last_pushed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, entityType, lastPulledAt, lastPushedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
        _lastPulledAtMeta,
        lastPulledAt.isAcceptableOrUnknown(data['last_pulled_at']!, _lastPulledAtMeta),
      );
    }
    if (data.containsKey('last_pushed_at')) {
      context.handle(
        _lastPushedAtMeta,
        lastPushedAt.isAcceptableOrUnknown(data['last_pushed_at']!, _lastPushedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, entityType};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      lastPulledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pulled_at'],
      ),
      lastPushedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pushed_at'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String userId;

  /// e.g. `topics`, `flashcards`, `mcqs`, `progress`, `notes`.
  final String entityType;
  final DateTime? lastPulledAt;
  final DateTime? lastPushedAt;
  const SyncStateData({
    required this.userId,
    required this.entityType,
    this.lastPulledAt,
    this.lastPushedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['entity_type'] = Variable<String>(entityType);
    if (!nullToAbsent || lastPulledAt != null) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt);
    }
    if (!nullToAbsent || lastPushedAt != null) {
      map['last_pushed_at'] = Variable<DateTime>(lastPushedAt);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      userId: Value(userId),
      entityType: Value(entityType),
      lastPulledAt: lastPulledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAt),
      lastPushedAt: lastPushedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushedAt),
    );
  }

  factory SyncStateData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      userId: serializer.fromJson<String>(json['userId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      lastPulledAt: serializer.fromJson<DateTime?>(json['lastPulledAt']),
      lastPushedAt: serializer.fromJson<DateTime?>(json['lastPushedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'entityType': serializer.toJson<String>(entityType),
      'lastPulledAt': serializer.toJson<DateTime?>(lastPulledAt),
      'lastPushedAt': serializer.toJson<DateTime?>(lastPushedAt),
    };
  }

  SyncStateData copyWith({
    String? userId,
    String? entityType,
    Value<DateTime?> lastPulledAt = const Value.absent(),
    Value<DateTime?> lastPushedAt = const Value.absent(),
  }) => SyncStateData(
    userId: userId ?? this.userId,
    entityType: entityType ?? this.entityType,
    lastPulledAt: lastPulledAt.present ? lastPulledAt.value : this.lastPulledAt,
    lastPushedAt: lastPushedAt.present ? lastPushedAt.value : this.lastPushedAt,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      userId: data.userId.present ? data.userId.value : this.userId,
      entityType: data.entityType.present ? data.entityType.value : this.entityType,
      lastPulledAt: data.lastPulledAt.present ? data.lastPulledAt.value : this.lastPulledAt,
      lastPushedAt: data.lastPushedAt.present ? data.lastPushedAt.value : this.lastPushedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, entityType, lastPulledAt, lastPushedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.userId == this.userId &&
          other.entityType == this.entityType &&
          other.lastPulledAt == this.lastPulledAt &&
          other.lastPushedAt == this.lastPushedAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> userId;
  final Value<String> entityType;
  final Value<DateTime?> lastPulledAt;
  final Value<DateTime?> lastPushedAt;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.userId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String userId,
    required String entityType,
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       entityType = Value(entityType);
  static Insertable<SyncStateData> custom({
    Expression<String>? userId,
    Expression<String>? entityType,
    Expression<DateTime>? lastPulledAt,
    Expression<DateTime>? lastPushedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (entityType != null) 'entity_type': entityType,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (lastPushedAt != null) 'last_pushed_at': lastPushedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? userId,
    Value<String>? entityType,
    Value<DateTime?>? lastPulledAt,
    Value<DateTime?>? lastPushedAt,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      lastPushedAt: lastPushedAt ?? this.lastPushedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt.value);
    }
    if (lastPushedAt.present) {
      map['last_pushed_at'] = Variable<DateTime>(lastPushedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChallengeProgressTable extends ChallengeProgress
    with TableInfo<$ChallengeProgressTable, ChallengeProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChallengeProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastActionDateMeta = const VerificationMeta('lastActionDate');
  @override
  late final GeneratedColumn<DateTime> lastActionDate = GeneratedColumn<DateTime>(
    'last_action_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedDaysJsonMeta = const VerificationMeta(
    'completedDaysJson',
  );
  @override
  late final GeneratedColumn<String> completedDaysJson = GeneratedColumn<String>(
    'completed_days_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _skippedDaysJsonMeta = const VerificationMeta('skippedDaysJson');
  @override
  late final GeneratedColumn<String> skippedDaysJson = GeneratedColumn<String>(
    'skipped_days_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _bookmarkedDaysJsonMeta = const VerificationMeta(
    'bookmarkedDaysJson',
  );
  @override
  late final GeneratedColumn<String> bookmarkedDaysJson = GeneratedColumn<String>(
    'bookmarked_days_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    startedAt,
    lastActionDate,
    completedDaysJson,
    skippedDaysJson,
    bookmarkedDaysJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'challenge_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChallengeProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('last_action_date')) {
      context.handle(
        _lastActionDateMeta,
        lastActionDate.isAcceptableOrUnknown(data['last_action_date']!, _lastActionDateMeta),
      );
    }
    if (data.containsKey('completed_days_json')) {
      context.handle(
        _completedDaysJsonMeta,
        completedDaysJson.isAcceptableOrUnknown(
          data['completed_days_json']!,
          _completedDaysJsonMeta,
        ),
      );
    }
    if (data.containsKey('skipped_days_json')) {
      context.handle(
        _skippedDaysJsonMeta,
        skippedDaysJson.isAcceptableOrUnknown(data['skipped_days_json']!, _skippedDaysJsonMeta),
      );
    }
    if (data.containsKey('bookmarked_days_json')) {
      context.handle(
        _bookmarkedDaysJsonMeta,
        bookmarkedDaysJson.isAcceptableOrUnknown(
          data['bookmarked_days_json']!,
          _bookmarkedDaysJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  ChallengeProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChallengeProgressData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      lastActionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_action_date'],
      ),
      completedDaysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_days_json'],
      )!,
      skippedDaysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skipped_days_json'],
      )!,
      bookmarkedDaysJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bookmarked_days_json'],
      )!,
    );
  }

  @override
  $ChallengeProgressTable createAlias(String alias) {
    return $ChallengeProgressTable(attachedDatabase, alias);
  }
}

class ChallengeProgressData extends DataClass implements Insertable<ChallengeProgressData> {
  final String userId;
  final DateTime startedAt;
  final DateTime? lastActionDate;
  final String completedDaysJson;
  final String skippedDaysJson;
  final String bookmarkedDaysJson;
  const ChallengeProgressData({
    required this.userId,
    required this.startedAt,
    this.lastActionDate,
    required this.completedDaysJson,
    required this.skippedDaysJson,
    required this.bookmarkedDaysJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || lastActionDate != null) {
      map['last_action_date'] = Variable<DateTime>(lastActionDate);
    }
    map['completed_days_json'] = Variable<String>(completedDaysJson);
    map['skipped_days_json'] = Variable<String>(skippedDaysJson);
    map['bookmarked_days_json'] = Variable<String>(bookmarkedDaysJson);
    return map;
  }

  ChallengeProgressCompanion toCompanion(bool nullToAbsent) {
    return ChallengeProgressCompanion(
      userId: Value(userId),
      startedAt: Value(startedAt),
      lastActionDate: lastActionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActionDate),
      completedDaysJson: Value(completedDaysJson),
      skippedDaysJson: Value(skippedDaysJson),
      bookmarkedDaysJson: Value(bookmarkedDaysJson),
    );
  }

  factory ChallengeProgressData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChallengeProgressData(
      userId: serializer.fromJson<String>(json['userId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      lastActionDate: serializer.fromJson<DateTime?>(json['lastActionDate']),
      completedDaysJson: serializer.fromJson<String>(json['completedDaysJson']),
      skippedDaysJson: serializer.fromJson<String>(json['skippedDaysJson']),
      bookmarkedDaysJson: serializer.fromJson<String>(json['bookmarkedDaysJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'lastActionDate': serializer.toJson<DateTime?>(lastActionDate),
      'completedDaysJson': serializer.toJson<String>(completedDaysJson),
      'skippedDaysJson': serializer.toJson<String>(skippedDaysJson),
      'bookmarkedDaysJson': serializer.toJson<String>(bookmarkedDaysJson),
    };
  }

  ChallengeProgressData copyWith({
    String? userId,
    DateTime? startedAt,
    Value<DateTime?> lastActionDate = const Value.absent(),
    String? completedDaysJson,
    String? skippedDaysJson,
    String? bookmarkedDaysJson,
  }) => ChallengeProgressData(
    userId: userId ?? this.userId,
    startedAt: startedAt ?? this.startedAt,
    lastActionDate: lastActionDate.present ? lastActionDate.value : this.lastActionDate,
    completedDaysJson: completedDaysJson ?? this.completedDaysJson,
    skippedDaysJson: skippedDaysJson ?? this.skippedDaysJson,
    bookmarkedDaysJson: bookmarkedDaysJson ?? this.bookmarkedDaysJson,
  );
  ChallengeProgressData copyWithCompanion(ChallengeProgressCompanion data) {
    return ChallengeProgressData(
      userId: data.userId.present ? data.userId.value : this.userId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastActionDate: data.lastActionDate.present ? data.lastActionDate.value : this.lastActionDate,
      completedDaysJson: data.completedDaysJson.present
          ? data.completedDaysJson.value
          : this.completedDaysJson,
      skippedDaysJson: data.skippedDaysJson.present
          ? data.skippedDaysJson.value
          : this.skippedDaysJson,
      bookmarkedDaysJson: data.bookmarkedDaysJson.present
          ? data.bookmarkedDaysJson.value
          : this.bookmarkedDaysJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeProgressData(')
          ..write('userId: $userId, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastActionDate: $lastActionDate, ')
          ..write('completedDaysJson: $completedDaysJson, ')
          ..write('skippedDaysJson: $skippedDaysJson, ')
          ..write('bookmarkedDaysJson: $bookmarkedDaysJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    startedAt,
    lastActionDate,
    completedDaysJson,
    skippedDaysJson,
    bookmarkedDaysJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChallengeProgressData &&
          other.userId == this.userId &&
          other.startedAt == this.startedAt &&
          other.lastActionDate == this.lastActionDate &&
          other.completedDaysJson == this.completedDaysJson &&
          other.skippedDaysJson == this.skippedDaysJson &&
          other.bookmarkedDaysJson == this.bookmarkedDaysJson);
}

class ChallengeProgressCompanion extends UpdateCompanion<ChallengeProgressData> {
  final Value<String> userId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> lastActionDate;
  final Value<String> completedDaysJson;
  final Value<String> skippedDaysJson;
  final Value<String> bookmarkedDaysJson;
  final Value<int> rowid;
  const ChallengeProgressCompanion({
    this.userId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastActionDate = const Value.absent(),
    this.completedDaysJson = const Value.absent(),
    this.skippedDaysJson = const Value.absent(),
    this.bookmarkedDaysJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChallengeProgressCompanion.insert({
    required String userId,
    required DateTime startedAt,
    this.lastActionDate = const Value.absent(),
    this.completedDaysJson = const Value.absent(),
    this.skippedDaysJson = const Value.absent(),
    this.bookmarkedDaysJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       startedAt = Value(startedAt);
  static Insertable<ChallengeProgressData> custom({
    Expression<String>? userId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? lastActionDate,
    Expression<String>? completedDaysJson,
    Expression<String>? skippedDaysJson,
    Expression<String>? bookmarkedDaysJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (startedAt != null) 'started_at': startedAt,
      if (lastActionDate != null) 'last_action_date': lastActionDate,
      if (completedDaysJson != null) 'completed_days_json': completedDaysJson,
      if (skippedDaysJson != null) 'skipped_days_json': skippedDaysJson,
      if (bookmarkedDaysJson != null) 'bookmarked_days_json': bookmarkedDaysJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChallengeProgressCompanion copyWith({
    Value<String>? userId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? lastActionDate,
    Value<String>? completedDaysJson,
    Value<String>? skippedDaysJson,
    Value<String>? bookmarkedDaysJson,
    Value<int>? rowid,
  }) {
    return ChallengeProgressCompanion(
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      lastActionDate: lastActionDate ?? this.lastActionDate,
      completedDaysJson: completedDaysJson ?? this.completedDaysJson,
      skippedDaysJson: skippedDaysJson ?? this.skippedDaysJson,
      bookmarkedDaysJson: bookmarkedDaysJson ?? this.bookmarkedDaysJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (lastActionDate.present) {
      map['last_action_date'] = Variable<DateTime>(lastActionDate.value);
    }
    if (completedDaysJson.present) {
      map['completed_days_json'] = Variable<String>(completedDaysJson.value);
    }
    if (skippedDaysJson.present) {
      map['skipped_days_json'] = Variable<String>(skippedDaysJson.value);
    }
    if (bookmarkedDaysJson.present) {
      map['bookmarked_days_json'] = Variable<String>(bookmarkedDaysJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeProgressCompanion(')
          ..write('userId: $userId, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastActionDate: $lastActionDate, ')
          ..write('completedDaysJson: $completedDaysJson, ')
          ..write('skippedDaysJson: $skippedDaysJson, ')
          ..write('bookmarkedDaysJson: $bookmarkedDaysJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderPreferenceTable extends ReminderPreference
    with TableInfo<$ReminderPreferenceTable, ReminderPreferenceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderPreferenceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(19),
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _timezoneIdMeta = const VerificationMeta('timezoneId');
  @override
  late final GeneratedColumn<String> timezoneId = GeneratedColumn<String>(
    'timezone_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastNotifiedDateMeta = const VerificationMeta('lastNotifiedDate');
  @override
  late final GeneratedColumn<DateTime> lastNotifiedDate = GeneratedColumn<DateTime>(
    'last_notified_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    enabled,
    hour,
    minute,
    timezoneId,
    lastNotifiedDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_preference';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderPreferenceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta, enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    if (data.containsKey('hour')) {
      context.handle(_hourMeta, hour.isAcceptableOrUnknown(data['hour']!, _hourMeta));
    }
    if (data.containsKey('minute')) {
      context.handle(_minuteMeta, minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta));
    }
    if (data.containsKey('timezone_id')) {
      context.handle(
        _timezoneIdMeta,
        timezoneId.isAcceptableOrUnknown(data['timezone_id']!, _timezoneIdMeta),
      );
    }
    if (data.containsKey('last_notified_date')) {
      context.handle(
        _lastNotifiedDateMeta,
        lastNotifiedDate.isAcceptableOrUnknown(data['last_notified_date']!, _lastNotifiedDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  ReminderPreferenceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderPreferenceData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      hour: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}hour'])!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      )!,
      timezoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone_id'],
      ),
      lastNotifiedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_notified_date'],
      ),
    );
  }

  @override
  $ReminderPreferenceTable createAlias(String alias) {
    return $ReminderPreferenceTable(attachedDatabase, alias);
  }
}

class ReminderPreferenceData extends DataClass implements Insertable<ReminderPreferenceData> {
  final String userId;
  final bool enabled;
  final int hour;
  final int minute;

  /// The IANA timezone identifier the daily notification was last
  /// scheduled against — compared to the device's current timezone on
  /// every app resume so travel across timezones triggers a reschedule
  /// instead of silently firing at the wrong local time.
  final String? timezoneId;

  /// The last calendar date (local, time-of-day stripped) a reminder
  /// notification was actually shown for — local-schedule fire, FCM
  /// fallback, or missed-reminder catch-up alike. Drives both
  /// duplicate-suppression (don't catch-up twice in one day) and
  /// missed-reminder detection (today's slot passed with nothing logged).
  final DateTime? lastNotifiedDate;
  const ReminderPreferenceData({
    required this.userId,
    required this.enabled,
    required this.hour,
    required this.minute,
    this.timezoneId,
    this.lastNotifiedDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['enabled'] = Variable<bool>(enabled);
    map['hour'] = Variable<int>(hour);
    map['minute'] = Variable<int>(minute);
    if (!nullToAbsent || timezoneId != null) {
      map['timezone_id'] = Variable<String>(timezoneId);
    }
    if (!nullToAbsent || lastNotifiedDate != null) {
      map['last_notified_date'] = Variable<DateTime>(lastNotifiedDate);
    }
    return map;
  }

  ReminderPreferenceCompanion toCompanion(bool nullToAbsent) {
    return ReminderPreferenceCompanion(
      userId: Value(userId),
      enabled: Value(enabled),
      hour: Value(hour),
      minute: Value(minute),
      timezoneId: timezoneId == null && nullToAbsent ? const Value.absent() : Value(timezoneId),
      lastNotifiedDate: lastNotifiedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastNotifiedDate),
    );
  }

  factory ReminderPreferenceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderPreferenceData(
      userId: serializer.fromJson<String>(json['userId']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      hour: serializer.fromJson<int>(json['hour']),
      minute: serializer.fromJson<int>(json['minute']),
      timezoneId: serializer.fromJson<String?>(json['timezoneId']),
      lastNotifiedDate: serializer.fromJson<DateTime?>(json['lastNotifiedDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'enabled': serializer.toJson<bool>(enabled),
      'hour': serializer.toJson<int>(hour),
      'minute': serializer.toJson<int>(minute),
      'timezoneId': serializer.toJson<String?>(timezoneId),
      'lastNotifiedDate': serializer.toJson<DateTime?>(lastNotifiedDate),
    };
  }

  ReminderPreferenceData copyWith({
    String? userId,
    bool? enabled,
    int? hour,
    int? minute,
    Value<String?> timezoneId = const Value.absent(),
    Value<DateTime?> lastNotifiedDate = const Value.absent(),
  }) => ReminderPreferenceData(
    userId: userId ?? this.userId,
    enabled: enabled ?? this.enabled,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    timezoneId: timezoneId.present ? timezoneId.value : this.timezoneId,
    lastNotifiedDate: lastNotifiedDate.present ? lastNotifiedDate.value : this.lastNotifiedDate,
  );
  ReminderPreferenceData copyWithCompanion(ReminderPreferenceCompanion data) {
    return ReminderPreferenceData(
      userId: data.userId.present ? data.userId.value : this.userId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      hour: data.hour.present ? data.hour.value : this.hour,
      minute: data.minute.present ? data.minute.value : this.minute,
      timezoneId: data.timezoneId.present ? data.timezoneId.value : this.timezoneId,
      lastNotifiedDate: data.lastNotifiedDate.present
          ? data.lastNotifiedDate.value
          : this.lastNotifiedDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderPreferenceData(')
          ..write('userId: $userId, ')
          ..write('enabled: $enabled, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('timezoneId: $timezoneId, ')
          ..write('lastNotifiedDate: $lastNotifiedDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, enabled, hour, minute, timezoneId, lastNotifiedDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderPreferenceData &&
          other.userId == this.userId &&
          other.enabled == this.enabled &&
          other.hour == this.hour &&
          other.minute == this.minute &&
          other.timezoneId == this.timezoneId &&
          other.lastNotifiedDate == this.lastNotifiedDate);
}

class ReminderPreferenceCompanion extends UpdateCompanion<ReminderPreferenceData> {
  final Value<String> userId;
  final Value<bool> enabled;
  final Value<int> hour;
  final Value<int> minute;
  final Value<String?> timezoneId;
  final Value<DateTime?> lastNotifiedDate;
  final Value<int> rowid;
  const ReminderPreferenceCompanion({
    this.userId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.timezoneId = const Value.absent(),
    this.lastNotifiedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderPreferenceCompanion.insert({
    required String userId,
    this.enabled = const Value.absent(),
    this.hour = const Value.absent(),
    this.minute = const Value.absent(),
    this.timezoneId = const Value.absent(),
    this.lastNotifiedDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<ReminderPreferenceData> custom({
    Expression<String>? userId,
    Expression<bool>? enabled,
    Expression<int>? hour,
    Expression<int>? minute,
    Expression<String>? timezoneId,
    Expression<DateTime>? lastNotifiedDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (enabled != null) 'enabled': enabled,
      if (hour != null) 'hour': hour,
      if (minute != null) 'minute': minute,
      if (timezoneId != null) 'timezone_id': timezoneId,
      if (lastNotifiedDate != null) 'last_notified_date': lastNotifiedDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderPreferenceCompanion copyWith({
    Value<String>? userId,
    Value<bool>? enabled,
    Value<int>? hour,
    Value<int>? minute,
    Value<String?>? timezoneId,
    Value<DateTime?>? lastNotifiedDate,
    Value<int>? rowid,
  }) {
    return ReminderPreferenceCompanion(
      userId: userId ?? this.userId,
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      timezoneId: timezoneId ?? this.timezoneId,
      lastNotifiedDate: lastNotifiedDate ?? this.lastNotifiedDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (timezoneId.present) {
      map['timezone_id'] = Variable<String>(timezoneId.value);
    }
    if (lastNotifiedDate.present) {
      map['last_notified_date'] = Variable<DateTime>(lastNotifiedDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderPreferenceCompanion(')
          ..write('userId: $userId, ')
          ..write('enabled: $enabled, ')
          ..write('hour: $hour, ')
          ..write('minute: $minute, ')
          ..write('timezoneId: $timezoneId, ')
          ..write('lastNotifiedDate: $lastNotifiedDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationLogTable extends NotificationLog
    with TableInfo<$NotificationLogTable, NotificationLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _deepLinkMeta = const VerificationMeta('deepLink');
  @override
  late final GeneratedColumn<String> deepLink = GeneratedColumn<String>(
    'deep_link',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta('receivedAt');
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    type,
    title,
    body,
    payloadJson,
    deepLink,
    receivedAt,
    readAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(data['payload_json']!, _payloadJsonMeta),
      );
    }
    if (data.containsKey('deep_link')) {
      context.handle(
        _deepLinkMeta,
        deepLink.isAcceptableOrUnknown(data['deep_link']!, _deepLinkMeta),
      );
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(_readAtMeta, readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationLogData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      deepLink: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deep_link'],
      ),
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
    );
  }

  @override
  $NotificationLogTable createAlias(String alias) {
    return $NotificationLogTable(attachedDatabase, alias);
  }
}

class NotificationLogData extends DataClass implements Insertable<NotificationLogData> {
  final String id;
  final String userId;

  /// `daily_reminder | streak_risk | achievement | billing` — only
  /// `daily_reminder` is actually produced by this codebase today.
  final String type;
  final String title;
  final String body;
  final String payloadJson;
  final String? deepLink;
  final DateTime receivedAt;
  final DateTime? readAt;
  const NotificationLogData({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.payloadJson,
    this.deepLink,
    required this.receivedAt,
    this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['payload_json'] = Variable<String>(payloadJson);
    if (!nullToAbsent || deepLink != null) {
      map['deep_link'] = Variable<String>(deepLink);
    }
    map['received_at'] = Variable<DateTime>(receivedAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    return map;
  }

  NotificationLogCompanion toCompanion(bool nullToAbsent) {
    return NotificationLogCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      payloadJson: Value(payloadJson),
      deepLink: deepLink == null && nullToAbsent ? const Value.absent() : Value(deepLink),
      receivedAt: Value(receivedAt),
      readAt: readAt == null && nullToAbsent ? const Value.absent() : Value(readAt),
    );
  }

  factory NotificationLogData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationLogData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      deepLink: serializer.fromJson<String?>(json['deepLink']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'deepLink': serializer.toJson<String?>(deepLink),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
    };
  }

  NotificationLogData copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? body,
    String? payloadJson,
    Value<String?> deepLink = const Value.absent(),
    DateTime? receivedAt,
    Value<DateTime?> readAt = const Value.absent(),
  }) => NotificationLogData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    title: title ?? this.title,
    body: body ?? this.body,
    payloadJson: payloadJson ?? this.payloadJson,
    deepLink: deepLink.present ? deepLink.value : this.deepLink,
    receivedAt: receivedAt ?? this.receivedAt,
    readAt: readAt.present ? readAt.value : this.readAt,
  );
  NotificationLogData copyWithCompanion(NotificationLogCompanion data) {
    return NotificationLogData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      payloadJson: data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      deepLink: data.deepLink.present ? data.deepLink.value : this.deepLink,
      receivedAt: data.receivedAt.present ? data.receivedAt.value : this.receivedAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('deepLink: $deepLink, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, type, title, body, payloadJson, deepLink, receivedAt, readAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationLogData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.payloadJson == this.payloadJson &&
          other.deepLink == this.deepLink &&
          other.receivedAt == this.receivedAt &&
          other.readAt == this.readAt);
}

class NotificationLogCompanion extends UpdateCompanion<NotificationLogData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<String> payloadJson;
  final Value<String?> deepLink;
  final Value<DateTime> receivedAt;
  final Value<DateTime?> readAt;
  final Value<int> rowid;
  const NotificationLogCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.deepLink = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationLogCompanion.insert({
    required String id,
    required String userId,
    required String type,
    required String title,
    required String body,
    this.payloadJson = const Value.absent(),
    this.deepLink = const Value.absent(),
    required DateTime receivedAt,
    this.readAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       type = Value(type),
       title = Value(title),
       body = Value(body),
       receivedAt = Value(receivedAt);
  static Insertable<NotificationLogData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? payloadJson,
    Expression<String>? deepLink,
    Expression<DateTime>? receivedAt,
    Expression<DateTime>? readAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (deepLink != null) 'deep_link': deepLink,
      if (receivedAt != null) 'received_at': receivedAt,
      if (readAt != null) 'read_at': readAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationLogCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? type,
    Value<String>? title,
    Value<String>? body,
    Value<String>? payloadJson,
    Value<String?>? deepLink,
    Value<DateTime>? receivedAt,
    Value<DateTime?>? readAt,
    Value<int>? rowid,
  }) {
    return NotificationLogCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      payloadJson: payloadJson ?? this.payloadJson,
      deepLink: deepLink ?? this.deepLink,
      receivedAt: receivedAt ?? this.receivedAt,
      readAt: readAt ?? this.readAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (deepLink.present) {
      map['deep_link'] = Variable<String>(deepLink.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationLogCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('deepLink: $deepLink, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('readAt: $readAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiCacheLocalTable extends AiCacheLocal with TableInfo<$AiCacheLocalTable, AiCacheLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiCacheLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta('cacheKey');
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta('itemType');
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cacheKey, itemType, itemId, content, fetchedAt, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_cache_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiCacheLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta, itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta, content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  AiCacheLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiCacheLocalData(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $AiCacheLocalTable createAlias(String alias) {
    return $AiCacheLocalTable(attachedDatabase, alias);
  }
}

class AiCacheLocalData extends DataClass implements Insertable<AiCacheLocalData> {
  final String cacheKey;

  /// `mcq | topic | flashcard` — mirrors the docs' `itemType`.
  final String itemType;
  final String itemId;
  final String content;
  final DateTime fetchedAt;
  final DateTime expiresAt;
  const AiCacheLocalData({
    required this.cacheKey,
    required this.itemType,
    required this.itemId,
    required this.content,
    required this.fetchedAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['item_type'] = Variable<String>(itemType);
    map['item_id'] = Variable<String>(itemId);
    map['content'] = Variable<String>(content);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  AiCacheLocalCompanion toCompanion(bool nullToAbsent) {
    return AiCacheLocalCompanion(
      cacheKey: Value(cacheKey),
      itemType: Value(itemType),
      itemId: Value(itemId),
      content: Value(content),
      fetchedAt: Value(fetchedAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory AiCacheLocalData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiCacheLocalData(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      itemType: serializer.fromJson<String>(json['itemType']),
      itemId: serializer.fromJson<String>(json['itemId']),
      content: serializer.fromJson<String>(json['content']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'itemType': serializer.toJson<String>(itemType),
      'itemId': serializer.toJson<String>(itemId),
      'content': serializer.toJson<String>(content),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  AiCacheLocalData copyWith({
    String? cacheKey,
    String? itemType,
    String? itemId,
    String? content,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  }) => AiCacheLocalData(
    cacheKey: cacheKey ?? this.cacheKey,
    itemType: itemType ?? this.itemType,
    itemId: itemId ?? this.itemId,
    content: content ?? this.content,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  AiCacheLocalData copyWithCompanion(AiCacheLocalCompanion data) {
    return AiCacheLocalData(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      content: data.content.present ? data.content.value : this.content,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiCacheLocalData(')
          ..write('cacheKey: $cacheKey, ')
          ..write('itemType: $itemType, ')
          ..write('itemId: $itemId, ')
          ..write('content: $content, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, itemType, itemId, content, fetchedAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiCacheLocalData &&
          other.cacheKey == this.cacheKey &&
          other.itemType == this.itemType &&
          other.itemId == this.itemId &&
          other.content == this.content &&
          other.fetchedAt == this.fetchedAt &&
          other.expiresAt == this.expiresAt);
}

class AiCacheLocalCompanion extends UpdateCompanion<AiCacheLocalData> {
  final Value<String> cacheKey;
  final Value<String> itemType;
  final Value<String> itemId;
  final Value<String> content;
  final Value<DateTime> fetchedAt;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const AiCacheLocalCompanion({
    this.cacheKey = const Value.absent(),
    this.itemType = const Value.absent(),
    this.itemId = const Value.absent(),
    this.content = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiCacheLocalCompanion.insert({
    required String cacheKey,
    required String itemType,
    required String itemId,
    required String content,
    required DateTime fetchedAt,
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       itemType = Value(itemType),
       itemId = Value(itemId),
       content = Value(content),
       fetchedAt = Value(fetchedAt),
       expiresAt = Value(expiresAt);
  static Insertable<AiCacheLocalData> custom({
    Expression<String>? cacheKey,
    Expression<String>? itemType,
    Expression<String>? itemId,
    Expression<String>? content,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (itemType != null) 'item_type': itemType,
      if (itemId != null) 'item_id': itemId,
      if (content != null) 'content': content,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiCacheLocalCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? itemType,
    Value<String>? itemId,
    Value<String>? content,
    Value<DateTime>? fetchedAt,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return AiCacheLocalCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      content: content ?? this.content,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiCacheLocalCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('itemType: $itemType, ')
          ..write('itemId: $itemId, ')
          ..write('content: $content, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeachingSessionsTable extends TeachingSessions
    with TableInfo<$TeachingSessionsTable, TeachingSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeachingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicTitleMeta = const VerificationMeta('topicTitle');
  @override
  late final GeneratedColumn<String> topicTitle = GeneratedColumn<String>(
    'topic_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationTextMeta = const VerificationMeta('explanationText');
  @override
  late final GeneratedColumn<String> explanationText = GeneratedColumn<String>(
    'explanation_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyScoreMeta = const VerificationMeta('accuracyScore');
  @override
  late final GeneratedColumn<int> accuracyScore = GeneratedColumn<int>(
    'accuracy_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clinicalReasoningScoreMeta = const VerificationMeta(
    'clinicalReasoningScore',
  );
  @override
  late final GeneratedColumn<int> clinicalReasoningScore = GeneratedColumn<int>(
    'clinical_reasoning_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completenessScoreMeta = const VerificationMeta(
    'completenessScore',
  );
  @override
  late final GeneratedColumn<int> completenessScore = GeneratedColumn<int>(
    'completeness_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceScoreMeta = const VerificationMeta('confidenceScore');
  @override
  late final GeneratedColumn<int> confidenceScore = GeneratedColumn<int>(
    'confidence_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _missingConceptsJsonMeta = const VerificationMeta(
    'missingConceptsJson',
  );
  @override
  late final GeneratedColumn<String> missingConceptsJson = GeneratedColumn<String>(
    'missing_concepts_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _hallucinationsJsonMeta = const VerificationMeta(
    'hallucinationsJson',
  );
  @override
  late final GeneratedColumn<String> hallucinationsJson = GeneratedColumn<String>(
    'hallucinations_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _feedbackMeta = const VerificationMeta('feedback');
  @override
  late final GeneratedColumn<String> feedback = GeneratedColumn<String>(
    'feedback',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _masteryScoreMeta = const VerificationMeta('masteryScore');
  @override
  late final GeneratedColumn<int> masteryScore = GeneratedColumn<int>(
    'mastery_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    topicId,
    topicTitle,
    mode,
    explanationText,
    accuracyScore,
    clinicalReasoningScore,
    completenessScore,
    confidenceScore,
    missingConceptsJson,
    hallucinationsJson,
    feedback,
    masteryScore,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teaching_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeachingSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta, topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('topic_title')) {
      context.handle(
        _topicTitleMeta,
        topicTitle.isAcceptableOrUnknown(data['topic_title']!, _topicTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_topicTitleMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(_modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('explanation_text')) {
      context.handle(
        _explanationTextMeta,
        explanationText.isAcceptableOrUnknown(data['explanation_text']!, _explanationTextMeta),
      );
    } else if (isInserting) {
      context.missing(_explanationTextMeta);
    }
    if (data.containsKey('accuracy_score')) {
      context.handle(
        _accuracyScoreMeta,
        accuracyScore.isAcceptableOrUnknown(data['accuracy_score']!, _accuracyScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyScoreMeta);
    }
    if (data.containsKey('clinical_reasoning_score')) {
      context.handle(
        _clinicalReasoningScoreMeta,
        clinicalReasoningScore.isAcceptableOrUnknown(
          data['clinical_reasoning_score']!,
          _clinicalReasoningScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clinicalReasoningScoreMeta);
    }
    if (data.containsKey('completeness_score')) {
      context.handle(
        _completenessScoreMeta,
        completenessScore.isAcceptableOrUnknown(
          data['completeness_score']!,
          _completenessScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completenessScoreMeta);
    }
    if (data.containsKey('confidence_score')) {
      context.handle(
        _confidenceScoreMeta,
        confidenceScore.isAcceptableOrUnknown(data['confidence_score']!, _confidenceScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceScoreMeta);
    }
    if (data.containsKey('missing_concepts_json')) {
      context.handle(
        _missingConceptsJsonMeta,
        missingConceptsJson.isAcceptableOrUnknown(
          data['missing_concepts_json']!,
          _missingConceptsJsonMeta,
        ),
      );
    }
    if (data.containsKey('hallucinations_json')) {
      context.handle(
        _hallucinationsJsonMeta,
        hallucinationsJson.isAcceptableOrUnknown(
          data['hallucinations_json']!,
          _hallucinationsJsonMeta,
        ),
      );
    }
    if (data.containsKey('feedback')) {
      context.handle(
        _feedbackMeta,
        feedback.isAcceptableOrUnknown(data['feedback']!, _feedbackMeta),
      );
    } else if (isInserting) {
      context.missing(_feedbackMeta);
    }
    if (data.containsKey('mastery_score')) {
      context.handle(
        _masteryScoreMeta,
        masteryScore.isAcceptableOrUnknown(data['mastery_score']!, _masteryScoreMeta),
      );
    } else if (isInserting) {
      context.missing(_masteryScoreMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeachingSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeachingSessionRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
      topicTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_title'],
      )!,
      mode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      explanationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation_text'],
      )!,
      accuracyScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy_score'],
      )!,
      clinicalReasoningScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}clinical_reasoning_score'],
      )!,
      completenessScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completeness_score'],
      )!,
      confidenceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confidence_score'],
      )!,
      missingConceptsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}missing_concepts_json'],
      )!,
      hallucinationsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hallucinations_json'],
      )!,
      feedback: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback'],
      )!,
      masteryScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mastery_score'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $TeachingSessionsTable createAlias(String alias) {
    return $TeachingSessionsTable(attachedDatabase, alias);
  }
}

class TeachingSessionRow extends DataClass implements Insertable<TeachingSessionRow> {
  final String id;
  final String userId;
  final String topicId;
  final String topicTitle;

  /// `voice | written`.
  final String mode;
  final String explanationText;
  final int accuracyScore;
  final int clinicalReasoningScore;
  final int completenessScore;
  final int confidenceScore;
  final String missingConceptsJson;
  final String hallucinationsJson;
  final String feedback;

  /// Stored rather than only re-derived, so history queries (e.g. "best
  /// score for this topic") don't need to load and recompute every row.
  final int masteryScore;
  final DateTime completedAt;
  const TeachingSessionRow({
    required this.id,
    required this.userId,
    required this.topicId,
    required this.topicTitle,
    required this.mode,
    required this.explanationText,
    required this.accuracyScore,
    required this.clinicalReasoningScore,
    required this.completenessScore,
    required this.confidenceScore,
    required this.missingConceptsJson,
    required this.hallucinationsJson,
    required this.feedback,
    required this.masteryScore,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['topic_id'] = Variable<String>(topicId);
    map['topic_title'] = Variable<String>(topicTitle);
    map['mode'] = Variable<String>(mode);
    map['explanation_text'] = Variable<String>(explanationText);
    map['accuracy_score'] = Variable<int>(accuracyScore);
    map['clinical_reasoning_score'] = Variable<int>(clinicalReasoningScore);
    map['completeness_score'] = Variable<int>(completenessScore);
    map['confidence_score'] = Variable<int>(confidenceScore);
    map['missing_concepts_json'] = Variable<String>(missingConceptsJson);
    map['hallucinations_json'] = Variable<String>(hallucinationsJson);
    map['feedback'] = Variable<String>(feedback);
    map['mastery_score'] = Variable<int>(masteryScore);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  TeachingSessionsCompanion toCompanion(bool nullToAbsent) {
    return TeachingSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      topicId: Value(topicId),
      topicTitle: Value(topicTitle),
      mode: Value(mode),
      explanationText: Value(explanationText),
      accuracyScore: Value(accuracyScore),
      clinicalReasoningScore: Value(clinicalReasoningScore),
      completenessScore: Value(completenessScore),
      confidenceScore: Value(confidenceScore),
      missingConceptsJson: Value(missingConceptsJson),
      hallucinationsJson: Value(hallucinationsJson),
      feedback: Value(feedback),
      masteryScore: Value(masteryScore),
      completedAt: Value(completedAt),
    );
  }

  factory TeachingSessionRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeachingSessionRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      topicId: serializer.fromJson<String>(json['topicId']),
      topicTitle: serializer.fromJson<String>(json['topicTitle']),
      mode: serializer.fromJson<String>(json['mode']),
      explanationText: serializer.fromJson<String>(json['explanationText']),
      accuracyScore: serializer.fromJson<int>(json['accuracyScore']),
      clinicalReasoningScore: serializer.fromJson<int>(json['clinicalReasoningScore']),
      completenessScore: serializer.fromJson<int>(json['completenessScore']),
      confidenceScore: serializer.fromJson<int>(json['confidenceScore']),
      missingConceptsJson: serializer.fromJson<String>(json['missingConceptsJson']),
      hallucinationsJson: serializer.fromJson<String>(json['hallucinationsJson']),
      feedback: serializer.fromJson<String>(json['feedback']),
      masteryScore: serializer.fromJson<int>(json['masteryScore']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'topicId': serializer.toJson<String>(topicId),
      'topicTitle': serializer.toJson<String>(topicTitle),
      'mode': serializer.toJson<String>(mode),
      'explanationText': serializer.toJson<String>(explanationText),
      'accuracyScore': serializer.toJson<int>(accuracyScore),
      'clinicalReasoningScore': serializer.toJson<int>(clinicalReasoningScore),
      'completenessScore': serializer.toJson<int>(completenessScore),
      'confidenceScore': serializer.toJson<int>(confidenceScore),
      'missingConceptsJson': serializer.toJson<String>(missingConceptsJson),
      'hallucinationsJson': serializer.toJson<String>(hallucinationsJson),
      'feedback': serializer.toJson<String>(feedback),
      'masteryScore': serializer.toJson<int>(masteryScore),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  TeachingSessionRow copyWith({
    String? id,
    String? userId,
    String? topicId,
    String? topicTitle,
    String? mode,
    String? explanationText,
    int? accuracyScore,
    int? clinicalReasoningScore,
    int? completenessScore,
    int? confidenceScore,
    String? missingConceptsJson,
    String? hallucinationsJson,
    String? feedback,
    int? masteryScore,
    DateTime? completedAt,
  }) => TeachingSessionRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    topicId: topicId ?? this.topicId,
    topicTitle: topicTitle ?? this.topicTitle,
    mode: mode ?? this.mode,
    explanationText: explanationText ?? this.explanationText,
    accuracyScore: accuracyScore ?? this.accuracyScore,
    clinicalReasoningScore: clinicalReasoningScore ?? this.clinicalReasoningScore,
    completenessScore: completenessScore ?? this.completenessScore,
    confidenceScore: confidenceScore ?? this.confidenceScore,
    missingConceptsJson: missingConceptsJson ?? this.missingConceptsJson,
    hallucinationsJson: hallucinationsJson ?? this.hallucinationsJson,
    feedback: feedback ?? this.feedback,
    masteryScore: masteryScore ?? this.masteryScore,
    completedAt: completedAt ?? this.completedAt,
  );
  TeachingSessionRow copyWithCompanion(TeachingSessionsCompanion data) {
    return TeachingSessionRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      topicTitle: data.topicTitle.present ? data.topicTitle.value : this.topicTitle,
      mode: data.mode.present ? data.mode.value : this.mode,
      explanationText: data.explanationText.present
          ? data.explanationText.value
          : this.explanationText,
      accuracyScore: data.accuracyScore.present ? data.accuracyScore.value : this.accuracyScore,
      clinicalReasoningScore: data.clinicalReasoningScore.present
          ? data.clinicalReasoningScore.value
          : this.clinicalReasoningScore,
      completenessScore: data.completenessScore.present
          ? data.completenessScore.value
          : this.completenessScore,
      confidenceScore: data.confidenceScore.present
          ? data.confidenceScore.value
          : this.confidenceScore,
      missingConceptsJson: data.missingConceptsJson.present
          ? data.missingConceptsJson.value
          : this.missingConceptsJson,
      hallucinationsJson: data.hallucinationsJson.present
          ? data.hallucinationsJson.value
          : this.hallucinationsJson,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
      masteryScore: data.masteryScore.present ? data.masteryScore.value : this.masteryScore,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeachingSessionRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('topicId: $topicId, ')
          ..write('topicTitle: $topicTitle, ')
          ..write('mode: $mode, ')
          ..write('explanationText: $explanationText, ')
          ..write('accuracyScore: $accuracyScore, ')
          ..write('clinicalReasoningScore: $clinicalReasoningScore, ')
          ..write('completenessScore: $completenessScore, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('missingConceptsJson: $missingConceptsJson, ')
          ..write('hallucinationsJson: $hallucinationsJson, ')
          ..write('feedback: $feedback, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    topicId,
    topicTitle,
    mode,
    explanationText,
    accuracyScore,
    clinicalReasoningScore,
    completenessScore,
    confidenceScore,
    missingConceptsJson,
    hallucinationsJson,
    feedback,
    masteryScore,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeachingSessionRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.topicId == this.topicId &&
          other.topicTitle == this.topicTitle &&
          other.mode == this.mode &&
          other.explanationText == this.explanationText &&
          other.accuracyScore == this.accuracyScore &&
          other.clinicalReasoningScore == this.clinicalReasoningScore &&
          other.completenessScore == this.completenessScore &&
          other.confidenceScore == this.confidenceScore &&
          other.missingConceptsJson == this.missingConceptsJson &&
          other.hallucinationsJson == this.hallucinationsJson &&
          other.feedback == this.feedback &&
          other.masteryScore == this.masteryScore &&
          other.completedAt == this.completedAt);
}

class TeachingSessionsCompanion extends UpdateCompanion<TeachingSessionRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> topicId;
  final Value<String> topicTitle;
  final Value<String> mode;
  final Value<String> explanationText;
  final Value<int> accuracyScore;
  final Value<int> clinicalReasoningScore;
  final Value<int> completenessScore;
  final Value<int> confidenceScore;
  final Value<String> missingConceptsJson;
  final Value<String> hallucinationsJson;
  final Value<String> feedback;
  final Value<int> masteryScore;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const TeachingSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.topicTitle = const Value.absent(),
    this.mode = const Value.absent(),
    this.explanationText = const Value.absent(),
    this.accuracyScore = const Value.absent(),
    this.clinicalReasoningScore = const Value.absent(),
    this.completenessScore = const Value.absent(),
    this.confidenceScore = const Value.absent(),
    this.missingConceptsJson = const Value.absent(),
    this.hallucinationsJson = const Value.absent(),
    this.feedback = const Value.absent(),
    this.masteryScore = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeachingSessionsCompanion.insert({
    required String id,
    required String userId,
    required String topicId,
    required String topicTitle,
    required String mode,
    required String explanationText,
    required int accuracyScore,
    required int clinicalReasoningScore,
    required int completenessScore,
    required int confidenceScore,
    this.missingConceptsJson = const Value.absent(),
    this.hallucinationsJson = const Value.absent(),
    required String feedback,
    required int masteryScore,
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       topicId = Value(topicId),
       topicTitle = Value(topicTitle),
       mode = Value(mode),
       explanationText = Value(explanationText),
       accuracyScore = Value(accuracyScore),
       clinicalReasoningScore = Value(clinicalReasoningScore),
       completenessScore = Value(completenessScore),
       confidenceScore = Value(confidenceScore),
       feedback = Value(feedback),
       masteryScore = Value(masteryScore),
       completedAt = Value(completedAt);
  static Insertable<TeachingSessionRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? topicId,
    Expression<String>? topicTitle,
    Expression<String>? mode,
    Expression<String>? explanationText,
    Expression<int>? accuracyScore,
    Expression<int>? clinicalReasoningScore,
    Expression<int>? completenessScore,
    Expression<int>? confidenceScore,
    Expression<String>? missingConceptsJson,
    Expression<String>? hallucinationsJson,
    Expression<String>? feedback,
    Expression<int>? masteryScore,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (topicId != null) 'topic_id': topicId,
      if (topicTitle != null) 'topic_title': topicTitle,
      if (mode != null) 'mode': mode,
      if (explanationText != null) 'explanation_text': explanationText,
      if (accuracyScore != null) 'accuracy_score': accuracyScore,
      if (clinicalReasoningScore != null) 'clinical_reasoning_score': clinicalReasoningScore,
      if (completenessScore != null) 'completeness_score': completenessScore,
      if (confidenceScore != null) 'confidence_score': confidenceScore,
      if (missingConceptsJson != null) 'missing_concepts_json': missingConceptsJson,
      if (hallucinationsJson != null) 'hallucinations_json': hallucinationsJson,
      if (feedback != null) 'feedback': feedback,
      if (masteryScore != null) 'mastery_score': masteryScore,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeachingSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? topicId,
    Value<String>? topicTitle,
    Value<String>? mode,
    Value<String>? explanationText,
    Value<int>? accuracyScore,
    Value<int>? clinicalReasoningScore,
    Value<int>? completenessScore,
    Value<int>? confidenceScore,
    Value<String>? missingConceptsJson,
    Value<String>? hallucinationsJson,
    Value<String>? feedback,
    Value<int>? masteryScore,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return TeachingSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topicId: topicId ?? this.topicId,
      topicTitle: topicTitle ?? this.topicTitle,
      mode: mode ?? this.mode,
      explanationText: explanationText ?? this.explanationText,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      clinicalReasoningScore: clinicalReasoningScore ?? this.clinicalReasoningScore,
      completenessScore: completenessScore ?? this.completenessScore,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      missingConceptsJson: missingConceptsJson ?? this.missingConceptsJson,
      hallucinationsJson: hallucinationsJson ?? this.hallucinationsJson,
      feedback: feedback ?? this.feedback,
      masteryScore: masteryScore ?? this.masteryScore,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (topicTitle.present) {
      map['topic_title'] = Variable<String>(topicTitle.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (explanationText.present) {
      map['explanation_text'] = Variable<String>(explanationText.value);
    }
    if (accuracyScore.present) {
      map['accuracy_score'] = Variable<int>(accuracyScore.value);
    }
    if (clinicalReasoningScore.present) {
      map['clinical_reasoning_score'] = Variable<int>(clinicalReasoningScore.value);
    }
    if (completenessScore.present) {
      map['completeness_score'] = Variable<int>(completenessScore.value);
    }
    if (confidenceScore.present) {
      map['confidence_score'] = Variable<int>(confidenceScore.value);
    }
    if (missingConceptsJson.present) {
      map['missing_concepts_json'] = Variable<String>(missingConceptsJson.value);
    }
    if (hallucinationsJson.present) {
      map['hallucinations_json'] = Variable<String>(hallucinationsJson.value);
    }
    if (feedback.present) {
      map['feedback'] = Variable<String>(feedback.value);
    }
    if (masteryScore.present) {
      map['mastery_score'] = Variable<int>(masteryScore.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeachingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('topicId: $topicId, ')
          ..write('topicTitle: $topicTitle, ')
          ..write('mode: $mode, ')
          ..write('explanationText: $explanationText, ')
          ..write('accuracyScore: $accuracyScore, ')
          ..write('clinicalReasoningScore: $clinicalReasoningScore, ')
          ..write('completenessScore: $completenessScore, ')
          ..write('confidenceScore: $confidenceScore, ')
          ..write('missingConceptsJson: $missingConceptsJson, ')
          ..write('hallucinationsJson: $hallucinationsJson, ')
          ..write('feedback: $feedback, ')
          ..write('masteryScore: $masteryScore, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionCacheTable extends SubscriptionCache
    with TableInfo<$SubscriptionCacheTable, SubscriptionCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<String> tier = GeneratedColumn<String>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentPeriodEndMeta = const VerificationMeta('currentPeriodEnd');
  @override
  late final GeneratedColumn<DateTime> currentPeriodEnd = GeneratedColumn<DateTime>(
    'current_period_end',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _autoRenewMeta = const VerificationMeta('autoRenew');
  @override
  late final GeneratedColumn<bool> autoRenew = GeneratedColumn<bool>(
    'auto_renew',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("auto_renew" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    tier,
    status,
    currentPeriodEnd,
    autoRenew,
    source,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscriptionCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(_tierMeta, tier.isAcceptableOrUnknown(data['tier']!, _tierMeta));
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta, status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('current_period_end')) {
      context.handle(
        _currentPeriodEndMeta,
        currentPeriodEnd.isAcceptableOrUnknown(data['current_period_end']!, _currentPeriodEndMeta),
      );
    }
    if (data.containsKey('auto_renew')) {
      context.handle(
        _autoRenewMeta,
        autoRenew.isAcceptableOrUnknown(data['auto_renew']!, _autoRenewMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(data['last_synced_at']!, _lastSyncedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  SubscriptionCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionCacheData(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      tier: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}tier'])!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      currentPeriodEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}current_period_end'],
      ),
      autoRenew: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_renew'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      )!,
    );
  }

  @override
  $SubscriptionCacheTable createAlias(String alias) {
    return $SubscriptionCacheTable(attachedDatabase, alias);
  }
}

class SubscriptionCacheData extends DataClass implements Insertable<SubscriptionCacheData> {
  final String userId;
  final String tier;
  final String status;
  final DateTime? currentPeriodEnd;
  final bool autoRenew;
  final String source;
  final DateTime lastSyncedAt;
  const SubscriptionCacheData({
    required this.userId,
    required this.tier,
    required this.status,
    this.currentPeriodEnd,
    required this.autoRenew,
    required this.source,
    required this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['tier'] = Variable<String>(tier);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || currentPeriodEnd != null) {
      map['current_period_end'] = Variable<DateTime>(currentPeriodEnd);
    }
    map['auto_renew'] = Variable<bool>(autoRenew);
    map['source'] = Variable<String>(source);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    return map;
  }

  SubscriptionCacheCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionCacheCompanion(
      userId: Value(userId),
      tier: Value(tier),
      status: Value(status),
      currentPeriodEnd: currentPeriodEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPeriodEnd),
      autoRenew: Value(autoRenew),
      source: Value(source),
      lastSyncedAt: Value(lastSyncedAt),
    );
  }

  factory SubscriptionCacheData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionCacheData(
      userId: serializer.fromJson<String>(json['userId']),
      tier: serializer.fromJson<String>(json['tier']),
      status: serializer.fromJson<String>(json['status']),
      currentPeriodEnd: serializer.fromJson<DateTime?>(json['currentPeriodEnd']),
      autoRenew: serializer.fromJson<bool>(json['autoRenew']),
      source: serializer.fromJson<String>(json['source']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'tier': serializer.toJson<String>(tier),
      'status': serializer.toJson<String>(status),
      'currentPeriodEnd': serializer.toJson<DateTime?>(currentPeriodEnd),
      'autoRenew': serializer.toJson<bool>(autoRenew),
      'source': serializer.toJson<String>(source),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
    };
  }

  SubscriptionCacheData copyWith({
    String? userId,
    String? tier,
    String? status,
    Value<DateTime?> currentPeriodEnd = const Value.absent(),
    bool? autoRenew,
    String? source,
    DateTime? lastSyncedAt,
  }) => SubscriptionCacheData(
    userId: userId ?? this.userId,
    tier: tier ?? this.tier,
    status: status ?? this.status,
    currentPeriodEnd: currentPeriodEnd.present ? currentPeriodEnd.value : this.currentPeriodEnd,
    autoRenew: autoRenew ?? this.autoRenew,
    source: source ?? this.source,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
  );
  SubscriptionCacheData copyWithCompanion(SubscriptionCacheCompanion data) {
    return SubscriptionCacheData(
      userId: data.userId.present ? data.userId.value : this.userId,
      tier: data.tier.present ? data.tier.value : this.tier,
      status: data.status.present ? data.status.value : this.status,
      currentPeriodEnd: data.currentPeriodEnd.present
          ? data.currentPeriodEnd.value
          : this.currentPeriodEnd,
      autoRenew: data.autoRenew.present ? data.autoRenew.value : this.autoRenew,
      source: data.source.present ? data.source.value : this.source,
      lastSyncedAt: data.lastSyncedAt.present ? data.lastSyncedAt.value : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionCacheData(')
          ..write('userId: $userId, ')
          ..write('tier: $tier, ')
          ..write('status: $status, ')
          ..write('currentPeriodEnd: $currentPeriodEnd, ')
          ..write('autoRenew: $autoRenew, ')
          ..write('source: $source, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, tier, status, currentPeriodEnd, autoRenew, source, lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionCacheData &&
          other.userId == this.userId &&
          other.tier == this.tier &&
          other.status == this.status &&
          other.currentPeriodEnd == this.currentPeriodEnd &&
          other.autoRenew == this.autoRenew &&
          other.source == this.source &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class SubscriptionCacheCompanion extends UpdateCompanion<SubscriptionCacheData> {
  final Value<String> userId;
  final Value<String> tier;
  final Value<String> status;
  final Value<DateTime?> currentPeriodEnd;
  final Value<bool> autoRenew;
  final Value<String> source;
  final Value<DateTime> lastSyncedAt;
  final Value<int> rowid;
  const SubscriptionCacheCompanion({
    this.userId = const Value.absent(),
    this.tier = const Value.absent(),
    this.status = const Value.absent(),
    this.currentPeriodEnd = const Value.absent(),
    this.autoRenew = const Value.absent(),
    this.source = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionCacheCompanion.insert({
    required String userId,
    required String tier,
    required String status,
    this.currentPeriodEnd = const Value.absent(),
    this.autoRenew = const Value.absent(),
    required String source,
    required DateTime lastSyncedAt,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       tier = Value(tier),
       status = Value(status),
       source = Value(source),
       lastSyncedAt = Value(lastSyncedAt);
  static Insertable<SubscriptionCacheData> custom({
    Expression<String>? userId,
    Expression<String>? tier,
    Expression<String>? status,
    Expression<DateTime>? currentPeriodEnd,
    Expression<bool>? autoRenew,
    Expression<String>? source,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (tier != null) 'tier': tier,
      if (status != null) 'status': status,
      if (currentPeriodEnd != null) 'current_period_end': currentPeriodEnd,
      if (autoRenew != null) 'auto_renew': autoRenew,
      if (source != null) 'source': source,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionCacheCompanion copyWith({
    Value<String>? userId,
    Value<String>? tier,
    Value<String>? status,
    Value<DateTime?>? currentPeriodEnd,
    Value<bool>? autoRenew,
    Value<String>? source,
    Value<DateTime>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return SubscriptionCacheCompanion(
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      autoRenew: autoRenew ?? this.autoRenew,
      source: source ?? this.source,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (tier.present) {
      map['tier'] = Variable<String>(tier.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (currentPeriodEnd.present) {
      map['current_period_end'] = Variable<DateTime>(currentPeriodEnd.value);
    }
    if (autoRenew.present) {
      map['auto_renew'] = Variable<bool>(autoRenew.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionCacheCompanion(')
          ..write('userId: $userId, ')
          ..write('tier: $tier, ')
          ..write('status: $status, ')
          ..write('currentPeriodEnd: $currentPeriodEnd, ')
          ..write('autoRenew: $autoRenew, ')
          ..write('source: $source, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlashcardSchedulesTable extends FlashcardSchedules
    with TableInfo<$FlashcardSchedulesTable, FlashcardScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flashcardIdMeta = const VerificationMeta('flashcardId');
  @override
  late final GeneratedColumn<String> flashcardId = GeneratedColumn<String>(
    'flashcard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stageMeta = const VerificationMeta('stage');
  @override
  late final GeneratedColumn<String> stage = GeneratedColumn<String>(
    'stage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta('lastReviewedAt');
  @override
  late final GeneratedColumn<DateTime> lastReviewedAt = GeneratedColumn<DateTime>(
    'last_reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timesReviewedMeta = const VerificationMeta('timesReviewed');
  @override
  late final GeneratedColumn<int> timesReviewed = GeneratedColumn<int>(
    'times_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _timesLapsedMeta = const VerificationMeta('timesLapsed');
  @override
  late final GeneratedColumn<int> timesLapsed = GeneratedColumn<int>(
    'times_lapsed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    flashcardId,
    topicId,
    stage,
    dueDate,
    lastReviewedAt,
    timesReviewed,
    timesLapsed,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcard_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlashcardScheduleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('flashcard_id')) {
      context.handle(
        _flashcardIdMeta,
        flashcardId.isAcceptableOrUnknown(data['flashcard_id']!, _flashcardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_flashcardIdMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta, topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('stage')) {
      context.handle(_stageMeta, stage.isAcceptableOrUnknown(data['stage']!, _stageMeta));
    } else if (isInserting) {
      context.missing(_stageMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta, dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(data['last_reviewed_at']!, _lastReviewedAtMeta),
      );
    }
    if (data.containsKey('times_reviewed')) {
      context.handle(
        _timesReviewedMeta,
        timesReviewed.isAcceptableOrUnknown(data['times_reviewed']!, _timesReviewedMeta),
      );
    }
    if (data.containsKey('times_lapsed')) {
      context.handle(
        _timesLapsedMeta,
        timesLapsed.isAcceptableOrUnknown(data['times_lapsed']!, _timesLapsedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlashcardScheduleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashcardScheduleRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      flashcardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flashcard_id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
      stage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stage'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      timesReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_reviewed'],
      )!,
      timesLapsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_lapsed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FlashcardSchedulesTable createAlias(String alias) {
    return $FlashcardSchedulesTable(attachedDatabase, alias);
  }
}

class FlashcardScheduleRow extends DataClass implements Insertable<FlashcardScheduleRow> {
  /// `'<userId>_<flashcardId>'` — composite identity as a single text
  /// primary key, since Drift's `primaryKey` set doesn't compose cleanly
  /// with the per-user scoping queries this table needs (watch/count by
  /// `userId` alone, look up by `userId` + `flashcardId` together).
  final String id;
  final String userId;
  final String flashcardId;
  final String topicId;

  /// `newCard | day7 | day30 | day90 | mastered` — see `RepetitionStage`.
  final String stage;
  final DateTime dueDate;
  final DateTime? lastReviewedAt;
  final int timesReviewed;
  final int timesLapsed;
  final DateTime createdAt;
  const FlashcardScheduleRow({
    required this.id,
    required this.userId,
    required this.flashcardId,
    required this.topicId,
    required this.stage,
    required this.dueDate,
    this.lastReviewedAt,
    required this.timesReviewed,
    required this.timesLapsed,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['flashcard_id'] = Variable<String>(flashcardId);
    map['topic_id'] = Variable<String>(topicId);
    map['stage'] = Variable<String>(stage);
    map['due_date'] = Variable<DateTime>(dueDate);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt);
    }
    map['times_reviewed'] = Variable<int>(timesReviewed);
    map['times_lapsed'] = Variable<int>(timesLapsed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FlashcardSchedulesCompanion toCompanion(bool nullToAbsent) {
    return FlashcardSchedulesCompanion(
      id: Value(id),
      userId: Value(userId),
      flashcardId: Value(flashcardId),
      topicId: Value(topicId),
      stage: Value(stage),
      dueDate: Value(dueDate),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      timesReviewed: Value(timesReviewed),
      timesLapsed: Value(timesLapsed),
      createdAt: Value(createdAt),
    );
  }

  factory FlashcardScheduleRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashcardScheduleRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      flashcardId: serializer.fromJson<String>(json['flashcardId']),
      topicId: serializer.fromJson<String>(json['topicId']),
      stage: serializer.fromJson<String>(json['stage']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      lastReviewedAt: serializer.fromJson<DateTime?>(json['lastReviewedAt']),
      timesReviewed: serializer.fromJson<int>(json['timesReviewed']),
      timesLapsed: serializer.fromJson<int>(json['timesLapsed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'flashcardId': serializer.toJson<String>(flashcardId),
      'topicId': serializer.toJson<String>(topicId),
      'stage': serializer.toJson<String>(stage),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'lastReviewedAt': serializer.toJson<DateTime?>(lastReviewedAt),
      'timesReviewed': serializer.toJson<int>(timesReviewed),
      'timesLapsed': serializer.toJson<int>(timesLapsed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FlashcardScheduleRow copyWith({
    String? id,
    String? userId,
    String? flashcardId,
    String? topicId,
    String? stage,
    DateTime? dueDate,
    Value<DateTime?> lastReviewedAt = const Value.absent(),
    int? timesReviewed,
    int? timesLapsed,
    DateTime? createdAt,
  }) => FlashcardScheduleRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    flashcardId: flashcardId ?? this.flashcardId,
    topicId: topicId ?? this.topicId,
    stage: stage ?? this.stage,
    dueDate: dueDate ?? this.dueDate,
    lastReviewedAt: lastReviewedAt.present ? lastReviewedAt.value : this.lastReviewedAt,
    timesReviewed: timesReviewed ?? this.timesReviewed,
    timesLapsed: timesLapsed ?? this.timesLapsed,
    createdAt: createdAt ?? this.createdAt,
  );
  FlashcardScheduleRow copyWithCompanion(FlashcardSchedulesCompanion data) {
    return FlashcardScheduleRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      flashcardId: data.flashcardId.present ? data.flashcardId.value : this.flashcardId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      stage: data.stage.present ? data.stage.value : this.stage,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      lastReviewedAt: data.lastReviewedAt.present ? data.lastReviewedAt.value : this.lastReviewedAt,
      timesReviewed: data.timesReviewed.present ? data.timesReviewed.value : this.timesReviewed,
      timesLapsed: data.timesLapsed.present ? data.timesLapsed.value : this.timesLapsed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardScheduleRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('topicId: $topicId, ')
          ..write('stage: $stage, ')
          ..write('dueDate: $dueDate, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('timesReviewed: $timesReviewed, ')
          ..write('timesLapsed: $timesLapsed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    flashcardId,
    topicId,
    stage,
    dueDate,
    lastReviewedAt,
    timesReviewed,
    timesLapsed,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashcardScheduleRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.flashcardId == this.flashcardId &&
          other.topicId == this.topicId &&
          other.stage == this.stage &&
          other.dueDate == this.dueDate &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.timesReviewed == this.timesReviewed &&
          other.timesLapsed == this.timesLapsed &&
          other.createdAt == this.createdAt);
}

class FlashcardSchedulesCompanion extends UpdateCompanion<FlashcardScheduleRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> flashcardId;
  final Value<String> topicId;
  final Value<String> stage;
  final Value<DateTime> dueDate;
  final Value<DateTime?> lastReviewedAt;
  final Value<int> timesReviewed;
  final Value<int> timesLapsed;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FlashcardSchedulesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.flashcardId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.stage = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.timesReviewed = const Value.absent(),
    this.timesLapsed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardSchedulesCompanion.insert({
    required String id,
    required String userId,
    required String flashcardId,
    required String topicId,
    required String stage,
    required DateTime dueDate,
    this.lastReviewedAt = const Value.absent(),
    this.timesReviewed = const Value.absent(),
    this.timesLapsed = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       flashcardId = Value(flashcardId),
       topicId = Value(topicId),
       stage = Value(stage),
       dueDate = Value(dueDate),
       createdAt = Value(createdAt);
  static Insertable<FlashcardScheduleRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? flashcardId,
    Expression<String>? topicId,
    Expression<String>? stage,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? lastReviewedAt,
    Expression<int>? timesReviewed,
    Expression<int>? timesLapsed,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (flashcardId != null) 'flashcard_id': flashcardId,
      if (topicId != null) 'topic_id': topicId,
      if (stage != null) 'stage': stage,
      if (dueDate != null) 'due_date': dueDate,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (timesReviewed != null) 'times_reviewed': timesReviewed,
      if (timesLapsed != null) 'times_lapsed': timesLapsed,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardSchedulesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? flashcardId,
    Value<String>? topicId,
    Value<String>? stage,
    Value<DateTime>? dueDate,
    Value<DateTime?>? lastReviewedAt,
    Value<int>? timesReviewed,
    Value<int>? timesLapsed,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FlashcardSchedulesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      flashcardId: flashcardId ?? this.flashcardId,
      topicId: topicId ?? this.topicId,
      stage: stage ?? this.stage,
      dueDate: dueDate ?? this.dueDate,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      timesLapsed: timesLapsed ?? this.timesLapsed,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (flashcardId.present) {
      map['flashcard_id'] = Variable<String>(flashcardId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (stage.present) {
      map['stage'] = Variable<String>(stage.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<DateTime>(lastReviewedAt.value);
    }
    if (timesReviewed.present) {
      map['times_reviewed'] = Variable<int>(timesReviewed.value);
    }
    if (timesLapsed.present) {
      map['times_lapsed'] = Variable<int>(timesLapsed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('topicId: $topicId, ')
          ..write('stage: $stage, ')
          ..write('dueDate: $dueDate, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('timesReviewed: $timesReviewed, ')
          ..write('timesLapsed: $timesLapsed, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteFoldersTable extends NoteFolders with TableInfo<$NoteFoldersTable, NoteFolderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userId, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteFolderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteFolderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteFolderRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NoteFoldersTable createAlias(String alias) {
    return $NoteFoldersTable(attachedDatabase, alias);
  }
}

class NoteFolderRow extends DataClass implements Insertable<NoteFolderRow> {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NoteFolderRow({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NoteFoldersCompanion toCompanion(bool nullToAbsent) {
    return NoteFoldersCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteFolderRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteFolderRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NoteFolderRow copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NoteFolderRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NoteFolderRow copyWithCompanion(NoteFoldersCompanion data) {
    return NoteFolderRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteFolderRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteFolderRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NoteFoldersCompanion extends UpdateCompanion<NoteFolderRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NoteFoldersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteFoldersCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NoteFolderRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteFoldersCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return NoteFoldersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteFoldersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta('folderId');
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMarkdownMeta = const VerificationMeta('bodyMarkdown');
  @override
  late final GeneratedColumn<String> bodyMarkdown = GeneratedColumn<String>(
    'body_markdown',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _imagesJsonMeta = const VerificationMeta('imagesJson');
  @override
  late final GeneratedColumn<String> imagesJson = GeneratedColumn<String>(
    'images_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isBookmarkedMeta = const VerificationMeta('isBookmarked');
  @override
  late final GeneratedColumn<bool> isBookmarked = GeneratedColumn<bool>(
    'is_bookmarked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_bookmarked" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    folderId,
    title,
    bodyMarkdown,
    imagesJson,
    isBookmarked,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<NoteRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('body_markdown')) {
      context.handle(
        _bodyMarkdownMeta,
        bodyMarkdown.isAcceptableOrUnknown(data['body_markdown']!, _bodyMarkdownMeta),
      );
    }
    if (data.containsKey('images_json')) {
      context.handle(
        _imagesJsonMeta,
        imagesJson.isAcceptableOrUnknown(data['images_json']!, _imagesJsonMeta),
      );
    }
    if (data.containsKey('is_bookmarked')) {
      context.handle(
        _isBookmarkedMeta,
        isBookmarked.isAcceptableOrUnknown(data['is_bookmarked']!, _isBookmarkedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      bodyMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_markdown'],
      )!,
      imagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}images_json'],
      )!,
      isBookmarked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bookmarked'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String userId;
  final String? folderId;
  final String title;
  final String bodyMarkdown;
  final String imagesJson;
  final bool isBookmarked;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NoteRow({
    required this.id,
    required this.userId,
    this.folderId,
    required this.title,
    required this.bodyMarkdown,
    required this.imagesJson,
    required this.isBookmarked,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<String>(folderId);
    }
    map['title'] = Variable<String>(title);
    map['body_markdown'] = Variable<String>(bodyMarkdown);
    map['images_json'] = Variable<String>(imagesJson);
    map['is_bookmarked'] = Variable<bool>(isBookmarked);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      userId: Value(userId),
      folderId: folderId == null && nullToAbsent ? const Value.absent() : Value(folderId),
      title: Value(title),
      bodyMarkdown: Value(bodyMarkdown),
      imagesJson: Value(imagesJson),
      isBookmarked: Value(isBookmarked),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      folderId: serializer.fromJson<String?>(json['folderId']),
      title: serializer.fromJson<String>(json['title']),
      bodyMarkdown: serializer.fromJson<String>(json['bodyMarkdown']),
      imagesJson: serializer.fromJson<String>(json['imagesJson']),
      isBookmarked: serializer.fromJson<bool>(json['isBookmarked']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'folderId': serializer.toJson<String?>(folderId),
      'title': serializer.toJson<String>(title),
      'bodyMarkdown': serializer.toJson<String>(bodyMarkdown),
      'imagesJson': serializer.toJson<String>(imagesJson),
      'isBookmarked': serializer.toJson<bool>(isBookmarked),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NoteRow copyWith({
    String? id,
    String? userId,
    Value<String?> folderId = const Value.absent(),
    String? title,
    String? bodyMarkdown,
    String? imagesJson,
    bool? isBookmarked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NoteRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    folderId: folderId.present ? folderId.value : this.folderId,
    title: title ?? this.title,
    bodyMarkdown: bodyMarkdown ?? this.bodyMarkdown,
    imagesJson: imagesJson ?? this.imagesJson,
    isBookmarked: isBookmarked ?? this.isBookmarked,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NoteRow copyWithCompanion(NotesCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      title: data.title.present ? data.title.value : this.title,
      bodyMarkdown: data.bodyMarkdown.present ? data.bodyMarkdown.value : this.bodyMarkdown,
      imagesJson: data.imagesJson.present ? data.imagesJson.value : this.imagesJson,
      isBookmarked: data.isBookmarked.present ? data.isBookmarked.value : this.isBookmarked,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('folderId: $folderId, ')
          ..write('title: $title, ')
          ..write('bodyMarkdown: $bodyMarkdown, ')
          ..write('imagesJson: $imagesJson, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    folderId,
    title,
    bodyMarkdown,
    imagesJson,
    isBookmarked,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.folderId == this.folderId &&
          other.title == this.title &&
          other.bodyMarkdown == this.bodyMarkdown &&
          other.imagesJson == this.imagesJson &&
          other.isBookmarked == this.isBookmarked &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> folderId;
  final Value<String> title;
  final Value<String> bodyMarkdown;
  final Value<String> imagesJson;
  final Value<bool> isBookmarked;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.folderId = const Value.absent(),
    this.title = const Value.absent(),
    this.bodyMarkdown = const Value.absent(),
    this.imagesJson = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String userId,
    this.folderId = const Value.absent(),
    this.title = const Value.absent(),
    this.bodyMarkdown = const Value.absent(),
    this.imagesJson = const Value.absent(),
    this.isBookmarked = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? folderId,
    Expression<String>? title,
    Expression<String>? bodyMarkdown,
    Expression<String>? imagesJson,
    Expression<bool>? isBookmarked,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (folderId != null) 'folder_id': folderId,
      if (title != null) 'title': title,
      if (bodyMarkdown != null) 'body_markdown': bodyMarkdown,
      if (imagesJson != null) 'images_json': imagesJson,
      if (isBookmarked != null) 'is_bookmarked': isBookmarked,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? folderId,
    Value<String>? title,
    Value<String>? bodyMarkdown,
    Value<String>? imagesJson,
    Value<bool>? isBookmarked,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      folderId: folderId ?? this.folderId,
      title: title ?? this.title,
      bodyMarkdown: bodyMarkdown ?? this.bodyMarkdown,
      imagesJson: imagesJson ?? this.imagesJson,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (bodyMarkdown.present) {
      map['body_markdown'] = Variable<String>(bodyMarkdown.value);
    }
    if (imagesJson.present) {
      map['images_json'] = Variable<String>(imagesJson.value);
    }
    if (isBookmarked.present) {
      map['is_bookmarked'] = Variable<bool>(isBookmarked.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('folderId: $folderId, ')
          ..write('title: $title, ')
          ..write('bodyMarkdown: $bodyMarkdown, ')
          ..write('imagesJson: $imagesJson, ')
          ..write('isBookmarked: $isBookmarked, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $ChallengeProgressTable challengeProgress = $ChallengeProgressTable(this);
  late final $ReminderPreferenceTable reminderPreference = $ReminderPreferenceTable(this);
  late final $NotificationLogTable notificationLog = $NotificationLogTable(this);
  late final $AiCacheLocalTable aiCacheLocal = $AiCacheLocalTable(this);
  late final $TeachingSessionsTable teachingSessions = $TeachingSessionsTable(this);
  late final $SubscriptionCacheTable subscriptionCache = $SubscriptionCacheTable(this);
  late final $FlashcardSchedulesTable flashcardSchedules = $FlashcardSchedulesTable(this);
  late final $NoteFoldersTable noteFolders = $NoteFoldersTable(this);
  late final $NotesTable notes = $NotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    outbox,
    syncState,
    challengeProgress,
    reminderPreference,
    notificationLog,
    aiCacheLocal,
    teachingSessions,
    subscriptionCache,
    flashcardSchedules,
    noteFolders,
    notes,
  ];
}

typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      required String id,
      required String userId,
      required String entityType,
      required String entityId,
      required String operation,
      required String payloadJson,
      required DateTime createdAt,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
      Value<int> retryCount,
      Value<DateTime?> lastAttemptAt,
      Value<String> status,
      Value<int> rowid,
    });

class $$OutboxTableFilterComposer extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAt =>
      $composableBuilder(column: $table.lastAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$OutboxTableOrderingComposer extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$OutboxTableAnnotationComposer extends Composer<_$AppDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount =>
      $composableBuilder(column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt =>
      $composableBuilder(column: $table.lastAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxTable,
          OutboxData,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
          OutboxData,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$AppDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion(
                id: id,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String entityType,
                required String entityId,
                required String operation,
                required String payloadJson,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion.insert(
                id: id,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payloadJson: payloadJson,
                createdAt: createdAt,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxTable,
      OutboxData,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$AppDatabase, $OutboxTable, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String userId,
      required String entityType,
      Value<DateTime?> lastPulledAt,
      Value<DateTime?> lastPushedAt,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> userId,
      Value<String> entityType,
      Value<DateTime?> lastPulledAt,
      Value<DateTime?> lastPushedAt,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPulledAt =>
      $composableBuilder(column: $table.lastPulledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPushedAt =>
      $composableBuilder(column: $table.lastPushedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncStateTableOrderingComposer extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPulledAt =>
      $composableBuilder(column: $table.lastPulledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPushedAt =>
      $composableBuilder(column: $table.lastPushedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncStateTableAnnotationComposer extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityType =>
      $composableBuilder(column: $table.entityType, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPulledAt =>
      $composableBuilder(column: $table.lastPulledAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPushedAt =>
      $composableBuilder(column: $table.lastPushedAt, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (SyncStateData, BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<DateTime?> lastPulledAt = const Value.absent(),
                Value<DateTime?> lastPushedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                userId: userId,
                entityType: entityType,
                lastPulledAt: lastPulledAt,
                lastPushedAt: lastPushedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String entityType,
                Value<DateTime?> lastPulledAt = const Value.absent(),
                Value<DateTime?> lastPushedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                userId: userId,
                entityType: entityType,
                lastPulledAt: lastPulledAt,
                lastPushedAt: lastPushedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (SyncStateData, BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$ChallengeProgressTableCreateCompanionBuilder =
    ChallengeProgressCompanion Function({
      required String userId,
      required DateTime startedAt,
      Value<DateTime?> lastActionDate,
      Value<String> completedDaysJson,
      Value<String> skippedDaysJson,
      Value<String> bookmarkedDaysJson,
      Value<int> rowid,
    });
typedef $$ChallengeProgressTableUpdateCompanionBuilder =
    ChallengeProgressCompanion Function({
      Value<String> userId,
      Value<DateTime> startedAt,
      Value<DateTime?> lastActionDate,
      Value<String> completedDaysJson,
      Value<String> skippedDaysJson,
      Value<String> bookmarkedDaysJson,
      Value<int> rowid,
    });

class $$ChallengeProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ChallengeProgressTable> {
  $$ChallengeProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastActionDate =>
      $composableBuilder(column: $table.lastActionDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completedDaysJson => $composableBuilder(
    column: $table.completedDaysJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skippedDaysJson => $composableBuilder(
    column: $table.skippedDaysJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookmarkedDaysJson => $composableBuilder(
    column: $table.bookmarkedDaysJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChallengeProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ChallengeProgressTable> {
  $$ChallengeProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastActionDate => $composableBuilder(
    column: $table.lastActionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedDaysJson => $composableBuilder(
    column: $table.completedDaysJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skippedDaysJson => $composableBuilder(
    column: $table.skippedDaysJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookmarkedDaysJson => $composableBuilder(
    column: $table.bookmarkedDaysJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChallengeProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChallengeProgressTable> {
  $$ChallengeProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActionDate =>
      $composableBuilder(column: $table.lastActionDate, builder: (column) => column);

  GeneratedColumn<String> get completedDaysJson =>
      $composableBuilder(column: $table.completedDaysJson, builder: (column) => column);

  GeneratedColumn<String> get skippedDaysJson =>
      $composableBuilder(column: $table.skippedDaysJson, builder: (column) => column);

  GeneratedColumn<String> get bookmarkedDaysJson =>
      $composableBuilder(column: $table.bookmarkedDaysJson, builder: (column) => column);
}

class $$ChallengeProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChallengeProgressTable,
          ChallengeProgressData,
          $$ChallengeProgressTableFilterComposer,
          $$ChallengeProgressTableOrderingComposer,
          $$ChallengeProgressTableAnnotationComposer,
          $$ChallengeProgressTableCreateCompanionBuilder,
          $$ChallengeProgressTableUpdateCompanionBuilder,
          (
            ChallengeProgressData,
            BaseReferences<_$AppDatabase, $ChallengeProgressTable, ChallengeProgressData>,
          ),
          ChallengeProgressData,
          PrefetchHooks Function()
        > {
  $$ChallengeProgressTableTableManager(_$AppDatabase db, $ChallengeProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChallengeProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChallengeProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChallengeProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> lastActionDate = const Value.absent(),
                Value<String> completedDaysJson = const Value.absent(),
                Value<String> skippedDaysJson = const Value.absent(),
                Value<String> bookmarkedDaysJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChallengeProgressCompanion(
                userId: userId,
                startedAt: startedAt,
                lastActionDate: lastActionDate,
                completedDaysJson: completedDaysJson,
                skippedDaysJson: skippedDaysJson,
                bookmarkedDaysJson: bookmarkedDaysJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required DateTime startedAt,
                Value<DateTime?> lastActionDate = const Value.absent(),
                Value<String> completedDaysJson = const Value.absent(),
                Value<String> skippedDaysJson = const Value.absent(),
                Value<String> bookmarkedDaysJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChallengeProgressCompanion.insert(
                userId: userId,
                startedAt: startedAt,
                lastActionDate: lastActionDate,
                completedDaysJson: completedDaysJson,
                skippedDaysJson: skippedDaysJson,
                bookmarkedDaysJson: bookmarkedDaysJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChallengeProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChallengeProgressTable,
      ChallengeProgressData,
      $$ChallengeProgressTableFilterComposer,
      $$ChallengeProgressTableOrderingComposer,
      $$ChallengeProgressTableAnnotationComposer,
      $$ChallengeProgressTableCreateCompanionBuilder,
      $$ChallengeProgressTableUpdateCompanionBuilder,
      (
        ChallengeProgressData,
        BaseReferences<_$AppDatabase, $ChallengeProgressTable, ChallengeProgressData>,
      ),
      ChallengeProgressData,
      PrefetchHooks Function()
    >;
typedef $$ReminderPreferenceTableCreateCompanionBuilder =
    ReminderPreferenceCompanion Function({
      required String userId,
      Value<bool> enabled,
      Value<int> hour,
      Value<int> minute,
      Value<String?> timezoneId,
      Value<DateTime?> lastNotifiedDate,
      Value<int> rowid,
    });
typedef $$ReminderPreferenceTableUpdateCompanionBuilder =
    ReminderPreferenceCompanion Function({
      Value<String> userId,
      Value<bool> enabled,
      Value<int> hour,
      Value<int> minute,
      Value<String?> timezoneId,
      Value<DateTime?> lastNotifiedDate,
      Value<int> rowid,
    });

class $$ReminderPreferenceTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderPreferenceTable> {
  $$ReminderPreferenceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezoneId =>
      $composableBuilder(column: $table.timezoneId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastNotifiedDate => $composableBuilder(
    column: $table.lastNotifiedDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderPreferenceTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderPreferenceTable> {
  $$ReminderPreferenceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezoneId =>
      $composableBuilder(column: $table.timezoneId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastNotifiedDate => $composableBuilder(
    column: $table.lastNotifiedDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderPreferenceTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderPreferenceTable> {
  $$ReminderPreferenceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<String> get timezoneId =>
      $composableBuilder(column: $table.timezoneId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastNotifiedDate =>
      $composableBuilder(column: $table.lastNotifiedDate, builder: (column) => column);
}

class $$ReminderPreferenceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderPreferenceTable,
          ReminderPreferenceData,
          $$ReminderPreferenceTableFilterComposer,
          $$ReminderPreferenceTableOrderingComposer,
          $$ReminderPreferenceTableAnnotationComposer,
          $$ReminderPreferenceTableCreateCompanionBuilder,
          $$ReminderPreferenceTableUpdateCompanionBuilder,
          (
            ReminderPreferenceData,
            BaseReferences<_$AppDatabase, $ReminderPreferenceTable, ReminderPreferenceData>,
          ),
          ReminderPreferenceData,
          PrefetchHooks Function()
        > {
  $$ReminderPreferenceTableTableManager(_$AppDatabase db, $ReminderPreferenceTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderPreferenceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderPreferenceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderPreferenceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<String?> timezoneId = const Value.absent(),
                Value<DateTime?> lastNotifiedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderPreferenceCompanion(
                userId: userId,
                enabled: enabled,
                hour: hour,
                minute: minute,
                timezoneId: timezoneId,
                lastNotifiedDate: lastNotifiedDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<bool> enabled = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> minute = const Value.absent(),
                Value<String?> timezoneId = const Value.absent(),
                Value<DateTime?> lastNotifiedDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderPreferenceCompanion.insert(
                userId: userId,
                enabled: enabled,
                hour: hour,
                minute: minute,
                timezoneId: timezoneId,
                lastNotifiedDate: lastNotifiedDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderPreferenceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderPreferenceTable,
      ReminderPreferenceData,
      $$ReminderPreferenceTableFilterComposer,
      $$ReminderPreferenceTableOrderingComposer,
      $$ReminderPreferenceTableAnnotationComposer,
      $$ReminderPreferenceTableCreateCompanionBuilder,
      $$ReminderPreferenceTableUpdateCompanionBuilder,
      (
        ReminderPreferenceData,
        BaseReferences<_$AppDatabase, $ReminderPreferenceTable, ReminderPreferenceData>,
      ),
      ReminderPreferenceData,
      PrefetchHooks Function()
    >;
typedef $$NotificationLogTableCreateCompanionBuilder =
    NotificationLogCompanion Function({
      required String id,
      required String userId,
      required String type,
      required String title,
      required String body,
      Value<String> payloadJson,
      Value<String?> deepLink,
      required DateTime receivedAt,
      Value<DateTime?> readAt,
      Value<int> rowid,
    });
typedef $$NotificationLogTableUpdateCompanionBuilder =
    NotificationLogCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> type,
      Value<String> title,
      Value<String> body,
      Value<String> payloadJson,
      Value<String?> deepLink,
      Value<DateTime> receivedAt,
      Value<DateTime?> readAt,
      Value<int> rowid,
    });

class $$NotificationLogTableFilterComposer extends Composer<_$AppDatabase, $NotificationLogTable> {
  $$NotificationLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deepLink =>
      $composableBuilder(column: $table.deepLink, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get receivedAt =>
      $composableBuilder(column: $table.receivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => ColumnFilters(column));
}

class $$NotificationLogTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationLogTable> {
  $$NotificationLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deepLink =>
      $composableBuilder(column: $table.deepLink, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get receivedAt =>
      $composableBuilder(column: $table.receivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => ColumnOrderings(column));
}

class $$NotificationLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationLogTable> {
  $$NotificationLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get deepLink =>
      $composableBuilder(column: $table.deepLink, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt =>
      $composableBuilder(column: $table.receivedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);
}

class $$NotificationLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationLogTable,
          NotificationLogData,
          $$NotificationLogTableFilterComposer,
          $$NotificationLogTableOrderingComposer,
          $$NotificationLogTableAnnotationComposer,
          $$NotificationLogTableCreateCompanionBuilder,
          $$NotificationLogTableUpdateCompanionBuilder,
          (
            NotificationLogData,
            BaseReferences<_$AppDatabase, $NotificationLogTable, NotificationLogData>,
          ),
          NotificationLogData,
          PrefetchHooks Function()
        > {
  $$NotificationLogTableTableManager(_$AppDatabase db, $NotificationLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotificationLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String?> deepLink = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationLogCompanion(
                id: id,
                userId: userId,
                type: type,
                title: title,
                body: body,
                payloadJson: payloadJson,
                deepLink: deepLink,
                receivedAt: receivedAt,
                readAt: readAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String type,
                required String title,
                required String body,
                Value<String> payloadJson = const Value.absent(),
                Value<String?> deepLink = const Value.absent(),
                required DateTime receivedAt,
                Value<DateTime?> readAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationLogCompanion.insert(
                id: id,
                userId: userId,
                type: type,
                title: title,
                body: body,
                payloadJson: payloadJson,
                deepLink: deepLink,
                receivedAt: receivedAt,
                readAt: readAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationLogTable,
      NotificationLogData,
      $$NotificationLogTableFilterComposer,
      $$NotificationLogTableOrderingComposer,
      $$NotificationLogTableAnnotationComposer,
      $$NotificationLogTableCreateCompanionBuilder,
      $$NotificationLogTableUpdateCompanionBuilder,
      (
        NotificationLogData,
        BaseReferences<_$AppDatabase, $NotificationLogTable, NotificationLogData>,
      ),
      NotificationLogData,
      PrefetchHooks Function()
    >;
typedef $$AiCacheLocalTableCreateCompanionBuilder =
    AiCacheLocalCompanion Function({
      required String cacheKey,
      required String itemType,
      required String itemId,
      required String content,
      required DateTime fetchedAt,
      required DateTime expiresAt,
      Value<int> rowid,
    });
typedef $$AiCacheLocalTableUpdateCompanionBuilder =
    AiCacheLocalCompanion Function({
      Value<String> cacheKey,
      Value<String> itemType,
      Value<String> itemId,
      Value<String> content,
      Value<DateTime> fetchedAt,
      Value<DateTime> expiresAt,
      Value<int> rowid,
    });

class $$AiCacheLocalTableFilterComposer extends Composer<_$AppDatabase, $AiCacheLocalTable> {
  $$AiCacheLocalTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => ColumnFilters(column));
}

class $$AiCacheLocalTableOrderingComposer extends Composer<_$AppDatabase, $AiCacheLocalTable> {
  $$AiCacheLocalTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => ColumnOrderings(column));
}

class $$AiCacheLocalTableAnnotationComposer extends Composer<_$AppDatabase, $AiCacheLocalTable> {
  $$AiCacheLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$AiCacheLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiCacheLocalTable,
          AiCacheLocalData,
          $$AiCacheLocalTableFilterComposer,
          $$AiCacheLocalTableOrderingComposer,
          $$AiCacheLocalTableAnnotationComposer,
          $$AiCacheLocalTableCreateCompanionBuilder,
          $$AiCacheLocalTableUpdateCompanionBuilder,
          (AiCacheLocalData, BaseReferences<_$AppDatabase, $AiCacheLocalTable, AiCacheLocalData>),
          AiCacheLocalData,
          PrefetchHooks Function()
        > {
  $$AiCacheLocalTableTableManager(_$AppDatabase db, $AiCacheLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AiCacheLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AiCacheLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiCacheLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiCacheLocalCompanion(
                cacheKey: cacheKey,
                itemType: itemType,
                itemId: itemId,
                content: content,
                fetchedAt: fetchedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String itemType,
                required String itemId,
                required String content,
                required DateTime fetchedAt,
                required DateTime expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => AiCacheLocalCompanion.insert(
                cacheKey: cacheKey,
                itemType: itemType,
                itemId: itemId,
                content: content,
                fetchedAt: fetchedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiCacheLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiCacheLocalTable,
      AiCacheLocalData,
      $$AiCacheLocalTableFilterComposer,
      $$AiCacheLocalTableOrderingComposer,
      $$AiCacheLocalTableAnnotationComposer,
      $$AiCacheLocalTableCreateCompanionBuilder,
      $$AiCacheLocalTableUpdateCompanionBuilder,
      (AiCacheLocalData, BaseReferences<_$AppDatabase, $AiCacheLocalTable, AiCacheLocalData>),
      AiCacheLocalData,
      PrefetchHooks Function()
    >;
typedef $$TeachingSessionsTableCreateCompanionBuilder =
    TeachingSessionsCompanion Function({
      required String id,
      required String userId,
      required String topicId,
      required String topicTitle,
      required String mode,
      required String explanationText,
      required int accuracyScore,
      required int clinicalReasoningScore,
      required int completenessScore,
      required int confidenceScore,
      Value<String> missingConceptsJson,
      Value<String> hallucinationsJson,
      required String feedback,
      required int masteryScore,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$TeachingSessionsTableUpdateCompanionBuilder =
    TeachingSessionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> topicId,
      Value<String> topicTitle,
      Value<String> mode,
      Value<String> explanationText,
      Value<int> accuracyScore,
      Value<int> clinicalReasoningScore,
      Value<int> completenessScore,
      Value<int> confidenceScore,
      Value<String> missingConceptsJson,
      Value<String> hallucinationsJson,
      Value<String> feedback,
      Value<int> masteryScore,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

class $$TeachingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $TeachingSessionsTable> {
  $$TeachingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicTitle =>
      $composableBuilder(column: $table.topicTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanationText => $composableBuilder(
    column: $table.explanationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accuracyScore =>
      $composableBuilder(column: $table.accuracyScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clinicalReasoningScore => $composableBuilder(
    column: $table.clinicalReasoningScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completenessScore => $composableBuilder(
    column: $table.completenessScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get missingConceptsJson => $composableBuilder(
    column: $table.missingConceptsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hallucinationsJson => $composableBuilder(
    column: $table.hallucinationsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get masteryScore =>
      $composableBuilder(column: $table.masteryScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$TeachingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TeachingSessionsTable> {
  $$TeachingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicTitle =>
      $composableBuilder(column: $table.topicTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanationText => $composableBuilder(
    column: $table.explanationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accuracyScore => $composableBuilder(
    column: $table.accuracyScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clinicalReasoningScore => $composableBuilder(
    column: $table.clinicalReasoningScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completenessScore => $composableBuilder(
    column: $table.completenessScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get confidenceScore => $composableBuilder(
    column: $table.confidenceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get missingConceptsJson => $composableBuilder(
    column: $table.missingConceptsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hallucinationsJson => $composableBuilder(
    column: $table.hallucinationsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get masteryScore =>
      $composableBuilder(column: $table.masteryScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$TeachingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeachingSessionsTable> {
  $$TeachingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get topicTitle =>
      $composableBuilder(column: $table.topicTitle, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get explanationText =>
      $composableBuilder(column: $table.explanationText, builder: (column) => column);

  GeneratedColumn<int> get accuracyScore =>
      $composableBuilder(column: $table.accuracyScore, builder: (column) => column);

  GeneratedColumn<int> get clinicalReasoningScore =>
      $composableBuilder(column: $table.clinicalReasoningScore, builder: (column) => column);

  GeneratedColumn<int> get completenessScore =>
      $composableBuilder(column: $table.completenessScore, builder: (column) => column);

  GeneratedColumn<int> get confidenceScore =>
      $composableBuilder(column: $table.confidenceScore, builder: (column) => column);

  GeneratedColumn<String> get missingConceptsJson =>
      $composableBuilder(column: $table.missingConceptsJson, builder: (column) => column);

  GeneratedColumn<String> get hallucinationsJson =>
      $composableBuilder(column: $table.hallucinationsJson, builder: (column) => column);

  GeneratedColumn<String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);

  GeneratedColumn<int> get masteryScore =>
      $composableBuilder(column: $table.masteryScore, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => column);
}

class $$TeachingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeachingSessionsTable,
          TeachingSessionRow,
          $$TeachingSessionsTableFilterComposer,
          $$TeachingSessionsTableOrderingComposer,
          $$TeachingSessionsTableAnnotationComposer,
          $$TeachingSessionsTableCreateCompanionBuilder,
          $$TeachingSessionsTableUpdateCompanionBuilder,
          (
            TeachingSessionRow,
            BaseReferences<_$AppDatabase, $TeachingSessionsTable, TeachingSessionRow>,
          ),
          TeachingSessionRow,
          PrefetchHooks Function()
        > {
  $$TeachingSessionsTableTableManager(_$AppDatabase db, $TeachingSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeachingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeachingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeachingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<String> topicTitle = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> explanationText = const Value.absent(),
                Value<int> accuracyScore = const Value.absent(),
                Value<int> clinicalReasoningScore = const Value.absent(),
                Value<int> completenessScore = const Value.absent(),
                Value<int> confidenceScore = const Value.absent(),
                Value<String> missingConceptsJson = const Value.absent(),
                Value<String> hallucinationsJson = const Value.absent(),
                Value<String> feedback = const Value.absent(),
                Value<int> masteryScore = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeachingSessionsCompanion(
                id: id,
                userId: userId,
                topicId: topicId,
                topicTitle: topicTitle,
                mode: mode,
                explanationText: explanationText,
                accuracyScore: accuracyScore,
                clinicalReasoningScore: clinicalReasoningScore,
                completenessScore: completenessScore,
                confidenceScore: confidenceScore,
                missingConceptsJson: missingConceptsJson,
                hallucinationsJson: hallucinationsJson,
                feedback: feedback,
                masteryScore: masteryScore,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String topicId,
                required String topicTitle,
                required String mode,
                required String explanationText,
                required int accuracyScore,
                required int clinicalReasoningScore,
                required int completenessScore,
                required int confidenceScore,
                Value<String> missingConceptsJson = const Value.absent(),
                Value<String> hallucinationsJson = const Value.absent(),
                required String feedback,
                required int masteryScore,
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => TeachingSessionsCompanion.insert(
                id: id,
                userId: userId,
                topicId: topicId,
                topicTitle: topicTitle,
                mode: mode,
                explanationText: explanationText,
                accuracyScore: accuracyScore,
                clinicalReasoningScore: clinicalReasoningScore,
                completenessScore: completenessScore,
                confidenceScore: confidenceScore,
                missingConceptsJson: missingConceptsJson,
                hallucinationsJson: hallucinationsJson,
                feedback: feedback,
                masteryScore: masteryScore,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeachingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeachingSessionsTable,
      TeachingSessionRow,
      $$TeachingSessionsTableFilterComposer,
      $$TeachingSessionsTableOrderingComposer,
      $$TeachingSessionsTableAnnotationComposer,
      $$TeachingSessionsTableCreateCompanionBuilder,
      $$TeachingSessionsTableUpdateCompanionBuilder,
      (
        TeachingSessionRow,
        BaseReferences<_$AppDatabase, $TeachingSessionsTable, TeachingSessionRow>,
      ),
      TeachingSessionRow,
      PrefetchHooks Function()
    >;
typedef $$SubscriptionCacheTableCreateCompanionBuilder =
    SubscriptionCacheCompanion Function({
      required String userId,
      required String tier,
      required String status,
      Value<DateTime?> currentPeriodEnd,
      Value<bool> autoRenew,
      required String source,
      required DateTime lastSyncedAt,
      Value<int> rowid,
    });
typedef $$SubscriptionCacheTableUpdateCompanionBuilder =
    SubscriptionCacheCompanion Function({
      Value<String> userId,
      Value<String> tier,
      Value<String> status,
      Value<DateTime?> currentPeriodEnd,
      Value<bool> autoRenew,
      Value<String> source,
      Value<DateTime> lastSyncedAt,
      Value<int> rowid,
    });

class $$SubscriptionCacheTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionCacheTable> {
  $$SubscriptionCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get currentPeriodEnd => $composableBuilder(
    column: $table.currentPeriodEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoRenew =>
      $composableBuilder(column: $table.autoRenew, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt =>
      $composableBuilder(column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));
}

class $$SubscriptionCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionCacheTable> {
  $$SubscriptionCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get currentPeriodEnd => $composableBuilder(
    column: $table.currentPeriodEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoRenew =>
      $composableBuilder(column: $table.autoRenew, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt =>
      $composableBuilder(column: $table.lastSyncedAt, builder: (column) => ColumnOrderings(column));
}

class $$SubscriptionCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionCacheTable> {
  $$SubscriptionCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get currentPeriodEnd =>
      $composableBuilder(column: $table.currentPeriodEnd, builder: (column) => column);

  GeneratedColumn<bool> get autoRenew =>
      $composableBuilder(column: $table.autoRenew, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt =>
      $composableBuilder(column: $table.lastSyncedAt, builder: (column) => column);
}

class $$SubscriptionCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionCacheTable,
          SubscriptionCacheData,
          $$SubscriptionCacheTableFilterComposer,
          $$SubscriptionCacheTableOrderingComposer,
          $$SubscriptionCacheTableAnnotationComposer,
          $$SubscriptionCacheTableCreateCompanionBuilder,
          $$SubscriptionCacheTableUpdateCompanionBuilder,
          (
            SubscriptionCacheData,
            BaseReferences<_$AppDatabase, $SubscriptionCacheTable, SubscriptionCacheData>,
          ),
          SubscriptionCacheData,
          PrefetchHooks Function()
        > {
  $$SubscriptionCacheTableTableManager(_$AppDatabase db, $SubscriptionCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> tier = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> currentPeriodEnd = const Value.absent(),
                Value<bool> autoRenew = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionCacheCompanion(
                userId: userId,
                tier: tier,
                status: status,
                currentPeriodEnd: currentPeriodEnd,
                autoRenew: autoRenew,
                source: source,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String tier,
                required String status,
                Value<DateTime?> currentPeriodEnd = const Value.absent(),
                Value<bool> autoRenew = const Value.absent(),
                required String source,
                required DateTime lastSyncedAt,
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionCacheCompanion.insert(
                userId: userId,
                tier: tier,
                status: status,
                currentPeriodEnd: currentPeriodEnd,
                autoRenew: autoRenew,
                source: source,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubscriptionCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionCacheTable,
      SubscriptionCacheData,
      $$SubscriptionCacheTableFilterComposer,
      $$SubscriptionCacheTableOrderingComposer,
      $$SubscriptionCacheTableAnnotationComposer,
      $$SubscriptionCacheTableCreateCompanionBuilder,
      $$SubscriptionCacheTableUpdateCompanionBuilder,
      (
        SubscriptionCacheData,
        BaseReferences<_$AppDatabase, $SubscriptionCacheTable, SubscriptionCacheData>,
      ),
      SubscriptionCacheData,
      PrefetchHooks Function()
    >;
typedef $$FlashcardSchedulesTableCreateCompanionBuilder =
    FlashcardSchedulesCompanion Function({
      required String id,
      required String userId,
      required String flashcardId,
      required String topicId,
      required String stage,
      required DateTime dueDate,
      Value<DateTime?> lastReviewedAt,
      Value<int> timesReviewed,
      Value<int> timesLapsed,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FlashcardSchedulesTableUpdateCompanionBuilder =
    FlashcardSchedulesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> flashcardId,
      Value<String> topicId,
      Value<String> stage,
      Value<DateTime> dueDate,
      Value<DateTime?> lastReviewedAt,
      Value<int> timesReviewed,
      Value<int> timesLapsed,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FlashcardSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardSchedulesTable> {
  $$FlashcardSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get flashcardId =>
      $composableBuilder(column: $table.flashcardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReviewedAt =>
      $composableBuilder(column: $table.lastReviewedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timesReviewed =>
      $composableBuilder(column: $table.timesReviewed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timesLapsed =>
      $composableBuilder(column: $table.timesLapsed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FlashcardSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardSchedulesTable> {
  $$FlashcardSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get flashcardId =>
      $composableBuilder(column: $table.flashcardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesReviewed => $composableBuilder(
    column: $table.timesReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesLapsed =>
      $composableBuilder(column: $table.timesLapsed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FlashcardSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardSchedulesTable> {
  $$FlashcardSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get flashcardId =>
      $composableBuilder(column: $table.flashcardId, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get stage =>
      $composableBuilder(column: $table.stage, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewedAt =>
      $composableBuilder(column: $table.lastReviewedAt, builder: (column) => column);

  GeneratedColumn<int> get timesReviewed =>
      $composableBuilder(column: $table.timesReviewed, builder: (column) => column);

  GeneratedColumn<int> get timesLapsed =>
      $composableBuilder(column: $table.timesLapsed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FlashcardSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlashcardSchedulesTable,
          FlashcardScheduleRow,
          $$FlashcardSchedulesTableFilterComposer,
          $$FlashcardSchedulesTableOrderingComposer,
          $$FlashcardSchedulesTableAnnotationComposer,
          $$FlashcardSchedulesTableCreateCompanionBuilder,
          $$FlashcardSchedulesTableUpdateCompanionBuilder,
          (
            FlashcardScheduleRow,
            BaseReferences<_$AppDatabase, $FlashcardSchedulesTable, FlashcardScheduleRow>,
          ),
          FlashcardScheduleRow,
          PrefetchHooks Function()
        > {
  $$FlashcardSchedulesTableTableManager(_$AppDatabase db, $FlashcardSchedulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardSchedulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardSchedulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> flashcardId = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<String> stage = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> timesReviewed = const Value.absent(),
                Value<int> timesLapsed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardSchedulesCompanion(
                id: id,
                userId: userId,
                flashcardId: flashcardId,
                topicId: topicId,
                stage: stage,
                dueDate: dueDate,
                lastReviewedAt: lastReviewedAt,
                timesReviewed: timesReviewed,
                timesLapsed: timesLapsed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String flashcardId,
                required String topicId,
                required String stage,
                required DateTime dueDate,
                Value<DateTime?> lastReviewedAt = const Value.absent(),
                Value<int> timesReviewed = const Value.absent(),
                Value<int> timesLapsed = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FlashcardSchedulesCompanion.insert(
                id: id,
                userId: userId,
                flashcardId: flashcardId,
                topicId: topicId,
                stage: stage,
                dueDate: dueDate,
                lastReviewedAt: lastReviewedAt,
                timesReviewed: timesReviewed,
                timesLapsed: timesLapsed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlashcardSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlashcardSchedulesTable,
      FlashcardScheduleRow,
      $$FlashcardSchedulesTableFilterComposer,
      $$FlashcardSchedulesTableOrderingComposer,
      $$FlashcardSchedulesTableAnnotationComposer,
      $$FlashcardSchedulesTableCreateCompanionBuilder,
      $$FlashcardSchedulesTableUpdateCompanionBuilder,
      (
        FlashcardScheduleRow,
        BaseReferences<_$AppDatabase, $FlashcardSchedulesTable, FlashcardScheduleRow>,
      ),
      FlashcardScheduleRow,
      PrefetchHooks Function()
    >;
typedef $$NoteFoldersTableCreateCompanionBuilder =
    NoteFoldersCompanion Function({
      required String id,
      required String userId,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$NoteFoldersTableUpdateCompanionBuilder =
    NoteFoldersCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$NoteFoldersTableFilterComposer extends Composer<_$AppDatabase, $NoteFoldersTable> {
  $$NoteFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$NoteFoldersTableOrderingComposer extends Composer<_$AppDatabase, $NoteFoldersTable> {
  $$NoteFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$NoteFoldersTableAnnotationComposer extends Composer<_$AppDatabase, $NoteFoldersTable> {
  $$NoteFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NoteFoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteFoldersTable,
          NoteFolderRow,
          $$NoteFoldersTableFilterComposer,
          $$NoteFoldersTableOrderingComposer,
          $$NoteFoldersTableAnnotationComposer,
          $$NoteFoldersTableCreateCompanionBuilder,
          $$NoteFoldersTableUpdateCompanionBuilder,
          (NoteFolderRow, BaseReferences<_$AppDatabase, $NoteFoldersTable, NoteFolderRow>),
          NoteFolderRow,
          PrefetchHooks Function()
        > {
  $$NoteFoldersTableTableManager(_$AppDatabase db, $NoteFoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$NoteFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$NoteFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteFoldersCompanion(
                id: id,
                userId: userId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => NoteFoldersCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteFoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteFoldersTable,
      NoteFolderRow,
      $$NoteFoldersTableFilterComposer,
      $$NoteFoldersTableOrderingComposer,
      $$NoteFoldersTableAnnotationComposer,
      $$NoteFoldersTableCreateCompanionBuilder,
      $$NoteFoldersTableUpdateCompanionBuilder,
      (NoteFolderRow, BaseReferences<_$AppDatabase, $NoteFoldersTable, NoteFolderRow>),
      NoteFolderRow,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      required String id,
      required String userId,
      Value<String?> folderId,
      Value<String> title,
      Value<String> bodyMarkdown,
      Value<String> imagesJson,
      Value<bool> isBookmarked,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> folderId,
      Value<String> title,
      Value<String> bodyMarkdown,
      Value<String> imagesJson,
      Value<bool> isBookmarked,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bodyMarkdown =>
      $composableBuilder(column: $table.bodyMarkdown, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagesJson =>
      $composableBuilder(column: $table.imagesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBookmarked =>
      $composableBuilder(column: $table.isBookmarked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$NotesTableOrderingComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodyMarkdown =>
      $composableBuilder(column: $table.bodyMarkdown, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagesJson =>
      $composableBuilder(column: $table.imagesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBookmarked =>
      $composableBuilder(column: $table.isBookmarked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$NotesTableAnnotationComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get bodyMarkdown =>
      $composableBuilder(column: $table.bodyMarkdown, builder: (column) => column);

  GeneratedColumn<String> get imagesJson =>
      $composableBuilder(column: $table.imagesJson, builder: (column) => column);

  GeneratedColumn<bool> get isBookmarked =>
      $composableBuilder(column: $table.isBookmarked, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          NoteRow,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (NoteRow, BaseReferences<_$AppDatabase, $NotesTable, NoteRow>),
          NoteRow,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> folderId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> bodyMarkdown = const Value.absent(),
                Value<String> imagesJson = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                userId: userId,
                folderId: folderId,
                title: title,
                bodyMarkdown: bodyMarkdown,
                imagesJson: imagesJson,
                isBookmarked: isBookmarked,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> folderId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> bodyMarkdown = const Value.absent(),
                Value<String> imagesJson = const Value.absent(),
                Value<bool> isBookmarked = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                userId: userId,
                folderId: folderId,
                title: title,
                bodyMarkdown: bodyMarkdown,
                imagesJson: imagesJson,
                isBookmarked: isBookmarked,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      NoteRow,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (NoteRow, BaseReferences<_$AppDatabase, $NotesTable, NoteRow>),
      NoteRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OutboxTableTableManager get outbox => $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncStateTableTableManager get syncState => $$SyncStateTableTableManager(_db, _db.syncState);
  $$ChallengeProgressTableTableManager get challengeProgress =>
      $$ChallengeProgressTableTableManager(_db, _db.challengeProgress);
  $$ReminderPreferenceTableTableManager get reminderPreference =>
      $$ReminderPreferenceTableTableManager(_db, _db.reminderPreference);
  $$NotificationLogTableTableManager get notificationLog =>
      $$NotificationLogTableTableManager(_db, _db.notificationLog);
  $$AiCacheLocalTableTableManager get aiCacheLocal =>
      $$AiCacheLocalTableTableManager(_db, _db.aiCacheLocal);
  $$TeachingSessionsTableTableManager get teachingSessions =>
      $$TeachingSessionsTableTableManager(_db, _db.teachingSessions);
  $$SubscriptionCacheTableTableManager get subscriptionCache =>
      $$SubscriptionCacheTableTableManager(_db, _db.subscriptionCache);
  $$FlashcardSchedulesTableTableManager get flashcardSchedules =>
      $$FlashcardSchedulesTableTableManager(_db, _db.flashcardSchedules);
  $$NoteFoldersTableTableManager get noteFolders =>
      $$NoteFoldersTableTableManager(_db, _db.noteFolders);
  $$NotesTableTableManager get notes => $$NotesTableTableManager(_db, _db.notes);
}
