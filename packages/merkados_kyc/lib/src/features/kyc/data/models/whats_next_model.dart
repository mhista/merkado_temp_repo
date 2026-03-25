import 'package:flutter/material.dart';

class WhatsNext {
  final String title;
  final String subTitle;
  final IconData icon;

  WhatsNext({required this.title, required this.subTitle, required this.icon});
}

final List<WhatsNext> whatsNext = [
  WhatsNext(
    title: 'Create a Deal',
    subTitle:
        'Set up a new deal, invite participants, define splits and terms — no value cap.',
    icon: Icons.add,
  ),
  WhatsNext(
    title: 'Fund a Deal',
    subTitle:
        'Contribute to existing deals and track your\npayout milestones in real time.',
    icon: Icons.wallet_membership,
  ),
  WhatsNext(
    title: 'Invite Collaborators',
    subTitle:
        'Bring partners, agents, and contributors into your\ndeals with role-based access.',
    icon: Icons.star_half_outlined,
  ),
];
