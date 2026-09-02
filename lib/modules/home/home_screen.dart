import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_info/modules/home/widget/city_chips.dart';
import 'package:weather_info/modules/home/widget/error_panel.dart';
import 'package:weather_info/modules/home/widget/search_box.dart';
import 'package:weather_info/modules/home/widget/section_title.dart';
import 'package:weather_info/modules/home/widget/weather_card.dart';
import '../../core/constant/style.dart';
import 'provider/weather_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);
    final notifier = ref.read(weatherProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Weather Atlas', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const Text(
                        'Find your weather',
                        style: AppTextStyles.heroTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Search a city for a clear.',
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 24),
                      SearchBox(
                        controller: _searchController,
                        enabled: !state.isLoading,
                        onSearch: () => notifier.search(_searchController.text),
                      ),
                      if (state.isLoading) ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(minHeight: 3),
                      ],
                      if (state.error) ...[
                        const SizedBox(height: 18),
                        ErrorPanel(
                          message: state.errorMessage ?? 'Search failed.',
                          onRetry: notifier.retry,
                        ),
                      ],
                      if (state.weather != null) ...[
                        const SizedBox(height: 24),
                        WeatherCard(
                          weather: state.weather!,
                          isFavorite: state.favorites.contains(
                            state.weather!.location?.name?.trim(),
                          ),
                          onToggleFavorite: notifier.toggleFavorite,
                        ),
                      ],
                      if (state.favorites.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        const SectionTitle(
                          title: 'Favorites',
                          icon: Icons.star_rounded,
                        ),
                        const SizedBox(height: 10),
                        CityChips(
                          cities: state.favorites,
                          onTap: (city) {
                            _searchController.text = city;
                            notifier.search(city);
                          },
                        ),
                      ],
                      if (state.recentSearches.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        SectionTitle(
                          title: 'Recent searches',
                          icon: Icons.history_rounded,
                          action: TextButton(
                            onPressed: notifier.clearRecentSearches,
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CityChips(
                          cities: state.recentSearches,
                          onTap: (city) {
                            _searchController.text = city;
                            notifier.searchRecent(city);
                          },
                        ),
                      ],
                    ]),
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
