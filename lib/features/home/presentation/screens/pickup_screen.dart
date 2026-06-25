import 'package:flutter/material.dart';
import '/../../core/models/pickup_model.dart';
import '/../../core/services/bolajonim_api.dart';
import '/../../core/services/selected_child_service.dart';
import '/../../core/theme/app_colors.dart';
import '/../../core/theme/app_text_styles.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final TextEditingController _noteController = TextEditingController();

  PickupPerson? _selectedTodayPerson;
  List<PickupPerson> _pickupPeople = [];
  List<PickupHistoryItem> _history = [];
  bool _isLoading = true;
  String _childName = 'Farzand';
  String _groupName = '-';

  @override
  void initState() {
    super.initState();
    _loadPickup();
  }

  Future<void> _loadPickup() async {
    setState(() => _isLoading = true);

    try {
      final children = await BolajonimApi.getChildren();
      if (children.isEmpty) {
        if (!mounted) return;
        setState(() {
          _pickupPeople = [];
          _history = [];
          _selectedTodayPerson = null;
          _isLoading = false;
        });
        return;
      }

      final childNo = await SelectedChildService.resolveSelection(children);
      final child = children.firstWhere(
        (item) => item.childNo == childNo,
        orElse: () => children.first,
      );

      final pickup = await BolajonimApi.getPickup(childNo: child.childNo);
      final people = pickup.persons.map(_mapPerson).toList();
      final history = pickup.history.map(_mapHistoryItem).toList();

      PickupPerson? selected;
      final todayPlan = pickup.todayPlan;
      if (people.isNotEmpty) {
        if (todayPlan != null) {
          for (final person in people) {
            if (person.name == todayPlan.personName) {
              selected = person;
              break;
            }
          }
        }
        selected ??= people.firstWhere(
          (person) => person.isDefault,
          orElse: () => people.first,
        );
      }
      if (todayPlan != null) {
        _noteController.text = todayPlan.noteText ?? '';
      }

      if (!mounted) return;
      setState(() {
        _childName = child.childName;
        _groupName = child.groupName ?? '-';
        _pickupPeople = people;
        _history = history;
        _selectedTodayPerson = selected;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pickupPeople = [];
        _history = [];
        _selectedTodayPerson = null;
        _isLoading = false;
      });
    }
  }

  PickupPerson _mapPerson(PickupPersonModel model) {
    final style = _iconStyle(model.iconType);
    return PickupPerson(
      id: model.personNo?.toString() ?? model.personName,
      name: model.personName,
      relation: model.relationName,
      phone: model.phoneNo?.isNotEmpty == true ? model.phoneNo! : '-',
      avatarColor: style.$1,
      iconColor: style.$2,
      icon: style.$3,
      isDefault: model.isDefault,
    );
  }

  (Color, Color, IconData) _iconStyle(String? iconType) {
    switch (iconType?.toLowerCase()) {
      case 'father':
        return (
          const Color(0xFFEDF4FF),
          const Color(0xFF4A90E2),
          Icons.man_rounded,
        );
      case 'mother':
        return (
          const Color(0xFFEFF9F6),
          AppColors.primary,
          Icons.woman_rounded,
        );
      default:
        return (
          const Color(0xFFFFF5EA),
          const Color(0xFFFF9F43),
          Icons.person_outline_rounded,
        );
    }
  }

  PickupHistoryItem _mapHistoryItem(PickupPlanModel plan) {
    final date = plan.parsedDate;
    return PickupHistoryItem(
      dateLabel: date == null ? plan.pickupDate : _historyDateLabel(date),
      personName: plan.personName,
      relation: plan.relationName,
      time: plan.plannedTime ?? '-',
      status: plan.status.toLowerCase() == 'completed'
          ? PickupStatus.completed
          : PickupStatus.planned,
    );
  }

  String _historyDateLabel(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final yesterday = todayOnly.subtract(const Duration(days: 1));

    if (today == todayOnly) return 'Bugun';
    if (today == yesterday) return 'Kecha';

    const months = [
      '',
      'yanvar',
      'fevral',
      'mart',
      'aprel',
      'may',
      'iyun',
      'iyul',
      'avgust',
      'sentabr',
      'oktabr',
      'noyabr',
      'dekabr',
    ];

    return '${date.day}-${months[date.month]}';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _selectTodayPerson(PickupPerson person) {
    if (_selectedTodayPerson?.id == person.id) return;

    setState(() {
      _selectedTodayPerson = person;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bugungi olib ketish: ${person.name}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _PickupHeaderCard(
                    childName: _childName,
                    groupName: _groupName,
                  ),
                  const SizedBox(height: 12),
                  if (_selectedTodayPerson != null) ...[
                    _TodayPickupCard(person: _selectedTodayPerson!),
                    const SizedBox(height: 12),
                  ],
                  const _TeacherSafetyNoteCard(
                    note:
                        'Farzandni faqat oldindan ko‘rsatilgan va tasdiqlangan shaxs olib ketishi mumkin.',
                  ),
                  const SizedBox(height: 12),
                  _PickupNoteEditorCard(
                    controller: _noteController,
                    onSave: _savePickupInfo,
                  ),
                  const SizedBox(height: 12),
                  if (_pickupPeople.isNotEmpty)
                    _ApprovedPeopleCard(
                      people: _pickupPeople,
                      selectedTodayPerson: _selectedTodayPerson ?? _pickupPeople.first,
                      onSelect: _selectTodayPerson,
                    ),
                  if (_pickupPeople.isNotEmpty) const SizedBox(height: 12),
                  if (_history.isNotEmpty) _PickupHistoryCard(history: _history),
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

  const _TodayPickupCard({required this.person});

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
                    'Tarbiyachi farzandni shu shaxsga topshiradi. Quyidagi ro‘yxatdan o‘zgartirishingiz mumkin.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
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
            height: 48,
            child: OutlinedButton(
              onPressed: onSave,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF4F7FA),
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: Color(0xFFD5DDE6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Saqlash',
                style: TextStyle(fontWeight: FontWeight.w700),
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

  const _ApprovedPeopleCard({
    required this.people,
    required this.selectedTodayPerson,
    required this.onSelect,
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
          const Row(
            children: [
              Icon(Icons.people_alt_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Tasdiqlangan odamlar',
                style: AppTextStyles.titleLarge,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF9F6) : const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primary : const Color(0xFFE8EDF3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
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
