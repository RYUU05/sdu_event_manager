#!/bin/bash

BASE="feature/__brick__/{{name.snakeCase()}}"

mkdir -p "$BASE/data/datasources"
mkdir -p "$BASE/data/models"
mkdir -p "$BASE/data/repositories"
mkdir -p "$BASE/domain/entities"
mkdir -p "$BASE/domain/repositories"
mkdir -p "$BASE/domain/usecases"
mkdir -p "$BASE/presentation/bloc"
mkdir -p "$BASE/presentation/pages"
mkdir -p "$BASE/presentation/widgets"

cat > "$BASE/data/datasources/{{name.snakeCase()}}_data_source.dart" << 'EOF'
class {{name.pascalCase()}}DataSource {}
EOF

cat > "$BASE/data/models/{{name.snakeCase()}}_model.dart" << 'EOF'
class {{name.pascalCase()}}Model {}
EOF

cat > "$BASE/data/repositories/{{name.snakeCase()}}_repository_impl.dart" << 'EOF'
class {{name.pascalCase()}}RepositoryImpl {}
EOF

cat > "$BASE/domain/entities/{{name.snakeCase()}}_entity.dart" << 'EOF'
class {{name.pascalCase()}}Entity {}
EOF

cat > "$BASE/domain/repositories/{{name.snakeCase()}}_repository.dart" << 'EOF'
abstract class {{name.pascalCase()}}Repository {}
EOF

cat > "$BASE/domain/usecases/get_{{name.snakeCase()}}.dart" << 'EOF'
class Get{{name.pascalCase()}} {}
EOF

cat > "$BASE/presentation/bloc/{{name.snakeCase()}}_bloc.dart" << 'EOF'
import 'package:flutter_bloc/flutter_bloc.dart';
part '{{name.snakeCase()}}_event.dart';
part '{{name.snakeCase()}}_state.dart';

class {{name.pascalCase()}}Bloc extends Bloc<{{name.pascalCase()}}Event, {{name.pascalCase()}}State> {
  {{name.pascalCase()}}Bloc() : super({{name.pascalCase()}}Initial());
}
EOF

cat > "$BASE/presentation/bloc/{{name.snakeCase()}}_event.dart" << 'EOF'
part of '{{name.snakeCase()}}_bloc.dart';
abstract class {{name.pascalCase()}}Event {}
EOF

cat > "$BASE/presentation/bloc/{{name.snakeCase()}}_state.dart" << 'EOF'
part of '{{name.snakeCase()}}_bloc.dart';
abstract class {{name.pascalCase()}}State {}
class {{name.pascalCase()}}Initial extends {{name.pascalCase()}}State {}
EOF

cat > "$BASE/presentation/pages/{{name.snakeCase()}}_page.dart" << 'EOF'
import 'package:flutter/material.dart';
class {{name.pascalCase()}}Page extends StatelessWidget {
  const {{name.pascalCase()}}Page({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
EOF

echo "✅ Brick создан!"
