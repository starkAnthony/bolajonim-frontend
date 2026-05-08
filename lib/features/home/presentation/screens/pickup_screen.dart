import 'package:flutter/material.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final TextEditingController _noteController = TextEditingController();

  late PickupPerson _selectedTodayPerson;

  final List<PickupPerson> _pickupPeople = const [
    PickupPerson(
      id: '1',
      name: 'Onasi',
      relation: 'Ona',
      phone: '+82 10-1234-5678',
      avatarColor: Color(0xFFEFF9F6),
      iconColor: AppColors.primary,
      icon: Icons.woman_rounded,
      isDefault: true,
    ),
    PickupPerson(
      id: '2',
      name: 'Otasi',
      relation: 'Ota',
      phone: '+82 10-8765-4321',
      avatarColor: Color(0xFFEDF4FF),
      iconColor: Color(0xFF4A90E2),
      icon: Icons.man_rounded,
    ),
    PickupPerson(
      id: '3',
      name: 'Dilnoza opa',
      relation: 'Xolasi',
      phone: '+82 10-5555-1122',
      avatarColor: Color(0xFFFFF5EA),
      iconColor: Color(0xFFFF9F43),
      icon: Icons.person_outline_rounded,
    ),
  ];

  final List<PickupHistoryItem> _history = const [
    PickupHistoryItem(
      dateLabel: 'Bugun',
      personName: 'Onasi',
      relation: 'Ona',
      time: '17:40',
      status: PickupStatus.planned,
    ),
    PickupHistoryItem(
      dateLabel: 'Kecha',
      personName: 'Otasi',
      relation: 'Ota',
      time: '18:05',
      status: PickupStatus.completed,
    ),
    PickupHistoryItem(
      dateLabel: '18-aprel',
      personName: 'Onasi',
      relation: 'Ona',
      time: '17:32',
      status: PickupStatus.completed,
    ),
    PickupHistoryItem(
      dateLabel: '17-aprel',
      personName: 'Dilnoza opa',
      relation: 'Xolasi',
      time: '17:50',
      status: PickupStatus.completed,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTodayPerson = _pickupPeople.firstWhere((e) => e.isDefault);
    _noteController.text = 'Bugun odatdagidek kechki payt olib ketadi.';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _openPickupSelector() async {
    final PickupPerson? result = await showModalBottomSheet<PickupPerson>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PickupPersonSelectorSheet(
        people: _pickupPeople,
        selectedPerson: _selectedTodayPerson,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedTodayPerson = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bugungi olib ketish: ${result.name}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _savePickupInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Olib ketish ma’lumoti saqlandi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openAddPersonPlaceholder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const _PickupPlaceholderScreen(title: 'Yangi odam qo‘shish'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Olib ketish',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const _PickupHeaderCard(
              childName: 'SALIH (Sali)',
              groupName: 'Kichik guruh',
            ),
            const SizedBox(height: 12),

            _TodayPickupCard(
              person: _selectedTodayPerson,
              onChangeTap: _openPickupSelector,
            ),
            const SizedBox(height: 12),

            _TeacherSafetyNoteCard(
              note:
                  'Farzandni faqat oldindan ko‘rsatilgan va tasdiqlangan shaxs olib ketishi mumkin.',
            ),
            const SizedBox(height: 12),

            _PickupNoteEditorCard(
              controller: _noteController,
              onSave: _savePickupInfo,
            ),
            const SizedBox(height: 12),

            _ApprovedPeopleCard(
              people: _pickupPeople,
              selectedTodayPerson: _selectedTodayPerson,
              onSelect: (person) {
                setState(() {
                  _selectedTodayPerson = person;
                });
              },
              onAddNew: _openAddPersonPlaceholder,
            ),
            const SizedBox(height: 12),

            _PickupHistoryCard(history: _history),
          ],
        ),
      ),
    );
  }
}

class PickupPerson {
  final String id;
  final String name;
  final String relation;
  final String phone;
  final Color avatarColor;
  final Color iconColor;
  final IconData icon;
  final bool isDefault;

  const PickupPerson({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
    required this.avatarColor,
    required this.iconColor,
    required this.icon,
    this.isDefault = false,
  });
}

enum PickupStatus { planned, completed }

class PickupHistoryItem {
  final String dateLabel;
  final String personName;
  final String relation;
  final String time;
  final PickupStatus status;

  const PickupHistoryItem({
    required this.dateLabel,
    required this.personName,
    required this.relation,
    required this.time,
    required this.status,
  });
}

class _PickupHeaderCard extends StatelessWidget {
  final String childName;
  final String groupName;

  const _PickupHeaderCard({required this.childName, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFFFF5EA),
            child: Icon(
              Icons.directions_walk_rounded,
              size: 26,
              color: Color(0xFFFF9F43),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(childName, style: AppTextStyles.titleLarge),
                const SizedBox(height: 4),
                Text(groupName, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayPickupCard extends StatelessWidget {
  final PickupPerson person;
  final VoidCallback onChangeTap;

  const _TodayPickupCard({required this.person, required this.onChangeTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Bugungi olib ketish', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: person.avatarColor,
                child: Icon(person.icon, color: person.iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.name, style: AppTextStyles.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      '${person.relation} • ${person.phone}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF9F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tarbiyachi farzandni shu shaxsga topshiradi.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: onChangeTap,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'O‘zgartirish',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherSafetyNoteCard extends StatelessWidget {
  final String note;

  const _TeacherSafetyNoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF9F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.shield_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Xavfsizlik eslatmasi',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(note, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupNoteEditorCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;

  const _PickupNoteEditorCard({required this.controller, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Izoh qoldirish', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Masalan: Bugun xolasi olib ketadi. 18:00 atrofida keladi.',
              hintStyle: AppTextStyles.bodySmall,
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE8EDF3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFE8EDF3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: onSave,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Saqlash',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovedPeopleCard extends StatelessWidget {
  final List<PickupPerson> people;
  final PickupPerson selectedTodayPerson;
  final ValueChanged<PickupPerson> onSelect;
  final VoidCallback onAddNew;

  const _ApprovedPeopleCard({
    required this.people,
    required this.selectedTodayPerson,
    required this.onSelect,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tasdiqlangan odamlar',
                  style: AppTextStyles.titleLarge,
                ),
              ),
              InkWell(
                onTap: onAddNew,
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF9F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 16, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Qo‘shish',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...people.map(
            (person) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PickupPersonTile(
                person: person,
                isSelected: selectedTodayPerson.id == person.id,
                onTap: () => onSelect(person),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupPersonTile extends StatelessWidget {
  final PickupPerson person;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickupPersonTile({
    required this.person,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF9F6) : const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE8EDF3),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: person.avatarColor,
              child: Icon(person.icon, color: person.iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(person.name, style: AppTextStyles.titleLarge),
                      if (person.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5EA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Asosiy',
                            style: TextStyle(
                              color: Color(0xFFFF9F43),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${person.relation} • ${person.phone}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : const Color(0xFFC8D2DD),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupHistoryCard extends StatelessWidget {
  final List<PickupHistoryItem> history;

  const _PickupHistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Oxirgi olib ketishlar', style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: 14),
          ...history.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PickupHistoryTile(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupHistoryTile extends StatelessWidget {
  final PickupHistoryItem item;

  const _PickupHistoryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isPlanned = item.status == PickupStatus.planned;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isPlanned
                ? const Color(0xFFFFF5EA)
                : const Color(0xFFEFF9F6),
            child: Icon(
              isPlanned
                  ? Icons.schedule_rounded
                  : Icons.check_circle_outline_rounded,
              color: isPlanned ? const Color(0xFFFF9F43) : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.personName} • ${item.relation}',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.dateLabel} • ${item.time}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isPlanned
                  ? const Color(0xFFFFF5EA)
                  : const Color(0xFFEFF9F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isPlanned ? 'Rejada' : 'Olib ketildi',
              style: TextStyle(
                color: isPlanned ? const Color(0xFFFF9F43) : AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupPersonSelectorSheet extends StatelessWidget {
  final List<PickupPerson> people;
  final PickupPerson selectedPerson;

  const _PickupPersonSelectorSheet({
    required this.people,
    required this.selectedPerson,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5DDE6),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kim olib ketadi?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...people.map(
                (person) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BottomSheetPersonTile(
                    person: person,
                    isSelected: selectedPerson.id == person.id,
                    onTap: () {
                      Navigator.pop(context, person);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetPersonTile extends StatelessWidget {
  final PickupPerson person;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomSheetPersonTile({
    required this.person,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE8EDF3),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: person.avatarColor,
              child: Icon(person.icon, color: person.iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person.name, style: AppTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${person.relation} • ${person.phone}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _PickupPlaceholderScreen extends StatelessWidget {
  final String title;

  const _PickupPlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Center(
        child: Text('$title sahifasi', style: AppTextStyles.headlineMedium),
      ),
    );
  }
}
