import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCheckListScreen extends ConsumerStatefulWidget {
  final String? checklistId;
  final ChecklistMode mode;
  final bool showSkip;
  final ChecklistModel? checklist;

  const CreateCheckListScreen({
    super.key,
    this.mode = ChecklistMode.create,
    this.checklistId,
    this.showSkip = false,
    this.checklist,
  });

  @override
  ConsumerState<CreateCheckListScreen> createState() =>
      _CreateCheckListScreenState();
}

class _CreateCheckListScreenState extends ConsumerState<CreateCheckListScreen> {
  final _formkey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();

  DateTime? selectedDate;

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: selectedDate ?? DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  String get formattedDate {
    if (selectedDate == null) {
      return "Select Due Date";
    }

    return "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    nameFocusNode.dispose();
    descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // ---- Guard: edit mode requires checklist data to prefill fields.
    // If it's missing, warn the user instead of silently showing an empty form. ----
    if (widget.mode == ChecklistMode.edit && widget.checklist == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't load checklist details. Please go back and try again."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }

    if (widget.checklist != null) {
      nameController.text = widget.checklist!.title;
      descriptionController.text = widget.checklist!.description;
      selectedDate = widget.checklist!.dueDate;

      // Sync to riverpod controller for later saving — safe here
      // since it's a simple notifier update, not a rebuild-triggering read.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(checklistControllerProvider.notifier)
            .loadChecklist(widget.checklist!);
      });
    }
  }

  void _handleSkip() {
    ref.read(checklistControllerProvider.notifier).clear();
    ref.invalidate(dashboardProvider);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (routes) => false,
    );
  }

  Future<void> _confirmSkip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Skip Checklist Setup?"),
        content: const Text(
          "Any details you've entered will be lost. You can create a checklist anytime from the dashboard.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Skip"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _handleSkip();
    }
  }

  void _handleNext() {
    if (!_formkey.currentState!.validate()) return;

    ref
        .read(checklistControllerProvider.notifier)
        .updateBasicInfo(
          title: nameController.text.trim(),
          description: descriptionController.text.trim(),
          dueDate: selectedDate,
        );

    debugPrint("Checklist updated with ID: ${widget.checklistId}");

    Navigator.pushNamed(
      context,
      AppRoutes.checklistDetails,
      arguments: {
        'mode': widget.mode,
        'checklistId': widget.checklistId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final hintStyle = textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface.withOpacity(0.28),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.mode == ChecklistMode.create
              ? "Create Checklist"
              : "Edit Checklist",
        ),
        actions: widget.showSkip
            ? [
                TextButton(
                  onPressed: _confirmSkip,
                  child: const Text("Skip"),
                ),
              ]
            : null,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.assignment,
                      color: colorScheme.primary,
                      size: 45,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    widget.mode == ChecklistMode.create
                        ? "Let's create a new checklist"
                        : "Edit Checklist",
                    style: textTheme.headlineSmall,
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    widget.mode == ChecklistMode.create
                        ? "Fill in the basic details to get started."
                        : "Update your checklist information.",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: Text(
                    "Step 1 of 4",
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                LinearProgressIndicator(
                  value: 0.25,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(20),
                ),

                const SizedBox(height: 30),

                Text.rich(
                  TextSpan(
                    text: "Checklist Name ",
                    style: textTheme.labelLarge,
                    children: [
                      TextSpan(
                        text: "*",
                        style: textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: nameController,
                  focusNode: nameFocusNode,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.next,
                  maxLength: 26,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  inputFormatters: [LengthLimitingTextInputFormatter(26)],

                  buildCounter:
                      (
                        BuildContext context, {
                        required int currentLength,
                        required bool isFocused,
                        required int? maxLength,
                      }) {
                        return const SizedBox.shrink();
                      },

                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return "Checklist name is required";
                    }
                    if (trimmed.length < 2) {
                      return "Checklist name is too short";
                    }
                    return null;
                  },

                  decoration: InputDecoration(
                    hintText: "Bali Trip",
                    hintStyle: hintStyle,

                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: nameController,
                      builder: (context, value, child) {
                        final length = value.text.length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Center(
                            widthFactor: 1,
                            child: Text(
                              "$length/26",
                              style: TextStyle(
                                color: length == 26
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Text("Description (Optional)", style: textTheme.labelLarge),

                const SizedBox(height: 8),

                TextField(
                  controller: descriptionController,
                  focusNode: descriptionFocusNode,
                  maxLines: 4,
                  maxLength: 200,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: "Checklist for our Bali trip preparation.",
                    hintStyle: hintStyle,
                  ),
                ),

                const SizedBox(height: 22),

                Text("Due Date", style: textTheme.labelLarge),

                const SizedBox(height: 8),

                InkWell(
                  onTap: pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: selectedDate == null
                                ? hintStyle
                                : textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                          ),
                        ),
                        if (selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              setState(() => selectedDate = null);
                            },
                            visualDensity: VisualDensity.compact,
                          )
                        else
                          Icon(
                            Icons.calendar_today_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    child: const Text("Next"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}