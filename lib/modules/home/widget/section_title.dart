import 'package:flutter/material.dart';
import 'package:weather_info/core/constant/style.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.action,
  });

  final String title;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.sectionTitle),
        const Spacer(),
        ..._actions,
      ],
    );
  }

  Iterable<Widget> get _actions {
    return action == null ? const <Widget>[] : <Widget>[action!];
  }
}
