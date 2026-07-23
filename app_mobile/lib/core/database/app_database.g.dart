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

  /// `quiz_attempt | flashcard_grade | bookmark | settings | achievement_seen`
  final String entityType;
  final String entityId;

  /// `create | update`
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
  List<GeneratedColumn> get $columns => [entityType, lastPulledAt, lastPushedAt];
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
  Set<GeneratedColumn> get $primaryKey => {entityType};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
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
  /// e.g. `topics`, `flashcards`, `mcqs`, `progress`.
  final String entityType;
  final DateTime? lastPulledAt;
  final DateTime? lastPushedAt;
  const SyncStateData({required this.entityType, this.lastPulledAt, this.lastPushedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
      entityType: serializer.fromJson<String>(json['entityType']),
      lastPulledAt: serializer.fromJson<DateTime?>(json['lastPulledAt']),
      lastPushedAt: serializer.fromJson<DateTime?>(json['lastPushedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'lastPulledAt': serializer.toJson<DateTime?>(lastPulledAt),
      'lastPushedAt': serializer.toJson<DateTime?>(lastPushedAt),
    };
  }

  SyncStateData copyWith({
    String? entityType,
    Value<DateTime?> lastPulledAt = const Value.absent(),
    Value<DateTime?> lastPushedAt = const Value.absent(),
  }) => SyncStateData(
    entityType: entityType ?? this.entityType,
    lastPulledAt: lastPulledAt.present ? lastPulledAt.value : this.lastPulledAt,
    lastPushedAt: lastPushedAt.present ? lastPushedAt.value : this.lastPushedAt,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      entityType: data.entityType.present ? data.entityType.value : this.entityType,
      lastPulledAt: data.lastPulledAt.present ? data.lastPulledAt.value : this.lastPulledAt,
      lastPushedAt: data.lastPushedAt.present ? data.lastPushedAt.value : this.lastPushedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('entityType: $entityType, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, lastPulledAt, lastPushedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.entityType == this.entityType &&
          other.lastPulledAt == this.lastPulledAt &&
          other.lastPushedAt == this.lastPushedAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> entityType;
  final Value<DateTime?> lastPulledAt;
  final Value<DateTime?> lastPushedAt;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.entityType = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String entityType,
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType);
  static Insertable<SyncStateData> custom({
    Expression<String>? entityType,
    Expression<DateTime>? lastPulledAt,
    Expression<DateTime>? lastPushedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (lastPushedAt != null) 'last_pushed_at': lastPushedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? entityType,
    Value<DateTime?>? lastPulledAt,
    Value<DateTime?>? lastPushedAt,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      entityType: entityType ?? this.entityType,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      lastPushedAt: lastPushedAt ?? this.lastPushedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta('reminderEnabled');
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("reminder_enabled" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderHourMeta = const VerificationMeta('reminderHour');
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
    'reminder_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(19),
  );
  static const VerificationMeta _reminderMinuteMeta = const VerificationMeta('reminderMinute');
  @override
  late final GeneratedColumn<int> reminderMinute = GeneratedColumn<int>(
    'reminder_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    startedAt,
    lastActionDate,
    completedDaysJson,
    skippedDaysJson,
    bookmarkedDaysJson,
    reminderEnabled,
    reminderHour,
    reminderMinute,
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
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(data['reminder_enabled']!, _reminderEnabledMeta),
      );
    }
    if (data.containsKey('reminder_hour')) {
      context.handle(
        _reminderHourMeta,
        reminderHour.isAcceptableOrUnknown(data['reminder_hour']!, _reminderHourMeta),
      );
    }
    if (data.containsKey('reminder_minute')) {
      context.handle(
        _reminderMinuteMeta,
        reminderMinute.isAcceptableOrUnknown(data['reminder_minute']!, _reminderMinuteMeta),
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
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_hour'],
      )!,
      reminderMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute'],
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

  /// Daily reminder preference — stored alongside progress rather than a
  /// separate prefs mechanism, since it's per-user Challenge Mode state
  /// like everything else in this row.
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  const ChallengeProgressData({
    required this.userId,
    required this.startedAt,
    this.lastActionDate,
    required this.completedDaysJson,
    required this.skippedDaysJson,
    required this.bookmarkedDaysJson,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
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
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    map['reminder_hour'] = Variable<int>(reminderHour);
    map['reminder_minute'] = Variable<int>(reminderMinute);
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
      reminderEnabled: Value(reminderEnabled),
      reminderHour: Value(reminderHour),
      reminderMinute: Value(reminderMinute),
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
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      reminderHour: serializer.fromJson<int>(json['reminderHour']),
      reminderMinute: serializer.fromJson<int>(json['reminderMinute']),
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
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'reminderHour': serializer.toJson<int>(reminderHour),
      'reminderMinute': serializer.toJson<int>(reminderMinute),
    };
  }

  ChallengeProgressData copyWith({
    String? userId,
    DateTime? startedAt,
    Value<DateTime?> lastActionDate = const Value.absent(),
    String? completedDaysJson,
    String? skippedDaysJson,
    String? bookmarkedDaysJson,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) => ChallengeProgressData(
    userId: userId ?? this.userId,
    startedAt: startedAt ?? this.startedAt,
    lastActionDate: lastActionDate.present ? lastActionDate.value : this.lastActionDate,
    completedDaysJson: completedDaysJson ?? this.completedDaysJson,
    skippedDaysJson: skippedDaysJson ?? this.skippedDaysJson,
    bookmarkedDaysJson: bookmarkedDaysJson ?? this.bookmarkedDaysJson,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
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
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderHour: data.reminderHour.present ? data.reminderHour.value : this.reminderHour,
      reminderMinute: data.reminderMinute.present ? data.reminderMinute.value : this.reminderMinute,
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
          ..write('bookmarkedDaysJson: $bookmarkedDaysJson, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute')
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
    reminderEnabled,
    reminderHour,
    reminderMinute,
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
          other.bookmarkedDaysJson == this.bookmarkedDaysJson &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderHour == this.reminderHour &&
          other.reminderMinute == this.reminderMinute);
}

class ChallengeProgressCompanion extends UpdateCompanion<ChallengeProgressData> {
  final Value<String> userId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> lastActionDate;
  final Value<String> completedDaysJson;
  final Value<String> skippedDaysJson;
  final Value<String> bookmarkedDaysJson;
  final Value<bool> reminderEnabled;
  final Value<int> reminderHour;
  final Value<int> reminderMinute;
  final Value<int> rowid;
  const ChallengeProgressCompanion({
    this.userId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastActionDate = const Value.absent(),
    this.completedDaysJson = const Value.absent(),
    this.skippedDaysJson = const Value.absent(),
    this.bookmarkedDaysJson = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChallengeProgressCompanion.insert({
    required String userId,
    required DateTime startedAt,
    this.lastActionDate = const Value.absent(),
    this.completedDaysJson = const Value.absent(),
    this.skippedDaysJson = const Value.absent(),
    this.bookmarkedDaysJson = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
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
    Expression<bool>? reminderEnabled,
    Expression<int>? reminderHour,
    Expression<int>? reminderMinute,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (startedAt != null) 'started_at': startedAt,
      if (lastActionDate != null) 'last_action_date': lastActionDate,
      if (completedDaysJson != null) 'completed_days_json': completedDaysJson,
      if (skippedDaysJson != null) 'skipped_days_json': skippedDaysJson,
      if (bookmarkedDaysJson != null) 'bookmarked_days_json': bookmarkedDaysJson,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
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
    Value<bool>? reminderEnabled,
    Value<int>? reminderHour,
    Value<int>? reminderMinute,
    Value<int>? rowid,
  }) {
    return ChallengeProgressCompanion(
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      lastActionDate: lastActionDate ?? this.lastActionDate,
      completedDaysJson: completedDaysJson ?? this.completedDaysJson,
      skippedDaysJson: skippedDaysJson ?? this.skippedDaysJson,
      bookmarkedDaysJson: bookmarkedDaysJson ?? this.bookmarkedDaysJson,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
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
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    if (reminderMinute.present) {
      map['reminder_minute'] = Variable<int>(reminderMinute.value);
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
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [outbox, syncState, challengeProgress];
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
      required String entityType,
      Value<DateTime?> lastPulledAt,
      Value<DateTime?> lastPushedAt,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
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
                Value<String> entityType = const Value.absent(),
                Value<DateTime?> lastPulledAt = const Value.absent(),
                Value<DateTime?> lastPushedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                entityType: entityType,
                lastPulledAt: lastPulledAt,
                lastPushedAt: lastPushedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                Value<DateTime?> lastPulledAt = const Value.absent(),
                Value<DateTime?> lastPushedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
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
      Value<bool> reminderEnabled,
      Value<int> reminderHour,
      Value<int> reminderMinute,
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
      Value<bool> reminderEnabled,
      Value<int> reminderHour,
      Value<int> reminderMinute,
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

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderHour =>
      $composableBuilder(column: $table.reminderHour, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reminderMinute =>
      $composableBuilder(column: $table.reminderMinute, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderHour =>
      $composableBuilder(column: $table.reminderHour, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
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

  GeneratedColumn<bool> get reminderEnabled =>
      $composableBuilder(column: $table.reminderEnabled, builder: (column) => column);

  GeneratedColumn<int> get reminderHour =>
      $composableBuilder(column: $table.reminderHour, builder: (column) => column);

  GeneratedColumn<int> get reminderMinute =>
      $composableBuilder(column: $table.reminderMinute, builder: (column) => column);
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
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<int> reminderMinute = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChallengeProgressCompanion(
                userId: userId,
                startedAt: startedAt,
                lastActionDate: lastActionDate,
                completedDaysJson: completedDaysJson,
                skippedDaysJson: skippedDaysJson,
                bookmarkedDaysJson: bookmarkedDaysJson,
                reminderEnabled: reminderEnabled,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
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
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<int> reminderMinute = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChallengeProgressCompanion.insert(
                userId: userId,
                startedAt: startedAt,
                lastActionDate: lastActionDate,
                completedDaysJson: completedDaysJson,
                skippedDaysJson: skippedDaysJson,
                bookmarkedDaysJson: bookmarkedDaysJson,
                reminderEnabled: reminderEnabled,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OutboxTableTableManager get outbox => $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncStateTableTableManager get syncState => $$SyncStateTableTableManager(_db, _db.syncState);
  $$ChallengeProgressTableTableManager get challengeProgress =>
      $$ChallengeProgressTableTableManager(_db, _db.challengeProgress);
}
