import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/src/models/house.dart';

class AddPropertyDialog extends StatefulWidget {
  final Function(House) onSave;
  const AddPropertyDialog({super.key, required this.onSave});

  @override
  State<AddPropertyDialog> createState() => _AddPropertyDialogState();
}

class _AddPropertyDialogState extends State<AddPropertyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _roomsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _roomsController.dispose();
    super.dispose();
  }

  void _saveHouse() {
    if (_formKey.currentState!.validate()) {
      final newHouse = House(
        id: DateTime.now().toString(),
        name: _nameController.text,
        address: _addressController.text,
        totalRooms: int.parse(_roomsController.text),
        imageUrl: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/300',
        location: 'Unknown',
        price: '0',
        occupiedRooms: 0,
        rooms: [],
      );
      widget.onSave(newHouse);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final title = Text(
      'Add New House',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );

    final subtitle = Text(
      'Enter the details for your new rental property. Click save when you\'re done.',
      style: Theme.of(context).textTheme.bodyMedium,
    );

    final form = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('House Name', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'e.g. Sunnyvale Villa',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a house name' : null,
          ),
          const SizedBox(height: 16),
          const Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              hintText: '123 Main St, Anytown, USA',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Please enter an address' : null,
          ),
          const SizedBox(height: 16),
          const Text('Number of Rooms', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _roomsController,
            decoration: const InputDecoration(
              hintText: '1',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the number of rooms';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ),
    );

    final actions = [
      TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
             backgroundColor: Theme.of(context).colorScheme.primary,
             foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        onPressed: _saveHouse,
        child: const Text('Save House'),
      ),
    ];

    if (isMobile) {
      return Material(
        child: Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    title,
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                subtitle,
                const SizedBox(height: 24),
                form,
                const SizedBox(height: 24),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      title: title,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            subtitle,
            const SizedBox(height: 24),
            form,
          ],
        ),
      ),
      actions: actions,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
