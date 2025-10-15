import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/models/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(room: room),
            const SizedBox(height: 16),
            Expanded(
              child: _CardContent(room: room),
            ),
            const SizedBox(height: 16),
            _CardFooter(room: room),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final Room room;

  const _CardHeader({required this.room});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room ${room.roomNumber}',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                room.tenantName ?? 'No tenant assigned',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Row(
          children: [
            _StatusBadge(status: room.status),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardContent extends StatelessWidget {
  final Room room;

  const _CardContent({required this.room});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (room.status == RoomStatus.vacant) {
      return const Center(
          child: Text('This room is available for rent.',
              style: TextStyle(color: Colors.grey)));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text('\$${NumberFormat('#,##0').format(room.rentAmount)}',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Flexible(
                child: Text('TZS / month',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
              icon: Icons.calendar_today,
              text: 'Start Date: ${DateFormat.yMMMd().format(room.startDate)}'),
          const SizedBox(height: 8),
          _InfoRow(
              icon: Icons.schedule,
              text:
                  'Next Due: ${DateFormat.yMMMd().format(room.nextDueDate)}'),
          const SizedBox(height: 16),
          _PaymentStatusBadge(status: room.rentStatus),
        ],
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  final Room room;

  const _CardFooter({required this.room});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement manage room functionality
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: const Text('Manage Room'),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final RoomStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case RoomStatus.occupied:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        icon = Icons.check_circle_outline;
        break;
      case RoomStatus.vacant:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        icon = Icons.person_off_outlined;
        break;
      case RoomStatus.pending:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        icon = Icons.article_outlined;
        break;
    }

    return Chip(
      avatar: Icon(icon, color: textColor, size: 16),
      label: Text(status.toString().split('.').last),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.w500),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 16),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  final String status;

  const _PaymentStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case 'Overdue':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        text = 'Overdue by 31 months';
        break;
      case 'Due Today':
        backgroundColor = Colors.grey.shade300;
        textColor = Colors.grey.shade800;
        text = 'Due in 5 days';
        break;
      default:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        text = 'Payment is on track';
    }

    return Chip(
      label: Text(text),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    );
  }
}
