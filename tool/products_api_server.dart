import 'dart:convert';
import 'dart:io';

final _dbFile = File('server/db.json');

Future<Map<String, dynamic>> _readDb() async {
  final raw = await _dbFile.readAsString();
  final parsed = jsonDecode(raw);
  if (parsed is! Map) {
    throw StateError('Invalid server/db.json format');
  }
  final db = Map<String, dynamic>.from(parsed);
  final productsRaw = db['products'];
  if (productsRaw is! List) db['products'] = <dynamic>[];
  final nextIdRaw = db['nextId'];
  if (nextIdRaw is! num) {
    final products = (db['products'] as List).cast<dynamic>();
    var maxId = 0;
    for (final p in products) {
      if (p is Map && p['id'] is num) {
        maxId = maxId < (p['id'] as num).toInt() ? (p['id'] as num).toInt() : maxId;
      }
    }
    db['nextId'] = maxId + 1;
  }
  return db;
}

Future<void> _writeDb(Map<String, dynamic> db) async {
  final raw = '${const JsonEncoder.withIndent('  ').convert(db)}\n';
  await _dbFile.writeAsString(raw);
}

int? _asInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString();
  return int.tryParse(s);
}

double? _asDouble(Object? v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  final s = v.toString();
  return double.tryParse(s);
}


void _setCors(HttpResponse res) {
  res.headers
    ..set('Access-Control-Allow-Origin', '*')
    ..set('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS')
    ..set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
}

Future<Object?> _readJson(HttpRequest req) async {
  final body = await utf8.decoder.bind(req).join();
  if (body.trim().isEmpty) return null;
  return jsonDecode(body);
}

void _sendJson(HttpResponse res, int status, Object? body) {
  _setCors(res);
  res.statusCode = status;
  res.headers.contentType = ContentType.json;
  if (body == null) {
    res.write('null');
  } else {
    res.write(jsonEncode(body));
  }
}

void _sendNoContent(HttpResponse res) {
  _setCors(res);
  res.statusCode = HttpStatus.noContent;
}

Map<String, dynamic>? _validateProduct(Map<String, dynamic> body, {required bool partial}) {
  final errors = <String>[];

  bool has(String k) => body.containsKey(k);

  void reqNonEmptyString(String k) {
    final v = body[k];
    if (v is! String || v.trim().isEmpty) errors.add('$k must be a non-empty string');
  }

  void reqPrice(String k) {
    final n = _asDouble(body[k]);
    if (n == null) {
      errors.add('$k must be a number');
    } else if (n < 0) {
      errors.add('$k must be >= 0');
    }
  }

  if (!partial || has('imageUrl')) reqNonEmptyString('imageUrl');
  if (!partial || has('name')) reqNonEmptyString('name');
  if (!partial || has('type')) reqNonEmptyString('type');
  if (!partial || has('price')) reqPrice('price');

  if (errors.isNotEmpty) {
    return {'error': 'Validation failed', 'details': errors};
  }
  return null;
}

Future<void> main(List<String> args) async {
  final port = int.tryParse(Platform.environment['PORT'] ?? '') ?? 3001;

  if (!await _dbFile.exists()) {
    stderr.writeln('Missing ${_dbFile.path}. Run from repo root.');
    exitCode = 1;
    return;
  }

  // Bind to all interfaces so Android emulators and real devices can reach it.
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  stdout.writeln('Products API running on http://0.0.0.0:$port');

  await for (final req in server) {
    try {
      final path = req.uri.path;
      final method = req.method.toUpperCase();

      if (method == 'OPTIONS') {
        _setCors(req.response);
        req.response.statusCode = HttpStatus.noContent;
        await req.response.close();
        continue;
      }

      // Health
      if (method == 'GET' && path == '/health') {
        _sendJson(req.response, 200, {'ok': true});
        await req.response.close();
        continue;
      }

      // /products and /products/:id
      final segments = req.uri.pathSegments;
      if (segments.isEmpty || segments.first != 'products') {
        _sendJson(req.response, 404, {'error': 'Not found'});
        await req.response.close();
        continue;
      }

      final db = await _readDb();
      final products = (db['products'] as List).cast<dynamic>();

      // GET /products
      if (segments.length == 1 && method == 'GET') {
        final q = (req.uri.queryParameters['q'] ?? '').trim().toLowerCase();
        if (q.isEmpty) {
          _sendJson(req.response, 200, products);
        } else {
          final filtered = products.where((p) {
            if (p is! Map) return false;
            final name = (p['name'] ?? '').toString().toLowerCase();
            final type = (p['type'] ?? '').toString().toLowerCase();
            return ('$name $type').contains(q);
          }).toList();
          _sendJson(req.response, 200, filtered);
        }
        await req.response.close();
        continue;
      }

      // POST /products
      if (segments.length == 1 && method == 'POST') {
        final bodyRaw = await _readJson(req);
        if (bodyRaw is! Map) {
          _sendJson(req.response, 400, {'error': 'Body must be a JSON object'});
          await req.response.close();
          continue;
        }
        final body = Map<String, dynamic>.from(bodyRaw);
        final err = _validateProduct(body, partial: false);
        if (err != null) {
          _sendJson(req.response, 400, err);
          await req.response.close();
          continue;
        }
        final nextId = (db['nextId'] as num).toInt();
        db['nextId'] = nextId + 1;

        final product = <String, Object?>{
          'id': nextId,
          'imageUrl': (body['imageUrl'] as String).trim(),
          'name': (body['name'] as String).trim(),
          'type': (body['type'] as String).trim(),
          'price': _asDouble(body['price']),
        };
        products.add(product);
        await _writeDb(db);
        _sendJson(req.response, 201, product);
        await req.response.close();
        continue;
      }

      if (segments.length == 2) {
        final id = _asInt(segments[1]);
        if (id == null) {
          _sendJson(req.response, 400, {'error': 'Invalid id'});
          await req.response.close();
          continue;
        }

        int idxOfId() {
          for (var i = 0; i < products.length; i++) {
            final p = products[i];
            if (p is Map && _asInt(p['id']) == id) return i;
          }
          return -1;
        }

        final idx = idxOfId();

        // GET /products/:id
        if (method == 'GET') {
          if (idx == -1) {
            _sendJson(req.response, 404, {'error': 'Product not found'});
          } else {
            _sendJson(req.response, 200, products[idx]);
          }
          await req.response.close();
          continue;
        }

        // DELETE /products/:id
        if (method == 'DELETE') {
          if (idx == -1) {
            _sendJson(req.response, 404, {'error': 'Product not found'});
            await req.response.close();
            continue;
          }
          products.removeAt(idx);
          await _writeDb(db);
          _sendNoContent(req.response);
          await req.response.close();
          continue;
        }

        // PUT/PATCH /products/:id
        if (method == 'PUT' || method == 'PATCH') {
          if (idx == -1) {
            _sendJson(req.response, 404, {'error': 'Product not found'});
            await req.response.close();
            continue;
          }

          final bodyRaw = await _readJson(req);
          if (bodyRaw is! Map) {
            _sendJson(req.response, 400, {'error': 'Body must be a JSON object'});
            await req.response.close();
            continue;
          }
          final body = Map<String, dynamic>.from(bodyRaw);
          final err = _validateProduct(body, partial: method == 'PATCH');
          if (err != null) {
            _sendJson(req.response, 400, err);
            await req.response.close();
            continue;
          }

          final current = Map<String, dynamic>.from((products[idx] as Map).cast<String, dynamic>());
          if (method == 'PUT') {
            final updated = <String, Object?>{
              'id': id,
              'imageUrl': (body['imageUrl'] as String).trim(),
              'name': (body['name'] as String).trim(),
              'type': (body['type'] as String).trim(),
              'price': _asDouble(body['price']),
            };
            products[idx] = updated;
            await _writeDb(db);
            _sendJson(req.response, 200, updated);
          } else {
            if (body.containsKey('imageUrl')) current['imageUrl'] = (body['imageUrl'] as String).trim();
            if (body.containsKey('name')) current['name'] = (body['name'] as String).trim();
            if (body.containsKey('type')) current['type'] = (body['type'] as String).trim();
            if (body.containsKey('price')) current['price'] = _asDouble(body['price']);
            products[idx] = current;
            await _writeDb(db);
            _sendJson(req.response, 200, current);
          }
          await req.response.close();
          continue;
        }
      }

      _sendJson(req.response, 404, {'error': 'Not found'});
      await req.response.close();
    } catch (e) {
      _sendJson(req.response, 500, {'error': 'Server error', 'details': e.toString()});
      await req.response.close();
    }
  }
}

