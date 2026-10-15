import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../core/extensions/build_context_extensions.dart';
import '../../../core/widgets/zing_card.dart';
import '../../../core/widgets/zing_empty_state.dart';
import '../../../core/widgets/zing_filter_chip.dart';
import '../../../core/widgets/zing_segmented.dart';
import '../../../core/widgets/zing_text_field.dart';
import '../../materials/domain/study_material.dart';
import '../../materials/presentation/material_type_style.dart';
import 'library_cubit.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LibraryCubit>();
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            final items = state.visible;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Library',
                              style: context.text.headlineLarge,
                            ),
                          ),
                          ZingSegmented<bool>(
                            options: const {true: 'Grid', false: 'List'},
                            value: state.grid,
                            onChanged: cubit.setGrid,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ZingTextField(
                        label: 'Search',
                        hint: 'Search materials',
                        onChanged: cubit.search,
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          spacing: 8,
                          children: [
                            for (final f in LibraryFilter.values)
                              ZingFilterChip(
                                label: f.label,
                                selected: state.filter == f,
                                onTap: () => cubit.setFilter(f),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: SingleChildScrollView(
                            child: ZingEmptyState(
                              title: 'No results',
                              message:
                                  'Nothing matches your search or filters. Try another term or add new material.',
                              actionLabel: 'Add material',
                              onAction: () => context.push('/add-material'),
                            ),
                          ),
                        )
                      : state.grid
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                mainAxisExtent: 168,
                              ),
                          itemCount: items.length,
                          itemBuilder: (_, i) => _GridCard(material: items[i]),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _ListCard(material: items[i]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.material});
  final StudyMaterial material;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = MaterialTypeStyle.of(material.type, c);
    return Container(
      decoration: BoxDecoration(
        boxShadow: AppShadows.level1(c.shadow),
        borderRadius: AppRadius.cardAll,
      ),
      child: ZingCard(
        padding: const EdgeInsets.all(14),
        onTap: () => context.push('/material/${material.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 64,
              width: double.infinity,
              decoration: BoxDecoration(
                color: style.bg,
                borderRadius: AppRadius.smallAll,
              ),
              child: Center(
                child: Text(
                  style.label,
                  style: context.text.labelSmall?.copyWith(
                    color: style.fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              material.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelLarge?.copyWith(height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              material.meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(
                color: c.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.material});
  final StudyMaterial material;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = MaterialTypeStyle.of(material.type, c);
    return ZingCard(
      radius: AppRadius.tileAll,
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/material/${material.id}'),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: AppRadius.smallAll,
            ),
            child: Icon(style.icon, size: 20, color: style.fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.title, style: context.text.labelLarge),
                Text(
                  material.meta,
                  style: context.text.labelSmall?.copyWith(
                    color: c.textSecondary,
                    fontWeight: FontWeight.w400,
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
