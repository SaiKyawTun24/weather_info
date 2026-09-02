import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/model/weather_response.dart';
import '../weather/weather_provider.dart';

class MyMain extends ConsumerStatefulWidget {
  const MyMain({super.key});

  @override
  ConsumerState<MyMain> createState() => _MyMainState();
}

class _MyMainState extends ConsumerState<MyMain> {
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
        title: const Text(
          'Weather Atlas',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (state.favorites.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: Text(
                  '${state.favorites.length} saved',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
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
                        style: TextStyle(
                          fontSize: 34,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Search a city for a clear, current snapshot.',
                        style: TextStyle(
                          color: Colors.blueGrey.shade700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SearchBox(
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
                        _ErrorPanel(
                          message: state.errorMessage ?? 'Search failed.',
                          onRetry: notifier.retry,
                        ),
                      ],
                      if (state.weather != null) ...[
                        const SizedBox(height: 24),
                        _WeatherCard(
                          weather: state.weather!,
                          isFavorite: state.favorites.contains(
                            state.weather!.location?.name?.trim(),
                          ),
                          onToggleFavorite: notifier.toggleFavorite,
                        ),
                      ],
                      if (state.favorites.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        const _SectionTitle(
                          title: 'Favorites',
                          icon: Icons.star_rounded,
                        ),
                        const SizedBox(height: 10),
                        _CityChips(
                          cities: state.favorites,
                          onTap: (city) {
                            _searchController.text = city;
                            notifier.search(city);
                          },
                        ),
                      ],
                      if (state.recentSearches.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        _SectionTitle(
                          title: 'Recent searches',
                          icon: Icons.history_rounded,
                          action: TextButton(
                            onPressed: notifier.clearRecentSearches,
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _CityChips(
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

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.enabled,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
      decoration: InputDecoration(
        hintText: 'Search city, country or region',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: enabled ? onSearch : null,
          tooltip: 'Search weather',
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({
    required this.weather,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final WeatherResponse weather;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final location = weather.location;
    final current = weather.current;
    final condition = current?.condition;
    final iconUrl = condition?.icon;
    final city = location?.name ?? 'Unknown city';

    return Card(
      elevation: 0,
      color: const Color(0xFF103B46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [location?.region, location?.country]
                            .whereType<String>()
                            .where((part) => part.isNotEmpty)
                            .join(', '),
                        style: TextStyle(color: Colors.blueGrey.shade100),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onToggleFavorite,
                  tooltip: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  color: isFavorite ? const Color(0xFFFFD166) : Colors.white,
                  icon: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                if (iconUrl != null)
                  Image.network(
                    iconUrl.startsWith('//') ? 'https:$iconUrl' : iconUrl,
                    width: 72,
                    height: 72,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.cloud_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                const SizedBox(width: 12),
                Text(
                  '${current?.tempC?.round() ?? '--'}°',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 64,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    condition?.text ?? 'Current conditions unavailable',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _Metric(
                  label: 'Humidity',
                  value: '${current?.humidity ?? '--'}%',
                ),
                _Metric(
                  label: 'Wind speed',
                  value: '${current?.windKph?.toStringAsFixed(1) ?? '--'} km/h',
                ),
                _Metric(
                  label: 'Cloud cover',
                  value: '${current?.cloud ?? '--'}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.blueGrey.shade200)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CityChips extends StatelessWidget {
  const _CityChips({required this.cities, required this.onTap});

  final List<String> cities;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cities
          .map(
            (city) => ActionChip(
              label: Text(city),
              onPressed: () => onTap(city),
              avatar: const Icon(Icons.location_on_outlined, size: 18),
            ),
          )
          .toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon, this.action});

  final String title;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        ..._actions,
      ],
    );
  }

  Iterable<Widget> get _actions {
    return action == null ? const <Widget>[] : <Widget>[action!];
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFFB42318)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF7A271A)),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
