import 'package:core_sim_ia/features/users/domain/entities/user_entity.dart';
import 'package:core_sim_ia/features/users/presentation/controllers/users_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: SafeArea(
        child: usersState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _UsersErrorView(
            message: usersErrorMessage(error),
            onRetry: () => ref.read(usersControllerProvider.notifier).retry(),
          ),
          data: (users) => _UsersListView(users: users),
        ),
      ),
    );
  }
}

class _UsersListView extends StatelessWidget {
  const _UsersListView({required this.users});

  final List<UserEntity> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = users[index];

        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(user.name.characters.first)),
            title: Text(user.name),
            subtitle: Text(user.email),
          ),
        );
      },
    );
  }
}

class _UsersErrorView extends StatelessWidget {
  const _UsersErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
